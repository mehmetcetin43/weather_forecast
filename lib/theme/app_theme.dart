import 'package:flutter/material.dart';

class AppTheme {
  // Color palette
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color secondaryBlue = Color(0xFF1976D2);
  static const Color accentBlue = Color(0xFF64B5F6);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color darkBlue = Color(0xFF0D47A1);
  
  static const Color warmOrange = Color(0xFFFF9800);
  static const Color coolCyan = Color(0xFF00BCD4);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningAmber = Color(0xFFFFC107);
  static const Color errorRed = Color(0xFFF44336);
  
  // Weather-specific colors
  static const Color sunnyGradientStart = Color(0xFFFF9800);
  static const Color sunnyGradientEnd = Color(0xFFFFEB3B);
  static const Color cloudyGradientStart = Color(0xFF9E9E9E);
  static const Color cloudyGradientEnd = Color(0xFFE0E0E0);
  static const Color rainyGradientStart = Color(0xFF2196F3);
  static const Color rainyGradientEnd = Color(0xFF64B5F6);
  static const Color snowyGradientStart = Color(0xFFE3F2FD);
  static const Color snowyGradientEnd = Color(0xFFBBDEFB);
  static const Color stormyGradientStart = Color(0xFF673AB7);
  static const Color stormyGradientEnd = Color(0xFF9C27B0);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 8,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 8,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.grey.shade800,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade800,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  // Weather-specific gradients
  static LinearGradient getWeatherGradient(int iconCode, {bool isDay = true}) {
    if (iconCode >= 1 && iconCode <= 3) {
      return const LinearGradient(
        colors: [sunnyGradientStart, sunnyGradientEnd],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (iconCode >= 4 && iconCode <= 8) {
      return const LinearGradient(
        colors: [cloudyGradientStart, cloudyGradientEnd],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (iconCode >= 12 && iconCode <= 18) {
      return const LinearGradient(
        colors: [rainyGradientStart, rainyGradientEnd],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (iconCode >= 15 && iconCode <= 17) {
      return const LinearGradient(
        colors: [stormyGradientStart, stormyGradientEnd],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (iconCode >= 19 && iconCode <= 24) {
      return const LinearGradient(
        colors: [snowyGradientStart, snowyGradientEnd],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else {
      return const LinearGradient(
        colors: [cloudyGradientStart, cloudyGradientEnd],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }
  }

  // Default gradient for app background
  static const LinearGradient defaultGradient = LinearGradient(
    colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
