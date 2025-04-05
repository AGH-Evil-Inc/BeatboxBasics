import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/io_client.dart';

class SoundPage extends StatefulWidget {
  const SoundPage({super.key});

  @override
  State<SoundPage> createState() => _SoundPageState();
}

class _SoundPageState extends State<SoundPage> {
  final AudioPlayer audioPlayer = AudioPlayer();
  List<dynamic> items = [];
  String url = "";

  @override
  void initState() {
    super.initState();
    fetchSounds();
  }

  Future<void> fetchSounds() async {
    if (Platform.isAndroid || Platform.isIOS) {
      url = "https://192.168.218.107:5001/api/sound";
    } else if (Platform.isWindows) {
      url = "https://localhost:5001/api/sound";
    }

    try {
      final ioc = HttpClient();
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() {
          items = json.decode(response.body);
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
        title: const Text('Sound Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final String name = item['name'] ?? 'No name';
            final String path = item['audioPath'] ?? '';

            return Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: ListTile(
                title: GestureDetector(
                  onTap: () => playSound(path),
                  child: Text(name),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () => playSound(path),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
