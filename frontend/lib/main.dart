import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/notifiers.dart';
import 'views/widget_tree.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  // Load saved preferences
  final prefs = await SharedPreferences.getInstance();
  final isLightMode = prefs.getBool('isLightMode') ?? true;
  final customColors = AppColors(
    primaryColor: Color(prefs.getInt('primaryColor') ?? 0xFF006D77),
    secondaryColor: Color(prefs.getInt('secondaryColor') ?? 0xFF5C6B73),
    textColor: Color(prefs.getInt('textColor') ?? 0xFF2D3748),
    backgroundColor: Color(prefs.getInt('backgroundColor') ?? 0xFFF5F7FA),
    accentColor: Color(prefs.getInt('accentColor') ?? 0xFFFF6F61),
    navSelectedColor: Color(prefs.getInt('navSelectedColor') ?? 0xFFFF6F61),
    navUnselectedColor: Color(prefs.getInt('navUnselectedColor') ?? 0xFFA0AEC0),
    cardColor: Color(prefs.getInt('cardColor') ?? 0xFFE8ECEF),
    buttonPrimaryColor: Color(prefs.getInt('buttonPrimaryColor') ?? 0xFFFF6F61),
    buttonSecondaryColor: Color(prefs.getInt('buttonSecondaryColor') ?? 0xFF83C5BE),
    waveformLiveColor: Color(prefs.getInt('waveformLiveColor') ?? 0xFFFFB400),
    waveformFixedColor: Color(prefs.getInt('waveformFixedColor') ?? 0xFF4A5568),
    waveformSeekColor: Color(prefs.getInt('waveformSeekColor') ?? 0xFFFF6F61),
    errorColor: Color(prefs.getInt('errorColor') ?? 0xFFE53E3E),
    soundGradientStart: Color(prefs.getInt('soundGradientStart') ?? 0xFFFF9B85),
    soundGradientEnd: Color(prefs.getInt('soundGradientEnd') ?? 0xFFFF5A5F),
    patternGradientStart: Color(prefs.getInt('patternGradientStart') ?? 0xFF4ECDC4),
    patternGradientEnd: Color(prefs.getInt('patternGradientEnd') ?? 0xFF1A936F),
    dictionaryGradientStart: Color(prefs.getInt('dictionaryGradientStart') ?? 0xFFFFD166),
    dictionaryGradientEnd: Color(prefs.getInt('dictionaryGradientEnd') ?? 0xFFEF476F),
  );

  isLightModeNotifier.value = isLightMode;
  customColorsNotifier.value = customColors;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isLightModeNotifier,
      builder: (context, isLightMode, child) {
        return ValueListenableBuilder<AppColors>(
          valueListenable: customColorsNotifier,
          builder: (context, customColors, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.light,
                scaffoldBackgroundColor: customColors.backgroundColor,
                textTheme: GoogleFonts.poppinsTextTheme(
                  Theme.of(context).textTheme.copyWith(
                        headlineSmall: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                        ),
                        bodyMedium: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customColors.buttonPrimaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    elevation: 6,
                    textStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                cardTheme: CardTheme(
                  elevation: 6,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  color: customColors.cardColor,
                ),
                snackBarTheme: SnackBarThemeData(
                  backgroundColor: customColors.accentColor,
                  contentTextStyle: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
                colorScheme: ColorScheme.fromSeed(
                  seedColor: customColors.accentColor,
                  brightness: Brightness.light,
                  primary: customColors.primaryColor,
                  secondary: customColors.accentColor,
                ),
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android: FadeTransitionBuilder(),
                    TargetPlatform.iOS: FadeTransitionBuilder(),
                    TargetPlatform.windows: FadeTransitionBuilder(),
                    TargetPlatform.macOS: FadeTransitionBuilder(),
                    TargetPlatform.linux: FadeTransitionBuilder(),
                  },
                ),
                extensions: [customColors],
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.dark,
                scaffoldBackgroundColor: customColors.backgroundColor,
                textTheme: GoogleFonts.poppinsTextTheme(
                  Theme.of(context).textTheme.copyWith(
                        headlineSmall: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                        ),
                        bodyMedium: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customColors.buttonPrimaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    elevation: 6,
                    textStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                cardTheme: CardTheme(
                  elevation: 6,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  color: customColors.cardColor,
                ),
                iconButtonTheme: IconButtonThemeData(
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
                snackBarTheme: SnackBarThemeData(
                  backgroundColor: customColors.accentColor,
                  contentTextStyle: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
                colorScheme: ColorScheme.fromSeed(
                  seedColor: customColors.accentColor,
                  brightness: Brightness.dark,
                  primary: customColors.primaryColor,
                  secondary: customColors.accentColor,
                ),
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android: FadeTransitionBuilder(),
                    TargetPlatform.iOS: FadeTransitionBuilder(),
                    TargetPlatform.windows: FadeTransitionBuilder(),
                    TargetPlatform.macOS: FadeTransitionBuilder(),
                    TargetPlatform.linux: FadeTransitionBuilder(),
                  },
                ),
                extensions: [customColors],
              ),
              themeMode: isLightMode ? ThemeMode.light : ThemeMode.dark,
              home: const WidgetTree(),
            );
          },
        );
      },
    );
  }
}

