import 'dart:convert';
import 'dart:io';
import 'package:app/main.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/io_client.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibration/vibration.dart';
import 'pattern_details_page.dart';

class PatternPage extends StatefulWidget {
  const PatternPage({super.key});

  @override
  State<PatternPage> createState() => _PatternPageState();
}

class _PatternPageState extends State<PatternPage> {
  final AudioPlayer audioPlayer = AudioPlayer();
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> sounds = [];
  bool isLoading = true;
  bool hasError = false;
  bool isPlaying = false;
  String? currentlyPlayingPath;
  int playedPatterns = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      await Future.wait([fetchPatterns(), fetchSounds()]);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      debugPrint("Error fetching data: $e");
    }
  }

  Future<void> fetchPatterns() async {
    String url = Platform.isAndroid || Platform.isIOS
        ? "https://192.168.218.107:5001/api/pattern"
        : "https://localhost:5001/api/pattern";

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
      });
    } else {
      throw Exception('Failed to load patterns: ${response.statusCode}');
    }
  }

  Future<void> fetchSounds() async {
    String url = Platform.isAndroid || Platform.isIOS
        ? "https://192.168.218.107:5001/api/sound"
        : "https://localhost:5001/api/sound";

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
        sounds = data.entries
            .map((entry) => {
                  'key': entry.key,
                  ...entry.value as Map<String, dynamic>,
                })
            .toList();
      });
    } else {
      throw Exception('Failed to load sounds: ${response.statusCode}');
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
            playedPatterns = items.where((item) => item['isPlayed'] == true).length;
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
            'Nie udało się załadować patternów.',
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
              fetchData();
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
            'Ładujemy patterny...',
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

  Widget _buildDifficultyBadge(String difficulty) {
    final level = int.tryParse(difficulty) ?? 0;
    final appColors = Theme.of(context).extension<AppColors>()!;

    if (level < 1 || level > 3) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: appColors.navUnselectedColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Brak poziomu',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: appColors.navUnselectedColor,
          ),
        ),
      );
    }

    final colors = [
      appColors.accentColor,
      Colors.amber.shade600,
      appColors.errorColor,
    ];
    const labels = ['Łatwy', 'Średni', 'Trudny'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors[level - 1].withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 14,
            color: colors[level - 1],
          ),
          const SizedBox(width: 4),
          Text(
            labels[level - 1],
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colors[level - 1],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(String difficulty) {
    final level = int.tryParse(difficulty) ?? 0;
    final appColors = Theme.of(context).extension<AppColors>()!;
    if (level < 1 || level > 3) return const SizedBox();

    final colors = [
      appColors.accentColor,
      Colors.amber.shade600,
      appColors.errorColor,
    ];

    return Expanded(
      child: LinearProgressIndicator(
        value: level / 3,
        backgroundColor: appColors.navUnselectedColor.withOpacity(0.2),
        color: colors[level - 1],
        minHeight: 6,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildPatternList() {
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
        final difficulty = item['difficulty']?.toString() ?? 'Brak poziomu';
        final isPlayed = item['isPlayed'] ?? false;

        return Material(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(24),
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(8),
          ),
          color: appColors.cardColor,
          elevation: 6,
          child: InkWell(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(24),
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(8),
            ),
            onTap: () async {
              await AudioPlayer().play(AssetSource('audio/click.mp3'));
              Vibration.vibrate(pattern: [0, 50, 50, 50]);
              audioPlayer.stop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PatternDetailsPage(
                    pattern: item,
                    sounds: sounds,
                  ),
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
                      Icons.library_music,
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
                        Row(
                          children: [
                            _buildDifficultyBadge(difficulty),
                            const SizedBox(width: 8),
                            _buildProgressIndicator(difficulty),
                          ],
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
                  'Ogarnij patterny!',
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
                    fetchData();
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
                'Odtworzyłeś $playedPatterns/${items.length} patternów!',
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
                        : _buildPatternList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}