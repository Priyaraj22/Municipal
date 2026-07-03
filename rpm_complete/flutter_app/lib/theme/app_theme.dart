import 'package:flutter/material.dart';

class AppTheme {
  // Colors - Updated to Ramco Royal Blue Theme
  static const Color teal = Color(0xFF003893); // Royal Blue from Image
  static const Color tealLight = Color(0xFF1E88E5); // Medium Blue
  static const Color blue = Color(0xFF003893);
  static const Color blueLight = Color(0xFF1E88E5);
  static const Color amber = Color(0xFFF59E0B);
  static const Color rose = Color(0xFFE11D48);
  static const Color purple = Color(0xFF7C3AED);
  static const Color ink = Color(0xFF1A1A2E);
  static const Color ink2 = Color(0xFF4B5563);
  static const Color ink3 = Color(0xFF9CA3AF);
  static const Color surface = Color(0xFFF8FAFB);
  static const Color white = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E7EB);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: blue,
        primary: blue,
        secondary: blueLight,
        surface: surface,
      ),
      scaffoldBackgroundColor: surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: blue,
        foregroundColor: white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: white,
        ),
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: border),
        ),
        margin: const EdgeInsets.only(bottom: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: blue,
          foregroundColor: white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: teal, width: 2),
        ),
        labelStyle: const TextStyle(color: ink2, fontSize: 13),
        hintStyle: const TextStyle(color: ink3, fontSize: 13),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: ink),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: ink),
        titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ink),
        bodyMedium: TextStyle(fontSize: 14, color: ink2),
        bodySmall: TextStyle(fontSize: 12, color: ink3),
      ),
    );
  }
}
