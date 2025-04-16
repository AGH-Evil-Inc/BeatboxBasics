import 'dart:convert';
import 'dart:io';
import 'package:app/main.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/io_client.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
        ? "https://192.168.0.34:5001/api/pattern"
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
                })
            .toList();
      });
    } else {
      throw Exception('Failed to load patterns: ${response.statusCode}');
    }
  }

  Future<void> fetchSounds() async {
    String url = Platform.isAndroid || Platform.isIOS
        ? "https://192.168.0.34:5001/api/sound"
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

  Future<void> playSound(String path) async {
    try {
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
            'Oj, coś poszło nie tak!',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: appColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Spróbuj jeszcze raz.',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: appColors.secondaryColor,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: Text(
              'Spróbuj ponownie',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: appColors.buttonPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: fetchData,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
                  'Patterny',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                centerTitle: true,
                backgroundColor: appColors.patternColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                elevation: 4,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        appColors.patternColor,
                        appColors.accentColor,
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.refresh, color: appColors.navSelectedColor),
                    onPressed: fetchData,
                    tooltip: 'Odśwież',
                  ),
                ],
              ),
              Expanded(
                child: isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: appColors.patternColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Ładujemy patterny…',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: appColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      )
                    : hasError
                        ? _buildErrorState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              final name = item['name'] ?? 'Brak nazwy';
                              final path = item['audioPath'] ?? '';
                              final description =
                                  item['description'] ?? 'Dowiedz się więcej!';
                              final difficulty =
                                  item['difficulty']?.toString() ?? 'Brak poziomu';

                              return GestureDetector(
                                onTap: () {
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
                                child: Card(
                                  color: appColors.cardColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 4,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: appColors.waveformFixedColor,
                                          child: Icon(
                                            Icons.library_music_outlined,
                                            color: appColors.highlightColor,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                name,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: appColors.primaryColor,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                description.length > 50
                                                    ? '${description.substring(0, 50)}…'
                                                    : description,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: appColors.secondaryColor,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    _getDifficultyIcon(difficulty),
                                                    color: _getDifficultyColor(difficulty),
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Poziom: $difficulty',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      color: _getDifficultyColor(
                                                          difficulty),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  _buildDifficultyStars(difficulty),
                                                ],
                                              ).animate().fadeIn(duration: 300.ms),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            SizedBox(
                                              width: 48,
                                              height: 48,
                                              child: CircularProgressIndicator(
                                                value: _getProgressValue(difficulty),
                                                color: _getDifficultyColor(difficulty),
                                                backgroundColor: appColors.waveformFixedColor,
                                                strokeWidth: 3,
                                              ),
                                            ).animate().scale(
                                                  begin: const Offset(0.8, 0.8),
                                                  end: const Offset(1.0, 1.0),
                                                  duration: 500.ms,
                                                ),
                                            IconButton(
                                              icon: Icon(
                                                isPlaying &&
                                                        path == currentlyPlayingPath
                                                    ? Icons.pause_circle_filled
                                                    : Icons.play_circle_filled,
                                                color: Colors.white,
                                                size: 36,
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: isPlaying &&
                                                        path == currentlyPlayingPath
                                                    ? appColors.buttonSecondaryColor
                                                    : appColors.buttonPrimaryColor,
                                                shape: const CircleBorder(),
                                                padding: const EdgeInsets.all(8),
                                              ),
                                              onPressed: () => playSound(path),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ).animate().slideX(
                                    begin: 0.2,
                                    end: 0,
                                    duration: 500.ms,
                                    delay: (50 * index).ms,
                                  );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getDifficultyIcon(String difficulty) {
    final level = int.tryParse(difficulty) ?? 0;
    switch (level) {
      case 1:
        return Icons.emoji_emotions;
      case 2:
        return Icons.rocket_launch;
      case 3:
        return Icons.flash_on;
      default:
        return Icons.help_outline;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final level = int.tryParse(difficulty) ?? 0;
    switch (level) {
      case 1:
        return appColors.buttonPrimaryColor;
      case 2:
        return appColors.accentColor;
      case 3:
        return appColors.errorColor;
      default:
        return appColors.navUnselectedColor;
    }
  }

  double _getProgressValue(String difficulty) {
    final level = int.tryParse(difficulty) ?? 0;
    return level / 3.0;
  }

  Widget _buildDifficultyStars(String difficulty) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final level = int.tryParse(difficulty) ?? 0;
    if (level < 1 || level > 3) {
      return Text(
        'Brak poziomu',
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: appColors.navUnselectedColor,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Row(
      children: List.generate(level, (index) {
        return Icon(
          Icons.music_note,
          color: _getDifficultyColor(difficulty),
          size: 16,
        );
      }),
    );
  }
}