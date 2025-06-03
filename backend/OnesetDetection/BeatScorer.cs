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
        public float MSE { get; set; } = -1f; // time diff mean square error (miliseconds)
        public float SE { get; set; } = -1f; // time diff square error (miliseconds)
        public float StepMSE { get; set; } = -1f; // no samples diff mean square error
        public int StepSE { get; set; } = -1; // no samples diff square error
        public int Score { get; set; } = -1;
        public bool[] ActualOnsets { get; set; } // Detected from user's recording
        public bool[] ModelOnsets { get; set; } // Generated
        public float TimePerSample { get; set; }
    }

    public static class BeatScorer
    {
        public static BeatScoreResult ScoreBeat(string audioPath, int bpm, int noBars, int[] rhythm, int leniency=1) // (redundant) , int scoreHarshnessMul=6 Harshness could be variable on beat difficulty
        {
            BeatScoreResult result = new();

            AudioAnalysis audioAnalysis = new();

            audioAnalysis.LoadAudioFromFile(audioPath);
            audioAnalysis.DetectOnsets(0.5f); // parametr: czułość wykrywania onsetów, im mniejsza wartość tym bardziej czułe (autor rekomenduje od 1.3 do 1.6) 
            audioAnalysis.NormalizeOnsets(0); // parametr: 0 - normalizacja między 0 a max, 1 - normalizacja między min a max
            float[] onsets = audioAnalysis.GetOnsets();

            float timePerSample = audioAnalysis.GetTimePerSample();
            Console.WriteLine(timePerSample);
            result.TimePerSample = timePerSample; 

            foreach (var onset in onsets)
            {
                Console.WriteLine(onset);
            }

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
                    return result;
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
                throw new Exception($"Something went really damn wrong. Notes: {noNotes}, differences: {noteDifferences.Count}");

            Console.WriteLine("\nRóżnice nut:");
            float se = 0.0f;
            int stepse = 0;
            for (int i = 1; i < noNotes; i++) // Nie bierzemy pod uwagę pierwszego porównania bo zawsze wynosi 0 (synchronizacja)
            {
                Console.WriteLine(noteDifferences[i]);

                // Zmniejszamy błąd o leniency żeby wziąć pod uwagę błąd wykrywania onsetów
                int lenientDifference = Math.Max(0, noteDifferences[i] - leniency);

                float timeDifference = lenientDifference * timePerSample;
                se += timeDifference * timeDifference;
                stepse += lenientDifference * lenientDifference;
            }

            se *= 1000000;
            result.MSE = se / (noNotes - 1);
            result.StepMSE = (float)stepse / (noNotes - 1);
            result.SE = se; result.StepSE = stepse;

            float[] scoreThresholds = [15.0f, 5.0f, 0.75f, 0.1f, 0.0f];
            float scale = 455f;
            for (int i = 0; i < scoreThresholds.Length; i++)
            {
                scoreThresholds[i] *= scale;
            }

            int score = -1;
            for (int i = 0; i < scoreThresholds.Length; i++)
            {
                if (result.MSE >= scoreThresholds[i])
                {
                    score = i + 1; // Wynik od 1 do 5 (gwiazdek - im więcej tym lepiej)
                    break;
                }
            }

            //int score = Math.Max(0, 100 - (int)(result.StepMSE * scoreHarshnessMul)); // TODO: temporary score calculation, make it cool
            result.Score = score;

            return result;
        }

        // For very very fast beats there is a risk of cooldown being too long and eating actual percussion
        private static bool[] GetQuantizedOnsets(float[] onsets, int cooldownSteps=3, float threshold=0.05f)
        {
            List<bool> quantizedOnsets = new();
            int cooldown = 0;
            bool quietBeginning = true;
            foreach (float onset in onsets)
            {
                cooldown--;

                bool quantizedOnset = onset > threshold ? true : false;

                bool setToFalse = cooldown > 0 ? true : false;

                // The false values at the start should be ignored so both model and live start at the same time
                if (quantizedOnset)
                {
                    quietBeginning = false;
                    cooldown = cooldownSteps + 1; // one more because one will go down immediatly after
                } 
                else if (quietBeginning)
                    continue;

                if (setToFalse)
                    quantizedOnset = false;
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
                modelOnsetsMultiplied.AddRange(modelOnsets);

            return modelOnsetsMultiplied.ToArray();
        }
    }
}
