using api.Models;
using Microsoft.AspNetCore.Mvc;

namespace api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class SoundController : ControllerBase
    {
        [HttpGet]
        public IActionResult GetSounds()
        {
            var items = new List<Sound>
            {
                new Sound { Name = "Beat 1", AudioPath = "audio/sounds/example_kicks.wav" },
                new Sound { Name = "Beat 2", AudioPath = "audio/sounds/example_kicks.wav" },
                new Sound { Name = "Beat 3", AudioPath = "audio/sounds/example_kicks.wav" }
            };

            return Ok(items);
        }
    }
}

