// Źródło: https://github.com/Teh-Lemon/Onset-Detection?tab=readme-ov-file
using OnesetDetection; // z powyższego źródła zrobiłem dll i dorobiłem BeatScorer.cs

// Tymczasowa ścieżka absolutna (ZMIENIĆ)
string examplesPath = "E:\\SzkolaProgramowanie\\BeatboxBasics\\backend\\OnesetDetectionExample\\";

//string audioName = "pattern_basic_B_130BPM.wav";
//string audioName = "example_recording.wav";
string audioName = "example_2.wav";
//string audioName = "example_bad.wav";

string audioPath = examplesPath + audioName;
BeatScoreResult score = BeatScorer.ScoreBeat(audioPath, 130, 2, [4, 4, 4, 4, 4, 4, 4, 4]);

Console.WriteLine($"\nBeat accepted: {score.BeatAccepted}");
Console.WriteLine($"\nSE: {score.SE}");
Console.WriteLine($"\nMSE: {score.MSE}");
Console.WriteLine($"\nStep SE: {score.StepSE}");
Console.WriteLine($"\nStep MSE: {score.StepMSE}");
Console.WriteLine($"\nScore: {score.Score}");
Console.WriteLine($"\nTime per sample: {score.TimePerSample}");
Console.WriteLine($"\nActual onsets: \n{(score.ActualOnsets != null ? string.Join(" ", score.ActualOnsets.Select(b => b ? "1" : "0")) : "null")}");
Console.WriteLine($"\nModel onsets: \n{(score.ModelOnsets != null ? string.Join(" ", score.ModelOnsets.Select(b => b ? "1" : "0")) : "null")}");
