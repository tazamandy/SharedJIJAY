import 'package:flutter/material.dart';

/// Centralized app theme for consistent UI across the app
class AppTheme {
  // Primary colors
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color primaryPurple = Color(0xFF7B1FA2);
  static const Color primaryGreen = Color(0xFF388E3C);
  static const Color primaryOrange = Color(0xFFF57C00);
  static const Color primaryRed = Color(0xFFD32F2F);

  // Gradients
  static LinearGradient get blueGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryBlue, const Color(0xFF0D47A1)],
      );

  static LinearGradient get purpleGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryPurple, const Color(0xFF4A148C)],
      );

  static LinearGradient get studentGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryBlue, const Color(0xFF0D47A1)],
      );

  // Card decoration
  static BoxDecoration cardDecoration({
    Color? color,
    double borderRadius = 15,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: shadows ??
          [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
    );
  }

  // Elevated card decoration
  static BoxDecoration elevatedCardDecoration({
    Color? color,
    double borderRadius = 15,
  }) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // Button style
  static ButtonStyle primaryButtonStyle({
    Color? backgroundColor,
    Color? foregroundColor,
    double borderRadius = 12,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? primaryBlue,
      foregroundColor: foregroundColor ?? Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      elevation: 2,
    );
  }

  // Text styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white70,
  );

  static const TextStyle cardTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle cardSubtitleStyle = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );

  // Spacing
  static const double defaultPadding = 20.0;
  static const double cardPadding = 16.0;
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 15.0;
  static const double largeSpacing = 25.0;

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}

