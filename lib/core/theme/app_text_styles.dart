import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// KalaSetuV2 Typography System
/// Primary: Outfit (Latin + numerics)
/// Secondary: Noto Sans (Indic script support)
class AppTextStyles {
  AppTextStyles._();

  // ── Display ───────────────────────────────────────────────────
  static TextStyle get displayLarge => GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: AppColors.lightTextPrimary,
        height: 1.2,
      );

  static TextStyle get displayMedium => GoogleFonts.outfit(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: AppColors.lightTextPrimary,
        height: 1.25,
      );

  static TextStyle get displaySmall => GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: AppColors.lightTextPrimary,
        height: 1.3,
      );

  // ── Headline ──────────────────────────────────────────────────
  static TextStyle get headlineLarge => GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.lightTextPrimary,
        height: 1.3,
      );

  static TextStyle get headlineMedium => GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
        height: 1.35,
      );

  static TextStyle get headlineSmall => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
        height: 1.4,
      );

  // ── Title ─────────────────────────────────────────────────────
  static TextStyle get titleLarge => GoogleFonts.outfit(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
        height: 1.4,
      );

  static TextStyle get titleMedium => GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
        height: 1.4,
      );

  static TextStyle get titleSmall => GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextSecondary,
        height: 1.4,
        letterSpacing: 0.1,
      );

  // ── Body ──────────────────────────────────────────────────────
  static TextStyle get bodyLarge => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.lightTextPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.lightTextPrimary,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.lightTextSecondary,
        height: 1.5,
      );

  // ── Label ─────────────────────────────────────────────────────
  static TextStyle get labelLarge => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: AppColors.lightTextPrimary,
        height: 1.4,
      );

  static TextStyle get labelMedium => GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: AppColors.lightTextSecondary,
        height: 1.4,
      );

  static TextStyle get labelSmall => GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: AppColors.lightTextSecondary,
        height: 1.4,
      );

  // ── Caption ───────────────────────────────────────────────────
  static TextStyle get caption => GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.lightTextDisabled,
        height: 1.4,
        letterSpacing: 0.3,
      );

  // ── Button ────────────────────────────────────────────────────
  static TextStyle get button => GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.2,
      );

  static TextStyle get buttonSmall => GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        height: 1.2,
      );

  // ── Indic Script (Noto Sans) ──────────────────────────────────
  static TextStyle get indicBody => GoogleFonts.notoSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.6,
      );

  static TextStyle get indicTitle => GoogleFonts.notoSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
      );

  static TextStyle get indicCaption => GoogleFonts.notoSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  // ── Price / Numbers (Outfit Bold) ─────────────────────────────
  static TextStyle get priceHero => GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.accent,
        letterSpacing: -0.5,
        height: 1.1,
      );

  static TextStyle get priceLarge => GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.accent,
        height: 1.2,
      );

  static TextStyle get priceMedium => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.accent,
        height: 1.3,
      );

  static TextStyle get priceSmall => GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.accent,
        height: 1.3,
      );

  // ── Overline / Chip Labels ────────────────────────────────────
  static TextStyle get overline => GoogleFonts.outfit(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        height: 1.4,
      );

  static TextStyle get chipLabel => GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        height: 1.2,
      );
}
