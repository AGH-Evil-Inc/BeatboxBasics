namespace api.Models
{
    public class ScoreRecord
    {
        public DateTime Timestamp { get; set; }
        public string PatternKey { get; set; }
        public bool BeatAccepted { get; set; }
        public float MSE { get; set; }
        public float SE { get; set; }
        public int Score { get; set; }
        public string? AudioFileName { get; set; }
    }
}
