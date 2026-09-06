import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';

import '../../../core/network/api_client.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/product_thumbnail.dart';

final artisanProductsProvider = FutureProvider.autoDispose<List<ProductModel>>((ref) async {
  final api = ref.read(apiClientProvider);
  return api.getProducts();
});

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
      'id': 'p1',
      'titleEn': 'Handwoven Varanasi Pure Silk Dupatta with Zari Border',
      'titleHi': 'हथकरघा बनारसी सिल्क दुपट्टा (ज़री बॉर्डर)',
      'price': 1200,
      'status': 'Active',
      'stock': 24,
      'hasGi': true,
      'imageUrl': 'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=600',
    },
    {
      'id': 'p2',
      'titleEn': 'Jaipur Blue Pottery Decorative Vase Set',
      'titleHi': 'जयपुर नीली मिट्टी का सजावटी फूलदान सेट',
      'price': 850,
      'status': 'Active',
      'stock': 8,
      'hasGi': true,
      'imageUrl': 'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?w=600',
    },
    {
      'id': 'p3',
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
    final productsAsync = ref.watch(artisanProductsProvider);

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
                child: RefreshIndicator(
                  onRefresh: () async => ref.invalidate(artisanProductsProvider),
                  child: productsAsync.when(
                    data: (products) {
                      final filtered = products.where((p) {
                        if (_selectedFilter == 'Active') return p.status == 'Active';
                        if (_selectedFilter == 'Drafts') return p.status == 'Draft' || p.status == 'Pending Review';
                        if (_selectedFilter == 'Sold Out') return p.status == 'Sold Out';
                        return true;
                      }).toList();

                      if (filtered.isEmpty && products.isEmpty) {
                        return ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: _demoCatalogue.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 18),
                          itemBuilder: (context, index) {
                            final item = _demoCatalogue[index];
                            return _CatalogueCard(
                              id: item['id'] as String?,
                              titleEn: item['titleEn'] as String,
                              titleHi: item['titleHi'] as String,
                              price: item['price'] as int,
                              status: item['status'] as String,
                              initialStock: item['stock'] as int,
                              hasGi: item['hasGi'] as bool,
                              imageUrl: item['imageUrl'] as String,
                            );
                          },
                        );
                      }

                      return ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 18),
                        itemBuilder: (context, index) {
                          final p = filtered[index];
                          return _CatalogueCard(
                            id: p.id,
                            titleEn: p.titleEn,
                            titleHi: p.titleHi.isNotEmpty ? p.titleHi : p.titleEn,
                            price: p.retailPrice.toInt(),
                            status: p.status,
                            initialStock: p.stock,
                            hasGi: p.giTag,
                            imageUrl: (p.imageUrl != null && p.imageUrl!.isNotEmpty)
                                ? p.imageUrl!
                                : 'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=600',
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                    error: (err, stack) => ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: _demoCatalogue.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 18),
                      itemBuilder: (context, index) {
                        final item = _demoCatalogue[index];
                        return _CatalogueCard(
                          id: item['id'] as String?,
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

class _CatalogueCard extends ConsumerStatefulWidget {
  final String? id;
  final String titleEn;
  final String titleHi;
  final int price;
  final String status;
  final int initialStock;
  final bool hasGi;
  final String imageUrl;

  const _CatalogueCard({
    this.id,
    required this.titleEn,
    required this.titleHi,
    required this.price,
    required this.status,
    required this.initialStock,
    required this.hasGi,
    required this.imageUrl,
  });

  @override
  ConsumerState<_CatalogueCard> createState() => _CatalogueCardState();
}

class _CatalogueCardState extends ConsumerState<_CatalogueCard> {
  late int _stock;
  late String _titleEn;
  late String _titleHi;
  late int _price;
  late String _status;

  @override
  void initState() {
    super.initState();
    _stock = widget.initialStock;
    _titleEn = widget.titleEn;
    _titleHi = widget.titleHi;
    _price = widget.price;
    _status = widget.status;
  }

  @override
  void didUpdateWidget(covariant _CatalogueCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialStock != widget.initialStock) _stock = widget.initialStock;
    if (oldWidget.titleEn != widget.titleEn) _titleEn = widget.titleEn;
    if (oldWidget.titleHi != widget.titleHi) _titleHi = widget.titleHi;
    if (oldWidget.price != widget.price) _price = widget.price;
    if (oldWidget.status != widget.status) _status = widget.status;
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF047857);
      case 'sold out':
        return const Color(0xFFDC2626);
      case 'draft':
        return const Color(0xFFD97706);
      case 'pending review':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFF64748B);
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFFD1FAE5);
      case 'sold out':
        return const Color(0xFFFEE2E2);
      case 'draft':
        return const Color(0xFFFEF3C7);
      case 'pending review':
        return const Color(0xFFDBEAFE);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  void _showProductQrModal(BuildContext context) {
    final productId = widget.id ?? 'p1';
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Product QR Code',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(dialogContext),
                      splashRadius: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _titleEn,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '₹$_price • Authenticated Artisan Craft',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: FutureBuilder<Uint8List>(
                    future: ref.read(apiClientProvider).getProductQr(productId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          width: 190,
                          height: 190,
                          child: Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                        );
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return const SizedBox(
                          width: 190,
                          height: 190,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.qr_code_rounded, size: 56, color: Color(0xFF94A3B8)),
                              SizedBox(height: 8),
                              Text(
                                'Could not load QR code',
                                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          snapshot.data!,
                          width: 190,
                          height: 190,
                          fit: BoxFit.contain,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Scan to view authentic artisan catalog listing on KalaSetu.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Product QR Code ready for sharing!')),
                      );
                    },
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: const Text('Share Listing'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditProductModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _EditProductSheet(
        id: widget.id,
        initialTitleEn: _titleEn,
        initialTitleHi: _titleHi,
        initialPrice: _price,
        initialStock: _stock,
        initialStatus: _status,
        onUpdated: (titleEn, titleHi, price, stock, status) {
          setState(() {
            _titleEn = titleEn;
            _titleHi = titleHi;
            _price = price;
            _stock = stock;
            _status = status;
          });
          ref.invalidate(artisanProductsProvider);
        },
      ),
    );
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
            child: ProductThumbnail(
              imageUrl: widget.imageUrl,
              width: double.infinity,
              height: 170,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.zero,
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
                        _titleEn,
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
                  _titleHi,
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
                      '₹$_price',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: _getStatusBgColor(_status),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _getStatusTextColor(_status),
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
                          onTap: () async {
                            if (_stock > 0) {
                              setState(() => _stock--);
                              if (widget.id != null && !widget.id!.startsWith('p')) {
                                try {
                                  final api = ref.read(apiClientProvider);
                                  await api.updateProductStock(widget.id!, _stock);
                                } catch (_) {}
                              }
                            }
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
                          onTap: () async {
                            setState(() => _stock++);
                            if (widget.id != null && !widget.id!.startsWith('p')) {
                              try {
                                final api = ref.read(apiClientProvider);
                                await api.updateProductStock(widget.id!, _stock);
                              } catch (_) {}
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Actions: Edit Product and QR button
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showEditProductModal(context),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit Product'),
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
                      onTap: () => _showProductQrModal(context),
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

class _EditProductSheet extends ConsumerStatefulWidget {
  final String? id;
  final String initialTitleEn;
  final String initialTitleHi;
  final int initialPrice;
  final int initialStock;
  final String initialStatus;
  final void Function(String titleEn, String titleHi, int price, int stock, String status) onUpdated;

  const _EditProductSheet({
    this.id,
    required this.initialTitleEn,
    required this.initialTitleHi,
    required this.initialPrice,
    required this.initialStock,
    required this.initialStatus,
    required this.onUpdated,
  });

  @override
  ConsumerState<_EditProductSheet> createState() => _EditProductSheetState();
}

class _EditProductSheetState extends ConsumerState<_EditProductSheet> {
  late final TextEditingController _titleEnController;
  late final TextEditingController _titleHiController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late String _status;
  bool _isLoading = false;

  static const _statusOptions = ['Active', 'Draft', 'Sold Out', 'Pending Review', 'Archived'];

  @override
  void initState() {
    super.initState();
    _titleEnController = TextEditingController(text: widget.initialTitleEn);
    _titleHiController = TextEditingController(text: widget.initialTitleHi);
    _priceController = TextEditingController(text: widget.initialPrice.toString());
    _stockController = TextEditingController(text: widget.initialStock.toString());
    _status = _statusOptions.contains(widget.initialStatus) ? widget.initialStatus : 'Active';
  }

  @override
  void dispose() {
    _titleEnController.dispose();
    _titleHiController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    final titleEn = _titleEnController.text.trim();
    if (titleEn.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product title cannot be empty.')),
      );
      return;
    }

    final price = int.tryParse(_priceController.text.trim()) ?? widget.initialPrice;
    final stock = int.tryParse(_stockController.text.trim()) ?? widget.initialStock;
    final titleHi = _titleHiController.text.trim();

    setState(() => _isLoading = true);
    try {
      if (widget.id != null && widget.id!.isNotEmpty && !widget.id!.startsWith('p')) {
        final api = ref.read(apiClientProvider);
        await api.updateProduct(widget.id!, {
          'title_en': titleEn,
          'title_hi': titleHi.isNotEmpty ? titleHi : titleEn,
          'base_price': price,
          'retail_price': price,
          'stock_count': stock,
          'status': _status,
        });
      }

      widget.onUpdated(titleEn, titleHi.isNotEmpty ? titleHi : titleEn, price, stock, _status);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product updated successfully!'),
            backgroundColor: Color(0xFF047857),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update product: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20 + bottomInset,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 24),
                SizedBox(width: 8),
                Text(
                  'Edit Product',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _titleEnController,
              decoration: InputDecoration(
                labelText: 'Title (English) *',
                prefixIcon: const Icon(Icons.title_rounded, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _titleHiController,
              decoration: InputDecoration(
                labelText: 'Title (Hindi)',
                prefixIcon: const Icon(Icons.translate_rounded, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Price (₹) *',
                      prefixIcon: const Icon(Icons.currency_rupee_rounded, color: AppColors.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _stockController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Stock Units',
                      prefixIcon: const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: InputDecoration(
                labelText: 'Listing Status',
                prefixIcon: const Icon(Icons.check_circle_outline, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              items: _statusOptions.map((opt) {
                return DropdownMenuItem<String>(
                  value: opt,
                  child: Text(opt),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _status = val);
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Save Product Changes',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
