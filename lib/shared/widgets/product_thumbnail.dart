import 'dart:convert';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/theme/app_colors.dart';

/// Universal product image renderer:
/// Handles base64 Data URIs (data:image/png;base64,...), raw base64 strings,
/// relative URLs (/uploads/...), and remote HTTP/HTTPS URLs with shimmer & fallback.
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

    // 1. Direct byte buffer
    if (imageBytes != null && imageBytes!.isNotEmpty) {
      child = Image.memory(
        imageBytes!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildFallback(isDark),
      );
    }
    // 2. Image URL (may be Data URI, raw Base64, relative, or HTTP/HTTPS)
    else if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      final raw = imageUrl!.trim();

      // Case A: Data URI (e.g. data:image/png;base64,iVBOR...)
      if (raw.startsWith('data:image/') || raw.contains(';base64,')) {
        final commaIdx = raw.indexOf(',');
        final b64 = commaIdx != -1 ? raw.substring(commaIdx + 1).trim() : raw;
        try {
          final decoded = base64Decode(b64);
          child = Image.memory(
            decoded,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, __, ___) => _buildFallback(isDark),
          );
        } catch (_) {
          child = _buildFallback(isDark);
        }
      }
      // Case B: Raw Base64 string without data: header (starts with iVBOR or /9j/ or long string)
      else if (!raw.startsWith('http://') &&
          !raw.startsWith('https://') &&
          !raw.startsWith('/') &&
          raw.length > 80 &&
          !raw.contains(' ')) {
        try {
          final decoded = base64Decode(raw);
          child = Image.memory(
            decoded,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, __, ___) => _buildFallback(isDark),
          );
        } catch (_) {
          child = _buildFallback(isDark);
        }
      }
      // Case C: Relative or Network URL
      else {
        String resolvedUrl = raw;
        if (resolvedUrl.startsWith('/')) {
          final base = ApiEndpoints.getBaseUrlSync();
          resolvedUrl = '$base$resolvedUrl';
        } else if (!resolvedUrl.startsWith('http://') && !resolvedUrl.startsWith('https://')) {
          final base = ApiEndpoints.getBaseUrlSync();
          resolvedUrl = '$base/$resolvedUrl';
        }

        resolvedUrl = ApiEndpoints.normalizeUrl(resolvedUrl);

        child = CachedNetworkImage(
          imageUrl: resolvedUrl,
          width: width,
          height: height,
          fit: fit,
          placeholder: (context, url) => _buildShimmer(isDark),
          errorWidget: (context, url, error) => _buildFallback(isDark),
        );
      }
    } else {
      child = _buildFallback(isDark);
    }

    if (radius == BorderRadius.zero) {
      return SizedBox(
        width: width,
        height: height,
        child: child,
      );
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
            size: (height != null && height! < 100) ? 24 : 36,
            color: isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled,
          ),
        ),
      );
}
