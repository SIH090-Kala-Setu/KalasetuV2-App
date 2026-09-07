import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';

import '../../../core/network/api_client.dart';
import '../../../shared/models/models.dart';

final artisanInquiriesProvider = FutureProvider.autoDispose<List<InquiryModel>>((ref) async {
  final api = ref.read(apiClientProvider);
  return api.getInquiries();
});

class ArtisanInquiriesScreen extends ConsumerWidget {
  const ArtisanInquiriesScreen({super.key});

  static const _inquiries = [
    {
      'buyer': 'FabIndia',
      'status': 'New',
      'statusBg': Color(0xFFFEF3C7),
      'statusColor': Color(0xFFD97706),
      'description': '50 units · Handwoven Varanasi Pure Silk Dupatta',
      'time': '2 hours ago',
    },
    {
      'buyer': 'Dastkar',
      'status': 'Quoted',
      'statusBg': Color(0xFFDBEAFE),
      'statusColor': Color(0xFF1D4ED8),
      'description': '25 units · Bastar Dhokra Bronze Figurine',
      'time': '5 hours ago',
    },
    {
      'buyer': 'Tribal Co-op',
      'status': 'New',
      'statusBg': Color(0xFFFEF3C7),
      'statusColor': Color(0xFFD97706),
      'description': '15 units · Kutch Mirror Embroidery Panel',
      'time': '1 day ago',
    },
    {
      'buyer': 'Crafts Council of India',
      'status': 'Finalized',
      'statusBg': Color(0xFFD1FAE5),
      'statusColor': Color(0xFF047857),
      'description': '30 units · Madhubani Fish Folk Painting',
      'time': '2 days ago',
    },
    {
      'buyer': 'Taneira (Titan)',
      'status': 'Dispatched',
      'statusBg': Color(0xFFE0E7FF),
      'statusColor': Color(0xFF4338CA),
      'description': '100 units · Pochampally Ikat Cotton Stole',
      'time': '3 days ago',
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inquiriesAsync = ref.watch(artisanInquiriesProvider);

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
                'B2B Inquiries',
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
                  onRefresh: () async => ref.invalidate(artisanInquiriesProvider),
                  child: inquiriesAsync.when(
                    data: (items) {
                      if (items.isEmpty) {
                        return ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: _inquiries.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = _inquiries[index];
                            return _InquiryListItem(
                              buyer: item['buyer'] as String,
                              status: item['status'] as String,
                              statusBg: item['statusBg'] as Color,
                              statusColor: item['statusColor'] as Color,
                              description: item['description'] as String,
                              time: item['time'] as String,
                              onTap: () => _showInquiryDetailsModal(context, ref, null, item['buyer'] as String, item['description'] as String),
                            );
                          },
                        );
                      }

                      return ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final s = item.status.toLowerCase();
                          final isAccepted = s.contains('accept') || s.contains('complet') || s.contains('final');
                          final isDeclined = s.contains('decline') || s.contains('denied') || s.contains('reject');
                          final isNew = item.status == 'inquiry-sent' || s.contains('new') || s.contains('pending');

                          final Color statusBg = isAccepted
                              ? const Color(0xFFD1FAE5)
                              : isDeclined
                                  ? const Color(0xFFFEE2E2)
                                  : isNew
                                      ? const Color(0xFFFEF3C7)
                                      : const Color(0xFFDBEAFE);

                          final Color statusColor = isAccepted
                              ? const Color(0xFF047857)
                              : isDeclined
                                  ? const Color(0xFFB91C1C)
                                  : isNew
                                      ? const Color(0xFFD97706)
                                      : const Color(0xFF1D4ED8);

                          return _InquiryListItem(
                            buyer: item.buyerName,
                            status: item.status,
                            statusBg: statusBg,
                            statusColor: statusColor,
                            description: '${item.quantity} units · ${item.productTitle.isNotEmpty ? item.productTitle : "Artisan Craft"}',
                            time: item.createdAt != null
                                ? '${item.createdAt!.day}/${item.createdAt!.month}/${item.createdAt!.year}'
                                : 'Recent',
                            onTap: () => _showInquiryDetailsModal(
                              context,
                              ref,
                              item.id,
                              item.buyerName,
                              '${item.quantity} units · ${item.productTitle}\n${item.note ?? ""}',
                              status: item.status,
                              responseMessage: item.responseMessage,
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    error: (err, stack) => ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: _inquiries.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _inquiries[index];
                        return _InquiryListItem(
                          buyer: item['buyer'] as String,
                          status: item['status'] as String,
                          statusBg: item['statusBg'] as Color,
                          statusColor: item['statusColor'] as Color,
                          description: item['description'] as String,
                          time: item['time'] as String,
                          onTap: () => _showInquiryDetailsModal(
                            context,
                            ref,
                            null,
                            item['buyer'] as String,
                            item['description'] as String,
                            status: item['status'] as String,
                          ),
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

  void _showInquiryDetailsModal(
    BuildContext context,
    WidgetRef ref,
    String? inquiryId,
    String buyer,
    String desc, {
    String status = 'Pending',
    String? responseMessage,
  }) {
    final s = status.toLowerCase();
    final isAccepted = s.contains('accept') || s.contains('complet') || s.contains('final');
    final isDeclined = s.contains('decline') || s.contains('denied') || s.contains('reject');
    final isResponded = s.contains('respond') && !isAccepted && !isDeclined;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
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
                    buyer,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                desc.trim(),
                style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.4),
              ),
            ),
            const SizedBox(height: 18),

            // If already resolved, show the resolution status banner instead of action buttons!
            if (isAccepted) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: Color(0xFF15803D), size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Inquiry Accepted',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      responseMessage != null && responseMessage.isNotEmpty
                          ? 'Response: $responseMessage'
                          : 'You accepted this inquiry! Order preparation is underway.',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF166534)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ] else if (isDeclined) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Inquiry Declined',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      responseMessage != null && responseMessage.isNotEmpty
                          ? 'Response: $responseMessage'
                          : 'You declined this inquiry.',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF991B1B)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ] else if (isResponded) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF93C5FD)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF1D4ED8), size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Responded to Buyer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1D4ED8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      responseMessage ?? 'Your response was sent to the buyer.',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF1E40AF)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ] else ...[
              // Still pending / unresolved: Show both Decline and Accept buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        if (inquiryId != null) {
                          try {
                            await ref.read(apiClientProvider).respondToInquiry(
                              inquiryId,
                              'Inquiry declined by artisan.',
                              status: 'Declined',
                            );
                            ref.invalidate(artisanInquiriesProvider);
                          } catch (_) {}
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Inquiry declined')),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(color: Color(0xFFDC2626)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        if (inquiryId != null) {
                          try {
                            await ref.read(apiClientProvider).respondToInquiry(
                              inquiryId,
                              'Inquiry accepted! We are preparing the order.',
                              status: 'Accepted',
                            );
                            ref.invalidate(artisanInquiriesProvider);
                          } catch (_) {}
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Accepted inquiry from $buyer!')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF15803D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Accept Inquiry'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InquiryListItem extends StatelessWidget {
  final String buyer;
  final String status;
  final Color statusBg;
  final Color statusColor;
  final String description;
  final String time;
  final VoidCallback onTap;

  const _InquiryListItem({
    required this.buyer,
    required this.status,
    required this.statusBg,
    required this.statusColor,
    required this.description,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(color: Color(0x04000000), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            // Chat Icon Container
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF64748B), size: 22),
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        buyer,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 22),
          ],
        ),
      ),
    );
  }
}
