import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


class SoundDetailsPage extends StatefulWidget {
  final Map<String, dynamic> sound;

  const SoundDetailsPage({super.key, required this.sound});

  @override
  State<SoundDetailsPage> createState() => _SoundDetailsPageState();
}

class _SoundDetailsPageState extends State<SoundDetailsPage> {
  final List<YoutubePlayerController> _controllers = [];

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
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

  @override
  Widget build(BuildContext context) {
    final sound = widget.sound;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.sound['name'] ?? 'No name',
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sound['name'] ?? '',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Text('Notation: ${sound['notation'] ?? 'N/A'}'),
                      const SizedBox(height: 10),
                      Text(sound['description'] ?? 'No description'),
                    ],
                  ),
                ),
              ),
              if ((sound['tips'] ?? []).isNotEmpty) ...[
                buildSectionTitle("Tips"),
                ...sound['tips'].map<Widget>((tip) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text('• $tip'),
                ))
              ],
              if ((sound['links'] ?? []).isNotEmpty) ...[
                buildSectionTitle("Links"),
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
                          'Invalid YouTube link: $link',
                          style: const TextStyle(color: Colors.red),
                        )),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
