import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Reusable star rating widget — read-only display and interactive input modes
class StarRating extends StatefulWidget {
  final double rating;
  final int maxStars;
  final bool interactive;
  final ValueChanged<int>? onRatingChanged;
  final double starSize;
  final bool showCount;
  final int? reviewCount;
  final Color activeColor;
  final Color inactiveColor;

  const StarRating({
    super.key,
    required this.rating,
    this.maxStars = 5,
    this.interactive = false,
    this.onRatingChanged,
    this.starSize = 18,
    this.showCount = false,
    this.reviewCount,
    this.activeColor = AppColors.accent,
    this.inactiveColor = AppColors.gray300,
  });

  const StarRating.interactive({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.maxStars = 5,
    this.starSize = 32,
    this.showCount = false,
    this.reviewCount,
    this.activeColor = AppColors.accent,
    this.inactiveColor = AppColors.gray300,
  }) : interactive = true;

  const StarRating.display({
    super.key,
    required this.rating,
    this.maxStars = 5,
    this.starSize = 14,
    this.showCount = true,
    this.reviewCount,
    this.activeColor = AppColors.accent,
    this.inactiveColor = AppColors.gray300,
    this.interactive = false,
    this.onRatingChanged,
  });

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(widget.maxStars, (i) => _buildStar(i + 1)),
        if (widget.showCount) ...[
          const SizedBox(width: 6),
          Text(
            _currentRating.toStringAsFixed(1),
            style: AppTextStyles.labelLarge.copyWith(
              color: widget.activeColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (widget.reviewCount != null) ...[
            const SizedBox(width: 4),
            Text(
              '(${widget.reviewCount})',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.lightTextSecondary,
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildStar(int index) {
    IconData icon;
    Color color;

    if (_currentRating >= index) {
      icon = Icons.star_rounded;
      color = widget.activeColor;
    } else if (_currentRating >= index - 0.5) {
      icon = Icons.star_half_rounded;
      color = widget.activeColor;
    } else {
      icon = Icons.star_outline_rounded;
      color = widget.inactiveColor;
    }

    if (widget.interactive) {
      return GestureDetector(
        onTap: () {
          setState(() => _currentRating = index.toDouble());
          widget.onRatingChanged?.call(index);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: Icon(
              icon,
              key: ValueKey('$index-$_currentRating'),
              size: widget.starSize,
              color: color,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Icon(icon, size: widget.starSize, color: color),
    );
  }
}
