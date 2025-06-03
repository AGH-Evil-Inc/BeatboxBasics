using System.Text.Json;
using api.Models;
using Microsoft.AspNetCore.Mvc;

namespace api.Controllers;

[Route("api/[controller]")]
[ApiController]
public class StatsController : ControllerBase
{
    private const string ScoresLogFile = @"..\..\frontend\assets\text\scores_log.json";

    [HttpGet]
    public IActionResult GetStats()
    {
        var filePath = Path.Combine(Directory.GetCurrentDirectory(), ScoresLogFile);

        if (!System.IO.File.Exists(filePath))
            return Ok(new { message = "Brak danych statystycznych" });

        var json = System.IO.File.ReadAllText(filePath);
        var records = JsonSerializer.Deserialize<List<ScoreRecord>>(json) ?? new List<ScoreRecord>();

        // Proste statystyki
        var stats = new
        {
            TotalAttempts = records.Count,
            AcceptedBeats = records.Count(r => r.BeatAccepted),
            AverageScore = records.Average(r => r.Score),
            AverageMSE = records.Average(r => r.MSE),
            ByPattern = records.GroupBy(r => r.PatternKey)
                            .Select(g => new
                            {
                                Pattern = g.Key,
                                Count = g.Count(),
                                Accepted = g.Count(r => r.BeatAccepted),
                                AvgScore = g.Average(r => r.Score)
                            })
        };

        return Ok(stats);
    }
}