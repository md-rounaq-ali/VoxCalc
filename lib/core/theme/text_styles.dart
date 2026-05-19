import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';

/// Elite typographic system for VoxCalc.
/// Uses Google Fonts to create a premium, high-tech, and futuristic mathematical interface.
class AppTextStyles {
  /// Monospace display style for neon calculations
  static TextStyle displayStyle(ThemeMode mode, {
    double fontSize = 36,
    FontWeight fontWeight = FontWeight.bold,
    bool glow = false,
    Color? customColor,
  }) {
    final baseColor = customColor ?? AppTheme.getTextColor(mode);
    final accent = AppTheme.getAccentColor(mode);

    return GoogleFonts.shareTechMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: baseColor,
      shadows: glow
          ? [
              Shadow(color: accent.withOpacity(0.8), blurRadius: 12),
              Shadow(color: accent.withOpacity(0.5), blurRadius: 24),
            ]
          : null,
    );
  }

  /// System sans-serif style for clear screen headers
  static TextStyle headerStyle(ThemeMode mode, {
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.bold,
    bool glow = false,
  }) {
    final baseColor = AppTheme.getTextColor(mode);
    final accent = AppTheme.getAccentColor(mode);

    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: baseColor,
      shadows: glow
          ? [Shadow(color: accent.withOpacity(0.4), blurRadius: 8)]
          : null,
    );
  }

  /// System sans-serif style for descriptive labels and buttons
  static TextStyle bodyStyle(ThemeMode mode, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? customColor,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: customColor ?? AppTheme.getTextColor(mode),
    );
  }

  /// Stylized system monospace style for math derivations
  static TextStyle monoStyle(ThemeMode mode, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return GoogleFonts.spaceMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: AppTheme.getTextColor(mode),
    );
  }
}
