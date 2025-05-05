import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:http/io_client.dart';
import 'dart:convert';
import 'package:app/main.dart';

class DictionaryPage extends StatefulWidget {
  const DictionaryPage({super.key});

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  List<Map<String, dynamic>> entries = [];
  List<Map<String, dynamic>> filteredEntries = [];
  bool isLoading = true;
  bool hasError = false;
  final TextEditingController searchController = TextEditingController();
  int learnedTerms = 0;

  @override
  void initState() {
    super.initState();
    fetchDictionary();
    searchController.addListener(_filterEntries);
  }

  Future<void> fetchDictionary() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    String url;
    if (Platform.isAndroid || Platform.isIOS) {
      url = 'https://192.168.218.107:5001/api/Dictionary';
    } else {
      url = 'https://localhost:5001/api/Dictionary';
    }

    try {
      final ioc = HttpClient();
      ioc.badCertificateCallback = (cert, host, port) => true;
      final client = IOClient(ioc);

      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          entries = data.entries
              .map((entry) => {
                    'key': entry.key,
                    'name': entry.value['name'] ?? 'Brak nazwy',
                    'description': entry.value['description'] ?? 'Brak opisu',
                    'isLearned': false,
                  })
              .toList();
          filteredEntries = entries;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
        debugPrint('Failed to load dictionary: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      debugPrint('Error fetching dictionary: $e');
    }
  }

  void _filterEntries() {
    final query = searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredEntries = entries;
      } else {
        filteredEntries = entries
            .where((entry) => entry['name'].toString().toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _markAsLearned(int index) {
    setState(() {
      entries[index]['isLearned'] = true;
      filteredEntries[index]['isLearned'] = true;
      learnedTerms = entries.where((entry) => entry['isLearned'] == true).length;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Ogarnąłeś nowe pojęcie! 💪',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).extension<AppColors>()!.accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: appColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                'Poznałeś $learnedTerms/${entries.length} pojęć!',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: appColors.accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ).animate().fadeIn(duration: 500.ms),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: screenWidth > 600 ? 600 : screenWidth * 0.9),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 16),
                      _buildContent(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return AppBar(
      title: Text(
        'Ogarnij beatboxowe pojęcia!',
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      backgroundColor: appColors.accentColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      elevation: 6,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
          onPressed: () async {
            await AudioPlayer().play(AssetSource('audio/click.mp3'));
            Vibration.vibrate(pattern: [0, 50, 50, 50]);
            fetchDictionary();
          },
        ).animate().scale(
              duration: 400.ms,
              curve: Curves.easeOutBack,
              begin: const Offset(0.95, 0.95),
            ),
      ],
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildSearchBar() {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Card(
      elevation: 6,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(8),
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(24),
        ),
      ),
      color: appColors.cardColor,
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Szukaj pojęć…',
          hintStyle: GoogleFonts.poppins(
            color: appColors.navUnselectedColor,
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: appColors.accentColor,
            size: 28,
          ),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: appColors.accentColor,
                    size: 24,
                  ),
                  onPressed: () async {
                    await AudioPlayer().play(AssetSource('audio/click.mp3'));
                    Vibration.vibrate(pattern: [0, 50, 50, 50]);
                    searchController.clear();
                    _filterEntries();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(8),
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(24),
            ),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: appColors.cardColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        style: GoogleFonts.poppins(fontSize: 16, color: appColors.primaryColor),
        onChanged: (_) async {
          await AudioPlayer().play(AssetSource('audio/click.mp3'));
          Vibration.vibrate(duration: 30);
        },
      ),
    ).animate();
  }

  Widget _buildContent() {
    final appColors = Theme.of(context).extension<AppColors>()!;
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: appColors.accentColor,
          strokeWidth: 4,
        ),
      ).animate().fadeIn(duration: 300.ms);
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Coś poszło nie tak! 😕',
              style: GoogleFonts.poppins(
                fontSize: 20,
                color: appColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await AudioPlayer().play(AssetSource('audio/click.mp3'));
                Vibration.vibrate(pattern: [0, 50, 50, 50]);
                fetchDictionary();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: appColors.buttonPrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Spróbuj jeszcze raz',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms);
    }

    if (filteredEntries.isEmpty) {
      return Center(
        child: Text(
          'Nic nie znalazłem… 🤔',
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: appColors.navUnselectedColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ).animate().fadeIn(duration: 300.ms);
    }

    return Column(
      children: filteredEntries.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildDictionaryCard(
            index: index,
            name: item['name'],
            description: item['description'],
            isLearned: item['isLearned'] ?? false,
            delay: Duration(milliseconds: 100 * index),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDictionaryCard({
    required int index,
    required String name,
    required String description,
    required bool isLearned,
    required Duration delay,
  }) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return GestureDetector(
      onTap: () async {
        await AudioPlayer().play(AssetSource('audio/click.mp3'));
        Vibration.vibrate(pattern: [0, 50, 50, 50]);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: appColors.cardColor,
            title: Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: appColors.primaryColor,
              ),
            ),
            content: SingleChildScrollView(
              child: Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: appColors.secondaryColor,
                  height: 1.5,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await AudioPlayer().play(AssetSource('audio/click.mp3'));
                  Vibration.vibrate(pattern: [0, 50, 50, 50]);
                  _markAsLearned(index);
                  Navigator.pop(context);
                },
                child: Text(
                  'Ogarnąłem!',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: appColors.accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
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
      },
      child: Card(
        elevation: 6,
        color: appColors.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: appColors.primaryColor,
                      ),
                    ),
                  ),
                  if (isLearned)
                    Icon(
                      Icons.check_circle,
                      color: appColors.accentColor,
                      size: 24,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: appColors.secondaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dotknij, by dowiedzieć się więcej',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: appColors.accentColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate();
  }
}