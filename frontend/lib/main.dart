import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/notifiers.dart';
import 'views/widget_tree.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return ValueListenableBuilder<bool>(
        valueListenable: isLightModeNotifier,
        builder: (context, isLightMode, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: themeProvider.lightColors.backgroundColor,
              extensions: [themeProvider.lightColors],
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: themeProvider.darkColors.backgroundColor,
              extensions: [themeProvider.darkColors],
            ),
            themeMode: isLightMode ? ThemeMode.light : ThemeMode.dark,
            home: const WidgetTree(),
          );
        },
      );
    });
  }
}

class AppColors extends ThemeExtension<AppColors> {
  final Color primaryColor;
  final Color secondaryColor;
  final Color soundColor;
  final Color patternColor;
  final Color dictionaryColor;
  final Color backgroundColor;
  final Color accentColor;
  final Color navSelectedColor;
  final Color navUnselectedColor;
  final Color cardColor;
  final Color buttonPrimaryColor;
  final Color buttonSecondaryColor;
  final Color buttonTertiaryColor;
  final Color waveformLiveColor;
  final Color waveformFixedColor;
  final Color waveformSeekColor;
  final Color gradientStartColor;
  final Color gradientEndColor;
  final Color highlightColor;
  final Color errorColor;

  AppColors({
    required this.primaryColor,
    required this.secondaryColor,
    required this.soundColor,
    required this.patternColor,
    required this.dictionaryColor,
    required this.backgroundColor,
    required this.accentColor,
    required this.navSelectedColor,
    required this.navUnselectedColor,
    required this.cardColor,
    required this.buttonPrimaryColor,
    required this.buttonSecondaryColor,
    required this.buttonTertiaryColor,
    required this.waveformLiveColor,
    required this.waveformFixedColor,
    required this.waveformSeekColor,
    required this.gradientStartColor,
    required this.gradientEndColor,
    required this.highlightColor,
    required this.errorColor,
  });

  @override
  AppColors copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    Color? soundColor,
    Color? patternColor,
    Color? dictionaryColor,
    Color? backgroundColor,
    Color? accentColor,
    Color? navSelectedColor,
    Color? navUnselectedColor,
    Color? cardColor,
    Color? buttonPrimaryColor,
    Color? buttonSecondaryColor,
    Color? buttonTertiaryColor,
    Color? waveformLiveColor,
    Color? waveformFixedColor,
    Color? waveformSeekColor,
    Color? gradientStartColor,
    Color? gradientEndColor,
    Color? highlightColor,
    Color? errorColor,
  }) {
    return AppColors(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      soundColor: soundColor ?? this.soundColor,
      patternColor: patternColor ?? this.patternColor,
      dictionaryColor: dictionaryColor ?? this.dictionaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      accentColor: accentColor ?? this.accentColor,
      navSelectedColor: navSelectedColor ?? this.navSelectedColor,
      navUnselectedColor: navUnselectedColor ?? this.navUnselectedColor,
      cardColor: cardColor ?? this.cardColor,
      buttonPrimaryColor: buttonPrimaryColor ?? this.buttonPrimaryColor,
      buttonSecondaryColor: buttonSecondaryColor ?? this.buttonSecondaryColor,
      buttonTertiaryColor: buttonTertiaryColor ?? this.buttonTertiaryColor,
      waveformLiveColor: waveformLiveColor ?? this.waveformLiveColor,
      waveformFixedColor: waveformFixedColor ?? this.waveformFixedColor,
      waveformSeekColor: waveformSeekColor ?? this.waveformSeekColor,
      gradientStartColor: gradientStartColor ?? this.gradientStartColor,
      gradientEndColor: gradientEndColor ?? this.gradientEndColor,
      highlightColor: highlightColor ?? this.highlightColor,
      errorColor: errorColor ?? this.errorColor,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
      secondaryColor: Color.lerp(secondaryColor, other.secondaryColor, t)!,
      soundColor: Color.lerp(soundColor, other.soundColor, t)!,
      patternColor: Color.lerp(patternColor, other.patternColor, t)!,
      dictionaryColor: Color.lerp(dictionaryColor, other.dictionaryColor, t)!,
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      accentColor: Color.lerp(accentColor, other.accentColor, t)!,
      navSelectedColor: Color.lerp(navSelectedColor, other.navSelectedColor, t)!,
      navUnselectedColor: Color.lerp(navUnselectedColor, other.navUnselectedColor, t)!,
      cardColor: Color.lerp(cardColor, other.cardColor, t)!,
      buttonPrimaryColor: Color.lerp(buttonPrimaryColor, other.buttonPrimaryColor, t)!,
      buttonSecondaryColor: Color.lerp(buttonSecondaryColor, other.buttonSecondaryColor, t)!,
      buttonTertiaryColor: Color.lerp(buttonTertiaryColor, other.buttonTertiaryColor, t)!,
      waveformLiveColor: Color.lerp(waveformLiveColor, other.waveformLiveColor, t)!,
      waveformFixedColor: Color.lerp(waveformFixedColor, other.waveformFixedColor, t)!,
      waveformSeekColor: Color.lerp(waveformSeekColor, other.waveformSeekColor, t)!,
      gradientStartColor: Color.lerp(gradientStartColor, other.gradientStartColor, t)!,
      gradientEndColor: Color.lerp(gradientEndColor, other.gradientEndColor, t)!,
      highlightColor: Color.lerp(highlightColor, other.highlightColor, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
    );
  }
}

