import 'package:flutter/material.dart';

/// VoxCivica — Civic Trust Palette
/// Deep Navy + Teal + Mint  ·  Professional, government-grade authority.
abstract class AppColors {
  // ── Core Brand ──────────────────────────────────────────────────────
  static const Color navy   = Color(0xFF0B1F4B); // Primary — deep authority
  static const Color teal   = Color(0xFF028090); // Accent  — civic trust
  static const Color mint   = Color(0xFF02C39A); // Highlight — action / success
  static const Color ice    = Color(0xFFF0F4F8); // Surface — clean background
  static const Color white  = Color(0xFFFFFFFF); // Pure white

  // ── Semantic ─────────────────────────────────────────────────────────
  static const Color primary   = navy;
  static const Color accent    = teal;
  static const Color highlight = mint;
  static const Color surface   = ice;
  static const Color urgent    = Color(0xFFE63946); // Urgent / error
  static const Color resolved  = Color(0xFF2DC653); // Resolved / success

  // ── Text on dark backgrounds ─────────────────────────────────────────
  static const Color onPrimary  = white;
  static const Color textDark   = Color(0xFF0B1F4B);   // navy
  static const Color textMuted  = Color(0xFF52637A);   // muted slate
  static const Color textLight  = Color(0xFF8BA0B4);   // lighter grey-blue

  // ── Surface tints ────────────────────────────────────────────────────
  static const Color surfaceCard   = white;
  static const Color border        = Color(0xFFD7E2EB);
  static const Color divider       = Color(0xFFE8EEF4);

  // ── Gradient helpers ─────────────────────────────────────────────────
  static const LinearGradient navyToTeal = LinearGradient(
    colors: [navy, teal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealToMint = LinearGradient(
    colors: [teal, mint],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Full MaterialApp ThemeData for VoxCivica.
ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary:          AppColors.primary,
      onPrimary:        AppColors.onPrimary,
      primaryContainer: AppColors.navy.withOpacity(0.12),
      onPrimaryContainer: AppColors.navy,
      secondary:        AppColors.accent,
      onSecondary:      AppColors.onPrimary,
      secondaryContainer: AppColors.teal.withOpacity(0.12),
      onSecondaryContainer: AppColors.teal,
      tertiary:         AppColors.highlight,
      onTertiary:       AppColors.onPrimary,
      error:            AppColors.urgent,
      onError:          AppColors.onPrimary,
      surface:          AppColors.surface,
      onSurface:        AppColors.textDark,
      surfaceContainerHighest: AppColors.ice,
      outline:          AppColors.border,
    ),
    scaffoldBackgroundColor: AppColors.ice,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.navy,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.onPrimary),
      titleTextStyle: TextStyle(
        color: AppColors.onPrimary,
        fontWeight: FontWeight.w800,
        fontSize: 20,
        letterSpacing: -0.3,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.accent,
        side: const BorderSide(color: AppColors.accent),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.accent),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accent, width: 2),
      ),
      hintStyle: const TextStyle(color: AppColors.textLight),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.ice,
      selectedColor: AppColors.teal.withOpacity(0.15),
      labelStyle: const TextStyle(color: AppColors.textDark),
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.teal),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.navy,
      contentTextStyle: const TextStyle(color: AppColors.onPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.teal,
      foregroundColor: AppColors.onPrimary,
    ),
  );
}
