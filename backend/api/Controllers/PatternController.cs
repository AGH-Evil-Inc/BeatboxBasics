using System.Text.Json;
using api.Models;
using Microsoft.AspNetCore.Mvc;

namespace api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PatternController : ControllerBase
    {
        [HttpGet]
        public IActionResult GetPatterns()
        {
            string relativePath = @"..\..\frontend\assets\text\pattern_library.json";
            string jsonFilePath = Path.Combine(Directory.GetCurrentDirectory(), relativePath);
            Dictionary<string, Pattern> items;

            try
            {
                string jsonString = System.IO.File.ReadAllText(jsonFilePath);
                var options = new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true,
                    PropertyNamingPolicy = JsonNamingPolicy.CamelCase
                };
                items = JsonSerializer.Deserialize<Dictionary<string, Pattern>>(jsonString, options);

                // Mapowanie pola "pattern" na "PatternList" (jeśli JSON używa "pattern")
                foreach (var item in items.Values)
                {
                    item.PatternList = item.PatternList ?? new List<string>();
                }
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }

            return Ok(items);
        }
    }
}
