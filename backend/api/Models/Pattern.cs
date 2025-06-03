using System.Text.Json.Serialization;

namespace api.Models
{
    public class Pattern
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public int Base_BPM { get; set; }
        public int No_Bars { get; set; }

        [JsonPropertyName("pattern")]
        public List<string> PatternList { get; set; } = new List<string>();

        public List<int> Musical_notes { get; set; } = new List<int>();
        public int Difficulty { get; set; }
        public string AudioPath { get; set; }
        public string Description { get; set; }
    }
}
