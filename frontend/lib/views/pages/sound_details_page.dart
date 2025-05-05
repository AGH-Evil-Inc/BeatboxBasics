import 'dart:io';
import 'package:app/main.dart';
import 'package:audio_waveforms/audio_waveforms.dart' as audio_waveforms;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as yt;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
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
  int _playCount = 0; // Licznik odtworzeń dla grywalizacji
  bool _hasInternet = true; // Flaga dla połączenia internetowego

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
      final byteData = await rootBundle.load('assets/$assetPath');
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$assetPath');
      await file.create(recursive: true);
      await file.writeAsBytes(byteData.buffer.asUint8List());

      await _playerController.preparePlayer(
        path: file.path,
        shouldExtractWaveform: true,
      );

      await _playerController.onCompletion.listen((_) {
        setState(() => _isPlaying = false);
        _showCompletionSnackbar();
      });
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
          )..addListener(() {
              if (_youtubeControllers.any((controller) => controller.value.playerState == yt.PlayerState.ended)) {
                _showVideoCompletionSnackbar();
              }
            }),
        );
      }
    }
  }

  void _showCompletionSnackbar() {
    final appColors = Theme.of(context).extension<AppColors>()!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Dobra robota! Odczarowałeś ten dźwięk! 🎶',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: appColors.accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showVideoCompletionSnackbar() {
    final appColors = Theme.of(context).extension<AppColors>()!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Obejrzałeś tutorial! Szacun! 📹',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: appColors.accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _togglePlayback() async {
    await AudioPlayer().play(AssetSource('audio/click.mp3'));
    Vibration.vibrate(pattern: [0, 50, 50, 50]); // Wzorzec wibracji
    if (_isPlaying) {
      await _playerController.pausePlayer();
    } else {
      await _playerController.startPlayer();
      setState(() {
        _playCount++;
        if (_playCount == 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '3 razy z rzędu! Masz to w małym palcu! 💪',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              backgroundColor: Theme.of(context).extension<AppColors>()!.accentColor,
            ),
          );
        }
      });
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  Future<void> _setPlaybackSpeed(double speed) async {
    await AudioPlayer().play(AssetSource('audio/click.mp3'));
    Vibration.vibrate(duration: 30);
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: appColors.cardColor,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                sound['name'] ?? 'Dźwięk',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: appColors.primaryColor,
                ),
              ),
              background: Container(
                color: appColors.cardColor,
                child: Center(
                  child: Icon(
                    Icons.music_note,
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
                      _SoundNotationSection(notation: sound['notation'] ?? 'Brak notacji')
                          .animate(),
                      const SizedBox(height: 32),
                      _SoundDescriptionSection(description: sound['description'] ?? 'Brak opisu')
                          .animate(),
                      const SizedBox(height: 32),
                      _SoundPlayerSection(
                        controller: _playerController,
                        isPlaying: _isPlaying,
                        playbackSpeed: _playbackSpeed,
                        onPlayPressed: _togglePlayback,
                        onSpeedChanged: _setPlaybackSpeed,
                      ),
                      if (sound['tips'] != null) ...[
                        const SizedBox(height: 32),
                        _SoundTipsSection(tips: sound['tips']).animate(),
                      ],
                      if (_youtubeControllers.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        _hasInternet
                            ? _SoundVideosSection(controllers: _youtubeControllers)
                                .animate()
                            : _NoInternetSection(
                                onRetry: () async {
                                  await AudioPlayer().play(AssetSource('audio/click.mp3'));
                                  Vibration.vibrate(duration: 50);
                                  final connectivityResult = await Connectivity().checkConnectivity();
                                  setState(() {
                                    _hasInternet = connectivityResult != ConnectivityResult.none;
                                  });
                                },
                              ).animate(),
                      ],
                    ],
                  ).animate().fadeIn(duration: 600.ms),
                ),
              ]),
            ),
          ),
        ],
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

    return GestureDetector(
      onTap: () async {
        await AudioPlayer().play(AssetSource('audio/click.mp3'));
        Vibration.vibrate(pattern: [0, 50, 50, 50]);
        _showNotationDialog(context);
      },
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            topRight: const Radius.circular(8),
            bottomLeft: const Radius.circular(8),
            bottomRight: const Radius.circular(24),
          ),
        ),
        color: appColors.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notacja',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: appColors.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                notation,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: notation == 'Brak notacji' ? appColors.navUnselectedColor : appColors.accentColor,
                  fontStyle: notation == 'Brak notacji' ? FontStyle.italic : FontStyle.normal,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Dotknij, by powiększyć',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: appColors.secondaryColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
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
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: appColors.cardColor,
        title: Text(
          'Notacja',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: appColors.primaryColor,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            notation,
            style: GoogleFonts.poppins(
              fontSize: 22,
              color: appColors.secondaryColor,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await AudioPlayer().play(AssetSource('audio/click.mp3'));
              Vibration.vibrate(duration: 50);
              Navigator.pop(context);
            },
            child: Text(
              'Zamknij',
              style: GoogleFonts.poppins(
                fontSize: 16,
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
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(8),
          topRight: const Radius.circular(24),
          bottomLeft: const Radius.circular(24),
          bottomRight: const Radius.circular(8),
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
                fontWeight: FontWeight.bold,
                color: appColors.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: appColors.secondaryColor,
                height: 1.5,
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
            fontWeight: FontWeight.bold,
            color: appColors.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: appColors.cardColor,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                audio_waveforms.AudioFileWaveforms(
                  playerController: controller,
                  size: const Size(double.infinity, 60),
                  waveformType: audio_waveforms.WaveformType.fitWidth,
                  playerWaveStyle: audio_waveforms.PlayerWaveStyle(
                    liveWaveColor: appColors.accentColor,
                    fixedWaveColor: appColors.navUnselectedColor,
                    seekLineColor: appColors.accentColor,
                    seekLineThickness: 2,
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
                  // Dla większych ekranów - przyciski w rzędzie
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
          'Pro tipy',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: appColors.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(24),
              topRight: const Radius.circular(8),
              bottomLeft: const Radius.circular(8),
              bottomRight: const Radius.circular(24),
            ),
          ),
          color: appColors.cardColor,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: tips
                  .asMap()
                  .entries
                  .map<Widget>((entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: appColors.accentColor,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.value.toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: appColors.secondaryColor,
                                  height: 1.5,
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
            fontWeight: FontWeight.bold,
            color: appColors.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        ...controllers.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: appColors.cardColor,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
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
                  onReady: () async {
                    await AudioPlayer().play(AssetSource('audio/click.mp3'));
                    Vibration.vibrate(duration: 50);
                  },
                ),
              ),
            ),
          )
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
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(8),
          topRight: const Radius.circular(24),
          bottomLeft: const Radius.circular(24),
          bottomRight: const Radius.circular(8),
        ),
      ),
      color: appColors.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tutoriale na YouTube',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: appColors.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Oj, brak neta! 😕 Połącz się z internetem, by zobaczyć tutoriale.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: appColors.secondaryColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: appColors.buttonPrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                elevation: 4,
              ),
              child: Text(
                'Sprawdź połączenie',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack, begin: const Offset(0.95, 0.95)),
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
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack, begin: const Offset(0.95, 0.95)),
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
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack, begin: const Offset(0.95, 0.95));
  }
}