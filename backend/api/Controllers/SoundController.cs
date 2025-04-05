using System.Text.Json;
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
            string relativePath = @"..\..\frontend\assets\text\sound_library.json";
            string jsonFilePath = Path.Combine(Directory.GetCurrentDirectory(), relativePath);
            Dictionary<string, Sound> items;
            try
            {
                string jsonString = System.IO.File.ReadAllText(jsonFilePath);
                var options = new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                };
                items = JsonSerializer.Deserialize<Dictionary<string, Sound>>(jsonString, options);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }

            return Ok(items);
        }
    }
}

