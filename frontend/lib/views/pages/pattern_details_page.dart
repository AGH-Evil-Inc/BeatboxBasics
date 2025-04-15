import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart' as audio_waveforms;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:record/record.dart';
import 'sound_details_page.dart';

class PatternDetailsPage extends StatefulWidget {
  final Map<String, dynamic> pattern;
  final List<Map<String, dynamic>> sounds;

  const PatternDetailsPage({super.key, required this.pattern, required this.sounds});

  @override
  State<PatternDetailsPage> createState() => _PatternDetailsPageState();
}

class _PatternDetailsPageState extends State<PatternDetailsPage> {
  late final audio_waveforms.PlayerController patternController;
  late final audio_waveforms.PlayerController recordingController;
  final AudioRecorder recorder = AudioRecorder();
  String? recordingPath;
  bool isRecording = false;
  bool isPatternPlaying = false;
  bool isRecordingPlaying = false;
  double playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _initPatternPlayer();
    _initRecordingPlayer();
  }

  Future<void> _initPatternPlayer() async {
    patternController = audio_waveforms.PlayerController();
    final assetPath = widget.pattern['audioPath'];
    if (assetPath == null) {
      debugPrint('Brak ścieżki do pliku audio');
      return;
    }

    try {
      final byteData = await rootBundle.load('assets/$assetPath');
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$assetPath');
      await file.create(recursive: true);
      await file.writeAsBytes(byteData.buffer.asUint8List());

      await patternController.preparePlayer(
        path: file.path,
        shouldExtractWaveform: true,
      );
      patternController.onCompletion.listen((_) {
        setState(() => isPatternPlaying = false);
      });
      setState(() {});
    } catch (e) {
      debugPrint('Błąd podczas ładowania pliku audio: $e');
    }
  }

  Future<void> _initRecordingPlayer() async {
    recordingController = audio_waveforms.PlayerController();
  }

  Future<void> _startRecording() async {
    try {
      if (await recorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        recordingPath = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await recorder.start(const RecordConfig(), path: recordingPath!);
        setState(() => isRecording = true);
      }
    } catch (e) {
      debugPrint('Błąd podczas nagrywania: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await recorder.stop();
      if (recordingPath != null) {
        await recordingController.preparePlayer(
          path: recordingPath!,
          shouldExtractWaveform: true,
        );
      }
      setState(() => isRecording = false);
    } catch (e) {
      debugPrint('Błąd podczas zatrzymywania nagrywania: $e');
    }
  }

  Future<void> _playRecording() async {
    try {
      if (recordingPath != null) {
        await recordingController.startPlayer();
        setState(() => isRecordingPlaying = true);
        recordingController.onCompletion.listen((_) {
          setState(() => isRecordingPlaying = false);
        });
      }
    } catch (e) {
      debugPrint('Błąd podczas odtwarzania nagrania: $e');
    }
  }

  @override
  void dispose() {
    patternController.dispose();
    recordingController.dispose();
    recorder.dispose();
    super.dispose();
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple.shade900, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.purple.shade900,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildPatternCard() {
    final patternList = widget.pattern['pattern'] as List<dynamic>? ?? [];
    final patternStr = patternList.join(' ');
    final difficulty = widget.pattern['difficulty']?.toString() ?? 'Brak poziomu';

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'Pattern',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade900,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patternStr,
                    style: GoogleFonts.poppins(fontSize: 18, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Legenda:\n${_buildLegend()}',
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Zamknij',
                  style: GoogleFonts.poppins(color: Colors.purple.shade600),
                ),
              ),
            ],
          ),
        );
      },
      child: Card(
        color: Colors.orange.shade100,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pattern',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade900,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: patternList.map((note) {
                  return GestureDetector(
                    onTap: () {
                      final sound = widget.sounds.firstWhere(
                        (sound) => sound['notation'] == note.toString(),
                        orElse: () => <String, dynamic>{},
                      );
                      if (sound.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SoundDetailsPage(sound: sound),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Nie znaleziono dźwięku dla $note',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: Colors.red.shade600,
                          ),
                        );
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPatternPlaying
                            ? Colors.purple.shade100
                            : Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            note.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              color: Colors.purple.shade600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.purple.shade600,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    _getDifficultyIcon(difficulty),
                    color: Colors.purple.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Poziom: $difficulty',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.purple.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text( 
                'Kliknij na dźwięk, aby zobaczyć szczegóły',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.purple.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().slideY(begin: 0.2, end: 0, duration: 500.ms);
  }

  String _buildLegend() {
    final notations = widget.sounds.map((sound) {
      final notation = sound['notation'] ?? '';
      final name = sound['name'] ?? 'Nieznany dźwięk';
      return '$notation = $name';
    }).toSet();
    return notations.isEmpty ? 'Brak dostępnych dźwięków' : notations.join('\n');
  }

  Widget _buildDescriptionCard() {
    final description = widget.pattern['description'] ?? 'Brak opisu';
    final bpm = widget.pattern['base_BPM']?.toString() ?? 'Brak';
    final bars = widget.pattern['no_bars']?.toString() ?? 'Brak';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Opis',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$description\n\nBPM: $bpm',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.2, end: 0, duration: 500.ms);
  }

  Widget _buildPatternPlayer() {
    final audioPath = widget.pattern['audioPath'];
    if (audioPath == null) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Brak dostępnego audio'),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Posłuchaj patterny',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade900,
              ),
            ),
            const SizedBox(height: 12),
            audio_waveforms.AudioFileWaveforms(
              playerController: patternController,
              size: const Size(double.infinity, 100),
              waveformType: audio_waveforms.WaveformType.fitWidth,
              playerWaveStyle: audio_waveforms.PlayerWaveStyle(
                liveWaveColor: Colors.purple.shade700,
                fixedWaveColor: Colors.purple.shade200,
                scaleFactor: 100,
                showSeekLine: true,
                seekLineColor: Colors.orange.shade300,
                seekLineThickness: 2,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isPatternPlaying)
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation(Colors.purple.shade200),
                          strokeWidth: 3,
                          backgroundColor: Colors.transparent,
                        ),
                      ).animate().fadeIn(duration: 300.ms),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow, color: Colors.white),
                      label: Text(
                        'Odtwórz',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        patternController.startPlayer();
                        setState(() => isPatternPlaying = true);
                      },
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.pause, color: Colors.white),
                  label: Text(
                    'Pauza',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    patternController.pausePlayer();
                    setState(() => isPatternPlaying = false);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSpeedButton(
                  speed: 0.5,
                  label: 'Wolno',
                  icon: Icons.arrow_downward,
                ),
                const SizedBox(width: 8),
                _buildSpeedButton(
                  speed: 1.0,
                  label: 'Normalnie',
                  icon: Icons.play_arrow,
                ),
                const SizedBox(width: 8),
                _buildSpeedButton(
                  speed: 1.5,
                  label: 'Szybko',
                  icon: Icons.arrow_upward,
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildRecordingPlayer() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nagraj swoją próbę',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade900,
              ),
            ),
            const SizedBox(height: 12),
            if (recordingPath != null)
              audio_waveforms.AudioFileWaveforms(
                playerController: recordingController,
                size: const Size(double.infinity, 50),
                waveformType: audio_waveforms.WaveformType.fitWidth,
                playerWaveStyle: audio_waveforms.PlayerWaveStyle(
                  liveWaveColor: Colors.purple.shade700,
                  fixedWaveColor: Colors.purple.shade200,
                  scaleFactor: 50,
                  showSeekLine: true,
                  seekLineColor: Colors.orange.shade300,
                  seekLineThickness: 2,
                ),
              ),
            const SizedBox(height: 12),
            Wrap(
              children: [
                ElevatedButton.icon(
                  icon: Icon(
                    isRecording ? Icons.stop : Icons.mic,
                    color: Colors.white,
                  ),
                  label: Text(
                    isRecording ? 'Zatrzymaj' : 'Nagraj',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onPressed: isRecording ? _stopRecording : _startRecording,
                ),
                if (recordingPath != null) ...[
                  const SizedBox(width: 16),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isRecordingPlaying)
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation(Colors.purple.shade200),
                            strokeWidth: 3,
                            backgroundColor: Colors.transparent,
                          ),
                        ).animate().fadeIn(duration: 300.ms),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow, color: Colors.white),
                        label: Text(
                          'Odtwórz',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onPressed: _playRecording,
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.pause, color: Colors.white),
                    label: Text(
                      'Pauza',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      recordingController.pausePlayer();
                      setState(() => isRecordingPlaying = false);
                    },
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildSpeedButton({
    required double speed,
    required String label,
    required IconData icon,
  }) {
    final isSelected = playbackSpeed == speed;
    return ElevatedButton.icon(
      icon: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.purple.shade600,
        size: 20,
      ),
      label: Text(
        label,
        style: GoogleFonts.poppins(
          color: isSelected ? Colors.white : Colors.purple.shade600,
          fontSize: 12,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.purple.shade600 : Colors.purple.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        minimumSize: const Size(80, 40),
      ),
      onPressed: () {
        setState(() {
          playbackSpeed = speed;
          patternController.setRate(speed);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pattern = widget.pattern;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.purple.shade50,
                Colors.white,
              ],
            ),
          ),
          child: Column(
            children: [
              AppBar(
                title: Text(
                  pattern['name'] ?? 'Brak nazwy',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                centerTitle: true,
                backgroundColor: Colors.purple.shade600,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                elevation: 4,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.shade600,
                        Colors.purple.shade800,
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDescriptionCard(),
                      const SizedBox(height: 16),
                      _buildPatternCard(),
                      const SizedBox(height: 16),
                      _buildPatternPlayer(),
                      const SizedBox(height: 16),
                      _buildRecordingPlayer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getDifficultyIcon(String difficulty) {
    try {
      final level = int.parse(difficulty);
      if (level <= 1) return Icons.circle;
      if (level == 2) return Icons.star_border;
      return Icons.star;
    } catch (e) {
      return Icons.info_outline;
    }
  }
}