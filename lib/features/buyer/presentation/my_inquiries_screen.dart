import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';

class MyInquiriesScreen extends ConsumerWidget {
  const MyInquiriesScreen({super.key});

  static const _orders = [
    {
      'title': 'Handwoven Varanasi Pure Silk Dupatta',
      'client': 'FabIndia · 50 units',
      'stage': 1,
    },
    {
      'title': 'Bastar Dhokra Bronze Figurine',
      'client': 'Dastkar · 25 units',
      'stage': 2,
    },
    {
      'title': 'Kutch Mirror Embroidery Panel',
      'client': 'Tribal Co-op · 15 units',
      'stage': 1,
    },
    {
      'title': 'Madhubani Fish Folk Painting',
      'client': 'Crafts Council of India · 30 units',
      'stage': 3,
    },
    {
      'title': 'Pochampally Ikat Cotton Stole',
      'client': 'Taneira (Titan) · 100 units',
      'stage': 4,
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
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
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: _orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return _OrderStepperCard(
                      title: order['title'] as String,
                      client: order['client'] as String,
                      currentStage: order['stage'] as int,
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

class _OrderStepperCard extends StatelessWidget {
  final String title;
  final String client;
  final int currentStage; // 1 to 4

  const _OrderStepperCard({
    required this.title,
    required this.client,
    required this.currentStage,
  });

  static const _stageLabels = [
    'Inquiry Sent',
    'Artisan Quoted',
    'Order Finalized',
    'Dispatched',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x04000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: 3D Box Icon + Title + Client
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
            ],
          ),
          const SizedBox(height: 18),

          // 4-Stage Stepper
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(4, (index) {
              final stepNum = index + 1;
              final isPassed = currentStage > stepNum;
              final isCurrent = currentStage == stepNum;

              return Expanded(
                child: Column(
                  children: [
                    // Node + connecting line row
                    Row(
                      children: [
                        // Pre line
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

                        // Circle Indicator
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

                        // Post line
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

                    // Label
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
          ),
        ],
      ),
    );
  }
}
