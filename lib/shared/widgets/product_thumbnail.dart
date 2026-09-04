import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Hybrid image renderer: handles base64 Data URI bytes, remote URLs, and fallback
class ProductThumbnail extends StatelessWidget {
  final String? imageUrl;
  final Uint8List? imageBytes;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final Widget? placeholder;

  const ProductThumbnail({
    super.key,
    this.imageUrl,
    this.imageBytes,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(12);

    Widget child;

    if (imageBytes != null) {
      child = Image.memory(
        imageBytes!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildFallback(isDark),
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      child = CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => _buildShimmer(isDark),
        errorWidget: (context, url, error) => _buildFallback(isDark),
      );
    } else {
      child = _buildFallback(isDark);
    }

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: width,
        height: height,
        child: child,
      ),
    );
  }

  Widget _buildShimmer(bool isDark) => Container(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );

  Widget _buildFallback(bool isDark) =>
      placeholder ??
      Container(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
        child: Center(
          child: Icon(
            Icons.image_outlined,
            size: 36,
            color: isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled,
          ),
        ),
      );
}
