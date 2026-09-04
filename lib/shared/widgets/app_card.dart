import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// KalaSetuV2 design system card — adaptive elevation, border, glassmorphism
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double borderRadius;
  final bool glass;
  final Color? backgroundColor;
  final double? elevation;
  final bool noPadding;
  final Border? customBorder;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.borderRadius = 16,
    this.glass = false,
    this.backgroundColor,
    this.elevation,
    this.noPadding = false,
    this.customBorder,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ??
        (isDark ? AppColors.darkSurface : AppColors.lightSurface);
    final effectivePadding =
        noPadding ? EdgeInsets.zero : (padding ?? const EdgeInsets.all(16));

    final content = Padding(padding: effectivePadding, child: child);

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: _buildDecoratedBox(isDark, bgColor, content),
        ),
      );
    }

    return _buildDecoratedBox(isDark, bgColor, content);
  }

  Widget _buildDecoratedBox(bool isDark, Color bgColor, Widget content) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: glass
            ? bgColor.withValues(alpha: 0.85)
            : bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: customBorder ??
            Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: content,
      ),
    );
  }
}