class AppColors extends ThemeExtension<AppColors> {
  final Color primaryColor;
  final Color secondaryColor;
  final Color textColor;
  final Color backgroundColor;
  final Color accentColor;
  final Color navSelectedColor;
  final Color navUnselectedColor;
  final Color cardColor;
  final Color buttonPrimaryColor;
  final Color buttonSecondaryColor;
  final Color waveformLiveColor;
  final Color waveformFixedColor;
  final Color waveformSeekColor;
  final Color errorColor;
  final Color soundGradientStart;
  final Color soundGradientEnd;
  final Color patternGradientStart;
  final Color patternGradientEnd;
  final Color dictionaryGradientStart;
  final Color dictionaryGradientEnd;

  const AppColors({
    required this.primaryColor,
    required this.secondaryColor,
    required this.textColor,
    required this.backgroundColor,
    required this.accentColor,
    required this.navSelectedColor,
    required this.navUnselectedColor,
    required this.cardColor,
    required this.buttonPrimaryColor,
    required this.buttonSecondaryColor,
    required this.waveformLiveColor,
    required this.waveformFixedColor,
    required this.waveformSeekColor,
    required this.errorColor,
    required this.soundGradientStart,
    required this.soundGradientEnd,
    required this.patternGradientStart,
    required this.patternGradientEnd,
    required this.dictionaryGradientStart,
    required this.dictionaryGradientEnd,
  });

