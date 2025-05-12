import 'package:app/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/data/notifiers.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: appColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isSmallScreen ? screenWidth * 0.95 : 600),
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
                child: Column(
                  children: [
                    // Nagłówek z animowanym tekstem
                    _buildAnimatedHeader(context),
                    const SizedBox(height: 40),

                    // Kafelki funkcji
                    _buildFeatureGrid(context, isSmallScreen),
                    const SizedBox(height: 40),

                    // Stopka
                    _buildFooter(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    
    return Column(
      children: [
        Text(
          'Beatbox Basics',
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: appColors.accentColor,
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: appColors.accentColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Twoja brama do świata rytmu',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: appColors.secondaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 4,
          width: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                appColors.accentColor,
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureGrid(BuildContext context, bool isSmallScreen) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isSmallScreen ? 1 : 2,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: isSmallScreen ? 1.5 : 1.2,
      children: [
        _buildFeatureCard(
          context: context,
          icon: Icons.music_note,
          label: 'DŹWIĘKI',
          description: 'Poznaj podstawowe brzmienia beatboxowe',
          gradientColors: [
            appColors.soundGradientStart,
            appColors.soundGradientEnd,
          ],
          onTap: () => _navigateToPage(1),
        ),
        _buildFeatureCard(
          context: context,
          icon: Icons.library_music,
          label: 'PATTERNY',
          description: 'Naucz się profesjonalnych kombinacji',
          gradientColors: [
            appColors.patternGradientStart,
            appColors.patternGradientEnd,
          ],
          onTap: () => _navigateToPage(2),
        ),
        _buildFeatureCard(
          context: context,
          icon: Icons.book,
          label: 'SŁOWNIK',
          description: 'Poznaj terminologię beatboxową',
          gradientColors: [
            appColors.dictionaryGradientStart,
            appColors.dictionaryGradientEnd,
          ],
          onTap: () => _navigateToPage(3),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String description,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        onTap();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    
    return Column(
      children: [
        Text(
          'Rozwiń swoje umiejętności beatboxowe',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: appColors.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Aplikacja działa w trybie offline',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: appColors.secondaryColor,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  void _navigateToPage(int pageIndex) {
    selectedPageNotifier.value = pageIndex;
  }
}