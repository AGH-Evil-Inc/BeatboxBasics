import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http/io_client.dart';

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
            .where((entry) =>
                entry['name'].toString().toLowerCase().contains(query))
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
    return Scaffold(
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
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
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
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text(
        'Słowniczek Beatboxu',
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.teal.shade600,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      elevation: 4,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.teal.shade600,
              Colors.teal.shade800,
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildSearchBar() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Szukaj pojęć…',
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey.shade600,
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.teal.shade600,
          ),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.teal.shade600,
                  ),
                  onPressed: () {
                    searchController.clear();
                    _filterEntries();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        style: GoogleFonts.poppins(fontSize: 16),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.teal,
        ),
      ).animate().fadeIn(duration: 300.ms);
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Nie udało się załadować słowniczka',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchDictionary,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Spróbuj ponownie',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms);
    }

    if (filteredEntries.isEmpty) {
      return Center(
        child: Text(
          'Nie znaleziono pojęć…',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey.shade600,
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
            name: item['name'],
            description: item['description'],
            delay: Duration(milliseconds: 100 * index),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDictionaryCard({
    required String name,
    required String description,
    required Duration delay,
  }) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade900,
              ),
            ),
            content: SingleChildScrollView(
              child: Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Zamknij',
                  style: GoogleFonts.poppins(
                    color: Colors.teal.shade600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.orange.shade100,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dotknij, aby przeczytać więcej',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.teal.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: delay)
        .slideY(begin: 0.2, end: 0);
  }
}