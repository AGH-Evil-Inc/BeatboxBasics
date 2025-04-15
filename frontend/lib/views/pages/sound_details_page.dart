import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart' as audio_waveforms;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class SoundDetailsPage extends StatefulWidget {
  final Map<String, dynamic> sound;

  const SoundDetailsPage({super.key, required this.sound});

  @override
  State<SoundDetailsPage> createState() => _SoundDetailsPageState();
}

class _SoundDetailsPageState extends State<SoundDetailsPage> {
  final List<YoutubePlayerController> _controllers = [];
  late final audio_waveforms.PlayerController playerController;
  
  double playbackSpeed = 1.0;
  bool isRepeating = false;

  @override
  void initState() {
    super.initState();
    _initYoutubeControllers();
    _initAudioPlayer();
  

  }

  void _initYoutubeControllers() {
    if (widget.sound['links'] != null) {
      for (var link in widget.sound['links']) {
        final videoId = YoutubePlayer.convertUrlToId(link);
        if (videoId != null) {
          _controllers.add(
            YoutubePlayerController(
              initialVideoId: videoId,
              flags: const YoutubePlayerFlags(autoPlay: false),
            ),
          );
        }
      }
    }
  }

  void _initAudioPlayer() async {
    playerController = audio_waveforms.PlayerController();

    final assetPath = widget.sound['audioPath'];
    if (assetPath == null) {
      debugPrint('Brak ścieżki do pliku audio');
      return;
    }

    try {
      final byteData = await rootBundle.load('assets/$assetPath');
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$assetPath');
      await file.create(recursive: true);
      await file.writeAsBytes(byteData.buffer.asUint8List());

      await playerController.preparePlayer(
        path: file.path,
        shouldExtractWaveform: true,
      );

      

      setState(() {});
    } catch (e) {
      debugPrint('Błąd podczas ładowania pliku audio: $e');
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    // playerController.dispose();
    super.dispose();
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildAudioPlayer() {
    final audioPath = widget.sound['audioPath'];

    if (audioPath == null) {
      return const Text('Brak dostępnego audio');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Podgląd audio',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Center(
          child: audio_waveforms.AudioFileWaveforms(
            playerController: playerController,
            size: const Size(double.infinity, 60),
            waveformType: audio_waveforms.WaveformType.long,
            playerWaveStyle: const audio_waveforms.PlayerWaveStyle(
              liveWaveColor: Colors.blueAccent,
              fixedWaveColor: Colors.lightBlue,
              scaleFactor: 60,
              showSeekLine: true,
              seekLineColor: Colors.red,
              seekLineThickness: 2.0,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Odtwórz'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () => playerController.startPlayer(),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.pause),
              label: const Text('Pauza'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () => playerController.pausePlayer(),
            ),
            ElevatedButton.icon(
              icon: Icon( Icons.repeat),
              label: Text('Powtórz'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isRepeating ? Colors.blueGrey : Colors.grey,
              ),
              
              onPressed: () {
                setState(() {
                  isRepeating = !isRepeating;
                  playerController.seekTo(1);
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Szybkość odtwarzania:'),
            Text('${playbackSpeed.toStringAsFixed(1)}x'),
          ],
        ),
        Slider(
          value: playbackSpeed,
          min: 0.2,
          max: 1.5,
          divisions: 15,
          label: '${playbackSpeed.toStringAsFixed(1)}x',
          onChanged: (value) {
            setState(() {
              playbackSpeed = value;
              playerController.setRate(playbackSpeed);
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final sound = widget.sound;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            sound['name'] ?? 'Brak nazwy',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? Colors.lightBlueAccent
              : Colors.blue,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20.0),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.lightBlueAccent.shade100
                    : Colors.blue.shade700,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sound['name'] ?? '',
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Text('Notacja: ${sound['notation'] ?? 'Brak'}'),
                      const SizedBox(height: 10),
                      Text(sound['description'] ?? 'Brak opisu'),
                    ],
                  ),
                ),
              ),
              if ((sound['tips'] ?? []).isNotEmpty) ...[
                buildSectionTitle("Wskazówki"),
                ...sound['tips'].map<Widget>((tip) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text('• $tip'),
                    ))
              ],
              buildAudioPlayer(),
              if ((sound['links'] ?? []).isNotEmpty) ...[
                buildSectionTitle("Linki"),
                ..._controllers.map((controller) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: YoutubePlayer(
                        controller: controller,
                        showVideoProgressIndicator: true,
                      ),
                    )),
                ...sound['links']
                    .where((link) => YoutubePlayer.convertUrlToId(link) == null)
                    .map<Widget>((link) => Text(
                          'Nieprawidłowy link YouTube: $link',
                          style: const TextStyle(color: Colors.red),
                        )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}