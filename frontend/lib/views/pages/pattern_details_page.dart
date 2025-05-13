import 'dart:io';
import 'package:app/data/globals.dart' as globals;
import 'package:app/main.dart';
import 'package:app/views/pages/sound_details_page.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audio_waveforms/audio_waveforms.dart' as audio_waveforms;
import 'package:record/record.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScoreResponse {
  final bool beatAccepted;
  final double mse;
  final double se;
  final double stepMse;
  final int stepSe;
  final int score;

  ScoreResponse({
    required this.beatAccepted,
    required this.mse,
    required this.se,
    required this.stepMse,
    required this.stepSe,
    required this.score,
  });

  factory ScoreResponse.fromJson(Map<String, dynamic> json) {
    return ScoreResponse(
      beatAccepted: json['beatAccepted'],
      mse: (json['mse']).toDouble(),
      se: (json['se']).toDouble(),
      stepMse: (json['stepMSE']).toDouble(),
      stepSe: json['stepSE'] ,
      score: json['score'],
    );
  }
}

class PatternDetailsPage extends StatefulWidget {
  final Map<String, dynamic> pattern;
  final List<Map<String, dynamic>> sounds;
  final String patternkey;

  const PatternDetailsPage({
    super.key,
    required this.pattern,
    required this.sounds,
    required this.patternkey,
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
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  Future<void> _initControllers() async {
    _patternController = audio_waveforms.PlayerController();
    _recordingController = audio_waveforms.RecorderController()
      ..androidEncoder = audio_waveforms.AndroidEncoder.opus
      ..androidOutputFormat = audio_waveforms.AndroidOutputFormat.ogg
      ..iosEncoder = audio_waveforms.IosEncoder.kAudioFormatOpus;
    _recordingPlayerController = audio_waveforms.PlayerController();
    await _loadPatternAudio();
  }

  Future<void> _loadPatternAudio() async {
    final assetPath = widget.pattern['audioPath'];
    if (assetPath == null) return;

    try {
      final byteData = await DefaultAssetBundle.of(context).load('assets/$assetPath');
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$assetPath');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      final style = audio_waveforms.PlayerWaveStyle(
        scaleFactor: 100,
        scrollScale: 1.2,
      );
      final samples = style.getSamplesForWidth(MediaQuery.sizeOf(context).width / 1.2);

      await _patternController.preparePlayer(
        path: file.path,
        shouldExtractWaveform: true,
        noOfSamples: samples,
      );
      await _patternController.setFinishMode(finishMode: audio_waveforms.FinishMode.pause);

      _patternController.onCompletion.listen((_) {
        setState(() => _isPatternPlaying = false);
      });
    } catch (e) {
      debugPrint('Error loading audio: $e');
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    if (await _recorder.hasPermission()) {
      final tempDir = await getTemporaryDirectory();
      _recordingPath = '${tempDir.path}/recording.ogg'; 
      await _recordingController.record(path: _recordingPath);
      setState(() => _isRecording = true);
    }
  }

  Future<void> _stopRecording() async {
    await _recordingController.stop();
    if (_recordingPath != null) {
      final style = audio_waveforms.PlayerWaveStyle(
        scaleFactor: 100,
        scrollScale: 1.2,
      );
      final samples = style.getSamplesForWidth(MediaQuery.sizeOf(context).width / 1.2);
      await _recordingPlayerController.preparePlayer(
        path: _recordingPath!,
        shouldExtractWaveform: true,
        noOfSamples: samples,
      );
      await _recordingPlayerController.setFinishMode(finishMode: audio_waveforms.FinishMode.pause);
    }
    setState(() => _isRecording = false);
  }

  Future<void> _playRecording() async {
    if (_recordingPath == null) return;
    if (_isRecordingPlaying) {
      await _recordingPlayerController.pausePlayer();
    } else {
      await _patternController.stopPlayer();
      await _recordingPlayerController.startPlayer();
      setState(() => _isPatternPlaying = false);
    }
    setState(() => _isRecordingPlaying = !_isRecordingPlaying);
  }

  Future<void> _togglePatternPlayback() async {
    if (_isPatternPlaying) {
      await _patternController.pausePlayer();
    } else {
      await _recordingPlayerController.stopPlayer();
      await _patternController.startPlayer();
      setState(() => _isRecordingPlaying = false);
    }
    setState(() => _isPatternPlaying = !_isPatternPlaying);
  }

  Future<void> _setPlaybackSpeed(double speed) async {
    setState(() => _playbackSpeed = speed);
    await _patternController.setRate(speed);
  }

  Future<void> _submitRecording() async {
    if (_recordingPath == null || _isSubmitting) {
      print('Debug: Recording path is null or submission is already in progress.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      print('Debug: Submission started.');
    });

    try {
      final localIp = globals.localIP;
      print('Debug: Local IP is $localIp.');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://$localIp:5001/api/score'),
      );

      // Add patternKey
      final patternKey = widget.patternkey ?? 'unknown_pattern';
      request.fields['PatternKey'] = patternKey;
      print('Debug: PatternKey set to $patternKey.');

     // Add audio file (full path is logged, file content is sent)
      print('Debug: Audio file path: $_recordingPath');
      final file = File(_recordingPath!);
      final fileLength = await file.length();
      print('Debug: Audio file size: $fileLength bytes');
      final audioFile = await http.MultipartFile.fromPath('AudioPath', _recordingPath!);
      print('Debug: Audio file added to request with Content-Type: ${audioFile.contentType}');
      request.files.add(audioFile);
      print('Debug: Audio file added from path $_recordingPath.');

      final response = await request.send();
      print('Debug: Request sent. Status code: ${response.statusCode}.');

      final responseBody = await response.stream.bytesToString();
      print('Debug: Response body: $responseBody.');
      print('Debug: Response status code: ${response.statusCode}.');
      if (response.statusCode == 200) {
        final scoreResponse = ScoreResponse.fromJson(jsonDecode(responseBody));
        print('Debug: ScoreResponse parsed successfully.');
        _showResultsDialog(scoreResponse);
      } else {
        print('Debug: Server error with status code ${response.statusCode}.');
        _showErrorSnackBar('Błąd serwera: ${response.statusCode}');
      }
    } catch (e) {
      print('Debug: Exception occurred: $e.');
      _showErrorSnackBar('Błąd podczas wysyłania nagrania: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
        print('Debug: Submission finished.');
      });
    }
  }

