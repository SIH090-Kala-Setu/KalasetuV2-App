import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

enum BadgeStatus { active, draft, soldOut, verified, pending, giTag, quoted, finalized, dispatched }

/// Color-coded status pill badge
class StatusBadge extends StatelessWidget {
  final BadgeStatus status;
  final String? customLabel;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.customLabel,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    final (label, bg, text) = _getColors();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        customLabel ?? label,
        style: AppTextStyles.overline.copyWith(
          color: text,
          fontSize: fontSize,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  (String label, Color bg, Color text) _getColors() => switch (status) {
        BadgeStatus.active => ('Active', AppColors.badgeActiveLight, AppColors.badgeActive),
        BadgeStatus.draft => ('Draft', AppColors.badgeDraftLight, AppColors.badgeDraft),
        BadgeStatus.soldOut => ('Sold Out', AppColors.badgeSoldOutLight, AppColors.badgeSoldOut),
        BadgeStatus.verified => ('Verified ✓', AppColors.badgeVerifiedLight, AppColors.badgeVerified),
        BadgeStatus.pending => ('Pending', AppColors.badgePendingLight, AppColors.badgePending),
        BadgeStatus.giTag => ('GI Tag', AppColors.badgeGiTagLight, AppColors.badgeGiTag),
        BadgeStatus.quoted => ('Quoted', AppColors.badgeVerifiedLight, AppColors.badgeVerified),
        BadgeStatus.finalized => ('Finalized ✓', AppColors.badgeActiveLight, AppColors.badgeActive),
        BadgeStatus.dispatched => ('Dispatched', AppColors.badgeGiTagLight, AppColors.badgeGiTag),
      };
}

/// Convert string status to BadgeStatus
BadgeStatus badgeStatusFromString(String s) => switch (s.toLowerCase()) {
      'active' => BadgeStatus.active,
      'draft' => BadgeStatus.draft,
      'sold out' || 'soldout' || 'sold_out' => BadgeStatus.soldOut,
      'verified' => BadgeStatus.verified,
      'pending' => BadgeStatus.pending,
      'gi tag' || 'gitag' => BadgeStatus.giTag,
      'artisan-quoted' || 'quoted' => BadgeStatus.quoted,
      'order-finalized' || 'finalized' => BadgeStatus.finalized,
      'dispatched' => BadgeStatus.dispatched,
      _ => BadgeStatus.pending,
    };
