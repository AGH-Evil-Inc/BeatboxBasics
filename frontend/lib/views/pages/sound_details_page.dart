import 'dart:io';
import 'package:app/main.dart';
import 'package:audio_waveforms/audio_waveforms.dart' as audio_waveforms;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as yt;
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SoundDetailsPage extends StatefulWidget {
  final Map<String, dynamic> sound;

  const SoundDetailsPage({super.key, required this.sound});

  @override
  State<SoundDetailsPage> createState() => _SoundDetailsPageState();
}

class _SoundDetailsPageState extends State<SoundDetailsPage> {
  late final audio_waveforms.PlayerController _playerController;
  final List<yt.YoutubePlayerController> _youtubeControllers = [];
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;
  bool _hasInternet = true;

  @override
  void initState() {
    super.initState();
    _playerController = audio_waveforms.PlayerController();
    _initAudioPlayer();
    _checkConnectivity();
    _initYoutubePlayers();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _hasInternet = connectivityResult != ConnectivityResult.none;
    });
  }

  Future<void> _initAudioPlayer() async {
    final assetPath = widget.sound['audioPath'];
    if (assetPath == null) return;

    try {
      final byteData = await DefaultAssetBundle.of(context).load('assets/$assetPath');
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$assetPath');
      await file.create(recursive: true);
      await file.writeAsBytes(byteData.buffer.asUint8List());
      final style = audio_waveforms.PlayerWaveStyle(
        scaleFactor: 100,
        scrollScale: 1.2,
      );
      final samples = style.getSamplesForWidth(MediaQuery.sizeOf(context).width / 1.2);

      await _playerController.preparePlayer(
        path: file.path,
        shouldExtractWaveform: true,
        noOfSamples: samples,
      );
      await _playerController.setFinishMode(finishMode: audio_waveforms.FinishMode.pause);
      _playerController.updateFrequency = audio_waveforms.UpdateFrequency.high;
    } catch (e) {
      debugPrint('Error loading audio: $e');
    }
  }

  void _initYoutubePlayers() {
    final links = widget.sound['links'] as List<dynamic>? ?? [];
    for (var link in links) {
      final videoId = yt.YoutubePlayer.convertUrlToId(link.toString());
      if (videoId != null) {
        _youtubeControllers.add(
          yt.YoutubePlayerController(
            initialVideoId: videoId,
            flags: const yt.YoutubePlayerFlags(
              autoPlay: false,
              hideThumbnail: true,
            ),
          ),
        );
      }
    }
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _playerController.pausePlayer();
    } else {
      await _playerController.startPlayer();
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  Future<void> _setPlaybackSpeed(double speed) async {
    setState(() => _playbackSpeed = speed);
    await _playerController.setRate(speed);
  }

  @override
  void dispose() {
    _playerController.dispose();
    for (var controller in _youtubeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final sound = widget.sound;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: appColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          sound['name'] ?? 'Dźwięk',
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
                appColors.soundGradientStart,
                appColors.soundGradientEnd,
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
                _SoundNotationSection(notation: sound['notation'] ?? 'Brak notacji'),
                const SizedBox(height: 16),
                _SoundDescriptionSection(description: sound['description'] ?? 'Brak opisu'),
                const SizedBox(height: 16),
                _SoundPlayerSection(
                  controller: _playerController,
                  isPlaying: _isPlaying,
                  playbackSpeed: _playbackSpeed,
                  onPlayPressed: _togglePlayback,
                  onSpeedChanged: _setPlaybackSpeed,
                ),
                if (sound['tips'] != null) ...[
                  const SizedBox(height: 16),
                  _SoundTipsSection(tips: sound['tips']),
                ],
                if (_youtubeControllers.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _hasInternet
                      ? _SoundVideosSection(controllers: _youtubeControllers)
                      : _NoInternetSection(
                          onRetry: () async {
                            final connectivityResult = await Connectivity().checkConnectivity();
                            setState(() {
                              _hasInternet = connectivityResult != ConnectivityResult.none;
                            });
                          },
                        ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SoundNotationSection extends StatelessWidget {
  final String notation;

  const _SoundNotationSection({required this.notation});

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
              'Notacja',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: appColors.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              notation,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: notation == 'Brak notacji' ? appColors.navUnselectedColor : appColors.accentColor,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _showNotationDialog(context),
                child: Text(
                  'Powiększ',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: appColors.accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotationDialog(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: appColors.cardColor,
        title: Text(
          'Notacja',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: appColors.primaryColor,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            notation,
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: appColors.secondaryColor,
            ),
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
      ),
    );
  }
}

class _SoundDescriptionSection extends StatelessWidget {
  final String description;

  const _SoundDescriptionSection({required this.description});

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
                color: appColors.secondaryColor,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoundPlayerSection extends StatelessWidget {
  final audio_waveforms.PlayerController controller;
  final bool isPlaying;
  final double playbackSpeed;
  final VoidCallback onPlayPressed;
  final ValueChanged<double> onSpeedChanged;

  const _SoundPlayerSection({
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
          'Odtwórz dźwięk',
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

class _SoundTipsSection extends StatelessWidget {
  final List<dynamic> tips;

  const _SoundTipsSection({required this.tips});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wskazówki',
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
              children: tips
                  .asMap()
                  .entries
                  .map<Widget>((entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: appColors.accentColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.value.toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: appColors.secondaryColor,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _SoundVideosSection extends StatelessWidget {
  final List<yt.YoutubePlayerController> controllers;

  const _SoundVideosSection({required this.controllers});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tutoriale na YouTube',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: appColors.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        ...controllers.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: appColors.cardColor,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: yt.YoutubePlayer(
                      controller: entry.value,
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: appColors.accentColor,
                      progressColors: yt.ProgressBarColors(
                        playedColor: appColors.accentColor,
                        handleColor: appColors.accentColor,
                      ),
                      bottomActions: [
                        yt.CurrentPosition(),
                        yt.ProgressBar(isExpanded: true),
                        yt.RemainingDuration(),
                        yt.FullScreenButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      ],
    );
  }
}

class _NoInternetSection extends StatelessWidget {
  final VoidCallback onRetry;

  const _NoInternetSection({required this.onRetry});

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
              'Tutoriale na YouTube',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: appColors.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Brak połączenia z internetem. Połącz się, by zobaczyć tutoriale.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: appColors.secondaryColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColors.buttonPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  'Sprawdź połączenie',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaybackButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _PlaybackButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
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