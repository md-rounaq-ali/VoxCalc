import 'package:flutter/material.dart';

/// Elite visual themes system for VoxCalc.
/// Houses Dark Fusion, Cyberpunk, and Light Aurora styling schemas.
class AppTheme {
  static String currentTheme = "dark_fusion";

  // ==========================================
  // Custom Color Token Getters
  // ==========================================

  // Background Gradients
  static List<Color> getBgGradient(dynamic ignored) {
    if (currentTheme == "light_aurora") {
      return [const Color(0xFFF3F5FA), const Color(0xFFE3E9F5)];
    } else if (currentTheme == "cyberpunk") {
      return [const Color(0xFF0C0015), const Color(0xFF1E002B)];
    } else { // dark_fusion (default)
      return [const Color(0xFF07080B), const Color(0xFF0F1016)];
    }
  }

  // Accent and Border Colors
  static Color getAccentColor(dynamic ignored) {
    if (currentTheme == "light_aurora") {
      return const Color(0xFF4FACFE); // Soft pastel blue
    } else if (currentTheme == "cyberpunk") {
      return const Color(0xFFFF007F); // Shocking neon pink
    } else { // dark_fusion
      return const Color(0xFF00F2FE); // Glowing Neon Cyan
    }
  }

  static Color getSecondaryAccent(dynamic ignored) {
    if (currentTheme == "light_aurora") {
      return const Color(0xFF00C6FF); // Soft Turquoise
    } else if (currentTheme == "cyberpunk") {
      return const Color(0xFF00FF66); // Cyber Terminal Green
    } else { // dark_fusion
      return const Color(0xFF9B51E0); // Electric Purple
    }
  }

  // Tactile Glass Key Colors
  static Color getKeyColor(dynamic ignored, {bool isOperator = false, bool isAction = false}) {
    if (isAction) {
      return getAccentColor(currentTheme);
    }
    if (isOperator) {
      return getSecondaryAccent(currentTheme).withOpacity(0.2);
    }

    if (currentTheme == "light_aurora") {
      return Colors.white.withOpacity(0.7);
    } else if (currentTheme == "cyberpunk") {
      return const Color(0xFF280B3B).withOpacity(0.4);
    } else { // dark_fusion
      return const Color(0xFF1E2130).withOpacity(0.45);
    }
  }

  // Text Color Schemes
  static Color getTextColor(dynamic ignored, {bool isAccent = false}) {
    if (isAccent) return Colors.black;

    if (currentTheme == "light_aurora") {
      return const Color(0xFF1E293B);
    } else if (currentTheme == "cyberpunk") {
      return const Color(0xFF00FF66); // Cyber Terminal Green
    } else { // dark_fusion
      return const Color(0xFFE4E6EB);
    }
  }

  // Custom Border Decorator
  static BorderSide getBorderSide(dynamic ignored) {
    Color borderColor;
    if (currentTheme == "light_aurora") {
      borderColor = const Color(0xFF4FACFE).withOpacity(0.2);
    } else if (currentTheme == "cyberpunk") {
      borderColor = const Color(0xFFFF007F).withOpacity(0.4);
    } else { // dark_fusion
      borderColor = const Color(0xFF00F2FE).withOpacity(0.3);
    }
    return BorderSide(color: borderColor, width: 1.2);
  }

  // ==========================================
  // Flutter ThemeData Generators
  // ==========================================

  static ThemeData getThemeData(dynamic themeNameOrMode) {
    final String resolvedTheme = themeNameOrMode is String ? themeNameOrMode : currentTheme;
    final bool isLight = resolvedTheme == "light_aurora";
    final accent = getAccentColor(resolvedTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: isLight ? Brightness.light : Brightness.dark,
      primaryColor: accent,
      scaffoldBackgroundColor: Colors.transparent, // Managed by gradient view scaffold wrappers
      cardColor: isLight ? Colors.white.withOpacity(0.8) : const Color(0xFF11131E).withOpacity(0.8),
      dividerColor: isLight ? Colors.black12 : Colors.white12,
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: isLight ? Brightness.light : Brightness.dark,
        primary: accent,
        secondary: getSecondaryAccent(resolvedTheme),
        background: Colors.transparent,
      ),
    );
  }
}
