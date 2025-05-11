using System.Text.Json;
using api.Models;
using Microsoft.AspNetCore.Mvc;
using OnesetDetection;

namespace api.Controllers;

[Route("api/[controller]")]
[ApiController]
public class ScoreController : ControllerBase
{
    private const string PatternFileRelative =
        @"..\..\frontend\assets\text\pattern_library.json";

    [HttpPost]                         // POST /api/score
    public IActionResult ScoreBeat([FromBody] ScoreRequest req)
    {
        if (string.IsNullOrWhiteSpace(req.AudioPath) ||
            string.IsNullOrWhiteSpace(req.PatternKey))
            return BadRequest("AudioPath i PatternKey są wymagane.");
        // 1. Wczytaj bibliotekę patternów
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
            return StatusCode(500, $"Nie mogę wczytać patternów: {ex.Message}");
        }

        if (patterns is null ||
            !patterns.TryGetValue(req.PatternKey, out var p))
            return NotFound($"Brak patternu o kluczu „{req.PatternKey}”.");

        // 2. Przekonwertuj pattern na parametry dla algorytmu
        int bpm = p.Base_BPM;
        int noBars = p.No_Bars;

        // Algorytm Dawida oczekuje tablicy długości nut (4-ka = ćwierćnuta, 8-ka = ósemka …).
        // Jeśli w JSON-ie nie trzymasz długości, przyjmijmy, że każdy krok to ósemka:
        int[] rhythm = p.Musical_notes.ToArray();

        // 3. Uruchom skoring
        BeatScoreResult result;
        try
        {
            result = BeatScorer.ScoreBeat(req.AudioPath, bpm, noBars, rhythm);
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Błąd algorytmu: {ex.Message}");
        }

        return Ok(result);   // serializuje się automatycznie do JSON
    }
}
