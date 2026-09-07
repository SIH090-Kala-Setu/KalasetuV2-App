import 'package:flutter/material.dart';

enum DarkModeStyle {
  onyx,      // #1C1C1C (Deep Onyx)
  charcoal,  // #2C2C2C (Warm Charcoal)
}

/// KalaSetuV2 — Complete Color Design System
/// Light Mode: Canvas #FAF8F5, Cards #FFFFFF, Primary #1B2A4A, Accent #F5A623
/// Dark Mode 1 (Onyx): Canvas #1C1C1C, Cards #262626, Borders #383838
/// Dark Mode 2 (Charcoal): Canvas #2C2C2C, Cards #383838, Borders #4C4C4C
class AppColors {
  AppColors._();

  // ── Brand Colors ─────────────────────────────────────────────
  static const Color primary = Color(0xFF1B2A4A);       // Deep Navy from SS
  static const Color primaryLight = Color(0xFF2E4057);
  static const Color primaryDark = Color(0xFF0F1A2E);
  static const Color accent = Color(0xFFF5A623);        // Golden Amber from SS
  static const Color accentLight = Color(0xFFFBBF24);
  static const Color accentDark = Color(0xFFD97706);

  // ── Light Theme ───────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFFAF8F5);   // Warm Cream Canvas
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightDivider = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF1B2A4A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightTextDisabled = Color(0xFF94A3B8);
  static const Color lightCardShadow = Color(0x0A000000);

  // ── Dark Theme Style 1: Deep Onyx (#1C1C1C) ──────────────────
  static const Color onyxBackground = Color(0xFF1C1C1C);
  static const Color onyxSurface = Color(0xFF262626);
  static const Color onyxSurfaceVariant = Color(0xFF303030);
  static const Color onyxBorder = Color(0xFF383838);
  static const Color onyxDivider = Color(0xFF303030);

  // ── Dark Theme Style 2: Warm Charcoal (#2C2C2C) ───────────────
  static const Color charcoalBackground = Color(0xFF2C2C2C);
  static const Color charcoalSurface = Color(0xFF383838);
  static const Color charcoalSurfaceVariant = Color(0xFF444444);
  static const Color charcoalBorder = Color(0xFF4C4C4C);
  static const Color charcoalDivider = Color(0xFF404040);

  // ── Dynamic Dark Theme Accessors ──────────────────────────────
  static DarkModeStyle currentDarkStyle = DarkModeStyle.onyx;

  static Color get darkBackground =>
      currentDarkStyle == DarkModeStyle.charcoal ? charcoalBackground : onyxBackground;
  static Color get darkSurface =>
      currentDarkStyle == DarkModeStyle.charcoal ? charcoalSurface : onyxSurface;
  static Color get darkSurfaceVariant =>
      currentDarkStyle == DarkModeStyle.charcoal ? charcoalSurfaceVariant : onyxSurfaceVariant;
  static Color get darkBorder =>
      currentDarkStyle == DarkModeStyle.charcoal ? charcoalBorder : onyxBorder;
  static Color get darkDivider =>
      currentDarkStyle == DarkModeStyle.charcoal ? charcoalDivider : onyxDivider;

  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextDisabled = Color(0xFF64748B);
  static const Color darkCardShadow = Color(0x33000000);

  // ── Status Colors ─────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);       // Emerald green
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);       // Amber warning
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);         // Red error
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);          // Blue info
  static const Color infoLight = Color(0xFFDBEAFE);

  // ── Role-specific accent colors ───────────────────────────────
  static const Color artisanColor = Color(0xFF7C3AED);  // Purple
  static const Color aggregatorColor = Color(0xFF059669); // Green
  static const Color buyerColor = Color(0xFF0EA5E9);    // Sky blue

  // ── Badge / Status Pills ──────────────────────────────────────
  static const Color badgeActive = Color(0xFF10B981);
  static const Color badgeActiveLight = Color(0xFFD1FAE5);
  static const Color badgeDraft = Color(0xFFF59E0B);
  static const Color badgeDraftLight = Color(0xFFFEF3C7);
  static const Color badgeSoldOut = Color(0xFFEF4444);
  static const Color badgeSoldOutLight = Color(0xFFFEE2E2);
  static const Color badgeVerified = Color(0xFF3B82F6);
  static const Color badgeVerifiedLight = Color(0xFFDBEAFE);
  static const Color badgePending = Color(0xFFF97316);
  static const Color badgePendingLight = Color(0xFFFFEDD5);
  static const Color badgeGiTag = Color(0xFF8B5CF6);
  static const Color badgeGiTagLight = Color(0xFFEDE9FE);

  // ── Gold / Certification ──────────────────────────────────────
  static const Color gold = Color(0xFFD97706);
  static const Color goldLight = Color(0xFFFEF3C7);
  static const Color goldShimmer = Color(0xFFF4A226);

  // ── Neutral Grays ─────────────────────────────────────────────
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // ── Gradient Presets ──────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2E4057), Color(0xFF1E2D3D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFF4A226), Color(0xFFD98A1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF2E4057), Color(0xFF1A6B4A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF243148)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Adaptive Helpers ──────────────────────────────────────────
  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextPrimary : lightTextPrimary;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextSecondary : lightTextSecondary;

  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurface : lightSurface;

  static Color surfaceVariant(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurfaceVariant : lightSurfaceVariant;

  static Color border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBorder : lightBorder;

  static Color adaptivePrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? accent : primary;
}
