import 'dart:convert';
import 'dart:io';
import 'package:app/main.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/io_client.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibration/vibration.dart';
import 'sound_details_page.dart';

class SoundPage extends StatefulWidget {
  const SoundPage({super.key});

  @override
  State<SoundPage> createState() => _SoundPageState();
}

class _SoundPageState extends State<SoundPage> {
  final AudioPlayer audioPlayer = AudioPlayer();
  List<Map<String, dynamic>> items = [];
  bool isLoading = true;
  bool hasError = false;
  bool isPlaying = false;
  String? currentlyPlayingPath;
  int playedSounds = 0;

  @override
  void initState() {
    super.initState();
    fetchSounds();
  }

  Future<void> fetchSounds() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    String url = Platform.isAndroid || Platform.isIOS
        ? "https://192.168.218.107:5001/api/sound"
        : "https://localhost:5001/api/sound";

    try {
      final ioc = HttpClient();
      ioc.badCertificateCallback = (cert, host, port) => true;
      final http = IOClient(ioc);

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          items = data.entries
              .map((entry) => {
                    'key': entry.key,
                    ...entry.value as Map<String, dynamic>,
                    'isPlayed': false,
                  })
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
        debugPrint('Failed to load sounds: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      debugPrint("Error: $e");
    }
  }

  Future<void> playSound(String path, int index) async {
    try {
      await AudioPlayer().play(AssetSource('audio/click.mp3'));
      Vibration.vibrate(pattern: [0, 50, 50, 50]);
      if (isPlaying && currentlyPlayingPath == path) {
        await audioPlayer.stop();
        setState(() {
          isPlaying = false;
          currentlyPlayingPath = null;
        });
      } else {
        await audioPlayer.stop();
        await audioPlayer.play(AssetSource(path));
        setState(() {
          isPlaying = true;
          currentlyPlayingPath = path;
          if (!items[index]['isPlayed']) {
            items[index]['isPlayed'] = true;
            playedSounds = items.where((item) => item['isPlayed'] == true).length;
          }
        });
        audioPlayer.onPlayerComplete.listen((_) {
          setState(() {
            isPlaying = false;
            currentlyPlayingPath = null;
          });
        });
      }
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  Widget _buildErrorState() {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: appColors.errorColor,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Coś poszło nie tak! 😕',
            style: GoogleFonts.poppins(
              fontSize: 20,
              color: appColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nie udało się załadować dźwięków.',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: appColors.secondaryColor,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await AudioPlayer().play(AssetSource('audio/click.mp3'));
              Vibration.vibrate(pattern: [0, 50, 50, 50]);
              fetchSounds();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: appColors.buttonPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Spróbuj ponownie',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildLoadingState() {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              color: appColors.accentColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Ładujemy dźwięki...',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: appColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildSoundList() {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final screenWidth = MediaQuery.of(context).size.width;

    return ListView.separated(
      padding: EdgeInsets.all(screenWidth * 0.05),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        final name = item['name'] ?? 'Brak nazwy';
        final path = item['audioPath'] ?? '';
        final description = item['description'] ?? 'Dowiedz się więcej!';
        final notation = item['notation'] ?? 'Brak notacji';
        final isPlayed = item['isPlayed'] ?? false;

        return Material(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(8),
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(24),
          ),
          color: appColors.cardColor,
          elevation: 6,
          child: InkWell(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(8),
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(24),
            ),
            onTap: () async {
              await AudioPlayer().play(AssetSource('audio/click.mp3'));
              Vibration.vibrate(pattern: [0, 50, 50, 50]);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SoundDetailsPage(sound: item),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: appColors.accentColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.music_note,
                      color: appColors.accentColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: appColors.primaryColor,
                                ),
                              ),
                            ),
                            if (isPlayed)
                              Icon(
                                Icons.check_circle,
                                color: appColors.accentColor,
                                size: 20,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description.length > 60
                              ? '${description.substring(0, 60)}...'
                              : description,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: appColors.secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: appColors.accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            notation,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: appColors.accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: isPlaying && path == currentlyPlayingPath
                          ? const Icon(Icons.pause_rounded, key: ValueKey('pause'))
                          : const Icon(Icons.play_arrow_rounded, key: ValueKey('play')),
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: appColors.accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                    ),
                    onPressed: () => playSound(path, index),
                  ).animate().scale(
                        duration: 400.ms,
                        curve: Curves.easeOutBack,
                        begin: const Offset(0.95, 0.95),
                      ),
                ],
              ),
            ),
          ),
        ).animate();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: appColors.backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 160,
              floating: true,
              pinned: true,
              snap: false,
              backgroundColor: appColors.accentColor,
              elevation: 6,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Rozkmin dźwięki!',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                centerTitle: true,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
                  onPressed: () async {
                    await AudioPlayer().play(AssetSource('audio/click.mp3'));
                    Vibration.vibrate(pattern: [0, 50, 50, 50]);
                    fetchSounds();
                  },
                ).animate().scale(
                      duration: 400.ms,
                      curve: Curves.easeOutBack,
                      begin: const Offset(0.95, 0.95),
                    ),
              ],
            ),
          ];
        },
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                'Odtworzyłeś $playedSounds/${items.length} dźwięków!',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: appColors.accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ).animate().fadeIn(duration: 500.ms),
            Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: screenWidth > 600 ? 600 : screenWidth * 0.9),
                child: isLoading
                    ? _buildLoadingState()
                    : hasError
                        ? _buildErrorState()
                        : _buildSoundList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}