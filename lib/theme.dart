import 'package:flutter/material.dart';

final ThemeData themeData = new ThemeData(
    brightness: Brightness.light,
    cardColor: Colors.white,
    dividerColor: Colors.grey[300],
    backgroundColor: Colors.grey[100],
    primarySwatch: customSwatch,
    primaryColor: CustomColors.theme[500],
    primaryColorBrightness: Brightness.light,
    accentColor: CustomColors.accent[700],
    fontFamily: 'M PLUS 1p');

const MaterialColor customSwatch =
    const MaterialColor(0xFFA4C639, const <int, Color>{
  50: const Color(0xFFF4F8E7),
  100: const Color(0xFFE4EEC4),
  200: const Color(0xFFD2E39C),
  300: const Color(0xFFBFD774),
  400: const Color(0xFFB2CF57),
  500: const Color(0xFFA4C639),
  600: const Color(0xFF9CC033),
  700: const Color(0xFF92B92C),
  800: const Color(0xFF89B124),
  900: const Color(0xFF78A417),
});

class CustomColors {
  CustomColors._();
  static const Map<int, Color> theme = const <int, Color>{
    500: const Color(0xFFA4C639),
    600: const Color(0xFF9CC033),
  };

  static const Map<int, Color> accent = const <int, Color>{
    700: const Color(0xFF92B92C),
  };
}
