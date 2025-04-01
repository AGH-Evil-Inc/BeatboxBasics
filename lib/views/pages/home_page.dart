import 'package:app/data/notifiers.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage ({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(valueListenable: selectedPageNotifier, builder: (context, selectedPage, child) {
      return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0), 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                  'What would you like to learn?',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Theme.of(context).brightness == Brightness.light ? Colors.blueGrey : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () {
                      selectedPageNotifier.value = 1;
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.music_note,
                          size: 32.0,
                          color: Colors.white,
                        ),
                        SizedBox(height: 4.0), 
                        Text(
                          'Sound Page',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                 const SizedBox(width: 8.0), 
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      padding: const EdgeInsets.symmetric(vertical: 32.0), 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), 
                      ),
                    ),
                    onPressed: () {
                      selectedPageNotifier.value = 2; 
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.library_music, 
                          size: 32.0,
                          color: Colors.white,
                        ),
                        SizedBox(height: 4.0), 
                        Text(
                          'Pattern Page',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
              ],
            ),
          ],
        ),
      ),
    );
    });
  }
}