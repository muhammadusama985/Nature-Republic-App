import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const Color background = Color(0xFFFFFAF5);
  static const Color surface = Colors.white;
  static const Color text = Color(0xFF2A1B16);
  static const Color muted = Color(0xFF7E6C64);
  static const Color accent = Color(0xFFEC4B8F);
  static const Color accentDark = Color(0xFFC83373);
  static const Color gold = Color(0xFFD8B57F);

  static ThemeData get themeData {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        primary: accent,
        secondary: gold,
        surface: surface,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: text, height: 1.05),
        headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: text),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: text),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: text),
        bodyLarge: TextStyle(fontSize: 15, color: text, height: 1.65),
        bodyMedium: TextStyle(fontSize: 14, color: muted, height: 1.6),
      ),
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.07)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.07)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: accent),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }
}
