// Źródło: https://github.com/Teh-Lemon/Onset-Detection?tab=readme-ov-file
using OnesetDetection; // z powyższego źródła zrobiłem dll

// Tymczasowa ścieżka absolutna (ZMIENIĆ)
string audioPath = "E:\\SzkolaProgramowanie\\BeatboxBasics\\backend\\OnesetDetectionExample\\pattern_basic_B_130BPM.wav";

/*AudioAnalysis audioAnalysis = new();
audioAnalysis.LoadAudioFromFile(audioPath);
audioAnalysis.DetectOnsets(1.5f); // parametr: czułość wykrywania onsetów, im mniejsza wartość tym bardziej czułe (autor rekomenduje od 1.3 do 1.6) 
audioAnalysis.NormalizeOnsets(0); // parametr: 0 - normalizacja między 0 a max, 1 - normalizacja między min a max
float[] onsets = audioAnalysis.GetOnsets();

Console.WriteLine($"Czas trwania każdej próbki: {audioAnalysis.GetTimePerSample()} sekund.");

Console.WriteLine("Próbki:"); // Werble wykrywa dwukrotnie ale drugie wykrycie ma bardzo małą wartość i można zrobić jakiegoś thresholda
foreach (var onset in onsets)
{
    Console.WriteLine(onset);
}*/

BeatScoreResult score = BeatScorer.ScoreBeat(audioPath, 130, 2, [4, 4, 4, 4, 4, 4, 4, 4]);

Console.WriteLine($"\nBeatAccepted: {score.BeatAccepted}");
Console.WriteLine($"\nSE: {score.SE}");
Console.WriteLine($"\nMSE: {score.MSE}");
Console.WriteLine($"\nScore: {score.Score}");
Console.WriteLine($"\nTimePerSample: {score.TimePerSample}");
Console.WriteLine($"\nActualOnsets: \n{(score.ActualOnsets != null ? string.Join(" ", score.ActualOnsets.Select(b => b ? "1" : "0")) : "null")}");
Console.WriteLine($"\nModelOnsets: \n{(score.ModelOnsets != null ? string.Join(" ", score.ModelOnsets.Select(b => b ? "1" : "0")) : "null")}");
