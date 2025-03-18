import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF009a85);
  static const Color primaryColor1 = Color(0xFF009a85);
  static const Color primaryColor2 = Color(0xFFb54048);
  static const Color secondaryColor = Color(0xFF065a54);
  static const Color secondaryColo1 = Color(0xFF54c8be);

  // Background Colors
  static const Color cardColor = Color(0xFF184a84);
  static const Color cardColor1 = Color(0xFF009a85);
  static const Color cardColor2 = Color(0xFF99EED2);
  static const Color cardColor3 = Color(0xFFF4F4F4);
  static const Color cardColor4 = Color(0xFFFFE79E);


  // MaterialColor for primary and secondary colors with shades
  static const MaterialColor primaryColorShades = MaterialColor(
    0xFF009a85, // Primary color value
    <int, Color>{
      50: Color(0xFFE0F7F5),
      100: Color(0xFFB3ECE7),
      200: Color(0xFF80E1D8),
      300: Color(0xFF4DD5CA),
      400: Color(0xFF26CCC0),
      500: Color(0xFF009a85), // Primary color
      600: Color(0xFF008A7A),
      700: Color(0xFF00786D),
      800: Color(0xFF006661),
      900: Color(0xFF004D4C),
    },
  );

  static const MaterialColor secondaryColorShades = MaterialColor(
    0xFF184a84, // Secondary color value
    <int, Color>{
      50: Color(0xFFE6EAF3),
      100: Color(0xFFC0CBE0),
      200: Color(0xFF97AACB),
      300: Color(0xFF6D88B6),
      400: Color(0xFF4C6FA5),
      500: Color(0xFF184a84), // Secondary color
      600: Color(0xFF144378),
      700: Color(0xFF103B68),
      800: Color(0xFF0C3359),
      900: Color(0xFF082542),
    },
  );
}
