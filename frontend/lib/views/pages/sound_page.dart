import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/io_client.dart';
import 'sound_details_page.dart';

class SoundPage extends StatefulWidget {
  const SoundPage({super.key});

  @override
  State<SoundPage> createState() => _SoundPageState();
}

class _SoundPageState extends State<SoundPage> {
  final AudioPlayer audioPlayer = AudioPlayer();
  List<Map<String, dynamic>> items = [];
  String url = "";

  @override
  void initState() {
    super.initState();
    fetchSounds();
  }

  Future<void> fetchSounds() async {
    if (Platform.isAndroid || Platform.isIOS) {
      url = "https://192.168.170.22:5001/api/sound";
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
          items = data.entries.map((entry) => {
            'key': entry.key,
            ...entry.value as Map<String, dynamic>,
          }).toList();
        });
      } else {
        print('Failed to load sounds: ${response.statusCode}');
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> playSound(String path) async {
    try {
      await audioPlayer.play(AssetSource(path));
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sounds'),
        centerTitle: true,
      ),
      body: items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final name = item['name'] ?? 'Unknown';
                final path = item['audioPath'] ?? '';

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: const Text('Tap to view details'),
                    trailing: IconButton(
                      icon: const Icon(Icons.play_circle_fill, color: Colors.lightBlueAccent, size: 32),
                      onPressed: () => playSound(path),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SoundDetailsPage(sound: item),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
