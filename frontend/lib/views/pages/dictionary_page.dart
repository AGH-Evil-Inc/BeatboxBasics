import 'dart:io';
import 'package:app/data/globals.dart';
import 'package:app/data/globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final localIp = globals.localIP;
    String url;
    if (Platform.isAndroid || Platform.isIOS) {
      url = 'https://$localIp:5001/api/Dictionary';
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
      appBar: _buildAppBar(appColors),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: screenWidth > 600 ? 600 : screenWidth * 0.92),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(appColors),
                const SizedBox(height: 12),
                _buildContent(appColors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppColors appColors) {
    return AppBar(
      title: Text(
        'Słownik Beatboxu',
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
              appColors.dictionaryGradientStart,
              appColors.dictionaryGradientEnd,
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
          icon: Icon(Icons.refresh, color: Colors.white, size: 24),
          onPressed: fetchDictionary,
        ),
      ],
    );
  }

  Widget _buildSearchBar(AppColors appColors) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: appColors.cardColor,
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Szukaj pojęć…',
          hintStyle: GoogleFonts.poppins(
            color: appColors.navUnselectedColor,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: appColors.accentColor,
            size: 24,
          ),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: appColors.accentColor,
                    size: 20,
                  ),
                  onPressed: () {
                    searchController.clear();
                    _filterEntries();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: appColors.cardColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        style: GoogleFonts.poppins(fontSize: 14, color: appColors.primaryColor),
      ),
    );
  }

  Widget _buildContent(AppColors appColors) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: appColors.accentColor,
          strokeWidth: 3,
        ),
      );
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              onPressed: fetchDictionary,
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

    if (filteredEntries.isEmpty) {
      return Center(
        child: Text(
          'Brak wyników',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: appColors.navUnselectedColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Column(
      children: filteredEntries.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildDictionaryCard(
            name: item['name'],
            description: item['description'],
            appColors: appColors,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDictionaryCard({
    required String name,
    required String description,
    required AppColors appColors,
  }) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: appColors.cardColor,
            title: Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: appColors.primaryColor,
              ),
            ),
            content: SingleChildScrollView(
              child: Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: appColors.secondaryColor,
                  height: 1.4,
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
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 4,
        color: appColors.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
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
              const SizedBox(height: 6),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: appColors.secondaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}