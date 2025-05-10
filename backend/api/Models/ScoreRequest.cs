namespace api.Models;

public class ScoreRequest
{
    public string AudioPath { get; set; }   // np. "C:/Users/me/recording.wav"
    public string PatternKey { get; set; }  // np. "basic_beat"
}
