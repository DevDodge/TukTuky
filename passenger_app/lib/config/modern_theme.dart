import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Modern Design System with Notch Support, Safe Areas, and Advanced UI/UX
class ModernTheme {
  // ============================================================================
  // SPACING & LAYOUT
  // ============================================================================
  static const double spacingXs = 4;
  static const double spacingS = 8;
  static const double spacingM = 16;
  static const double spacingL = 24;
  static const double spacingXl = 32;
  static const double spacingXxl = 48;

  // Safe area padding for notched devices
  static const double notchPaddingTop = 16;
  static const double notchPaddingBottom = 20;
  static const double safeAreaPadding = 16;

  // ============================================================================
  // BORDER RADIUS
  // ============================================================================
  static const double radiusXs = 4;
  static const double radiusS = 8;
  static const double radiusM = 12;
  static const double radiusL = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 999;

  // ============================================================================
  // SHADOWS & ELEVATIONS
  // ============================================================================
  static final List<BoxShadow> shadowXs = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  static final List<BoxShadow> shadowS = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static final List<BoxShadow> shadowM = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> shadowL = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 12,
      offset: const Offset(0, 8),
    ),
  ];

  static final List<BoxShadow> shadowXl = [
    BoxShadow(
      color: Colors.black.withOpacity(0.20),
      blurRadius: 16,
      offset: const Offset(0, 12),
    ),
  ];

  // ============================================================================
  // GRADIENTS
  // ============================================================================
  static final LinearGradient primaryGradient = LinearGradient(
    colors: [const Color(0xFFFFD700), const Color(0xFFFFC700)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient darkGradient = LinearGradient(
    colors: [const Color(0xFF1A1A1A), const Color(0xFF0D0D0D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient accentGradient = LinearGradient(
    colors: [const Color(0xFFFF9500), const Color(0xFFFF6B00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient successGradient = LinearGradient(
    colors: [const Color(0xFF34C759), const Color(0xFF00B050)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================================================
  // ANIMATION DURATIONS
  // ============================================================================
  static const Duration durationXs = Duration(milliseconds: 100);
  static const Duration durationS = Duration(milliseconds: 200);
  static const Duration durationM = Duration(milliseconds: 300);
  static const Duration durationL = Duration(milliseconds: 500);
  static const Duration durationXl = Duration(milliseconds: 800);

  // ============================================================================
  // CURVES
  // ============================================================================
  static const Curve curveEaseInOut = Curves.easeInOut;
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveElasticOut = Curves.elasticOut;
  static const Curve curveBounceOut = Curves.bounceOut;

  // ============================================================================
  // HAPTIC FEEDBACK PATTERNS
  // ============================================================================
  static Future<void> hapticLight() async {
    await HapticFeedback.lightImpact();
  }

  static Future<void> hapticMedium() async {
    await HapticFeedback.mediumImpact();
  }

  static Future<void> hapticHeavy() async {
    await HapticFeedback.heavyImpact();
  }

  static Future<void> hapticSelection() async {
    await HapticFeedback.selectionClick();
  }

  // ============================================================================
  // RESPONSIVE BREAKPOINTS
  // ============================================================================
  static bool isSmallScreen(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isMediumScreen(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 900;

  static bool isLargeScreen(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return baseSize;
    if (width < 900) return baseSize * 1.1;
    return baseSize * 1.2;
  }

  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return baseSpacing;
    if (width < 900) return baseSpacing * 1.2;
    return baseSpacing * 1.5;
  }

  // ============================================================================
  // NOTCH & SAFE AREA HELPERS
  // ============================================================================
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.only(
      top: mediaQuery.padding.top + notchPaddingTop,
      bottom: mediaQuery.padding.bottom + notchPaddingBottom,
      left: safeAreaPadding,
      right: safeAreaPadding,
    );
  }

  static EdgeInsets getTopSafeArea(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.only(
      top: mediaQuery.padding.top + notchPaddingTop,
    );
  }

  static EdgeInsets getBottomSafeArea(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.only(
      bottom: mediaQuery.padding.bottom + notchPaddingBottom,
    );
  }

  static double getTopPadding(BuildContext context) {
    return MediaQuery.of(context).padding.top + notchPaddingTop;
  }

  static double getBottomPadding(BuildContext context) {
    return MediaQuery.of(context).padding.bottom + notchPaddingBottom;
  }
}
