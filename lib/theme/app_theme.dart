import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ClickBites Design System
/// Faithfully matching the warm organic cream & terracotta aesthetic
/// of the reference food delivery app, crafted for Konongo, Ghana.

class AppColors {
  AppColors._();

  // Brand Core - Restrained Terracotta & Warm Earth
  static const Color primary = Color(0xFFBD532B);       // Spiced Terracotta Red
  static const Color primaryDark = Color(0xFF983D1B);   // Deep Terracotta
  static const Color primaryLight = Color(0xFFE2744B);  // Warm Rust
  static const Color primarySubtle = Color(0xFFFBF0EA); // Terracotta Tint (Light)
  static const Color primarySubtleDark = Color(0xFF331F17); // Terracotta Tint (Dark)

  // Organic Warm Neutrals (Light Mode)
  static const Color background = Color(0xFFF6EFE8);    // Warm Cafe Cream
  static const Color surface = Color(0xFFFFFFFF);       // Crisp White Card
  static const Color surfaceElevated = Color(0xFFF9F4EE); // Soft Light Beige
  static const Color surfaceMuted = Color(0xFFEDE4DA);  // Warm Border/Divider Surface

  // Accessible Dark Mode Neutrals (Distinct Surface Levels & High Contrast)
  static const Color darkBackground = Color(0xFF161210);      // Level 0: Deep Warm Charcoal
  static const Color darkSurface = Color(0xFF221C18);         // Level 1: Warm Elevated Surface
  static const Color darkSurfaceElevated = Color(0xFF2E2621); // Level 2: Top Card Surface
  static const Color darkSurfaceMuted = Color(0xFF3B312B);    // Level 3: Active Element / Stroke

  // Typography Colors (Light Mode)
  static const Color textPrimary = Color(0xFF261B14);   // Deep Charcoal Brown (AAA contrast)
  static const Color textSecondary = Color(0xFF756458); // Warm Muted Umber (AA contrast)
  static const Color textTertiary = Color(0xFFA8988C);  // Soft Neutral Warm Gray
  static const Color textOnPrimary = Color(0xFFFFFFFF); // Pure White on Terracotta

  // Typography Colors (Dark Mode)
  static const Color darkTextPrimary = Color(0xFFF8F2EC);   // Soft Crisp White (AAA contrast)
  static const Color darkTextSecondary = Color(0xFFB5A79E); // Warm Muted Sand (AA contrast)
  static const Color darkTextTertiary = Color(0xFF7F7167);  // Low-emphasis Sand

  // Accents
  static const Color accent = Color(0xFFD48B28);        // Warm Ghanaian Gold
  static const Color accentLight = Color(0xFFFCEECC);   // Light Gold Cream
  static const Color warning = Color(0xFFD48B28);       // Warm Amber Warning
  static const Color success = Color(0xFF2E7D32);       // Fresh Garden Green
  static const Color error = Color(0xFFC0392B);         // Alert Red

  // Borders & Outlines
  static const Color border = Color(0xFFEFE6DC);        // Organic Soft Border
  static const Color borderSubtle = Color(0xFFF4ECE4);  // Barely-there divider
  static const Color darkBorder = Color(0xFF382F28);    // Dark Mode Border
  static const Color darkBorderSubtle = Color(0xFF2A221C);
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double base = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;
  static const double huge = 48.0;
  static const double massive = 64.0;
}

class AppRadius {
  AppRadius._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double pill = 28.0;
  static const double full = 100.0;
}

class AppTypography {
  AppTypography._();

  /// Wordmark / Brand title
  static TextStyle brandLogo(BuildContext context) => GoogleFonts.playfairDisplay(
    fontSize: 26,
    fontWeight: FontWeight.w900,
    letterSpacing: 2.5,
    color: AppColors.primary,
  );

  /// Brand Subtitle
  static TextStyle brandSubtitle(BuildContext context) => GoogleFonts.plusJakartaSans(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: AppColors.textSecondary,
  );

  /// Hero Display
  static TextStyle heroTitle(BuildContext context) => GoogleFonts.plusJakartaSans(
    fontSize: 26,
    fontWeight: FontWeight.w900,
    height: 1.08,
    letterSpacing: -0.3,
    color: Colors.white,
  );

  /// Section Headings
  static TextStyle sectionTitle(BuildContext context) => GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  /// Card Headings
  static TextStyle cardTitle(BuildContext context) => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  /// Body Standard
  static TextStyle body(BuildContext context) => GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColors.textSecondary,
  );

  /// Small Metadata / Caption
  static TextStyle caption(BuildContext context) => GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.textTertiary,
  );

  /// Price
  static TextStyle price(BuildContext context) => GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  /// Button Label
  static TextStyle button(BuildContext context) => GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    color: AppColors.textOnPrimary,
  );
}

class AppShadows {
  AppShadows._();

  static List<BoxShadow> get soft => [
    BoxShadow(
      color: const Color(0xFF261B14).withValues(alpha: 0.05),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get card => [
    BoxShadow(
      color: const Color(0xFF261B14).withValues(alpha: 0.06),
      blurRadius: 18,
      spreadRadius: -2,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get floatingNav => [
    BoxShadow(
      color: const Color(0xFF261B14).withValues(alpha: 0.10),
      blurRadius: 28,
      spreadRadius: -4,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get buttonElevated => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.35),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
  );
}

ThemeData buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryLight,
      onPrimary: AppColors.textOnPrimary,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      error: AppColors.error,
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
  );
}
