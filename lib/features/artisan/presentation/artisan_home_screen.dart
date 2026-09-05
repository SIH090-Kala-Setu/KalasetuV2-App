import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/auth_provider.dart';

class ArtisanHomeScreen extends ConsumerWidget {
  const ArtisanHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider).valueOrNull;
    final user = auth?.user;
    final name = user?.fullName.isNotEmpty == true ? user!.fullName : 'Ramesh Sharma';

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Greeting & Profile Row ─────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'नमस्ते, $name 🙏',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield_outlined, size: 14, color: Color(0xFF10B981)),
                            SizedBox(width: 4),
                            Text(
                              'MoSJE Verified Artisan',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF047857),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // User Avatar
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFF5A623), width: 2),
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1544717305-2782549b5136?w=150'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // ── Deep Navy Earnings Card ────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Subtle background circle decoration
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.04),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Estimated Monthly Earnings',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '₹ 24,500',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '12',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Active Listings',
                                  style: TextStyle(fontSize: 12, color: Colors.white60),
                                ),
                              ],
                            ),
                            Container(
                              height: 32,
                              width: 1,
                              color: Colors.white24,
                              margin: const EdgeInsets.symmetric(horizontal: 24),
                            ),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '184',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Catalog Views',
                                  style: TextStyle(fontSize: 12, color: Colors.white60),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        InkWell(
                          onTap: () {},
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.payments_outlined, size: 16, color: Color(0xFFF5A623)),
                              SizedBox(width: 6),
                              Text(
                                'Withdraw Payout →',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFF5A623),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ── 2x2 Action Cards ───────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _ActionTile(
                      title: 'Add Product (AI Studio)',
                      icon: Icons.camera_alt_outlined,
                      iconBg: const Color(0xFFF5A623),
                      onTap: () => context.push(RouteNames.artisanStudio),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _ActionTile(
                      title: 'My Catalogue',
                      icon: Icons.inventory_2_outlined,
                      iconBg: const Color(0xFF1B2A4A),
                      onTap: () => context.push(RouteNames.artisanCatalogue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _ActionTile(
                      title: 'Inquiries Inbox',
                      icon: Icons.chat_bubble_outline_rounded,
                      iconBg: const Color(0xFF3B82F6),
                      badgeText: '3 New',
                      onTap: () => context.push(RouteNames.artisanInquiries),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _ActionTile(
                      title: 'Exhibitions & Melas',
                      icon: Icons.holiday_village_outlined,
                      iconBg: const Color(0xFF10B981),
                      onTap: () => context.push(RouteNames.artisanExhibitions),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Recent B2B Inquiries ───────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent B2B Inquiries',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push(RouteNames.artisanInquiries),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _InquiryActionCard(
                buyerName: 'FabIndia',
                description: '50 units · Handwoven Varanasi Pure Silk Dupatta',
                onQuote: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening quotation sheet for FabIndia')),
                ),
                onAccept: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Accepted inquiry from FabIndia!')),
                ),
              ),
              const SizedBox(height: 10),

              _InquiryActionCard(
                buyerName: 'Dastkar',
                description: '25 units · Bastar Dhokra Bronze Figurine',
                onQuote: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening quotation sheet for Dastkar')),
                ),
                onAccept: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Accepted inquiry from Dastkar!')),
                ),
              ),
              const SizedBox(height: 24),

              // ── MoSJE Welfare Schemes ──────────────────────────────
              const Text(
                'MoSJE Welfare Schemes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 3)),
                  ],
                ),
                child: Column(
                  children: [
                    // Amber ribbon header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEF9EE),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.workspace_premium_outlined, color: Color(0xFFD97706), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Active Schemes for You',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF92400E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFFDE68A)),

                    _SchemeItem(
                      title: 'PM Vishwakarma Toolkit Incentive',
                      description:
                          'Get up to ₹15,000 for purchasing new tools and equipment. Available to verified artisans in 18 trades.',
                      deadline: '15 Sep 2026',
                      onApply: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Applying for PM Vishwakarma Toolkit Incentive...')),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),

                    _SchemeItem(
                      title: 'Mudra Loan Assistance',
                      description:
                          'Collateral-free micro-loans up to ₹10 lakh for working capital and business expansion. Direct subsidy credit.',
                      deadline: 'Ongoing',
                      onApply: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Applying for Mudra Loan Assistance...')),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconBg;
  final String? badgeText;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title,
    required this.icon,
    required this.iconBg,
    this.badgeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 130,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 3)),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    height: 1.25,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
            if (badgeText != null)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badgeText!,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InquiryActionCard extends StatelessWidget {
  final String buyerName;
  final String description;
  final VoidCallback onQuote;
  final VoidCallback onAccept;

  const _InquiryActionCard({
    required this.buyerName,
    required this.description,
    required this.onQuote,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
          // Gray squircle chat icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF64748B), size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  buyerName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Action Buttons: Quote (Amber), Accept (Green)
          ElevatedButton(
            onPressed: onQuote,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF5A623),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: const Size(0, 36),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Quote', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 6),
          ElevatedButton(
            onPressed: onAccept,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF15803D),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: const Size(0, 36),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Accept', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _SchemeItem extends StatelessWidget {
  final String title;
  final String description;
  final String deadline;
  final VoidCallback onApply;

  const _SchemeItem({
    required this.title,
    required this.description,
    required this.deadline,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Color(0xFF92400E)),
                    const SizedBox(width: 4),
                    Text(
                      'Deadline: $deadline',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onApply,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF5A623),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              minimumSize: const Size(0, 38),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Apply', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
