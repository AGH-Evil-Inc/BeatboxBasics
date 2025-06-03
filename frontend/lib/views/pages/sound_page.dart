import 'dart:convert';
import 'dart:io';
import 'package:app/data/globals.dart' as globals;
import 'package:app/main.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/io_client.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final localIp = globals.localIP;

    String url = Platform.isAndroid || Platform.isIOS
        ? "https://$localIp:5001/api/sound"
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
            'Ups, coś poszło nie tak!',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: appColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: fetchSounds,
            style: ElevatedButton.styleFrom(
              backgroundColor: appColors.buttonPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              'Spróbuj ponownie',
              style: GoogleFonts.poppins(
                fontSize: 14,
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
      child: CircularProgressIndicator(
        color: appColors.accentColor,
        strokeWidth: 3,
      ),
    );
  }

  Widget _buildSoundList() {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final screenWidth = MediaQuery.of(context).size.width;

    return ListView.builder(
      padding: EdgeInsets.all(screenWidth * 0.04),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final name = item['name'] ?? 'Brak nazwy';
        final path = item['audioPath'] ?? '';
        final description = item['description'] ?? 'Dowiedz się więcej!';
        final notation = item['notation'] ?? 'Brak notacji';

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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SoundDetailsPage(sound: item),
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
                      Icons.music_note,
                      color: appColors.accentColor,
                      size: 24,
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
                            fontSize: 12,
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
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: appColors.accentColor,
                            ),
                          ),
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: appColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Dźwięki',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 24),
            onPressed: fetchSounds,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth > 600 ? (screenWidth - 600) / 2 : screenWidth * 0.04),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: screenWidth > 600 ? 600 : screenWidth * 0.92),
            child: isLoading
                ? _buildLoadingState()
                : hasError
                    ? _buildErrorState()
                    : _buildSoundList(),
          ),
        ),
      ),
    );
  }
}