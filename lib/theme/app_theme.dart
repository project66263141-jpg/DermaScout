import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color bg = Color(0xFFFBF5EC);
  static const Color paper = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF1E2E2A);
  static const Color inkSoft = Color(0xFF5C6864);
  static const Color line = Color(0xFFE9DCC4);

  static const Color teal = Color(0xFF178077);
  static const Color tealDeep = Color(0xFF0E5750);
  static const Color tealWash = Color(0xFFDBF1EC);

  static const Color bloom = Color(0xFFE1592F);
  static const Color bloomDeep = Color(0xFFB8431F);
  static const Color bloomWash = Color(0xFFFBE1D3);

  static const Color tierGreen = Color(0xFF2E7D32);
  static const Color tierGreenWash = Color(0xFFE8F5E9);

  static const Color tierAmber = Color(0xFFF9A825);
  static const Color tierAmberWash = Color(0xFFFFFDE7);

  static const Color tierOrange = Color(0xFFEF6C00);
  static const Color tierOrangeWash = Color(0xFFFFF3E0);

  static const Color tierRed = Color(0xFFC62828);
  static const Color tierRedWash = Color(0xFFFFEBEE);

  static const Color tierGrey = Color(0xFF63665F);
  static const Color tierGreyWash = Color(0xFFE9E6DD);

  static ThemeData get lightTheme {
    final baseText = GoogleFonts.ibmPlexSansTextTheme();
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.light(
        surface: paper,
        primary: tealDeep,
        secondary: bloom,
        onSurface: ink,
      ),
      textTheme: baseText.copyWith(
        headlineLarge: GoogleFonts.ibmPlexSerif(
          fontSize: 32,
          fontWeight: FontWeight.w500,
          color: ink,
          height: 1.2,
        ),
        headlineMedium: GoogleFonts.ibmPlexSerif(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: ink,
          height: 1.25,
        ),
        titleLarge: GoogleFonts.ibmPlexSerif(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: ink,
        ),
        bodyLarge: GoogleFonts.ibmPlexSans(
          fontSize: 15,
          color: ink,
        ),
        bodyMedium: GoogleFonts.ibmPlexSans(
          fontSize: 13.5,
          color: inkSoft,
        ),
        labelSmall: GoogleFonts.ibmPlexMono(
          fontSize: 11.5,
          color: inkSoft,
        ),
      ),
    );
  }

  static Color getTierColor(int tier) {
    switch (tier) {
      case 0: return tierGreen;
      case 1: return tierAmber;
      case 2: return tierOrange;
      case 3: return tierRed;
      default: return tierGrey;
    }
  }

  static Color getTierWash(int tier) {
    switch (tier) {
      case 0: return tierGreenWash;
      case 1: return tierAmberWash;
      case 2: return tierOrangeWash;
      case 3: return tierRedWash;
      default: return tierGreyWash;
    }
  }
}
