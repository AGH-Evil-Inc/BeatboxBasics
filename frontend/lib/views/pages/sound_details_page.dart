import 'dart:io';
import 'package:app/main.dart';
import 'package:audio_waveforms/audio_waveforms.dart' as audio_waveforms;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SoundDetailsPage extends StatefulWidget {
  final Map<String, dynamic> sound;

  const SoundDetailsPage({super.key, required this.sound});

  @override
  State<SoundDetailsPage> createState() => _SoundDetailsPageState();
}

class _SoundDetailsPageState extends State<SoundDetailsPage> {
  final List<YoutubePlayerController> _controllers = [];
  late final audio_waveforms.PlayerController playerController;
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _initYoutubeControllers();
    _initAudioPlayer();
  }

  void _initYoutubeControllers() {
    if (widget.sound['links'] != null) {
      for (var link in widget.sound['links']) {
        final videoId = YoutubePlayer.convertUrlToId(link);
        if (videoId != null) {
          _controllers.add(
            YoutubePlayerController(
              initialVideoId: videoId,
              flags: const YoutubePlayerFlags(
                autoPlay: false,
                hideThumbnail: true,
                disableDragSeek: true,
                showLiveFullscreenButton: false,
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _initAudioPlayer() async {
    playerController = audio_waveforms.PlayerController();
    final assetPath = widget.sound['audioPath'];
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

      await playerController.preparePlayer(
        path: file.path,
        shouldExtractWaveform: true,
      );

      playerController.onCompletion.listen((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Świetnie! Posłuchałeś dźwięku!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Theme.of(context).extension<AppColors>()!.buttonPrimaryColor,
            duration: const Duration(seconds: 2),
          ),
        );
        setState(() => _isPlaying = false);
      });

      setState(() {});
    } catch (e) {
      debugPrint('Błąd podczas ładowania pliku audio: $e');
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    playerController.dispose();
    super.dispose();
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: appColors.primaryColor, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: appColors.primaryColor,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildNotationCard() {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final notation = widget.sound['notation'] ?? 'Brak notacji';
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Zapis w notacji:',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
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
                  style: GoogleFonts.poppins(color: appColors.highlightColor),
                ),
              ),
            ],
          ),
        );
      },
      child: Card(
        color: appColors.cardColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Zapis w notacji:',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: appColors.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                notation,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: notation == 'Brak notacji'
                      ? appColors.navUnselectedColor
                      : appColors.soundColor,
                  fontStyle: notation == 'Brak notacji'
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dotknij, aby powiększyć',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: appColors.highlightColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().slideY(begin: 0.2, end: 0, duration: 500.ms);
  }

  Widget _buildAudioPlayer() {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final audioPath = widget.sound['audioPath'];
    if (audioPath == null) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Brak dostępnego audio',
            style: GoogleFonts.poppins(color: appColors.secondaryColor),
          ),
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
              'Posłuchaj dźwięku',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: appColors.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            audio_waveforms.AudioFileWaveforms(
              playerController: playerController,
              size: const Size(double.infinity, 50),
              waveformType: audio_waveforms.WaveformType.fitWidth,
              playerWaveStyle: audio_waveforms.PlayerWaveStyle(
                liveWaveColor: appColors.waveformLiveColor,
                fixedWaveColor: appColors.waveformFixedColor,
                scaleFactor: 50,
                showSeekLine: true,
                seekLineColor: appColors.waveformSeekColor,
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
                    if (_isPlaying)
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(appColors.waveformFixedColor),
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
                        backgroundColor: appColors.buttonPrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        playerController.startPlayer();
                        setState(() => _isPlaying = true);
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
                    backgroundColor: appColors.buttonSecondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    playerController.pausePlayer();
                    setState(() => _isPlaying = false);
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

  Widget _buildSpeedButton({
    required double speed,
    required String label,
    required IconData icon,
  }) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final isSelected = _playbackSpeed == speed;
    return ElevatedButton.icon(
      icon: Icon(
        icon,
        color: isSelected ? Colors.white : appColors.highlightColor,
        size: 20,
      ),
      label: Text(
        label,
        style: GoogleFonts.poppins(
          color: isSelected ? Colors.white : appColors.highlightColor,
          fontSize: 12,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? appColors.buttonPrimaryColor : appColors.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        minimumSize: const Size(80, 40),
      ),
      onPressed: () {
        setState(() {
          _playbackSpeed = speed;
          playerController.setRate(speed);
        });
      },
    );
  }

  Widget _buildDescriptionCard() {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final description = widget.sound['description'] ?? 'Brak opisu';
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
                color: appColors.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: appColors.secondaryColor,
              ),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.2, end: 0, duration: 500.ms);
  }

  Widget _buildTipsSection() {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final tips = widget.sound['tips'] ?? [];
    if (tips.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Wskazówki', Icons.lightbulb_outline),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: tips
                  .asMap()
                  .entries
                  .map<Widget>((entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.star_border,
                              color: appColors.accentColor,
                              size: 24,
                            ).animate().scale(
                                  begin: Offset(0.8, 0.8),
                                  end: Offset(1.0, 1.0),
                                  duration: 300.ms,
                                  delay: (100 * entry.key).ms,
                                ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: appColors.secondaryColor,
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
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildLinksSection() {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final links = widget.sound['links'] ?? [];
    if (links.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Filmy', Icons.video_library),
        ..._controllers.map((controller) => Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: YoutubePlayer(
                  controller: controller,
                  showVideoProgressIndicator: true,
                  bottomActions: [
                    CurrentPosition(),
                    ProgressBar(isExpanded: true),
                    RemainingDuration(),
                  ],
                ),
              ),
            )),
        ...links
            .where((link) => YoutubePlayer.convertUrlToId(link) == null)
            .map<Widget>((link) => Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Nieprawidłowy link YouTube: $link',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: appColors.errorColor,
                      ),
                    ),
                  ),
                )),
      ],
    ).animate().fadeIn(duration: 500.ms);
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final sound = widget.sound;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              appColors.gradientStartColor,
              appColors.gradientEndColor,
            ],
          ),
        ),
        child: Column(
          children: [
            AppBar(
              title: Text(
                sound['name'] ?? 'Brak nazwy',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              backgroundColor: appColors.soundColor,
              shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              elevation: 4,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      appColors.soundColor,
                      appColors.accentColor,
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
                    _buildNotationCard(),
                    const SizedBox(height: 16),
                    _buildDescriptionCard(),
                    const SizedBox(height: 16),
                    _buildAudioPlayer(),
                    const SizedBox(height: 16),
                    _buildTipsSection(),
                    const SizedBox(height: 16),
                    _buildLinksSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}