  void _showResultsDialog(ScoreResponse response) {
    showDialog(
      context: context,
      builder: (context) {
        final appColors = Theme.of(context).extension<AppColors>()!;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: appColors.cardColor,
          title: Text(
            'Wyniki oceny',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: appColors.primaryColor,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wynik: ${response.score}',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: appColors.accentColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Zaakceptowano: ${response.beatAccepted ? "Tak" : "Nie"}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: response.beatAccepted ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'MSE: ${response.mse >= 0 ? response.mse.toStringAsFixed(3) : "N/A"} s',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: appColors.secondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'SE: ${response.se >= 0 ? response.se.toStringAsFixed(3) : "N/A"} s',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: appColors.secondaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                _DetailedResultsSection(response: response),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Zamknij',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: appColors.accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: appColors.accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'Ponów',
          textColor: Colors.white,
          onPressed: _submitRecording,
        ),
      ),
    );
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
    final pattern = widget.pattern;
    final patternList = pattern['pattern'] as List<dynamic>? ?? [];
    final description = pattern['description'] ?? 'Brak opisu';
    final bpm = pattern['base_BPM']?.toString() ?? 'N/A';
    final appColors = Theme.of(context).extension<AppColors>()!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 800;

    return Scaffold(
      backgroundColor: appColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          pattern['name'] ?? 'Pattern',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                appColors.patternGradientStart,
                appColors.patternGradientEnd,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
        ),
        elevation: 4,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: screenWidth > 600 ? 600 : screenWidth * 0.92),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PatternDescriptionSection(description: description, bpm: bpm),
                const SizedBox(height: 16),
                _PatternNotationSection(patternList: patternList, sounds: widget.sounds),
                const SizedBox(height: 16),
                _PatternPlayerSection(
                  controller: _patternController,
                  isPlaying: _isPatternPlaying,
                  playbackSpeed: _playbackSpeed,
                  onPlayPressed: _togglePatternPlayback,
                  onSpeedChanged: _setPlaybackSpeed,
                  isSmallScreen: isSmallScreen,
                ),
                const SizedBox(height: 16),
                _RecordingSection(
                  recorderController: _recordingController,
                  playerController: _recordingPlayerController,
                  isRecording: _isRecording,
                  isPlaying: _isRecordingPlaying,
                  onRecordPressed: _toggleRecording,
                  onPlayPressed: _playRecording,
                  onSubmitPressed: _submitRecording,
                  hasRecording: _recordingPath != null,
                  isSubmitting: _isSubmitting,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PatternDescriptionSection extends StatelessWidget {
  final String description;
  final String bpm;

  const _PatternDescriptionSection({
    required this.description,
    required this.bpm,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: appColors.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Opis',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: appColors.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: description == 'Brak opisu' ? appColors.navUnselectedColor : appColors.secondaryColor,
                fontStyle: description == 'Brak opisu' ? FontStyle.italic : FontStyle.normal,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'BPM: $bpm',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: bpm == 'N/A' ? appColors.navUnselectedColor : appColors.secondaryColor,
                fontStyle: bpm == 'N/A' ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatternNotationSection extends StatelessWidget {
  final List<dynamic> patternList;
  final List<Map<String, dynamic>> sounds;

  const _PatternNotationSection({
    required this.patternList,
    required this.sounds,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notacja patternu',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: appColors.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: appColors.cardColor,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: patternList.isEmpty
                ? Text(
                    'Brak notacji',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: appColors.navUnselectedColor,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: patternList.map((note) {
                      final sound = sounds.firstWhere(
                        (s) => s['notation'] == note,
                        orElse: () => <String, dynamic>{},
                      );
                      final isClickable = sound.isNotEmpty;

                      return ActionChip(
                        label: Text(
                          note.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isClickable ? appColors.accentColor : appColors.navUnselectedColor,
                          ),
                        ),
                        backgroundColor: isClickable ? appColors.accentColor.withOpacity(0.1) : appColors.cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isClickable ? appColors.accentColor : appColors.navUnselectedColor,
                          ),
                        ),
                        onPressed: isClickable
                            ? () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SoundDetailsPage(sound: sound),
                                  ),
                                )
                            : null,
                      );
                    }).toList(),
                  ),
          ),
        ),
      ],
    );
  }
}

