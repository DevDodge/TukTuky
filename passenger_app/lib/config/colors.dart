import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFFDD8B01);      // Golden Yellow - Main accent
  static const Color secondary = Color(0xFFDC8F01);    // Orange Gold - Gradients
  static const Color highlight = Color(0xFFFCF202);   // Bright Yellow - Badges/Prices
  
  // Background & Surface
  static const Color background = Color(0xFF0A0C0B);  // Black - Dark background
  static const Color surface = Color(0xFFFFFFFF);     // White - Cards/Text
  
  // Neutral Colors
  static const Color darkGrey = Color(0xFF1A1A1A);
  static const Color mediumGrey = Color(0xFF666666);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color veryLightGrey = Color(0xFFF5F5F5);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);     // Green
  static const Color error = Color(0xFFE53935);       // Red
  static const Color warning = Color(0xFFFFA726);     // Orange
  static const Color info = Color(0xFF29B6F6);        // Blue
  
  // Semantic Colors
  static const Color sosRed = Color(0xFFFF3B30);      // SOS Button Red
  static const Color acceptGreen = Color(0xFF34C759); // Accept/Confirm
  static const Color declineRed = Color(0xFFFF3B30);  // Decline/Cancel
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );
  
  static const LinearGradient highlightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [highlight, Color(0xFFFFD700)],
  );
  
  // Glassmorphism Effect
  static Color glassBackground = surface.withOpacity(0.1);
  static Color glassBackgroundStrong = surface.withOpacity(0.2);
  
  // Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
  
  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
  
  static const List<BoxShadow> floatingShadow = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];
}
