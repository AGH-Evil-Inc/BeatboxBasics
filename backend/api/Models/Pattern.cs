namespace api.Models
{
    public class Pattern
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public int Base_BPM { get; set; }
        public int No_Bars { get; set; }
        public List<string> PatternList { get; set; }
        public string AudioPath { get; set; }
        public string Description { get; set; }
    }
}
