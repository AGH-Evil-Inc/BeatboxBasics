import 'dart:io';
import 'package:app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audio_waveforms/audio_waveforms.dart' as audio_waveforms;
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'sound_details_page.dart';

class PatternDetailsPage extends StatefulWidget {
  final Map<String, dynamic> pattern;
  final List<Map<String, dynamic>> sounds;

  const PatternDetailsPage({
    super.key,
    required this.pattern,
    required this.sounds,
  });

  @override
  State<PatternDetailsPage> createState() => _PatternDetailsPageState();
}

class _PatternDetailsPageState extends State<PatternDetailsPage> {
  late final audio_waveforms.PlayerController _patternController;
  late final audio_waveforms.RecorderController _recordingController;
  late final audio_waveforms.PlayerController _recordingPlayerController;
  final AudioRecorder _recorder = AudioRecorder();
  String? _recordingPath;
  bool _isRecording = false;
  bool _isPatternPlaying = false;
  bool _isRecordingPlaying = false;
  double _playbackSpeed = 1.0;
  int _playCount = 0; 

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  Future<void> _initControllers() async {
    _patternController = audio_waveforms.PlayerController();
    _recordingController = audio_waveforms.RecorderController()
      ..androidEncoder = audio_waveforms.AndroidEncoder.aac
      ..androidOutputFormat = audio_waveforms.AndroidOutputFormat.mpeg4
      ..iosEncoder = audio_waveforms.IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 16000;
    _recordingPlayerController = audio_waveforms.PlayerController();
    await _loadPatternAudio();
  }

  Future<void> _loadPatternAudio() async {
    final assetPath = widget.pattern['audioPath'];
    if (assetPath == null) return;

    try {
      final byteData = await rootBundle.load('assets/$assetPath');
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$assetPath');
      await file.create(recursive: true);
      await file.writeAsBytes(byteData.buffer.asUint8List());

      await _patternController.preparePlayer(
        path: file.path,
        shouldExtractWaveform: true,
      );

      await _patternController.setFinishMode(finishMode: audio_waveforms.FinishMode.pause);
      _patternController.updateFrequency = audio_waveforms.UpdateFrequency.high;
      _patternController.onCompletion.listen((_) {
        setState(() => _isPatternPlaying = false);
      });
    } catch (e) {
      debugPrint('Error loading audio: $e');
    }
  }

  Future<void> _toggleRecording() async {
    await AudioPlayer().play(AssetSource('audio/click.mp3'));
    Vibration.vibrate(pattern: [0, 50, 50, 50]);
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    if (await _recorder.hasPermission()) {
      final tempDir = await getTemporaryDirectory();
      _recordingPath = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recordingController.record(path: _recordingPath);
      await _recorder.start(const RecordConfig(), path: _recordingPath!);
      setState(() => _isRecording = true);
    }
  }

  Future<void> _stopRecording() async {
    await _recorder.stop();
    await _recordingController.stop();
    if (_recordingPath != null) {
      await _recordingPlayerController.preparePlayer(
        path: _recordingPath!,
        shouldExtractWaveform: true,
      );
      _recordingPlayerController.onCompletion.listen((_) {
        setState(() => _isRecordingPlaying = false);
      });
    }
    setState(() => _isRecording = false);
  }

  Future<void> _playRecording() async {
    if (_recordingPath == null) return;
    await AudioPlayer().play(AssetSource('audio/click.mp3'));
    Vibration.vibrate(pattern: [0, 50, 50, 50]);
    if (_isRecordingPlaying) {
      await _recordingPlayerController.pausePlayer();
    } else {
      await _recordingPlayerController.startPlayer();
    }
    setState(() => _isRecordingPlaying = !_isRecordingPlaying);
  }

