import 'package:app/data/notifiers.dart';
import 'package:app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: appColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Dostosuj vibe aplikacji!',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: appColors.primaryColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: appColors.backgroundColor,
        elevation: 6,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(8),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.restart_alt,
              color: appColors.navUnselectedColor,
              size: 28,
            ),
            onPressed: () async {
              await AudioPlayer().play(AssetSource('audio/click.mp3'));
              Vibration.vibrate(pattern: [0, 50, 50, 50]);
              customColorsNotifier.value = isLightModeNotifier.value
                  ? AppColors.light()
                  : AppColors.dark();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Kolory zresetowane do domyślnych!',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: appColors.accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            tooltip: 'Resetuj kolory',
          ).animate().scale(
                duration: 400.ms,
                curve: Curves.easeOutBack,
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.0, 1.0),
              ),
        ],
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: isLightModeNotifier,
        builder: (context, isLightMode, child) {
          return ListView(
            padding: EdgeInsets.all(screenWidth * 0.05),
            children: [
              _buildThemeModeSwitch(context, isLightMode).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 32),
              _buildSectionTitle(context, 'Kolory główne').animate().fadeIn(duration: 400.ms),
              _buildColorPickerTile(
                context,
                'Kolor główny (tekst)',
                appColors.primaryColor,
                (color) {
                  customColorsNotifier.value = customColorsNotifier.value.copyWith(primaryColor: color);
                },
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
              _buildColorPickerTile(
                context,
                'Kolor dodatkowy (tekst)',
                appColors.secondaryColor,
                (color) {
                  customColorsNotifier.value = customColorsNotifier.value.copyWith(secondaryColor: color);
                },
              ).animate().fadeIn(duration: 400.ms, delay: 150.ms),
              _buildColorPickerTile(
                context,
                'Kolor tła',
                appColors.backgroundColor,
                (color) {
                  customColorsNotifier.value = customColorsNotifier.value.copyWith(backgroundColor: color);
                },
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
              _buildColorPickerTile(
                context,
                'Kolor kart',
                appColors.cardColor,
                (color) {
                  customColorsNotifier.value = customColorsNotifier.value.copyWith(cardColor: color);
                },
              ).animate().fadeIn(duration: 400.ms, delay: 250.ms),
              _buildColorPickerTile(
                context,
                'Kolor akcentu',
                appColors.accentColor,
                (color) {
                  customColorsNotifier.value = customColorsNotifier.value.copyWith(
                    accentColor: color,
                    navSelectedColor: color,
                    buttonPrimaryColor: color,
                    waveformLiveColor: color,
                    waveformSeekColor: color,
                  );
                },
              ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
              _buildColorPickerTile(
                context,
                'Kolor niewybranej nawigacji',
                appColors.navUnselectedColor,
                (color) {
                  customColorsNotifier.value = customColorsNotifier.value.copyWith(navUnselectedColor: color);
                },
              ).animate().fadeIn(duration: 400.ms, delay: 350.ms),
              _buildColorPickerTile(
                context,
                'Kolor dodatkowego przycisku',
                appColors.buttonSecondaryColor,
                (color) {
                  customColorsNotifier.value = customColorsNotifier.value.copyWith(buttonSecondaryColor: color);
                },
              ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
              _buildColorPickerTile(
                context,
                'Kolor błędu',
                appColors.errorColor,
                (color) {
                  customColorsNotifier.value = customColorsNotifier.value.copyWith(errorColor: color);
                },
              ).animate().fadeIn(duration: 400.ms, delay: 450.ms),
            ],
          );
        },
      ),
    );
  }

  Widget _buildThemeModeSwitch(BuildContext context, bool isLightMode) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Card(
      elevation: 6,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(8),
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(24),
        ),
      ),
      color: appColors.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isLightMode ? Icons.light_mode : Icons.dark_mode,
              size: 32,
              color: appColors.accentColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                isLightMode ? 'Tryb jasny' : 'Tryb ciemny',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: appColors.primaryColor,
                ),
              ),
            ),
            Switch(
              value: isLightMode,
              onChanged: (value) async {
                await AudioPlayer().play(AssetSource('audio/click.mp3'));
                Vibration.vibrate(pattern: [0, 50, 50, 50]);
                isLightModeNotifier.value = value;
                customColorsNotifier.value = value ? AppColors.light() : AppColors.dark();
              },
              activeColor: appColors.accentColor,
              inactiveThumbColor: appColors.navUnselectedColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: appColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildColorPickerTile(
    BuildContext context,
    String title,
    Color color,
    ValueChanged<Color> onColorChanged,
  ) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Card(
      elevation: 6,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(24),
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(8),
        ),
      ),
      color: appColors.cardColor,
      child: ListTile(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: appColors.primaryColor,
          ),
        ),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: appColors.secondaryColor, width: 1.5),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 20,
          color: appColors.accentColor,
        ),
        onTap: () async {
          await AudioPlayer().play(AssetSource('audio/click.mp3'));
          Vibration.vibrate(pattern: [0, 50, 50, 50]);
          _showColorPickerDialog(context, title, color, onColorChanged);
        },
      ),
    );
  }

  void _showColorPickerDialog(
    BuildContext context,
    String title,
    Color currentColor,
    ValueChanged<Color> onColorChanged,
  ) {
    Color tempColor = currentColor;
    final appColors = Theme.of(context).extension<AppColors>()!;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: appColors.cardColor,
          title: Text(
            'Wybierz $title',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: appColors.primaryColor,
            ),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (color) => tempColor = color,
              displayThumbColor: true,
              enableAlpha: false,
              labelTypes: const [],
              pickerAreaHeightPercent: 0.7,
              hexInputBar: true,
              portraitOnly: true,
              pickerAreaBorderRadius: BorderRadius.circular(16),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await AudioPlayer().play(AssetSource('audio/click.mp3'));
                Vibration.vibrate(duration: 50);
                Navigator.pop(context);
              },
              child: Text(
                'Anuluj',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: appColors.accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await AudioPlayer().play(AssetSource('audio/click.mp3'));
                Vibration.vibrate(duration: 50);
                onColorChanged(tempColor);
                Navigator.pop(context);
              },
              child: Text(
                'Zapisz',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: appColors.accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}