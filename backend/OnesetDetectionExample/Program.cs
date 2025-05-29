// Źródło: https://github.com/Teh-Lemon/Onset-Detection?tab=readme-ov-file
using OnesetDetection; // z powyższego źródła zrobiłem dll i dorobiłem BeatScorer.cs

// Tymczasowa ścieżka absolutna (ZMIENIĆ)
//string examplesPath = "D:\\studia\\BeatboxBasics\\backend\\OnesetDetectionExample\\";
string examplesPath = "E:\\SzkolaProgramowanie\\BeatboxBasics\\backend\\OnesetDetectionExample\\";

//string relativePath = @"..\..\backend\OnesetDetectionExample\";
//string examplesPath = Path.Combine(Directory.GetCurrentDirectory(), relativePath);

//string audioName = "pattern_basic_B_130BPM.wav";
//string audioName = "example_recording.wav";
//string audioName = "example_2.wav";
//string audioName = "example_bad.wav";
//string audioName = "recording_basicB.wav";
//string audioName = "rock_a_test.wav";

//string audioName = "recording_dnb.wav";
//string audioName = "pattern_dnb_A_170BPM.wav";

//string audioName = "dnb2pat.wav";

//string audioName = "pattern_amen_break_120BPM.wav";
//string audioName = "recording_amen.wav";
string audioName = "test_amen.wav";


string audioPath = examplesPath + audioName;
BeatScoreResult score = BeatScorer.ScoreBeat(audioPath, 120, 2, [8, 8, 8, 16, 16, 16, 16, 16, 16, 8, 16, 16]); // [8, 8, 8, 16, 16, 16, 16, 16, 16, 8, 16, 16]

Console.WriteLine($"\nBeat accepted: {score.BeatAccepted}");
Console.WriteLine($"\nSE: {score.SE}");
Console.WriteLine($"\nMSE: {score.MSE}");
Console.WriteLine($"\nStep SE: {score.StepSE}");
Console.WriteLine($"\nStep MSE: {score.StepMSE}");
Console.WriteLine($"\nScore: {score.Score}");
Console.WriteLine($"\nTime per sample: {score.TimePerSample}");
Console.WriteLine($"\nActual onsets: \n{(score.ActualOnsets != null ? string.Join(" ", score.ActualOnsets.Select(b => b ? "1" : "0")) : "null")}");
Console.WriteLine($"\nModel onsets: \n{(score.ModelOnsets != null ? string.Join(" ", score.ModelOnsets.Select(b => b ? "1" : "0")) : "null")}");
