import 'package:flutter/material.dart';

/// Design tokens and constants for Palmer Behavioral Health Coach
class AppConstants {
  // Color Palette (from requirements document)
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color primaryBlue = Color(0xFF007AFF);
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textMuted = Color(0xFF999999);
  static const Color border = Color(0xFFE0E0E0);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);

  // Typography sizes
  static const double largeTitleSize = 28.0;
  static const double titleSize = 24.0;
  static const double subtitleSize = 20.0;
  static const double bodySize = 16.0;
  static const double captionSize = 14.0;
  static const double smallSize = 12.0;
  static const double tinySize = 11.0;

  // Layout specifications
  static const double screenPadding = 20.0;
  static const double cardMargin = 10.0;
  static const double cardPadding = 15.0;
  static const double cardBorderRadius = 12.0;
  static const double inputBorderRadius = 20.0;
  static const double buttonBorderRadius = 20.0;
  static const double shadowBlurRadius = 4.0;
  static const double shadowElevation = 3.0;

  // Text Styles
  static const TextStyle largeTitleStyle = TextStyle(
    fontSize: largeTitleSize,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle titleStyle = TextStyle(
    fontSize: titleSize,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: subtitleSize,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: bodySize,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: captionSize,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );

  static const TextStyle smallStyle = TextStyle(
    fontSize: smallSize,
    fontWeight: FontWeight.normal,
    color: textMuted,
  );

  // Card styling
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(cardBorderRadius),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: shadowBlurRadius,
        offset: const Offset(0, 2),
      ),
    ],
  );
}