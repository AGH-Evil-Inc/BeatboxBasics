// This is the only file in OnesetDetection library that was made from scratch for the Beatbox basics project
// The code in the rest of the files was taken from this repo https://github.com/Teh-Lemon/Onset-Detection?tab=readme-ov-file
// Nothing in this file was made using AI

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OnesetDetection
{
    public class BeatScoreResult
    {
        public bool BeatAccepted { get; set; } = true; // Niezaakceptowany jeśli zostanie wykrytych mniej beatów niż powinno być
        public double MSE { get; set; } = -1;
        public int SE { get; set; } = -1;
        public int Score { get; set; } = -1;
        public bool[] ActualOnsets { get; set; }
        public bool[] ModelOnsets { get; set; }
        public float TimePerSample { get; set; }
    }

    public static class BeatScorer
    {
        public static BeatScoreResult ScoreBeat(string audioPath, int bpm, int noBars, int[] rhythm)
        {
            BeatScoreResult result = new();

            AudioAnalysis audioAnalysis = new();

            audioAnalysis.LoadAudioFromFile(audioPath);
            audioAnalysis.DetectOnsets(1.5f); // parametr: czułość wykrywania onsetów, im mniejsza wartość tym bardziej czułe (autor rekomenduje od 1.3 do 1.6) 
            audioAnalysis.NormalizeOnsets(0); // parametr: 0 - normalizacja między 0 a max, 1 - normalizacja między min a max
            float[] onsets = audioAnalysis.GetOnsets();

            float timePerSample = audioAnalysis.GetTimePerSample();
            result.TimePerSample = timePerSample;

            bool[] actualOnsets = GetQuantizedOnsets(onsets);
            result.ActualOnsets = actualOnsets;
            int actualOnsetsLength = actualOnsets.Length;

            bool[] modelOnsets = GenerateModelOnsets(bpm, noBars, rhythm, timePerSample);
            result.ModelOnsets = modelOnsets;
            int modelOnsetsLength = modelOnsets.Length;

            // Actual scoring - this algorithm took me so long to make, it's a complex one
            int actualNoteIdx = 0;
            int modelNoteIdx = 0;
            int actualOnsetIdx = 0;
            int modelOnsetIdx = 0;
            bool waitingForActual = false;
            bool waitingForModel = false;

            List<int> noteDifferences = new();
            int currentNoteDifference = 0;

            int noNotes = rhythm.Length * noBars;
            while (actualNoteIdx < noNotes || modelNoteIdx < noNotes)
            {
                if (waitingForActual && actualOnsetIdx > actualOnsetsLength)
                {
                    result.BeatAccepted = false;
                    break;
                }

                bool actualOnset = actualOnsetIdx < actualOnsetsLength ? actualOnsets[actualOnsetIdx] : false;
                bool modelOnset = modelOnsetIdx < modelOnsetsLength ? modelOnsets[modelOnsetIdx] : false;

                if (actualOnset)
                {
                    if (waitingForActual)
                    {
                        waitingForActual = false;
                        noteDifferences.Add(currentNoteDifference);
                        currentNoteDifference = 0;
                    }
                    else
                        waitingForModel = true;

                    actualNoteIdx++;
                    actualOnsetIdx++;
                }

                if (modelOnset)
                {
                    if (waitingForModel)
                    {
                        waitingForModel = false;
                        noteDifferences.Add(currentNoteDifference);
                        currentNoteDifference = 0;
                    }
                    else
                        waitingForActual = true;

                    modelNoteIdx++;
                    modelOnsetIdx++;
                }


                if (waitingForActual)
                {
                    actualOnsetIdx++;
                    currentNoteDifference++;
                }
                else if (waitingForModel)
                {
                    modelOnsetIdx++;
                    currentNoteDifference++;
                }
                else
                {
                    actualOnsetIdx++;
                    modelOnsetIdx++;
                }
            }

            if (noteDifferences.Count != noNotes)
                throw new Exception("Something went really damn wrong.");

            if (!result.BeatAccepted) 
                return result;

            Console.WriteLine("\nRóżnice nut:");
            int se = 0;
            double mse = 0;
            for (int i = 0; i < noNotes; i++)
            {
                Console.WriteLine(noteDifferences[i]);

                // Jeżeli błąd to tylko 1 to go nie ma, bo jest tak mały jak możliwy błąd wykrywania onsetów
                if (noteDifferences[i] > 0)
                    noteDifferences[i] -= 1; // Dlatego zmniejszam wszystko o 1

                se += noteDifferences[i] * noteDifferences[i];
            }

            mse = (double)se / noNotes;
            result.SE = se; result.MSE = mse;

            int score = Math.Max(0, 100 - (int)mse); // TODO: temporary score calculation, make it cool
            result.Score = score;

            return result;
        }

        private static bool[] GetQuantizedOnsets(float[] onsets, float threshold=0.1f)
        {
            List<bool> quantizedOnsets = new();
            bool quietBeginning = true;
            foreach (float onset in onsets)
            {
                bool quantizedOnset = onset > threshold ? true : false;

                // The false values at the start should be ignored so both model and live start at the same time
                if (quantizedOnset)  
                    quietBeginning = false;
                else if (quietBeginning)
                    continue;

                quantizedOnsets.Add(quantizedOnset);
            }

            return quantizedOnsets.ToArray();
        }

        private static bool[] GenerateModelOnsets(int bpm, int noBars, int[] rhythm, float timePerSample)
        {
            List<bool> modelOnsets = new();

            float lengthOfQuarterNote = (1.0f / (float)bpm) * 60.0f;

            float timeToNextNote = -0.1f;
            int currentNoteIdx = 0;
            
            while (currentNoteIdx < rhythm.Length || timeToNextNote > 0.0f)
            {
                if (timeToNextNote <= 0.0f)
                {
                    int currentNote = rhythm[currentNoteIdx];
                    float multipleOfQuarterNote = 1.0f / ((float)currentNote / 4.0f);
                    float lengthOfNote = multipleOfQuarterNote * lengthOfQuarterNote;

                    timeToNextNote = lengthOfNote;
                    currentNoteIdx++;

                    modelOnsets.Add(true);
                }
                else
                {
                    modelOnsets.Add(false);
                }

                timeToNextNote -= timePerSample;
            }

            List<bool> modelOnsetsMultiplied = new();
            for (int i = 0; i < noBars; i++)
            {
                modelOnsetsMultiplied.AddRange(modelOnsets); // Append the original list `n` times
            }

            return modelOnsetsMultiplied.ToArray();
        }
    }
}