class ThemeProvider with ChangeNotifier {
  AppColors _lightColors = AppColors(
    primaryColor: Colors.blueGrey,
    secondaryColor: Colors.black87,
    soundColor: Colors.lightBlueAccent,
    patternColor: Colors.deepPurpleAccent,
    dictionaryColor: Colors.teal,
    backgroundColor: Colors.white,
    accentColor: Colors.greenAccent,
    navSelectedColor: Colors.blue,
    navUnselectedColor: Colors.grey,
    cardColor: Colors.orange.shade100,
    buttonPrimaryColor: Colors.green.shade700,
    buttonSecondaryColor: Colors.orange.shade700,
    buttonTertiaryColor: Colors.purple.shade600,
    waveformLiveColor: Colors.purple.shade700,
    waveformFixedColor: Colors.purple.shade200,
    waveformSeekColor: Colors.orange.shade300,
    gradientStartColor: Colors.purple.shade50,
    gradientEndColor: Colors.white,
    highlightColor: Colors.purple.shade600,
    errorColor: Colors.red.shade600,
  );

  AppColors _darkColors = AppColors(
    primaryColor: Colors.white70,
    secondaryColor: Colors.grey.shade300,
    soundColor: Colors.lightBlue,
    patternColor: Colors.purpleAccent,
    dictionaryColor: Colors.tealAccent,
    backgroundColor: Colors.grey.shade900,
    accentColor: Colors.green,
    navSelectedColor: Colors.blueAccent,
    navUnselectedColor: Colors.grey.shade600,
    cardColor: Colors.yellow.shade200,
    buttonPrimaryColor: Colors.green.shade600,
    buttonSecondaryColor: Colors.orange.shade600,
    buttonTertiaryColor: Colors.purple.shade500,
    waveformLiveColor: Colors.blue.shade600,
    waveformFixedColor: Colors.blue.shade200,
    waveformSeekColor: Colors.red.shade300,
    gradientStartColor: Colors.blue.shade700,
    gradientEndColor: Colors.blue.shade900,
    highlightColor: Colors.blue.shade600,
    errorColor: Colors.red.shade500,
  );

  AppColors get lightColors => _lightColors;
  AppColors get darkColors => _darkColors;

  void updateLightColors({
    Color? primaryColor,
    Color? secondaryColor,
    Color? soundColor,
    Color? patternColor,
    Color? dictionaryColor,
    Color? backgroundColor,
    Color? accentColor,
    Color? navSelectedColor,
    Color? navUnselectedColor,
    Color? cardColor,
    Color? buttonPrimaryColor,
    Color? buttonSecondaryColor,
    Color? buttonTertiaryColor,
    Color? waveformLiveColor,
    Color? waveformFixedColor,
    Color? waveformSeekColor,
    Color? gradientStartColor,
    Color? gradientEndColor,
    Color? highlightColor,
    Color? errorColor,
  }) {
    _lightColors = _lightColors.copyWith(
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      soundColor: soundColor,
      patternColor: patternColor,
      dictionaryColor: dictionaryColor,
      backgroundColor: backgroundColor,
      accentColor: accentColor,
      navSelectedColor: navSelectedColor,
      navUnselectedColor: navUnselectedColor,
      cardColor: cardColor,
      buttonPrimaryColor: buttonPrimaryColor,
      buttonSecondaryColor: buttonSecondaryColor,
      buttonTertiaryColor: buttonTertiaryColor,
      waveformLiveColor: waveformLiveColor,
      waveformFixedColor: waveformFixedColor,
      waveformSeekColor: waveformSeekColor,
      gradientStartColor: gradientStartColor,
      gradientEndColor: gradientEndColor,
      highlightColor: highlightColor,
      errorColor: errorColor,
    );
    notifyListeners();
  }

  void updateDarkColors({
    Color? primaryColor,
    Color? secondaryColor,
    Color? soundColor,
    Color? patternColor,
    Color? dictionaryColor,
    Color? backgroundColor,
    Color? accentColor,
    Color? navSelectedColor,
    Color? navUnselectedColor,
    Color? cardColor,
    Color? buttonPrimaryColor,
    Color? buttonSecondaryColor,
    Color? buttonTertiaryColor,
    Color? waveformLiveColor,
    Color? waveformFixedColor,
    Color? waveformSeekColor,
    Color? gradientStartColor,
    Color? gradientEndColor,
    Color? highlightColor,
    Color? errorColor,
  }) {
    _darkColors = _darkColors.copyWith(
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      soundColor: soundColor,
      patternColor: patternColor,
      dictionaryColor: dictionaryColor,
      backgroundColor: backgroundColor,
      accentColor: accentColor,
      navSelectedColor: navSelectedColor,
      navUnselectedColor: navUnselectedColor,
      cardColor: cardColor,
      buttonPrimaryColor: buttonPrimaryColor,
      buttonSecondaryColor: buttonSecondaryColor,
      buttonTertiaryColor: buttonTertiaryColor,
      waveformLiveColor: waveformLiveColor,
      waveformFixedColor: waveformFixedColor,
      waveformSeekColor: waveformSeekColor,
      gradientStartColor: gradientStartColor,
      gradientEndColor: gradientEndColor,
      highlightColor: highlightColor,
      errorColor: errorColor,
    );
    notifyListeners();
  }
}