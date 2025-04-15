import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/notifiers.dart';
import 'pages/dictionary_page.dart';
import 'pages/home_page.dart';
import 'pages/pattern_page.dart';
import 'pages/settings_page.dart';
import 'pages/sound_page.dart';
import 'widgets/navbar_widget.dart';

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
          title: Text(
            'Beatbox Basics',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.purple.shade600,
          elevation: 4,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.shade600,
                  Colors.purple.shade800,
                ],
              ),
            ),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.teal),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
              tooltip: 'Ustawienia',
            ).animate().scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  duration: 200.ms,
                ),
            ValueListenableBuilder(
              valueListenable: isLightModeNotifier,
              builder: (context, isLightMode, child) {
                return IconButton(
                  icon: Icon(
                    isLightMode ? Icons.dark_mode : Icons.light_mode,
                    color: Colors.teal.shade600,
                  ),
                  onPressed: () {
                    isLightModeNotifier.value = !isLightMode;
                  },
                  tooltip: isLightMode ? 'Tryb ciemny' : 'Tryb jasny',
                ).animate().scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0),
                      duration: 200.ms,
                    );
              },
            ),
          ],
        ),
        body: ValueListenableBuilder(
          valueListenable: selectedPageNotifier,
          builder: (context, selectedPage, child) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: ConstrainedBox(
                key: ValueKey<int>(selectedPage),
                constraints: const BoxConstraints(maxWidth: 600),
                child: Center(
                  child: pages.elementAt(selectedPage),
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: const NavbarWidget().animate().slideY(
              begin: 0.2,
              end: 0,
              duration: 500.ms,
            ),
      ),
    );
  }
}