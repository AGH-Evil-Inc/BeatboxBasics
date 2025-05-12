using System.Text.Json;
using api.Models;
using Microsoft.AspNetCore.Mvc;
using OnesetDetection;
using NAudio.Wave; // Add for audio conversion

namespace api.Controllers;

[Route("api/[controller]")]
[ApiController]
public class ScoreController : ControllerBase
{
    private const string PatternFileRelative =
        @"..\..\frontend\assets\text\pattern_library.json";

    [HttpPost]                         // POST /api/score
    public async Task<IActionResult> ScoreBeat([FromForm] ScoreRequest req)
    {
        if (req.AudioPath == null || string.IsNullOrWhiteSpace(req.PatternKey))
            return BadRequest("AudioPath i PatternKey są wymagane.");

        // 1. Save the uploaded file to a temporary location as .m4a
        string? tempM4aPath = null;
        string? tempWavPath = null;
        try
        {
            var tempDir = Path.GetTempPath();
            tempM4aPath = Path.Combine(tempDir, $"recording_{Guid.NewGuid()}.m4a");
            tempWavPath = Path.Combine(tempDir, $"recording_{Guid.NewGuid()}.wav");
            using (var stream = new FileStream(tempM4aPath, FileMode.Create))
            {
                await req.AudioPath.CopyToAsync(stream);
            }

            // 2. Convert .m4a to .wav using NAudio
            using (var reader = new MediaFoundationReader(tempM4aPath))
            using (var writer = new WaveFileWriter(tempWavPath, reader.WaveFormat))
            {
                reader.CopyTo(writer);
            }
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Nie można zapisać lub przekonwertować pliku: {ex.Message}");
        }
        finally
        {
          
            // Clean up the temporary .m4a file
            if (System.IO.File.Exists(tempM4aPath))
            {
                System.IO.File.Delete(tempM4aPath);
            }
        }

        // 3. Wczytaj bibliotekę patternów
        Dictionary<string, Pattern>? patterns;
        try
        {
            var json = System.IO.File.ReadAllText(
                Path.Combine(Directory.GetCurrentDirectory(), PatternFileRelative));
            patterns = JsonSerializer.Deserialize<Dictionary<string, Pattern>>(json,
                       new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
        }
        catch (Exception ex)
        {
            System.IO.File.Delete(tempWavPath); // Clean up temp .wav file
            return StatusCode(500, $"Nie mogę wczytać patternów: {ex.Message}");
        }

        if (patterns is null ||
            !patterns.TryGetValue(req.PatternKey, out var p))
        {
            System.IO.File.Delete(tempWavPath); // Clean up temp .wav file
            return NotFound($"Brak patternu o kluczu „{req.PatternKey}”.");
        }

        // 4. Przekonwertuj pattern na parametry dla algorytmu
        int bpm = p.Base_BPM;
        int noBars = p.No_Bars;
        int[] rhythm = p.Musical_notes.ToArray();

        // 5. Uruchom skoring
        BeatScoreResult result;
        try
        {
            result = BeatScorer.ScoreBeat(tempWavPath, bpm, noBars, rhythm);
        }
        catch (Exception ex)
        {
            System.IO.File.Delete(tempWavPath); // Clean up temp .wav file
            return StatusCode(500, $"Błąd algorytmu: {ex.Message}");
        }
       
        return Ok(result);   // serializuje się automatycznie do JSON
    }
}