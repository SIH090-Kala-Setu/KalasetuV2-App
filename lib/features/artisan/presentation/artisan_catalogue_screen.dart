import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';

class ArtisanCatalogueScreen extends ConsumerStatefulWidget {
  const ArtisanCatalogueScreen({super.key});

  @override
  ConsumerState<ArtisanCatalogueScreen> createState() => _ArtisanCatalogueScreenState();
}

class _ArtisanCatalogueScreenState extends ConsumerState<ArtisanCatalogueScreen> {
  String _selectedFilter = 'All';

  // Demo fallback products matching the exact screenshot
  static final _demoCatalogue = [
    {
      'titleEn': 'Handwoven Varanasi Pure Silk Dupatta with Zari Border',
      'titleHi': 'हथकरघा बनारसी सिल्क दुपट्टा (ज़री बॉर्डर)',
      'price': 1200,
      'status': 'Active',
      'stock': 24,
      'hasGi': true,
      'imageUrl': 'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=600',
    },
    {
      'titleEn': 'Jaipur Blue Pottery Decorative Vase Set',
      'titleHi': 'जयपुर नीली मिट्टी का सजावटी फूलदान सेट',
      'price': 850,
      'status': 'Active',
      'stock': 8,
      'hasGi': true,
      'imageUrl': 'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?w=600',
    },
    {
      'titleEn': 'Bastar Dhokra Bronze Figurine',
      'titleHi': 'बस्तर ढोकरा कांस्य मूर्ति',
      'price': 2200,
      'status': 'Active',
      'stock': 12,
      'hasGi': true,
      'imageUrl': 'https://images.unsplash.com/photo-1582562124811-c09040d0a901?w=600',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Header: My Catalogue
              const Text(
                'My Catalogue',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 14),

              // Filter Pills Row: All, Active, Drafts, Sold Out
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterPill('All'),
                    const SizedBox(width: 8),
                    _buildFilterPill('Active'),
                    const SizedBox(width: 8),
                    _buildFilterPill('Drafts'),
                    const SizedBox(width: 8),
                    _buildFilterPill('Sold Out'),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Product Cards List
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: _demoCatalogue.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 18),
                  itemBuilder: (context, index) {
                    final item = _demoCatalogue[index];
                    return _CatalogueCard(
                      titleEn: item['titleEn'] as String,
                      titleHi: item['titleHi'] as String,
                      price: item['price'] as int,
                      status: item['status'] as String,
                      initialStock: item['stock'] as int,
                      hasGi: item['hasGi'] as bool,
                      imageUrl: item['imageUrl'] as String,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteNames.artisanStudio),
        backgroundColor: const Color(0xFFF5A623),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  Widget _buildFilterPill(String label) {
    final isSelected = _selectedFilter == label;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = label),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

class _CatalogueCard extends StatefulWidget {
  final String titleEn;
  final String titleHi;
  final int price;
  final String status;
  final int initialStock;
  final bool hasGi;
  final String imageUrl;

  const _CatalogueCard({
    required this.titleEn,
    required this.titleHi,
    required this.price,
    required this.status,
    required this.initialStock,
    required this.hasGi,
    required this.imageUrl,
  });

  @override
  State<_CatalogueCard> createState() => _CatalogueCardState();
}

class _CatalogueCardState extends State<_CatalogueCard> {
  late int _stock;

  @override
  void initState() {
    super.initState();
    _stock = widget.initialStock;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Header
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
            child: SizedBox(
              width: double.infinity,
              height: 170,
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFF1F5F9),
                  child: const Center(
                    child: Icon(Icons.broken_image_outlined, size: 40, color: Color(0xFF94A3B8)),
                  ),
                ),
              ),
            ),
          ),

          // Content Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and GI Tag Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.titleEn,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.hasGi) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'GI',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF047857),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  widget.titleHi,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8A94A6),
                  ),
                ),
                const SizedBox(height: 10),

                // Price and Status Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${widget.price}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.status,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF047857),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Stock Stepper Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Stock',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Row(
                      children: [
                        _buildStepperBtn(
                          icon: Icons.remove,
                          onTap: () {
                            if (_stock > 0) setState(() => _stock--);
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            '$_stock',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        _buildStepperBtn(
                          icon: Icons.add,
                          onTap: () => setState(() => _stock++),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Actions: Edit Price and QR button
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Opening price edit modal...')),
                          );
                        },
                        icon: const Icon(Icons.sell_outlined, size: 16),
                        label: const Text('Edit Price'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary, width: 1.2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Generating verifiable product QR Code...')),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 48,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: const Center(
                          child: Icon(Icons.qr_code_2_rounded, color: AppColors.primary, size: 24),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperBtn({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
      ),
    );
  }
}
