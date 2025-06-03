import 'dart:convert';
import 'dart:io';
import 'package:app/data/globals.dart' as globals;
import 'package:app/main.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/io_client.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final localIp = globals.localIP;
    String url = Platform.isAndroid || Platform.isIOS
        ? "https://$localIp:5001/api/pattern"
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
    final localIp = globals.localIP;
    String url = Platform.isAndroid || Platform.isIOS
        ? "https://$localIp:5001/api/sound"
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
            'Coś poszło nie tak!',
            style: GoogleFonts.poppins(
              fontSize: 20,
              color: appColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: fetchData,
            style: ElevatedButton.styleFrom(
              backgroundColor: appColors.buttonPrimaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Spróbuj ponownie',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: appColors.accentColor,
          ),
          const SizedBox(height: 20),
          Text(
            'Ładowanie patternów...',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: appColors.primaryColor,
            ),
          ),
        ],
      ),
    );
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
      ),
    );
  }

  Widget _buildPatternList() {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final name = item['name'] ?? 'Brak nazwy';
        final path = item['audioPath'] ?? '';
        final key = item['key'] ?? '';
        final description = item['description'] ?? 'Dowiedz się więcej!';
        final difficulty = item['difficulty']?.toString() ?? 'Brak poziomu';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: appColors.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              audioPlayer.stop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PatternDetailsPage(
                    pattern: item,
                    sounds: sounds,
                    patternkey: key
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
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
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: appColors.primaryColor,
                          ),
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
                    icon: Icon(
                      isPlaying && path == currentlyPlayingPath
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: appColors.accentColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => playSound(path, index),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: appColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Patterny',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 24),
            onPressed: fetchData,
          ),
        ],
      ),
      body: isLoading
          ? _buildLoadingState()
          : hasError
              ? _buildErrorState()
              : _buildPatternList(),
    );
  }
}