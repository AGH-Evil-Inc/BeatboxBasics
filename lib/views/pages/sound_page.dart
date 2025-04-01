import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundPage extends StatelessWidget {
  const SoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AudioPlayer audioPlayer = AudioPlayer();

    // List of items with their names and actions
    // Each item has a name, an action for the row tap, and an action for the icon tap
    final List<Map<String, dynamic>> items = [
      {
        'name': 'Beat 1',
        'onTapRow': () => print('Row of Beat 1 clicked'),
        'onTapIcon': () async {
          await audioPlayer.play(AssetSource('audio/sounds/example_kicks.wav'));
        },
      },
      {
        'name': 'Beat 2',
        'onTapRow': () => print('Row of Beat 2 clicked'),
        'onTapIcon': () async {
          await audioPlayer.play(AssetSource('audio/sounds/example_kicks.wav'));
        },
      },
      {
        'name': 'Beat 3',
        'onTapRow': () => print('Row of Beat 3 clicked'),
        'onTapIcon': () async {
          await audioPlayer.play(AssetSource('audio/sounds/example_kicks.wav'));
        },
      },
    ];

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
            return Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: ListTile(
                title: GestureDetector(
                  onTap: item['onTapRow'], 
                  child: Text(item['name']),
                ),
                trailing: GestureDetector(
                  onTap: item['onTapIcon'], 
                  child: Icon(Icons.play_arrow),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}