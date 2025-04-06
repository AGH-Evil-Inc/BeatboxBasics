import '../data/notifiers.dart';
import 'pages/dictionary_page.dart';
import 'pages/home_page.dart';
import 'pages/pattern_page.dart';
import 'pages/settings_page.dart';
import 'pages/sound_page.dart';
import 'widgets/navbar_widget.dart';
import 'package:flutter/material.dart';

List<Widget> pages = [
  const HomePage(),
  const SoundPage(),
  const PatternPage(),
  const DictionaryPage(),
];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Beatbox Basics', style: TextStyle(fontSize: 24,
            fontWeight: FontWeight.bold, 
            color: Theme.of(context).brightness == Brightness.light ? Colors.blueGrey : Colors.white
            ),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.lightGreenAccent : Colors.green,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              style: IconButton.styleFrom(
                foregroundColor: Theme.of(context).brightness == Brightness.light ? Colors.blueGrey : Colors.white,
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
              },
            ),
            IconButton(
              icon: ValueListenableBuilder(valueListenable: selectedPageNotifier, builder: (context, selectedPage, child) {
                return const Icon(Icons.book);
              },),
              style: IconButton.styleFrom(
                foregroundColor: Theme.of(context).brightness == Brightness.light ? Colors.blueGrey : Colors.white,
              ),
              onPressed: () {
                selectedPageNotifier.value = 3; 
              },
            ),

            IconButton(
              icon: ValueListenableBuilder(valueListenable: isLightModeNotifier, builder: (context, value, child) {
                return Icon(value ? Icons.dark_mode : Icons.light_mode);
              },),
               style: IconButton.styleFrom(
                foregroundColor: Theme.of(context).brightness == Brightness.light ? Colors.blueGrey : Colors.white,
              ),
              onPressed: () {
                isLightModeNotifier.value = !isLightModeNotifier.value;
                if (isLightModeNotifier.value) {
                  Theme.of(context).brightness == Brightness.light;
                } else {
                  Theme.of(context).brightness == Brightness.dark;
                }
              },
            )
            
          ],
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20.0), 
              ),
            ),
        ),
        body: ValueListenableBuilder(valueListenable: selectedPageNotifier, builder: (context, selectedPage, child) {
          return pages.elementAt(selectedPage);
        }),
        bottomNavigationBar: NavbarWidget()
      ),
    );
  }
}