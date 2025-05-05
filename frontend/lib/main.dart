import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'data/notifiers.dart';
import 'views/widget_tree.dart';

void main() {
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
                    backgroundColor: customColors.buttonSecondaryColor,
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
    );
  }

  static AppColors light() {
    return AppColors(
      primaryColor: Colors.grey.shade800,
      secondaryColor: Colors.grey.shade600,
      textColor: Colors.grey.shade800,
      backgroundColor: Colors.grey.shade100,
      accentColor: Colors.teal.shade400,
      navSelectedColor: Colors.teal.shade400,
      navUnselectedColor: Colors.grey.shade400,
      cardColor: Colors.grey.shade200,
      buttonPrimaryColor: Colors.teal.shade400,
      buttonSecondaryColor: Colors.grey.shade400,
      waveformLiveColor: Colors.teal.shade400,
      waveformFixedColor: Colors.grey.shade400,
      waveformSeekColor: Colors.teal.shade400,
      errorColor: Colors.red.shade400,
    );
  }

  static AppColors dark() {
    return AppColors(
      primaryColor: Colors.grey.shade200,
      secondaryColor: Colors.grey.shade400,
      textColor: Colors.grey.shade200,
      backgroundColor: Colors.grey.shade900,
      accentColor: Colors.teal.shade400,
      navSelectedColor: Colors.teal.shade400,
      navUnselectedColor: Colors.grey.shade600,
      cardColor: Colors.grey.shade800,
      buttonPrimaryColor: Colors.teal.shade400,
      buttonSecondaryColor: Colors.grey.shade600,
      waveformLiveColor: Colors.teal.shade400,
      waveformFixedColor: Colors.grey.shade600,
      waveformSeekColor: Colors.teal.shade400,
      errorColor: Colors.red.shade400,
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