  @override
  AppColors copyWith({
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
  }) {
    return AppColors(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      textColor: textColor ?? this.textColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      accentColor: accentColor ?? this.accentColor,
      navSelectedColor: navSelectedColor ?? this.navSelectedColor,
      navUnselectedColor: navUnselectedColor ?? this.navUnselectedColor,
      cardColor: cardColor ?? this.cardColor,
      buttonPrimaryColor: buttonPrimaryColor ?? this.buttonPrimaryColor,
      buttonSecondaryColor: buttonSecondaryColor ?? this.buttonSecondaryColor,
      waveformLiveColor: waveformLiveColor ?? this.waveformLiveColor,
      waveformFixedColor: waveformFixedColor ?? this.waveformFixedColor,
      waveformSeekColor: waveformSeekColor ?? this.waveformSeekColor,
      errorColor: errorColor ?? this.errorColor,
      soundGradientStart: soundGradientStart ?? this.soundGradientStart,
      soundGradientEnd: soundGradientEnd ?? this.soundGradientEnd,
      patternGradientStart: patternGradientStart ?? this.patternGradientStart,
      patternGradientEnd: patternGradientEnd ?? this.patternGradientEnd,
      dictionaryGradientStart: dictionaryGradientStart ?? this.dictionaryGradientStart,
      dictionaryGradientEnd: dictionaryGradientEnd ?? this.dictionaryGradientEnd,
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
      textColor: Color.lerp(textColor, other.textColor, t)!,
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      accentColor: Color.lerp(accentColor, other.accentColor, t)!,
      navSelectedColor: Color.lerp(navSelectedColor, other.navSelectedColor, t)!,
      navUnselectedColor: Color.lerp(navUnselectedColor, other.navUnselectedColor, t)!,
      cardColor: Color.lerp(cardColor, other.cardColor, t)!,
      buttonPrimaryColor: Color.lerp(buttonPrimaryColor, other.buttonPrimaryColor, t)!,
      buttonSecondaryColor: Color.lerp(buttonSecondaryColor, other.buttonSecondaryColor, t)!,
      waveformLiveColor: Color.lerp(waveformLiveColor, other.waveformLiveColor, t)!,
      waveformFixedColor: Color.lerp(waveformFixedColor, other.waveformFixedColor, t)!,
      waveformSeekColor: Color.lerp(waveformSeekColor, other.waveformSeekColor, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
      soundGradientStart: Color.lerp(soundGradientStart, other.soundGradientStart, t)!,
      soundGradientEnd: Color.lerp(soundGradientEnd, other.soundGradientEnd, t)!,
      patternGradientStart: Color.lerp(patternGradientStart, other.patternGradientStart, t)!,
      patternGradientEnd: Color.lerp(patternGradientEnd, other.patternGradientEnd, t)!,
      dictionaryGradientStart: Color.lerp(dictionaryGradientStart, other.dictionaryGradientStart, t)!,
      dictionaryGradientEnd: Color.lerp(dictionaryGradientEnd, other.dictionaryGradientEnd, t)!,
    );
  }

  static AppColors light() {
    return AppColors(
      primaryColor: const Color(0xFF006D77),
      secondaryColor: const Color(0xFF5C6B73),
      textColor: const Color(0xFF2D3748),
      backgroundColor: const Color(0xFFF5F7FA),
      accentColor: const Color(0xFFFF6F61),
      navSelectedColor: const Color(0xFFFF6F61),
      navUnselectedColor: const Color(0xFFA0AEC0),
      cardColor: const Color(0xFFE8ECEF),
      buttonPrimaryColor: const Color(0xFFFF6F61),
      buttonSecondaryColor: const Color(0xFF83C5BE),
      waveformLiveColor: const Color(0xFFFFB400),
      waveformFixedColor: const Color(0xFF4A5568),
      waveformSeekColor: const Color(0xFFFF6F61),
      errorColor: const Color(0xFFE53E3E),
      soundGradientStart: const Color(0xFFFF9B85),
      soundGradientEnd: const Color(0xFFFF5A5F),
      patternGradientStart: const Color(0xFF4ECDC4),
      patternGradientEnd: const Color(0xFF1A936F),
      dictionaryGradientStart: const Color(0xFFFFD166),
      dictionaryGradientEnd: const Color(0xFFEF476F),
    );
  }

  static AppColors dark() {
    return AppColors(
      primaryColor: const Color(0xFF83C5BE),
      secondaryColor: const Color(0xFFA0AEC0),
      textColor: const Color(0xFFE2E8F0),
      backgroundColor: const Color(0xFF1A2026),
      accentColor: const Color(0xFFFF6F61),
      navSelectedColor: const Color(0xFFFF6F61),
      navUnselectedColor: const Color(0xFF718096),
      cardColor: const Color(0xFF2D3748),
      buttonPrimaryColor: const Color(0xFFFF6F61),
      buttonSecondaryColor: const Color(0xFF4A7C7A),
      waveformLiveColor: const Color(0xFFFFB400),
      waveformFixedColor: const Color(0xFF718096),
      waveformSeekColor: const Color(0xFFFF6F61),
      errorColor: const Color(0xFFF56565),
      soundGradientStart: const Color(0xFFFF9B85),
      soundGradientEnd: const Color(0xFFFF5A5F),
      patternGradientStart: const Color(0xFF4ECDC4),
      patternGradientEnd: const Color(0xFF1A936F),
      dictionaryGradientStart: const Color(0xFFFFD166),
      dictionaryGradientEnd: const Color(0xFFEF476F),
    );
  }

  static AppColors of(BuildContext context) {
    return Theme.of(context).extension<AppColors>()!;
  }
}

class FadeTransitionBuilder extends PageTransitionsBuilder {
  const FadeTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}