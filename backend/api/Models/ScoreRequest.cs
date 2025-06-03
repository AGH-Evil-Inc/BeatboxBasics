namespace api.Models;

public class ScoreRequest
{
    public IFormFile AudioPath { get; set; }   // Changed to IFormFile for file upload
    public string PatternKey { get; set; }     // np. "basic_beat"

    public string? AudioFileName { get; set; }
}
