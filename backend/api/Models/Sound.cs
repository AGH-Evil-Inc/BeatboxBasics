using System.ComponentModel.DataAnnotations;

namespace api.Models
{
    public class Sound
    {
        public string Name { get; set; }
        public string AudioPath { get; set; }
        public string Notation { get; set; }
        public string Description { get; set; }
        public List<string> Tips { get; set; }
        public List<string> Links { get; set; }
    }
}