using OnesetDetection;

namespace api.Models;

public class ScoreResponse
{
    public bool BeatAccepted { get; set; } = true; // Niezaakceptowany jeśli zostanie wykrytych mniej beatów niż powinno być
    public float MSE { get; set; } = -1f; // time diff mean square error (seconds)
    public float SE { get; set; } = -1f; // time diff square error (seconds)
    public float StepMSE { get; set; } = -1f; // no samples diff mean square error
    public int StepSE { get; set; } = -1; // no samples diff square error
    public int Score { get; set; } = -1;   // np. "basic_beat"
}