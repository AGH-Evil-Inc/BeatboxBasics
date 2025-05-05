import 'package:app/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app/data/notifiers.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: appColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: screenWidth > 600 ? 600 : screenWidth * 0.9),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: LinearProgressIndicator(
                        value: 0.3,
                        backgroundColor: appColors.navUnselectedColor.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(appColors.accentColor),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ).animate().fadeIn(duration: 600.ms),
                    Text(
                      'Beatbox Basics',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: appColors.primaryColor,
                        letterSpacing: 1.2,
                      ),
                    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
                    const SizedBox(height: 8),
                    Text(
                      'Ogarnij beatbox jak pro',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: appColors.secondaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 600.ms),
                    const SizedBox(height: 40),
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: appColors.cardColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: appColors.accentColor.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.bolt, color: appColors.accentColor, size: 32),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Codzienne wyzwanie: Opanuj Hi-Hat!',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: appColors.primaryColor,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await AudioPlayer().play(AssetSource('audio/click.mp3'));
                              Vibration.vibrate(pattern: [0, 50, 50, 50]);
                              selectedPageNotifier.value = 1;
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appColors.accentColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            child: Text(
                              'Start',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ).animate().scale(
                                duration: 400.ms,
                                curve: Curves.easeOutBack,
                                begin: const Offset(0.95, 0.95),
                              ),
                        ],
                      ),
                    ).animate(),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: screenWidth < 400 ? 1 : 2,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: screenWidth < 400 ? 2.0 : 1.1,
                      children: [
                        _buildFeatureCard(
                          context: context,
                          icon: Icons.music_note_rounded,
                          label: 'Dźwięki',
                          subtitle: 'Poznaj podstawowe\nbrzmienia',
                          color: appColors.accentColor,
                          onTap: () async {
                            await AudioPlayer().play(AssetSource('audio/click.mp3'));
                            Vibration.vibrate(pattern: [0, 50, 50, 50]);
                            selectedPageNotifier.value = 1;
                          },
                          delay: 100.ms,
                        ),
                        _buildFeatureCard(
                          context: context,
                          icon: Icons.library_music_rounded,
                          label: 'Patterny',
                          subtitle: 'Naucz się\nkombinacji',
                          color: appColors.accentColor,
                          onTap: () async {
                            await AudioPlayer().play(AssetSource('audio/click.mp3'));
                            Vibration.vibrate(pattern: [0, 50, 50, 50]);
                            selectedPageNotifier.value = 2;
                          },
                          delay: 200.ms,
                        ),
                        _buildFeatureCard(
                          context: context,
                          icon: Icons.book_rounded,
                          label: 'Słowniczek',
                          subtitle: 'Terminologia\nbeatboxu',
                          color: appColors.accentColor,
                          onTap: () async {
                            await AudioPlayer().play(AssetSource('audio/click.mp3'));
                            Vibration.vibrate(pattern: [0, 50, 50, 50]);
                            selectedPageNotifier.value = 3;
                          },
                          delay: 300.ms,
                        ),
                        _buildFeatureCard(
                          context: context,
                          icon: Icons.bar_chart_rounded,
                          label: 'Statystyki',
                          subtitle: 'Śledź swoje\npostępy',
                          color: appColors.accentColor,
                          onTap: () async {
                            await AudioPlayer().play(AssetSource('audio/click.mp3'));
                            Vibration.vibrate(pattern: [0, 50, 50, 50]);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Statystyki już wkrótce!',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                backgroundColor: appColors.accentColor,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                          delay: 400.ms,
                          enabled: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        'Apka działa offline – ucz się gdzie chcesz!',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: appColors.secondaryColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ).animate().fadeIn(duration: 600.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required Duration delay,
    bool enabled = true,
  }) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(24),
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(8),
      ),
      splashColor: color.withOpacity(0.3),
      highlightColor: color.withOpacity(0.1),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          decoration: BoxDecoration(
            color: appColors.cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(24),
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(8),
            ),
            border: Border.all(color: color.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 32,
                      color: color,
                      semanticLabel: label,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: appColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: appColors.secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate();
  }
}