  Future<void> _togglePatternPlayback() async {
    await AudioPlayer().play(AssetSource('audio/click.mp3'));
    Vibration.vibrate(pattern: [0, 50, 50, 50]);
    if (_isPatternPlaying) {
      await _patternController.pausePlayer();
    } else {
      await _patternController.startPlayer();
      setState(() {
        _playCount++;
        if (_playCount == 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '3 razy z rzędu! Jesteś pro! 🔥',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              backgroundColor: Theme.of(context).extension<AppColors>()!.accentColor,
            ),
          );
        }
      });
    }
    setState(() => _isPatternPlaying = !_isPatternPlaying);
  }

  Future<void> _setPlaybackSpeed(double speed) async {
    await AudioPlayer().play(AssetSource('audio/click.mp3'));
    Vibration.vibrate(duration: 30);
    setState(() => _playbackSpeed = speed);
    await _patternController.setRate(speed);
  }

  @override
  void dispose() {
    _patternController.dispose();
    _recordingController.dispose();
    _recordingPlayerController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final pattern = widget.pattern;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: appColors.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: appColors.cardColor,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(8),
              ),
            ),
            title: Text(
              pattern['name'] ?? 'Pattern',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: appColors.primaryColor,
              ),
            ),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: appColors.cardColor,
                child: Center(
                  child: Icon(
                    Icons.library_music,
                    size: 48,
                    color: appColors.accentColor,
                  ),
                ),
              ).animate().fadeIn(duration: 600.ms),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: screenWidth > 600 ? 600 : screenWidth * 0.9),
                  child: Column(
                    children: [
                      _PatternInfoSection(pattern: pattern, sounds: widget.sounds)
                          .animate().fadeIn(duration: 600.ms, delay: 100.ms),
                      const SizedBox(height: 32),
                      _PatternPlayerSection(
                        controller: _patternController,
                        isPlaying: _isPatternPlaying,
                        playbackSpeed: _playbackSpeed,
                        onPlayPressed: _togglePatternPlayback,
                        onSpeedChanged: _setPlaybackSpeed,
                      ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                      const SizedBox(height: 32),
                      _RecordingSection(
                        recorderController: _recordingController,
                        playerController: _recordingPlayerController,
                        isRecording: _isRecording,
                        isPlaying: _isRecordingPlaying,
                        onRecordPressed: _toggleRecording,
                        onPlayPressed: _playRecording,
                      ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _PatternInfoSection extends StatelessWidget {
  final Map<String, dynamic> pattern;
  final List<Map<String, dynamic>> sounds;

  const _PatternInfoSection({
    required this.pattern,
    required this.sounds,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final patternList = pattern['pattern'] as List<dynamic>? ?? [];
    final description = pattern['description'] ?? 'Brak opisu';
    final bpm = pattern['base_BPM']?.toString() ?? 'N/A';

    return Card(
      elevation: 6,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(8),
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(24),
        ),
      ),
      color: appColors.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'O co chodzi?',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: appColors.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$description\n\nBPM: $bpm',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: appColors.secondaryColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Notacja patternu',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: appColors.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: patternList.map((note) {
                return _PatternNoteTile(
                  note: note.toString(),
                  sounds: sounds,
                ).animate().scale(
                      duration: 400.ms,
                      curve: Curves.easeOutBack,
                      begin: const Offset(0.95, 0.95),
                    );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatternNoteTile extends StatelessWidget {
  final String note;
  final List<Map<String, dynamic>> sounds;

  const _PatternNoteTile({
    required this.note,
    required this.sounds,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final sound = sounds.firstWhere(
      (s) => s['notation'] == note,
      orElse: () => <String, dynamic>{},
    );

    return Tooltip(
      message: sound['name'] ?? 'Nieznany dźwięk',
      child: GestureDetector(
        onTap: sound.isEmpty
            ? null
            : () async {
                await AudioPlayer().play(AssetSource('audio/click.mp3'));
                Vibration.vibrate(pattern: [0, 50, 50, 50]);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SoundDetailsPage(sound: sound),
                  ),
                );
              },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: appColors.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: appColors.accentColor, width: 1.5),
          ),
          child: Text(
            note,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: appColors.accentColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _PatternPlayerSection extends StatelessWidget {
  final audio_waveforms.PlayerController controller;
  final bool isPlaying;
  final double playbackSpeed;
  final VoidCallback onPlayPressed;
  final ValueChanged<double> onSpeedChanged;

  const _PatternPlayerSection({
    required this.controller,
    required this.isPlaying,
    required this.playbackSpeed,
    required this.onPlayPressed,
    required this.onSpeedChanged,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final isSmallScreen = MediaQuery.of(context).size.width < 800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Odtwórz pattern',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: appColors.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 6,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(8),
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(24),
            ),
          ),
          color: appColors.cardColor,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                audio_waveforms.AudioFileWaveforms(
                  enableSeekGesture: true,
                  playerController: controller,
                  size: const Size(double.infinity, 60),
                  waveformType: audio_waveforms.WaveformType.fitWidth,
                  playerWaveStyle: audio_waveforms.PlayerWaveStyle(
                    liveWaveColor: appColors.waveformLiveColor,
                    fixedWaveColor: appColors.waveformFixedColor,
                    seekLineColor: appColors.waveformSeekColor,
                    seekLineThickness: 2,
                    waveCap: StrokeCap.butt,
                  ),
                ),
                const SizedBox(height: 20),
                if (isSmallScreen) ...[
                  _PlaybackButton(
                    icon: isPlaying ? Icons.pause : Icons.play_arrow,
                    label: isPlaying ? 'Pauza' : 'Odtwórz',
                    color: appColors.buttonPrimaryColor,
                    onPressed: onPlayPressed,
                    isActive: isPlaying,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SpeedControlButton(
                        speed: 0.5,
                        currentSpeed: playbackSpeed,
                        onChanged: onSpeedChanged,
                      ),
                      const SizedBox(width: 12),
                      _SpeedControlButton(
                        speed: 1.0,
                        currentSpeed: playbackSpeed,
                        onChanged: onSpeedChanged,
                      ),
                      const SizedBox(width: 12),
                      _SpeedControlButton(
                        speed: 1.5,
                        currentSpeed: playbackSpeed,
                        onChanged: onSpeedChanged,
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _PlaybackButton(
                        icon: isPlaying ? Icons.pause : Icons.play_arrow,
                        label: isPlaying ? 'Pauza' : 'Odtwórz',
                        color: appColors.buttonPrimaryColor,
                        onPressed: onPlayPressed,
                        isActive: isPlaying,
                      ),
                      const SizedBox(width: 16),
                      _SpeedControlButton(
                        speed: 0.5,
                        currentSpeed: playbackSpeed,
                        onChanged: onSpeedChanged,
                      ),
                      const SizedBox(width: 12),
                      _SpeedControlButton(
                        speed: 1.0,
                        currentSpeed: playbackSpeed,
                        onChanged: onSpeedChanged,
                      ),
                      const SizedBox(width: 12),
                      _SpeedControlButton(
                        speed: 1.5,
                        currentSpeed: playbackSpeed,
                        onChanged: onSpeedChanged,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RecordingSection extends StatelessWidget {
  final audio_waveforms.RecorderController recorderController;
  final audio_waveforms.PlayerController playerController;
  final bool isRecording;
  final bool isPlaying;
  final VoidCallback onRecordPressed;
  final VoidCallback onPlayPressed;

  const _RecordingSection({
    required this.recorderController,
    required this.playerController,
    required this.isRecording,
    required this.isPlaying,
    required this.onRecordPressed,
    required this.onPlayPressed,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final isSmallScreen = MediaQuery.of(context).size.width < 800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nagraj swoje próby',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: appColors.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 6,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(24),
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(8),
            ),
          ),
          color: appColors.cardColor,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                audio_waveforms.AudioWaveforms(
                  enableGesture: true,
                  size: Size(MediaQuery.of(context).size.width / 2, 50),
                  recorderController: recorderController,
                  waveStyle: audio_waveforms.WaveStyle(
                    waveColor: appColors.waveformLiveColor,
                    extendWaveform: true,
                    showMiddleLine: false,
                  ),
                ),
                const SizedBox(height: 20),
                audio_waveforms.AudioFileWaveforms(
                  playerController: playerController,
                  enableSeekGesture: true,
              
                  size: const Size(double.infinity, 60),
                  waveformType: audio_waveforms.WaveformType.fitWidth,
                  playerWaveStyle: audio_waveforms.PlayerWaveStyle(
                    liveWaveColor: appColors.waveformLiveColor,
                    fixedWaveColor: appColors.waveformFixedColor,
                    seekLineColor: appColors.waveformSeekColor,
                    seekLineThickness: 2,
                  ),
                ),
                const SizedBox(height: 20),
                if (isSmallScreen) ...[
                  _PlaybackButton(
                    icon: isRecording ? Icons.stop : Icons.mic,
                    label: isRecording ? 'Stop' : 'Nagraj',
                    color: appColors.buttonSecondaryColor,
                    onPressed: onRecordPressed,
                    isActive: isRecording,
                  ),
                  const SizedBox(height: 12),
                  _PlaybackButton(
                    icon: isPlaying ? Icons.pause : Icons.play_arrow,
                    label: isPlaying ? 'Pauza' : 'Odtwórz',
                    color: appColors.buttonPrimaryColor,
                    onPressed: onPlayPressed,
                    isActive: isPlaying,
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _PlaybackButton(
                        icon: isRecording ? Icons.stop : Icons.mic,
                        label: isRecording ? 'Stop' : 'Nagraj',
                        color: appColors.buttonSecondaryColor,
                        onPressed: onRecordPressed,
                        isActive: isRecording,
                      ),
                      const SizedBox(width: 16),
                      _PlaybackButton(
                        icon: isPlaying ? Icons.pause : Icons.play_arrow,
                        label: isPlaying ? 'Pauza' : 'Odtwórz',
                        color: appColors.buttonPrimaryColor,
                        onPressed: onPlayPressed,
                        isActive: isPlaying,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PlaybackButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final bool isActive;

  const _PlaybackButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Stack(
      alignment: Alignment.center,
      children: [
        if (isActive)
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: appColors.accentColor.withOpacity(0.2),
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeInOut),
        ElevatedButton.icon(
          icon: Icon(icon, size: 28, color: Colors.white),
          label: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            elevation: 4,
          ),
          onPressed: onPressed,
        ).animate().scale(
              duration: 400.ms,
              curve: Curves.easeOutBack,
              begin: const Offset(0.95, 0.95),
            ),
      ],
    );
  }
}

class _SpeedControlButton extends StatelessWidget {
  final double speed;
  final double currentSpeed;
  final ValueChanged<double> onChanged;

  const _SpeedControlButton({
    required this.speed,
    required this.currentSpeed,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final isSelected = currentSpeed == speed;
    final icon = speed == 0.5
        ? Icons.arrow_downward
        : speed == 1.0
            ? Icons.play_arrow
            : Icons.arrow_upward;

    return IconButton(
      icon: Icon(icon, size: 24),
      color: isSelected ? Colors.white : appColors.secondaryColor,
      style: IconButton.styleFrom(
        backgroundColor: isSelected ? appColors.buttonPrimaryColor : appColors.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        elevation: isSelected ? 4 : 0,
      ),
      onPressed: () async {
        await AudioPlayer().play(AssetSource('audio/click.mp3'));
        Vibration.vibrate(duration: 30);
        onChanged(speed);
      },
    ).animate().scale(
          duration: 400.ms,
          curve: Curves.easeOutBack,
          begin: const Offset(0.95, 0.95),
        );
  }
}