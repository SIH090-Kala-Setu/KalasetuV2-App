import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';

import '../../../core/network/api_client.dart';
import '../../../shared/models/models.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/product_thumbnail.dart';
import '../../../shared/widgets/product_reviews_section.dart';
import '../../../shared/widgets/app_avatar.dart';

final productDetailProvider = FutureProvider.autoDispose.family<ProductModel, String>((ref, id) async {
  final api = ref.read(apiClientProvider);
  return api.getProductDetail(id);
});

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  String _language = 'English';
  int _quantity = 1;
  bool _isSendingRfq = false;

  int get _unitPrice {
    if (_quantity >= 50) return 780;
    if (_quantity >= 20) return 840;
    if (_quantity >= 10) return 900;
    return 1200;
  }

  int get _totalPrice => _unitPrice * _quantity;

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));
    final product = productAsync.valueOrNull;

    final title = product != null
        ? (_language == 'English' ? product.titleEn : (product.titleHi.isNotEmpty ? product.titleHi : product.titleEn))
        : 'Handwoven Varanasi Pure Silk Dupatta with Zari Border';
    final imageUrl = (product?.imageUrl != null && product!.imageUrl!.isNotEmpty)
        ? product.imageUrl!
        : 'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=800';
    final location = product?.region ?? product?.state ?? 'Varanasi, Uttar Pradesh';
    final artisanName = (product?.artisanName != null && product!.artisanName!.isNotEmpty)
        ? product.artisanName!
        : 'Ramesh Sharma';
    final artisanCraft = (product?.craft != null && product!.craft!.isNotEmpty)
        ? product.craft!
        : (product?.category ?? 'Master Handicrafts');
    final hasGi = product?.giTag ?? true;
    final rating = product?.rating != null && product!.rating > 0 ? product.rating : 4.8;
    final reviewCount = product?.reviewCount != null && product!.reviewCount > 0 ? product.reviewCount : 34;
    final desc = product != null
        ? (_language == 'English'
            ? (product.descriptionEn?.isNotEmpty == true ? product.descriptionEn! : 'Authentic mastercrafted artisan creation.')
            : (product.descriptionHi?.isNotEmpty == true ? product.descriptionHi! : product.descriptionEn ?? 'पारंपरिक प्रामाणिक कारीगर रचना।'))
        : (_language == 'English'
            ? 'This exquisite dupatta is handwoven on a traditional pit loom in the lanes of Varanasi. Master weaver Ramesh Sharma uses pure mulberry silk threads and real zari to create intricate floral jaal patterns passed down through four generations. The natural dyeing process uses indigo and madder roots, ensuring skin-friendly, sustainable color.'
            : 'यह उत्कृष्ट दुपट्टा वाराणसी की गलियों में पारंपरिक गड्ढा करघे पर हाथ से बुना गया है। मास्टर बुनकर रमेश शर्मा चार पीढ़ियों से चली आ रही जटिल पुष्प जाल पैटर्न बनाने के लिए शुद्ध शहतूत रेशम के धागे और असली ज़री का उपयोग करते हैं। प्राकृतिक रंगाई प्रक्रिया में नील और मजीठ की जड़ों का उपयोग किया जाता है।');

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
    final surfaceVariant = isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1F5F9);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Product Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close_rounded, color: textSecondary),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Full Hero Image ────────────────────────────────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: ProductThumbnail(
                      imageUrl: imageUrl,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Title + GI Tag ─────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                            height: 1.3,
                          ),
                        ),
                      ),
                      if (hasGi) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shield_outlined, size: 14, color: Color(0xFF047857)),
                              SizedBox(width: 4),
                              Text(
                                'GI\nTag',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  height: 1.1,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF047857),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Rating & Location Row
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF5A623)),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: textPrimary),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '($reviewCount reviews)',
                        style: TextStyle(fontSize: 12, color: textSecondary),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.location_on_outlined, size: 14, color: textSecondary),
                      const SizedBox(width: 2),
                      Text(
                        location,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── English / Hindi Toggle Switch ──────────────────────
                  Container(
                    width: double.infinity,
                    height: 44,
                    decoration: BoxDecoration(
                      color: surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _buildLangBtn('English', isDark),
                        _buildLangBtn('हिंदी', isDark),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Description Text
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── Artisan Card ───────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: border),
                    ),
                    child: Row(
                      children: [
                        AppAvatar(
                          photoUrl: null,
                          name: artisanName,
                          radius: 24,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    artisanName,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF10B981)),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$artisanCraft • $location',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'MoSJE Verified',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF047857),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── Bulk Procurement Calculator Card ───────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calculate_outlined, color: Color(0xFFD97706), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Bulk Procurement Calculator',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Quantity Stepper
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Quantity',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textSecondary),
                            ),
                            Row(
                              children: [
                                _buildCalcBtn(
                                  icon: Icons.remove,
                                  onTap: () {
                                    if (_quantity > 1) setState(() => _quantity -= 1);
                                  },
                                  isDark: isDark,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    '$_quantity',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary),
                                  ),
                                ),
                                _buildCalcBtn(
                                  icon: Icons.add,
                                  onTap: () => setState(() => _quantity += 1),
                                  isDark: isDark,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Tier Rows
                        _buildTierRow('10+ pcs', '25% off · ₹900/pc', isActive: _quantity >= 10 && _quantity < 20, isDark: isDark),
                        const SizedBox(height: 6),
                        _buildTierRow('20+ pcs', '30% off · ₹840/pc', isActive: _quantity >= 20 && _quantity < 50, isDark: isDark),
                        const SizedBox(height: 6),
                        _buildTierRow('50+ pcs', '35% off · ₹780/pc', isActive: _quantity >= 50, isDark: isDark),
                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Unit Price', style: TextStyle(fontSize: 13, color: textSecondary)),
                            Text('₹$_unitPrice', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Lead Time', style: TextStyle(fontSize: 13, color: textSecondary)),
                            Text('7 days', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Divider(color: border),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPrimary)),
                            Text('₹$_totalPrice', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.accent)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── Materials Chips ────────────────────────────────────
                  Text(
                    'MATERIALS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MaterialChip(label: 'Pure Mulberry Silk', isDark: isDark),
                      _MaterialChip(label: 'Real Zari Thread', isDark: isDark),
                      _MaterialChip(label: 'Natural Dyes', isDark: isDark),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // ── Artisan Profile Card ──────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: border),
                      boxShadow: isDark
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AppAvatar(
                              name: artisanName,
                              radius: 24,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          artisanName,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF10B981)),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$artisanCraft • $location',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Divider(height: 1, color: border),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.shield_outlined, size: 14, color: Color(0xFF047857)),
                                SizedBox(width: 4),
                                Text(
                                  'MoSJE Registered Artisan',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF047857),
                                  ),
                                ),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: () {
                                final targetId = (product?.artisanId != null && product!.artisanId!.isNotEmpty)
                                    ? product.artisanId!
                                    : 'artisan';
                                context.push(RouteNames.artisanPortfolio(targetId));
                              },
                              icon: Text(
                                'View Portfolio',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textPrimary),
                              ),
                              label: Icon(Icons.arrow_forward_rounded, size: 14, color: textPrimary),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── Authenticity & Certification Card ──────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.workspace_premium_outlined, color: Color(0xFF10B981), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Authenticity & Certification',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _AuthCheckItem('GI Tag Certified by Geographical Indications Registry', isDark: isDark),
                        const SizedBox(height: 8),
                        _AuthCheckItem('MoSJE Registered Artisan', isDark: isDark),
                        const SizedBox(height: 8),
                        _AuthCheckItem('Natural Dyes — No Chemical Colorants', isDark: isDark),
                        const SizedBox(height: 8),
                        _AuthCheckItem('Handwoven — No Machine Production', isDark: isDark),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── Live Buyer Reviews ─────────────────────────────────
                  ProductReviewsSection(productId: widget.productId),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Sticky Bottom CTA Button ──────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: surface,
              border: Border(top: BorderSide(color: border)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _isSendingRfq
                    ? null
                    : () async {
                        setState(() => _isSendingRfq = true);
                        try {
                          final auth = ref.read(authProvider).valueOrNull;
                          final api = ref.read(apiClientProvider);
                          await api.createInquiry(
                            productId: widget.productId,
                            buyerName: auth?.user?.fullName ?? 'Verified Buyer',
                            buyerEmail: auth?.user?.email ?? 'buyer@kalasetu.in',
                            quantity: _quantity,
                            notes: 'Bulk RFQ inquiry for $_quantity units at ₹$_totalPrice',
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('🎉 Bulk RFQ inquiry sent to artisan!'),
                                backgroundColor: Color(0xFF047857),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Inquiry request submitted: $e')),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isSendingRfq = false);
                        }
                      },
                icon: _isSendingRfq
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded, size: 20),
                label: Text(
                  _isSendingRfq ? 'Sending RFQ...' : 'Send Bulk Quotation Request (RFQ)',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5A623),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLangBtn(String label, bool isDark) {
    final isSelected = _language == label;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _language = label),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? surface : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected && !isDark
                ? const [BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2))]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? textPrimary : const Color(0xFF8A94A6),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalcBtn({required IconData icon, required VoidCallback onTap, required bool isDark}) {
    final bg = isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1F5F9);
    final fg = isDark ? AppColors.darkTextPrimary : AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(icon, color: fg, size: 18),
        ),
      ),
    );
  }

  Widget _buildTierRow(String pcs, String price, {required bool isActive, required bool isDark}) {
    final activeBg = isDark ? const Color(0xFF451A03) : const Color(0xFFFEF9EE);
    final inactiveBg = isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF8FAFC);
    final activeBorder = isDark ? const Color(0xFFB45309) : const Color(0xFFFDE68A);
    final inactiveBorder = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? activeBg : inactiveBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive ? activeBorder : inactiveBorder,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            pcs,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              color: isActive ? const Color(0xFFF59E0B) : const Color(0xFF64748B),
            ),
          ),
          Text(
            price,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isActive ? const Color(0xFFF59E0B) : textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MaterialChip extends StatelessWidget {
  final String label;
  final bool isDark;
  const _MaterialChip({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.darkTextPrimary : const Color(0xFF334155),
        ),
      ),
    );
  }
}

class _AuthCheckItem extends StatelessWidget {
  final String text;
  final bool isDark;
  const _AuthCheckItem(this.text, {required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_rounded, color: Color(0xFF10B981), size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : const Color(0xFF334155),
            ),
          ),
        ),
      ],
    );
  }
}
