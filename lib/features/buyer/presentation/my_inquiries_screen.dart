import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_client.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/models.dart';

final buyerInquiriesProvider = FutureProvider.autoDispose<List<InquiryModel>>((ref) async {
  final api = ref.read(apiClientProvider);
  return api.getInquiries();
});

class MyInquiriesScreen extends ConsumerWidget {
  const MyInquiriesScreen({super.key});

  static const _orders = [
    {
      'title': 'Handwoven Varanasi Pure Silk Dupatta',
      'client': 'FabIndia · 50 units',
      'stage': 1,
      'status': 'Inquiry Sent',
      'quantity': 50,
      'notes': 'Looking for authentic zari border with temple motif weave.',
      'response': null,
    },
    {
      'title': 'Bastar Dhokra Bronze Figurine',
      'client': 'Dastkar · 25 units',
      'stage': 2,
      'status': 'Artisan Quoted',
      'quantity': 25,
      'notes': 'Traditional lost-wax bell metal craft figurines for festive gifting.',
      'response': 'Quoted ₹1,800 per unit. Can complete casting in 3 weeks.',
    },
    {
      'title': 'Kutch Mirror Embroidery Panel',
      'client': 'Tribal Co-op · 15 units',
      'stage': 1,
      'status': 'Inquiry Sent',
      'quantity': 15,
      'notes': 'Need natural vegetable dyed organic cotton panels.',
      'response': null,
    },
    {
      'title': 'Madhubani Fish Folk Painting',
      'client': 'Crafts Council of India · 30 units',
      'stage': 3,
      'status': 'Order Finalized',
      'quantity': 30,
      'notes': 'Handmade paper Madhubani paintings with natural dyes.',
      'response': 'Inquiry accepted! Handcrafted production scheduled.',
    },
    {
      'title': 'Pochampally Ikat Cotton Stole',
      'client': 'Taneira (Titan) · 100 units',
      'stage': 4,
      'status': 'Dispatched',
      'quantity': 100,
      'notes': '100% mulberry silk warp with mercerized cotton weft.',
      'response': 'Order dispatched via insured logistics partner.',
    },
  ];

