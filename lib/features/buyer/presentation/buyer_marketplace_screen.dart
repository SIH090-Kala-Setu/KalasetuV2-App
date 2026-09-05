import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';

class BuyerMarketplaceScreen extends ConsumerStatefulWidget {
  const BuyerMarketplaceScreen({super.key});

  @override
  ConsumerState<BuyerMarketplaceScreen> createState() => _BuyerMarketplaceScreenState();
}

class _BuyerMarketplaceScreenState extends ConsumerState<BuyerMarketplaceScreen> {
  String _selectedCategory = 'All';
  final _searchCtrl = TextEditingController();

  static const _categories = ['All', 'Handloom', 'Pottery', 'Metalwork', 'Painting', 'Woodcraft'];

  static final _demoProducts = [
    {
      'id': 'p1',
      'title': 'Handwoven Varanasi Pure Silk Dupatta',
      'location': 'Varanasi',
      'rating': 4.8,
      'reviews': 34,
      'retailPrice': 1200,
      'bulkPrice': 900,
      'moq': 10,
      'hasGi': true,
      'isSoldOut': false,
      'imageUrl': 'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=600',
    },
    {
      'id': 'p2',
      'title': 'Jaipur Blue Pottery Vase Set',
      'location': 'Jaipur',
      'rating': 4.6,
      'reviews': 21,
      'retailPrice': 850,
      'bulkPrice': 640,
      'moq': 12,
      'hasGi': true,
      'isSoldOut': false,
      'imageUrl': 'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?w=600',
    },
    {
      'id': 'p3',
      'title': 'Bastar Dhokra Bronze Figurine',
      'location': 'Bastar',
      'rating': 4.9,
      'reviews': 18,
      'retailPrice': 2200,
      'bulkPrice': 1650,
      'moq': 5,
      'hasGi': true,
      'isSoldOut': false,
      'imageUrl': 'https://images.unsplash.com/photo-1582562124811-c09040d0a901?w=600',
    },
    {
      'id': 'p4',
      'title': 'Madhubani Fish Folk Painting',
      'location': 'Mithila',
      'rating': 4.7,
      'reviews': 42,
      'retailPrice': 650,
      'bulkPrice': 480,
      'moq': 20,
      'hasGi': true,
      'isSoldOut': true,
      'imageUrl': 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=600',
    },
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // ── Top Navy Banner Card ──────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Source Directly from Verified Indian Artisans',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Zero intermediary markups · GI-certified authentic crafts',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Search Bar ─────────────────────────────────────────
              SizedBox(
                height: 48,
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(fontSize: 14, color: AppColors.primary),
                  decoration: InputDecoration(
                    hintText: 'Search crafts, regions, artisans...',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Category Chips Row ─────────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => setState(() => _selectedCategory = cat),
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),

              // ── 2-Column Product Grid ──────────────────────────────
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: _demoProducts.length,
                  itemBuilder: (context, index) {
                    final p = _demoProducts[index];
                    return _ProductGridCard(
                      id: p['id'] as String,
                      title: p['title'] as String,
                      location: p['location'] as String,
                      rating: (p['rating'] as num).toDouble(),
                      reviews: p['reviews'] as int,
                      retailPrice: p['retailPrice'] as int,
                      bulkPrice: p['bulkPrice'] as int,
                      moq: p['moq'] as int,
                      hasGi: p['hasGi'] as bool,
                      isSoldOut: p['isSoldOut'] as bool,
                      imageUrl: p['imageUrl'] as String,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductGridCard extends StatelessWidget {
  final String id;
  final String title;
  final String location;
  final double rating;
  final int reviews;
  final int retailPrice;
  final int bulkPrice;
  final int moq;
  final bool hasGi;
  final bool isSoldOut;
  final String imageUrl;

  const _ProductGridCard({
    required this.id,
    required this.title,
    required this.location,
    required this.rating,
    required this.reviews,
    required this.retailPrice,
    required this.bulkPrice,
    required this.moq,
    required this.hasGi,
    required this.isSoldOut,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(RouteNames.productDetail(id)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image with GI badge / Sold out badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: SizedBox(
                    width: double.infinity,
                    height: 130,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFF1F5F9),
                        child: const Center(
                          child: Icon(Icons.image_outlined, color: Color(0xFF94A3B8), size: 32),
                        ),
                      ),
                    ),
                  ),
                ),
                if (hasGi)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield_outlined, size: 12, color: Color(0xFF047857)),
                          SizedBox(width: 3),
                          Text(
                            'GI',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF047857),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (isSoldOut)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Sold Out',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Card Body
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      height: 1.25,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF8A94A6)),
                      const SizedBox(width: 2),
                      Text(
                        location,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF8A94A6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF5A623)),
                      const SizedBox(width: 2),
                      Text(
                        '$rating',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '($reviews)',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8A94A6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Price
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '₹$retailPrice ',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        const TextSpan(
                          text: 'Retail',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF8A94A6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 1),

                  Text(
                    '₹$bulkPrice Bulk ($moq+)',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
