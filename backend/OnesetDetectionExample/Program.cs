// Źródło: https://github.com/Teh-Lemon/Onset-Detection?tab=readme-ov-file
using OnesetDetection; // z powyższego źródła zrobiłem dll

AudioAnalysis audioAnalysis = new();

// Tymczasowa ścieżka absolutna (ZMIENIĆ)
string audioPath = "E:\\SzkolaProgramowanie\\BeatboxBasics\\backend\\OnesetDetectionExample\\pattern_basic_B_130BPM.wav";

audioAnalysis.LoadAudioFromFile(audioPath);
audioAnalysis.DetectOnsets(1.5f); // parametr: czułość wykrywania onsetów, im mniejsza wartość tym bardziej czułe (autor rekomenduje od 1.3 do 1.6) 
audioAnalysis.NormalizeOnsets(0); // parametr: 0 - normalizacja między 0 a max, 1 - normalizacja między min a max
float[] onsets = audioAnalysis.GetOnsets();

Console.WriteLine($"Czas trwania każdej próbki: {audioAnalysis.GetTimePerSample()} sekund.");

Console.WriteLine("Próbki:"); // Werble wykrywa dwukrotnie ale drugie wykrycie ma bardzo małą wartość i można zrobić jakiegoś thresholda
foreach (var onset in onsets)
{
    Console.WriteLine(onset);
}