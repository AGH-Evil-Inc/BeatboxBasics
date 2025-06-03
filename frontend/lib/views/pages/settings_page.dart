import 'package:app/data/notifiers.dart';
import 'package:app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: appColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Dostosuj kolory aplikacji',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: appColors.primaryColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: appColors.backgroundColor,
        elevation: 6,
        actions: [
          IconButton(
            icon: Icon(
              Icons.restart_alt,
              color: appColors.navUnselectedColor,
              size: 28,
            ),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              customColorsNotifier.value = isLightModeNotifier.value
                  ? AppColors.light()
                  : AppColors.dark();
              await _saveColorsToPrefs(customColorsNotifier.value, isLightModeNotifier.value, prefs);
            },
            tooltip: 'Resetuj kolory',
          ),
        ],
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: isLightModeNotifier,
        builder: (context, isLightMode, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildThemeModeSwitch(context, isLightMode),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Kolory główne'),
              _buildColorPickerTile(
                context,
                'Kolor główny (primary)',
                appColors.primaryColor,
                (color) => _updateColors(primaryColor: color),
              ),
              _buildColorPickerTile(
                context,
                'Kolor dodatkowy (secondary)',
                appColors.secondaryColor,
                (color) => _updateColors(secondaryColor: color),
              ),
              _buildColorPickerTile(
                context,
                'Kolor tekstu',
                appColors.textColor,
                (color) => _updateColors(textColor: color),
              ),
              _buildColorPickerTile(
                context,
                'Kolor tła',
                appColors.backgroundColor,
                (color) => _updateColors(backgroundColor: color),
              ),
              _buildColorPickerTile(
                context,
                'Kolor akcentu',
                appColors.accentColor,
                (color) => _updateColors(
                  accentColor: color,
                  navSelectedColor: color,
                  buttonPrimaryColor: color,
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Kolory nawigacji'),
              _buildColorPickerTile(
                context,
                'Wybrany element nawigacji',
                appColors.navSelectedColor,
                (color) => _updateColors(navSelectedColor: color),
              ),
              _buildColorPickerTile(
                context,
                'Niewybrany element nawigacji',
                appColors.navUnselectedColor,
                (color) => _updateColors(navUnselectedColor: color),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Kolory kart i przycisków'),
              _buildColorPickerTile(
                context,
                'Kolor kart',
                appColors.cardColor,
                (color) => _updateColors(cardColor: color),
              ),
              _buildColorPickerTile(
                context,
                'Główny kolor przycisków',
                appColors.buttonPrimaryColor,
                (color) => _updateColors(buttonPrimaryColor: color),
              ),
              _buildColorPickerTile(
                context,
                'Dodatkowy kolor przycisków',
                appColors.buttonSecondaryColor,
                (color) => _updateColors(buttonSecondaryColor: color),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Kolory waveform'),
              _buildColorPickerTile(
                context,
                'Kolor aktywny waveform',
                appColors.waveformLiveColor,
                (color) => _updateColors(waveformLiveColor: color),
              ),
              _buildColorPickerTile(
                context,
                'Kolor nieaktywny waveform',
                appColors.waveformFixedColor,
                (color) => _updateColors(waveformFixedColor: color),
              ),
              _buildColorPickerTile(
                context,
                'Kolor linii przewijania',
                appColors.waveformSeekColor,
                (color) => _updateColors(waveformSeekColor: color),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Kolory gradientów kart funkcji'),
              _buildColorPickerTile(
                context,
                'Gradient dźwięków - początek',
                appColors.soundGradientStart,
                (color) => _updateColors(soundGradientStart: color),
              ),
              _buildColorPickerTile(
                context,
                'Gradient dźwięków - koniec',
                appColors.soundGradientEnd,
                (color) => _updateColors(soundGradientEnd: color),
              ),
              _buildColorPickerTile(
                context,
                'Gradient patternów - początek',
                appColors.patternGradientStart,
                (color) => _updateColors(patternGradientStart: color),
              ),
              _buildColorPickerTile(
                context,
                'Gradient patternów - koniec',
                appColors.patternGradientEnd,
                (color) => _updateColors(patternGradientEnd: color),
              ),
              _buildColorPickerTile(
                context,
                'Gradient słownika - początek',
                appColors.dictionaryGradientStart,
                (color) => _updateColors(dictionaryGradientStart: color),
              ),
              _buildColorPickerTile(
                context,
                'Gradient słownika - koniec',
                appColors.dictionaryGradientEnd,
                (color) => _updateColors(dictionaryGradientEnd: color),
              ),
              _buildColorPickerTile(
                context,
                'Gradient statystyk - początek',
                appColors.statsGradientStart,
                (color) => _updateColors(statsGradientStart: color),
              ),
              _buildColorPickerTile(
                context,
                'Gradient statystyk - koniec',
                appColors.statsGradientEnd,
                (color) => _updateColors(statsGradientEnd: color),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Inne kolory'),
              _buildColorPickerTile(
                context,
                'Kolor błędu',
                appColors.errorColor,
                (color) => _updateColors(errorColor: color),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _saveColorsToPrefs(AppColors colors, bool isLightMode, SharedPreferences prefs) async {
    await prefs.setBool('isLightMode', isLightMode);
    await prefs.setInt('primaryColor', colors.primaryColor.value);
    await prefs.setInt('secondaryColor', colors.secondaryColor.value);
    await prefs.setInt('textColor', colors.textColor.value);
    await prefs.setInt('backgroundColor', colors.backgroundColor.value);
    await prefs.setInt('accentColor', colors.accentColor.value);
    await prefs.setInt('navSelectedColor', colors.navSelectedColor.value);
    await prefs.setInt('navUnselectedColor', colors.navUnselectedColor.value);
    await prefs.setInt('cardColor', colors.cardColor.value);
    await prefs.setInt('buttonPrimaryColor', colors.buttonPrimaryColor.value);
    await prefs.setInt('buttonSecondaryColor', colors.buttonSecondaryColor.value);
    await prefs.setInt('waveformLiveColor', colors.waveformLiveColor.value);
    await prefs.setInt('waveformFixedColor', colors.waveformFixedColor.value);
    await prefs.setInt('waveformSeekColor', colors.waveformSeekColor.value);
    await prefs.setInt('errorColor', colors.errorColor.value);
    await prefs.setInt('soundGradientStart', colors.soundGradientStart.value);
    await prefs.setInt('soundGradientEnd', colors.soundGradientEnd.value);
    await prefs.setInt('patternGradientStart', colors.patternGradientStart.value);
    await prefs.setInt('patternGradientEnd', colors.patternGradientEnd.value);
    await prefs.setInt('dictionaryGradientStart', colors.dictionaryGradientStart.value);
    await prefs.setInt('dictionaryGradientEnd', colors.dictionaryGradientEnd.value);
  }

  void _updateColors({
    Color? primaryColor,
    Color? secondaryColor,
    Color? textColor,
    Color? backgroundColor,
    Color? accentColor,
    Color? navSelectedColor,
    Color? navUnselectedColor,
    Color? cardColor,
    Color? buttonPrimaryColor,
    Color? buttonSecondaryColor,
    Color? waveformLiveColor,
    Color? waveformFixedColor,
    Color? waveformSeekColor,
    Color? errorColor,
    Color? soundGradientStart,
    Color? soundGradientEnd,
    Color? patternGradientStart,
    Color? patternGradientEnd,
    Color? dictionaryGradientStart,
    Color? dictionaryGradientEnd,
    Color? statsGradientStart,
    Color? statsGradientEnd,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final currentColors = customColorsNotifier.value;
    final updatedColors = currentColors.copyWith(
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      textColor: textColor,
      backgroundColor: backgroundColor,
      accentColor: accentColor,
      navSelectedColor: navSelectedColor,
      navUnselectedColor: navUnselectedColor,
      cardColor: cardColor,
      buttonPrimaryColor: buttonPrimaryColor,
      buttonSecondaryColor: buttonSecondaryColor,
      waveformLiveColor: waveformLiveColor,
      waveformFixedColor: waveformFixedColor,
      waveformSeekColor: waveformSeekColor,
      errorColor: errorColor,
      soundGradientStart: soundGradientStart,
      soundGradientEnd: soundGradientEnd,
      patternGradientStart: patternGradientStart,
      patternGradientEnd: patternGradientEnd,
      dictionaryGradientStart: dictionaryGradientStart,
      dictionaryGradientEnd: dictionaryGradientEnd,
    );
    customColorsNotifier.value = updatedColors;
    await _saveColorsToPrefs(updatedColors, isLightModeNotifier.value, prefs);
  }

  Widget _buildThemeModeSwitch(BuildContext context, bool isLightMode) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: appColors.primaryColor,
                ),
              ),
            ),
            Switch(
              value: isLightMode,
              onChanged: (value) async {
                isLightModeNotifier.value = value;
                customColorsNotifier.value = value ? AppColors.light() : AppColors.dark();
                final prefs = await SharedPreferences.getInstance();
                await _saveColorsToPrefs(customColorsNotifier.value, value, prefs);
              },
              activeColor: appColors.accentColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 20,
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
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: appColors.cardColor,
      child: ListTile(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: appColors.primaryColor,
          ),
        ),
        leading: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: appColors.secondaryColor),
          ),
        ),
        onTap: () => _showColorPickerDialog(context, title, color, onColorChanged),
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
          backgroundColor: appColors.cardColor,
          title: Text(
            'Wybierz $title',
            style: GoogleFonts.poppins(
              color: appColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (color) => tempColor = color,
              displayThumbColor: true,
              enableAlpha: false,
              pickerAreaHeightPercent: 0.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Anuluj',
                style: GoogleFonts.poppins(
                  color: appColors.primaryColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                onColorChanged(tempColor);
                Navigator.pop(context);
              },
              child: Text(
                'Zapisz',
                style: GoogleFonts.poppins(
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