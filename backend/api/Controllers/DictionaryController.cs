using System.Text.Json;
using api.Models;
using Microsoft.AspNetCore.Mvc;

namespace api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class DictionaryController : ControllerBase
    {
        [HttpGet]
        public IActionResult GetDictionaryEntries()
        {
            string relativePath = @"..\..\frontend\assets\text\beatbox_dictionary.json";
            string jsonFilePath = Path.Combine(Directory.GetCurrentDirectory(), relativePath);
            Dictionary<string, DictionaryEntry> items;

            try
            {
                string jsonString = System.IO.File.ReadAllText(jsonFilePath);
                var options = new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                };
                items = JsonSerializer.Deserialize<Dictionary<string, DictionaryEntry>>(jsonString, options);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }

            return Ok(items);
        }
    }
}