class _PatternPlayerSection extends StatelessWidget {
  final audio_waveforms.PlayerController controller;
  final bool isPlaying;
  final double playbackSpeed;
  final VoidCallback onPlayPressed;
  final ValueChanged<double> onSpeedChanged;
  final bool isSmallScreen;

  const _PatternPlayerSection({
    required this.controller,
    required this.isPlaying,
    required this.playbackSpeed,
    required this.onPlayPressed,
    required this.onSpeedChanged,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Odtwórz pattern',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: appColors.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: appColors.cardColor,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                audio_waveforms.AudioFileWaveforms(
                  playerController: controller,
                  size: const Size(double.infinity, 60),
                  waveformType: audio_waveforms.WaveformType.fitWidth,
                  playerWaveStyle: audio_waveforms.PlayerWaveStyle(
                    liveWaveColor: appColors.waveformLiveColor,
                    fixedWaveColor: appColors.waveformFixedColor,
                    seekLineColor: appColors.waveformSeekColor,
                    seekLineThickness: 2,
                    scaleFactor: 100,
                    scrollScale: 10,
                    showSeekLine: true,
                    showBottom: true,
                    showTop: true,
                  ),
                ),
                const SizedBox(height: 16),
                if (isSmallScreen) ...[
                  _PlaybackButton(
                    icon: isPlaying ? Icons.pause : Icons.play_arrow,
                    label: isPlaying ? 'Pauza' : 'Odtwórz',
                    color: appColors.buttonPrimaryColor,
                    onPressed: onPlayPressed,
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
  final VoidCallback onSubmitPressed;
  final bool hasRecording;
  final bool isSubmitting;

  const _RecordingSection({
    required this.recorderController,
    required this.playerController,
    required this.isRecording,
    required this.isPlaying,
    required this.onRecordPressed,
    required this.onPlayPressed,
    required this.onSubmitPressed,
    required this.hasRecording,
    required this.isSubmitting,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nagraj swoje próby',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: appColors.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: appColors.cardColor,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                audio_waveforms.AudioWaveforms(
                  recorderController: recorderController,
                  size: const Size(double.infinity, 60),
                  waveStyle: audio_waveforms.WaveStyle(
                    waveColor: appColors.waveformLiveColor,
                    showMiddleLine: false,
                  ),
                ),
                if (hasRecording) ...[
                  const SizedBox(height: 16),
                  audio_waveforms.AudioFileWaveforms(
                    playerController: playerController,
                    size: const Size(double.infinity, 60),
                    waveformType: audio_waveforms.WaveformType.fitWidth,
                    playerWaveStyle: audio_waveforms.PlayerWaveStyle(
                      liveWaveColor: appColors.waveformLiveColor,
                      fixedWaveColor: appColors.waveformFixedColor,
                      seekLineColor: appColors.waveformSeekColor,
                      seekLineThickness: 2,
                      scaleFactor: 1000,
                      scrollScale: 40,
                      showSeekLine: true,
                      showBottom: true,
                      showTop: true,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    _PlaybackButton(
                      icon: isRecording ? Icons.stop : Icons.mic,
                      label: isRecording ? 'Zatrzymaj' : 'Nagraj',
                      color: appColors.buttonPrimaryColor,
                      onPressed: onRecordPressed,
                    ),
                    if (hasRecording) ...[
                      _PlaybackButton(
                        icon: isPlaying ? Icons.pause : Icons.play_arrow,
                        label: isPlaying ? 'Pauza' : 'Odtwórz',
                        color: appColors.buttonPrimaryColor,
                        onPressed: onPlayPressed,
                      ),
                      _PlaybackButton(
                        icon: isSubmitting ? Icons.hourglass_empty : Icons.send,
                        label: isSubmitting ? 'Wysyłanie...' : 'Wyślij do oceny',
                        color: isSubmitting ? appColors.navUnselectedColor : appColors.buttonPrimaryColor,
                        onPressed: isSubmitting ? null : onSubmitPressed,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailedResultsSection extends StatefulWidget {
  final ScoreResponse response;

  const _DetailedResultsSection({required this.response});

  @override
  _DetailedResultsSectionState createState() => _DetailedResultsSectionState();
}

class _DetailedResultsSectionState extends State<_DetailedResultsSection> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(
          onPressed: () => setState(() => _showDetails = !_showDetails),
          child: Text(
            _showDetails ? 'Ukryj szczegóły' : 'Pokaż szczegóły',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: appColors.accentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (_showDetails) ...[
          Text(
            'StepMSE: ${widget.response.stepMse >= 0 ? widget.response.stepMse.toStringAsFixed(3) : "N/A"}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: appColors.secondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'StepSE: ${widget.response.stepSe >= 0 ? widget.response.stepSe : "N/A"}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: appColors.secondaryColor,
            ),
          ),
        ],
      ],
    );
  }
}

class _PlaybackButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  const _PlaybackButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 24, color: Colors.white),
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        elevation: 4,
      ),
      onPressed: onPressed,
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

    return IconButton(
      icon: Text(
        '${speed}x',
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : appColors.secondaryColor,
        ),
      ),
      style: IconButton.styleFrom(
        backgroundColor: isSelected ? appColors.buttonPrimaryColor : appColors.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(10),
      ),
      onPressed: () => onChanged(speed),
    );
  }
}