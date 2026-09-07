import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Helper function to parse an avatar image from either a Web URL or a Base64 data URI.
ImageProvider? getAvatarImageProvider(String? photoUrl) {
  if (photoUrl == null || photoUrl.trim().isEmpty) return null;
  final trimmed = photoUrl.trim();

  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return NetworkImage(trimmed);
  }

  try {
    if (trimmed.startsWith('data:image')) {
      final base64Part = trimmed.contains(',') ? trimmed.split(',').last : trimmed;
      final bytes = base64Decode(base64Part);
      return MemoryImage(bytes);
    }

    // Try direct base64 decode if string is long enough
    if (trimmed.length > 50) {
      final bytes = base64Decode(trimmed);
      return MemoryImage(bytes);
    }
  } catch (_) {
    return null;
  }

  return null;
}

/// A standard, robust Avatar widget supporting real uploaded images, URLs, and initial fallbacks.
class AppAvatar extends StatelessWidget {
  final String? photoUrl;
  final Uint8List? imageBytes;
  final String? name;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final Border? border;

  const AppAvatar({
    super.key,
    this.photoUrl,
    this.imageBytes,
    this.name,
    this.radius = 24,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? provider;
    if (imageBytes != null && imageBytes!.isNotEmpty) {
      provider = MemoryImage(imageBytes!);
    } else {
      provider = getAvatarImageProvider(photoUrl);
    }

    final initial = (name != null && name!.trim().isNotEmpty)
        ? name!.trim()[0].toUpperCase()
        : '?';

    final bg = backgroundColor ?? AppColors.primary.withValues(alpha: 0.15);
    final fg = textColor ?? AppColors.primary;
    final fs = fontSize ?? (radius * 0.75);

    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      backgroundImage: provider,
      child: provider == null
          ? Text(
              initial,
              style: TextStyle(
                fontSize: fs,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            )
          : null,
    );

    if (border != null) {
      avatar = Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: border,
        ),
        child: avatar,
      );
    }

    return avatar;
  }
}
