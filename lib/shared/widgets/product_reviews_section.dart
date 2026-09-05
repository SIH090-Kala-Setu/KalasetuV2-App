import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/models.dart';
import 'star_rating.dart';
import 'app_button.dart';
import 'app_text_field.dart';
import 'shimmer_loader.dart';
import 'empty_state_view.dart';

/// Full product reviews container with rating summary, distribution bars, and write review
class ProductReviewsSection extends ConsumerStatefulWidget {
  final String productId;
  final List<ReviewModel>? preloadedReviews;

  const ProductReviewsSection({
    super.key,
    required this.productId,
    this.preloadedReviews,
  });

  @override
  ConsumerState<ProductReviewsSection> createState() => _ProductReviewsSectionState();
}

class _ProductReviewsSectionState extends ConsumerState<ProductReviewsSection> {
  List<ReviewModel>? _reviews;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.preloadedReviews != null) {
      _reviews = widget.preloadedReviews;
    } else {
      _loadReviews();
    }
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiClientProvider);
      final reviews = await api.getProductReviews(widget.productId);
      if (mounted) setState(() { _reviews = reviews; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    if (_isLoading) {
      return Column(
        children: List.generate(2, (_) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: ShimmerLoader(width: double.infinity, height: 100),
        )),
      );
    }

    if (_error != null && _reviews == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Failed to load reviews. Please try again.',
          style: AppTextStyles.bodyMedium.copyWith(color: textSecondary),
        ),
      );
    }

    final reviews = _reviews ?? [];
    final avgRating = reviews.isEmpty
        ? 0.0
        : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Reviews & Ratings',
                style: AppTextStyles.headlineSmall.copyWith(color: textPrimary)),
            TextButton.icon(
              onPressed: () => _showWriteReviewSheet(context),
              icon: const Icon(Icons.rate_review_outlined, size: 18),
              label: const Text('Write Review'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (reviews.isNotEmpty) ...[
          // Average score + distribution
          _buildRatingSummary(context, reviews, avgRating, isDark, textPrimary, textSecondary),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
        ],

        // Review cards
        if (reviews.isEmpty)
          EmptyStateView(
            title: 'No reviews yet',
            subtitle: 'Be the first to review this craft!',
            icon: Icons.star_outline_rounded,
            actionLabel: 'Write First Review',
            onAction: () => _showWriteReviewSheet(context),
          )
        else
          ...reviews.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ReviewCard(review: r),
              )),
      ],
    );
  }

  Widget _buildRatingSummary(
    BuildContext context,
    List<ReviewModel> reviews,
    double avg,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Big average score
        Column(
          children: [
            Text(
              avg.toStringAsFixed(1),
              style: AppTextStyles.priceHero.copyWith(color: AppColors.accent, fontSize: 42),
            ),
            StarRating(rating: avg, starSize: 16),
            const SizedBox(height: 4),
            Text('${reviews.length} reviews',
                style: AppTextStyles.bodySmall.copyWith(color: textSecondary)),
          ],
        ),
        const SizedBox(width: 20),
        // Distribution bars
        Expanded(
          child: Column(
            children: List.generate(5, (i) {
              final star = 5 - i;
              final count = reviews.where((r) => r.rating == star).length;
              final percent = reviews.isEmpty ? 0.0 : count / reviews.length;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Text('$star', style: AppTextStyles.labelSmall.copyWith(color: textSecondary)),
                    const SizedBox(width: 4),
                    const Icon(Icons.star_rounded, size: 12, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percent,
                          minHeight: 6,
                          backgroundColor: isDark ? AppColors.darkBorder : AppColors.gray200,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 24,
                      child: Text(
                        '$count',
                        style: AppTextStyles.labelSmall.copyWith(color: textSecondary),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  void _showWriteReviewSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _WriteReviewSheet(
        productId: widget.productId,
        onSubmitted: (review) {
          setState(() => _reviews = [...?_reviews, review]);
        },
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: Text(
                  review.buyerName.isNotEmpty ? review.buyerName[0] : '?',
                  style: AppTextStyles.titleSmall.copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(review.buyerName,
                            style: AppTextStyles.titleSmall.copyWith(color: textPrimary)),
                        if (review.isVerifiedBuyer) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.badgeActiveLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '✅ Verified',
                              style: AppTextStyles.overline.copyWith(
                                color: AppColors.success,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (review.buyerOrg != null)
                      Text(review.buyerOrg!,
                          style: AppTextStyles.bodySmall.copyWith(color: textSecondary)),
                  ],
                ),
              ),
              StarRating(rating: review.rating.toDouble(), starSize: 14),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment!,
              style: AppTextStyles.bodyMedium.copyWith(color: textPrimary),
            ),
          ],
          const SizedBox(height: 8),
          if (review.createdAt != null)
            Text(
              _formatDate(review.createdAt!),
              style: AppTextStyles.caption.copyWith(color: textSecondary),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    return '${(diff.inDays / 30).floor()} months ago';
  }
}

class _WriteReviewSheet extends ConsumerStatefulWidget {
  final String productId;
  final ValueChanged<ReviewModel> onSubmitted;

  const _WriteReviewSheet({
    required this.productId,
    required this.onSubmitted,
  });

  @override
  ConsumerState<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends ConsumerState<_WriteReviewSheet> {
  int _rating = 5;
  bool _isRecommended = true;
  bool _isSubmitting = false;
  final _commentController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Write a Review',
              style: AppTextStyles.headlineMedium.copyWith(color: textPrimary)),
          const SizedBox(height: 20),
          // Star rating
          Center(
            child: StarRating.interactive(
              rating: _rating.toDouble(),
              onRatingChanged: (r) => setState(() => _rating = r),
              starSize: 40,
            ),
          ),
          const SizedBox(height: 20),
          AppTextField(
            controller: _nameController,
            label: 'Your Name / Organization',
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _commentController,
            label: 'Your Review',
            hint: 'Share your experience with this craft...',
            prefixIcon: Icons.comment_outlined,
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          // Recommendation toggle
          SwitchListTile(
            value: _isRecommended,
            onChanged: (v) => setState(() => _isRecommended = v),
            title: Text(
              'Would you recommend this to other buyers?',
              style: AppTextStyles.bodyMedium.copyWith(color: textPrimary),
            ),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'Submit Review',
            isLoading: _isSubmitting,
            onPressed: _submitReview,
            leadingIcon: Icons.send_rounded,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _submitReview() async {
    if (_rating == 0) return;
    setState(() => _isSubmitting = true);
    try {
      final api = ref.read(apiClientProvider);
      final review = await api.createProductReview(
        productId: widget.productId,
        rating: _rating,
        comment: _commentController.text.trim(),
        reviewerName: _nameController.text.trim(),
        isRecommended: _isRecommended,
      );
      if (mounted) {
        widget.onSubmitted(review);
        Navigator.of(context).pop();
      }
    } catch (_) {
      // Optimistic local update
      final localReview = ReviewModel(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        productId: widget.productId,
        buyerName: _nameController.text.trim().isEmpty ? 'You' : _nameController.text.trim(),
        rating: _rating,
        comment: _commentController.text.trim(),
        createdAt: DateTime.now(),
        isVerifiedBuyer: false,
        isRecommended: _isRecommended,
      );
      if (mounted) {
        widget.onSubmitted(localReview);
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