  static int _mapStatusToStage(String status) {
    final s = status.toLowerCase();
    if (s.contains('dispatch') || s.contains('complet') || s.contains('deliver')) return 4;
    if (s.contains('final') || s.contains('accept') || s.contains('progress')) return 3;
    if (s.contains('quot') || s.contains('review')) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inquiriesAsync = ref.watch(buyerInquiriesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                'My Inquiries & Orders',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => ref.invalidate(buyerInquiriesProvider),
                  child: inquiriesAsync.when(
                    data: (items) {
                      if (items.isEmpty) {
                        return ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: _orders.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final order = _orders[index];
                            return _OrderStepperCard(
                              title: order['title'] as String,
                              client: order['client'] as String,
                              currentStage: order['stage'] as int,
                              onTap: () => _showMockInquiryDetailSheet(context, order),
                            );
                          },
                        );
                      }

                      return ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _OrderStepperCard(
                            title: item.productTitle.isNotEmpty ? item.productTitle : 'Artisan Craft Item',
                            client: '${item.quantity} units · Status: ${item.status}',
                            currentStage: _mapStatusToStage(item.status),
                            onTap: () => _showInquiryDetailSheet(context, item),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    error: (err, stack) => ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: _orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        return _OrderStepperCard(
                          title: order['title'] as String,
                          client: order['client'] as String,
                          currentStage: order['stage'] as int,
                          onTap: () => _showMockInquiryDetailSheet(context, order),
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
    );
  }

  void _showInquiryDetailSheet(BuildContext context, InquiryModel inquiry) {
    final stage = _mapStatusToStage(inquiry.status);
    final s = inquiry.status.toLowerCase();
    final isAccepted = s.contains('accept') || s.contains('final') || s.contains('complet') || s.contains('dispatch');
    final isDeclined = s.contains('decline') || s.contains('denied') || s.contains('reject');
    final isPending = !isAccepted && !isDeclined;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inquiry Details',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        inquiry.createdAt != null
                            ? 'Submitted on ${inquiry.createdAt!.day}/${inquiry.createdAt!.month}/${inquiry.createdAt!.year}'
                            : 'Inquiry Reference',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isAccepted
                        ? const Color(0xFFDCFCE7)
                        : isDeclined
                            ? const Color(0xFFFEE2E2)
                            : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    inquiry.status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isAccepted
                          ? const Color(0xFF15803D)
                          : isDeclined
                              ? const Color(0xFFB91C1C)
                              : const Color(0xFFD97706),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Product card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          inquiry.productTitle.isNotEmpty ? inquiry.productTitle : 'Artisan Craft Product',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Quantity: ${inquiry.quantity} pcs',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                        ),
                        if (inquiry.unitPrice != null && inquiry.unitPrice! > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Estimated: ${AppFormatters.inr(inquiry.unitPrice! * inquiry.quantity)} (${AppFormatters.inr(inquiry.unitPrice!)} / unit)',
                            style: const TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Stepper card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Stage Progress',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 14),
                  _ProgressStepperRow(currentStage: stage),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Buyer's Note
            if (inquiry.note != null && inquiry.note!.trim().isNotEmpty) ...[
              const Text(
                'Your Request Note',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Text(
                  inquiry.note!.trim(),
                  style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.4),
                ),
              ),
              const SizedBox(height: 18),
            ],

            // Artisan Response
            const Text(
              'Artisan Status & Response',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isAccepted
                    ? const Color(0xFFF0FDF4)
                    : isDeclined
                        ? const Color(0xFFFEF2F2)
                        : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isAccepted
                      ? const Color(0xFF86EFAC)
                      : isDeclined
                          ? const Color(0xFFFCA5A5)
                          : const Color(0xFFFCD34D),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isAccepted
                            ? Icons.check_circle_rounded
                            : isDeclined
                                ? Icons.cancel_rounded
                                : Icons.hourglass_top_rounded,
                        color: isAccepted
                            ? const Color(0xFF15803D)
                            : isDeclined
                                ? const Color(0xFFDC2626)
                                : const Color(0xFFD97706),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isAccepted
                            ? 'Inquiry Accepted by Artisan'
                            : isDeclined
                                ? 'Inquiry Declined by Artisan'
                                : 'Waiting for Artisan Review',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isAccepted
                              ? const Color(0xFF15803D)
                              : isDeclined
                                  ? const Color(0xFFDC2626)
                                  : const Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                  if (inquiry.responseMessage != null && inquiry.responseMessage!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      inquiry.responseMessage!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isAccepted
                            ? const Color(0xFF166534)
                            : isDeclined
                                ? const Color(0xFF991B1B)
                                : const Color(0xFF78350F),
                        height: 1.4,
                      ),
                    ),
                  ] else if (isPending) ...[
                    const SizedBox(height: 6),
                    const Text(
                      'The artisan has received your wholesale requirement and is preparing quotation / availability details.',
                      style: TextStyle(fontSize: 12.5, color: Color(0xFF78350F)),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                if (inquiry.productId.isNotEmpty) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: const Text('View Product'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.push(RouteNames.productDetail(inquiry.productId));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showMockInquiryDetailSheet(BuildContext context, Map<String, dynamic> order) {
    final title = order['title'] as String;
    final client = order['client'] as String;
    final stage = order['stage'] as int;
    final notes = order['notes'] as String? ?? '';
    final response = order['response'] as String?;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(client, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
            const SizedBox(height: 18),
            _ProgressStepperRow(currentStage: stage),
            const SizedBox(height: 18),
            if (notes.isNotEmpty) ...[
              const Text('Inquiry Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(notes, style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
              ),
              const SizedBox(height: 12),
            ],
            if (response != null && response.isNotEmpty) ...[
              const Text('Artisan Response', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: Text(response, style: const TextStyle(fontSize: 13, color: Color(0xFF15803D))),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressStepperRow extends StatelessWidget {
  final int currentStage;
  const _ProgressStepperRow({required this.currentStage});

  static const _stageLabels = [
    'Inquiry Sent',
    'Artisan Quoted',
    'Order Finalized',
    'Dispatched',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(4, (index) {
        final stepNum = index + 1;
        final isPassed = currentStage > stepNum;
        final isCurrent = currentStage == stepNum;

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  if (index > 0)
                    Expanded(
                      child: Container(
                        height: 2.5,
                        color: currentStage >= stepNum
                            ? const Color(0xFF15803D)
                            : const Color(0xFFE2E8F0),
                      ),
                    )
                  else
                    const Spacer(),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (isPassed || isCurrent)
                          ? const Color(0xFF15803D)
                          : const Color(0xFFF1F5F9),
                    ),
                    child: Center(
                      child: isPassed
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                          : Text(
                              '$stepNum',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isCurrent
                                    ? Colors.white
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                    ),
                  ),
                  if (index < 3)
                    Expanded(
                      child: Container(
                        height: 2.5,
                        color: currentStage > stepNum
                            ? const Color(0xFF15803D)
                            : const Color(0xFFE2E8F0),
                      ),
                    )
                  else
                    const Spacer(),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _stageLabels[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: (isPassed || isCurrent) ? FontWeight.w700 : FontWeight.w500,
                  color: (isPassed || isCurrent)
                      ? const Color(0xFF15803D)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _OrderStepperCard extends StatelessWidget {
  final String title;
  final String client;
  final int currentStage; // 1 to 4
  final VoidCallback? onTap;

  const _OrderStepperCard({
    required this.title,
    required this.client,
    required this.currentStage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(color: Color(0x04000000), blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: 3D Box Icon + Title + Client + Chevron tap indicator
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 22),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          client,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF94A3B8),
                    size: 22,
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 4-Stage Stepper
              _ProgressStepperRow(currentStage: currentStage),
            ],
          ),
        ),
      ),
    );
  }
}
