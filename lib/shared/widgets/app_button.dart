import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, accent, outlined, text, danger }

/// KalaSetuV2 design system button — 56px min height, loading state, haptic
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double? width;
  final double height;
  final bool isExpanded;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.height = 56,
    this.isExpanded = true,
  });

  const AppButton.accent({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.height = 56,
    this.isExpanded = true,
  }) : variant = AppButtonVariant.accent;

  const AppButton.outlined({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.height = 56,
    this.isExpanded = true,
  }) : variant = AppButtonVariant.outlined;

  const AppButton.text({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.height = 44,
    this.isExpanded = false,
  }) : variant = AppButtonVariant.text;

  const AppButton.danger({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.height = 56,
    this.isExpanded = true,
  }) : variant = AppButtonVariant.danger;

  const AppButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.height = 56,
    this.isExpanded = true,
  }) : variant = AppButtonVariant.secondary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveWidth = isExpanded ? double.infinity : width;

    return switch (variant) {
      AppButtonVariant.primary => _buildElevated(context, isDark, effectiveWidth),
      AppButtonVariant.secondary => _buildSecondary(context, isDark, effectiveWidth),
      AppButtonVariant.accent => _buildAccent(context, isDark, effectiveWidth),
      AppButtonVariant.outlined => _buildOutlined(context, isDark, effectiveWidth),
      AppButtonVariant.text => _buildText(context, isDark, effectiveWidth),
      AppButtonVariant.danger => _buildDanger(context, isDark, effectiveWidth),
    };
  }

  Widget _buildElevated(BuildContext context, bool isDark, double? w) {
    return SizedBox(
      width: w,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleTap,
        child: _content(Colors.white),
      ),
    );
  }

  Widget _buildAccent(BuildContext context, bool isDark, double? w) {
    return SizedBox(
      width: w,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _content(Colors.white),
      ),
    );
  }

  Widget _buildSecondary(BuildContext context, bool isDark, double? w) {
    return SizedBox(
      width: w,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
          foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _content(isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      ),
    );
  }

  Widget _buildOutlined(BuildContext context, bool isDark, double? w) {
    return SizedBox(
      width: w,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : _handleTap,
        child: _content(AppColors.primary),
      ),
    );
  }

  Widget _buildText(BuildContext context, bool isDark, double? w) {
    return SizedBox(
      width: w,
      height: height,
      child: TextButton(
        onPressed: isLoading ? null : _handleTap,
        child: _content(AppColors.accent),
      ),
    );
  }

  Widget _buildDanger(BuildContext context, bool isDark, double? w) {
    return SizedBox(
      width: w,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _content(Colors.white),
      ),
    );
  }

  Widget _content(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }
    if (leadingIcon != null || trailingIcon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: 20, color: color),
            const SizedBox(width: 8),
          ],
          Text(label, style: AppTextStyles.button.copyWith(color: color)),
          if (trailingIcon != null) ...[
            const SizedBox(width: 8),
            Icon(trailingIcon, size: 20, color: color),
          ],
        ],
      );
    }
    return Text(label, style: AppTextStyles.button.copyWith(color: color));
  }

  VoidCallback? get _handleTap => onPressed == null
      ? null
      : () {
          HapticFeedback.lightImpact();
          onPressed!();
        };
}
