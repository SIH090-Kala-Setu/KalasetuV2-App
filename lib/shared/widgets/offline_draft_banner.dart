import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Persistent amber banner for unsaved drafts or offline outbox items
class OfflineDraftBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onResume;
  final VoidCallback? onDismiss;
  final bool isOfflineSync;

  const OfflineDraftBanner({
    super.key,
    required this.message,
    this.onResume,
    this.onDismiss,
    this.isOfflineSync = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isOfflineSync ? AppColors.errorLight : AppColors.warningLight,
        border: Border(
          bottom: BorderSide(
            color: isOfflineSync ? AppColors.error.withValues(alpha: 0.3) : AppColors.warning.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOfflineSync ? Icons.cloud_upload_outlined : Icons.edit_note_rounded,
            size: 20,
            color: isOfflineSync ? AppColors.error : AppColors.warning,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: isOfflineSync ? AppColors.error : AppColors.badgeDraft,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onResume != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onResume,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                isOfflineSync ? 'Retry' : 'Resume',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              color: AppColors.lightTextSecondary,
            ),
        ],
      ),
    );
  }
}
