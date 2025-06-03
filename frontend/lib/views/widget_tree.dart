import 'package:app/views/pages/stats_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/notifiers.dart';
import '../main.dart';
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
  const StatsPage(),
];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return SafeArea(
      child: Scaffold(
        backgroundColor: appColors.backgroundColor,
        appBar: AppBar(
          title: Text(
            'Beatbox Basics',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: appColors.primaryColor,
            ),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  appColors.patternGradientStart,
                  appColors.patternGradientEnd,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            ),
          ),
          elevation: 6,
          actions: [
            IconButton(
              icon: Icon(
                Icons.settings,
                color: appColors.navUnselectedColor,
                size: 28,
              ),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
              tooltip: 'Ustawienia',
            ),
            ValueListenableBuilder<bool>(
              valueListenable: isLightModeNotifier,
              builder: (context, isLightMode, child) {
                return IconButton(
                  icon: Icon(
                    isLightMode ? Icons.dark_mode : Icons.light_mode,
                    color: appColors.navUnselectedColor,
                    
                    size: 28,
                  ),
                  onPressed: () async {
                    isLightModeNotifier.value = !isLightMode;
                    customColorsNotifier.value = isLightMode ? AppColors.dark() : AppColors.light();
                  },
                  tooltip: isLightMode ? 'Tryb ciemny' : 'Tryb jasny',
                ).animate().scale(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1.0, 1.0),
                      duration: 400.ms,
                      curve: Curves.easeOutBack,
                    );
              },
            ),
          ],
        ),
        body: ValueListenableBuilder<int>(
          valueListenable: selectedPageNotifier,
          builder: (context, selectedPage, child) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: ConstrainedBox(
                key: ValueKey<int>(selectedPage),
                constraints: BoxConstraints(
                  
                ),
                child: Center(
                  child: pages.elementAt(selectedPage),
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: const NavbarWidget()
      ),
    );
  }
}