import 'dart:convert';
import 'dart:io';
import 'package:app/views/pages/pattern_details_page.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/io_client.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PatternPage extends StatefulWidget {
  const PatternPage({super.key});

  @override
  State<PatternPage> createState() => _PatternPageState();
}

class _PatternPageState extends State<PatternPage> {
  final AudioPlayer audioPlayer = AudioPlayer();
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> sounds = [];
  String url = "";
  bool isLoading = true;
  bool hasError = false;
  bool isPlaying = false;
  String? currentlyPlayingPath;

  @override
  void initState() {
    super.initState();
    fetchPatterns();
  }

  Future<void> fetchPatterns() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    if (Platform.isAndroid || Platform.isIOS) {
      url = "https://192.168.218.107:5001/api/pattern";
    } else {
      url = "https://localhost:5001/api/pattern";
    }

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
                  })
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
        debugPrint('Failed to load patterns: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      debugPrint("Error: $e");
    }
  }

  Future<void> fetchSounds() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    if (Platform.isAndroid || Platform.isIOS) {
      url = "https://192.168.218.107:5001/api/sound";
    } else {
      url = "https://localhost:5001/api/sound";
    }

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
          sounds = data.entries
              .map((entry) => {
                    'key': entry.key,
                    ...entry.value as Map<String, dynamic>,
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade400,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Oj, coś poszło nie tak!',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.purple.shade900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Spróbuj jeszcze raz.',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.black87,
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
              backgroundColor: Colors.purple.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: fetchPatterns,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  @override
  Widget build(BuildContext context) {
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
                  'Wzorce',
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
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: fetchPatterns,
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
                              color: Colors.purple.shade600,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Ładujemy wzorce…',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.purple.shade900,
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
                              final difficulty = item['difficulty'] ?? 'Brak poziomu';
                        
                              return GestureDetector(
                                onTap: () {
                  
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PatternDetailsPage(pattern: item, sounds: sounds),
                                    ),
                                  );
                                },
                                child: Card(
                                  color: Colors.orange.shade50,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 4,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.purple.shade100,
                                          child: Icon(
                                            Icons.repeat,
                                            color: Colors.purple.shade600,
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
                                                  color: Colors.purple.shade900,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                description.length > 50
                                                    ? '${description.substring(0, 50)}…'
                                                    : description,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    _getDifficultyIcon(difficulty),
                                                    color: Colors.purple.shade600,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    difficulty == 'Brak poziomu'
                                                        ? 'Brak poziomu'
                                                        : 'Poziom trudności: ' + difficulty.toString(),
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      color: difficulty == 'Brak poziomu'
                                                          ? Colors.grey.shade600
                                                          : Colors.purple.shade600,
                                                      fontStyle:
                                                          difficulty == 'Brak poziomu'
                                                              ? FontStyle.italic
                                                              : FontStyle.normal,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
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
                                                value: difficulty/3.0,
                                                color: Colors.purple.shade600,
                                                backgroundColor: Colors.purple.shade100,
                                                strokeWidth: 3,
                                              ),
                                            ).animate().scale(
                                                  begin: Offset(0.8, 0),
                                                  end: Offset(1.0, 0.0),
                                                  duration: 500.ms,
                                                ),
                                            IconButton(
                                              icon: Icon(
                                                isPlaying && path == currentlyPlayingPath
                                                    ? Icons.pause_circle_filled
                                                    : Icons.play_circle_filled,
                                                color: Colors.white,
                                                size: 36,
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: isPlaying &&
                                                        path == currentlyPlayingPath
                                                    ? Colors.orange.shade700
                                                    : Colors.green.shade700,
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

  IconData _getDifficultyIcon(int difficulty) {
    switch (difficulty) {
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
}