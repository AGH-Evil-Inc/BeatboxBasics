﻿using System.Text.Json;
using api.Models;
using Microsoft.AspNetCore.Mvc;
using OnesetDetection;
using NAudio.Wave; // Add for audio conversion
using Concentus.Structs; // Add for OPUS decoding
using Xabe.FFmpeg;

namespace api.Controllers;

[Route("api/[controller]")]
[ApiController]
public class ScoreController : ControllerBase
{
    private const string PatternFileRelative =
        @"..\..\frontend\assets\text\pattern_library.json";

    protected const string ScoresLogFile = @"..\..\frontend\assets\text\scores_log.json";

    [HttpPost]                         // POST /api/score
    public async Task<IActionResult> ScoreBeat([FromForm] ScoreRequest req)
    {
        if (req.AudioPath == null || string.IsNullOrWhiteSpace(req.PatternKey))
            return BadRequest("AudioPath i PatternKey są wymagane.");

        // 1. Save the uploaded file to a temporary location
        string? tempOggPath = null;
        string? tempWavPath = null;
        try
        {
           
            var tempDir = Path.GetTempPath();
            tempOggPath = Path.Combine(tempDir, $"recording_{Guid.NewGuid()}.ogg");
            tempWavPath = Path.Combine(tempDir, $"recording_{Guid.NewGuid()}.wav");
            using (var stream = new FileStream(tempOggPath, FileMode.Create))
            {
                await req.AudioPath.CopyToAsync(stream);
            }

            // 2. Convert .ogg (OPUS) to .wav using FFmpeg
            var conversion = FFmpeg.Conversions.New()
                .AddParameter($"-i {tempOggPath} -ar 44100 {tempWavPath}")
                .SetOverwriteOutput(true);
            await conversion.Start();
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Nie można zapisać lub przekonwertować pliku: {ex.Message}");
        }
        finally
        {
            //// Clean up the temporary .ogg file
            //if (tempOggPath != null && System.IO.File.Exists(tempOggPath))
            //{
            //    System.IO.File.Delete(tempOggPath);
            //}
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
        ScoreResponse result;
        try
        {
            BeatScoreResult beatScoreResult = BeatScorer.ScoreBeat(tempWavPath, bpm, noBars, rhythm);
            result = new ScoreResponse
            {
                BeatAccepted = beatScoreResult.BeatAccepted,
                MSE = beatScoreResult.MSE,
                SE = beatScoreResult.SE,
                Score = beatScoreResult.Score
            };

            var record = new ScoreRecord
            {
                Timestamp = DateTime.UtcNow,
                PatternKey = req.PatternKey,
                BeatAccepted = result.BeatAccepted,
                MSE = result.MSE,
                SE = result.SE,
                Score = result.Score,
                AudioFileName = req?.AudioFileName
            };

            await AppendScoreRecordAsync(record);

        }
        catch (Exception ex)
        {
            System.IO.File.Delete(tempWavPath); // Clean up temp .wav file
            return StatusCode(500, $"Błąd algorytmu: {ex.Message}");
        }
       
        return Ok(result);   // serializuje się automatycznie do JSON
    }

    private async Task AppendScoreRecordAsync(ScoreRecord record)
    {
        var records = new List<ScoreRecord>();
        var filePath = Path.Combine(Directory.GetCurrentDirectory(), ScoresLogFile);

        // Odczytaj istniejące rekordy jeśli plik istnieje
        if (System.IO.File.Exists(filePath))
        {
            var json = await System.IO.File.ReadAllTextAsync(filePath);
            records = JsonSerializer.Deserialize<List<ScoreRecord>>(json) ?? new List<ScoreRecord>();
        }

        // Dodaj nowy rekord
        records.Add(record);

        // Zapisz zaktualizowaną listę
        var options = new JsonSerializerOptions { WriteIndented = true };
        var newJson = JsonSerializer.Serialize(records, options);
        await System.IO.File.WriteAllTextAsync(filePath, newJson);
    }
}