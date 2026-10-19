import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../state/vendor_state.dart';

/// Kitchen Performance, Top Dishes, and Sales Analytics Screen
class VendorAnalyticsScreen extends StatelessWidget {
  const VendorAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vendor = VendorState();

    return ListenableBuilder(
      listenable: vendor,
      builder: (context, _) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Screen Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kitchen Analytics',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Customer demand, top selling dishes & order speed metrics.',
                      style: AppTypography.caption(context).copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // 1. Weekly Revenue Histogram Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.xxl),
                    boxShadow: AppShadows.card,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('This Week Sales', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              Text(
                                'GH₵4,820.00',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '+18.4% vs last week',
                              style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w800, fontSize: 10),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Day Bars (Mon to Sun)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildDayBar('Mon', 0.5, '520'),
                          _buildDayBar('Tue', 0.65, '680'),
                          _buildDayBar('Wed', 0.45, '490'),
                          _buildDayBar('Thu', 0.75, '810'),
                          _buildDayBar('Fri', 0.95, '1040', isPeak: true),
                          _buildDayBar('Sat', 0.85, '920'),
                          _buildDayBar('Sun', 0.40, '360'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // 2. Operational KPIs Grid (Content-Driven)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildKpiBox(
                        context: context,
                        title: 'Avg Prep Time',
                        value: '18 mins',
                        subtitle: 'Target: < 22 mins',
                        icon: Icons.timer_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildKpiBox(
                        context: context,
                        title: 'Order Accuracy',
                        value: '99.2%',
                        subtitle: 'Zero wrong items',
                        icon: Icons.check_circle_outline_rounded,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // 3. Top Selling Dishes Ranking
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                child: Text(
                  'Top Selling Konongo Dishes',
                  style: AppTypography.cardTitle(context).copyWith(fontSize: 15),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.xxl),
                    boxShadow: AppShadows.card,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _buildDishRankRow(
                        rank: '1',
                        name: 'Smoky Jollof & Grilled Chicken',
                        ordersCount: '142 orders',
                        revenue: 'GH₵6,390',
                        progress: 0.95,
                      ),
                      const Divider(height: 16),
                      _buildDishRankRow(
                        rank: '2',
                        name: 'Fufu & Goat Meat Light Soup',
                        ordersCount: '98 orders',
                        revenue: 'GH₵3,920',
                        progress: 0.70,
                      ),
                      const Divider(height: 16),
                      _buildDishRankRow(
                        rank: '3',
                        name: 'Loaded Waakye Royal',
                        ordersCount: '86 orders',
                        revenue: 'GH₵3,010',
                        progress: 0.60,
                      ),
                      const Divider(height: 16),
                      _buildDishRankRow(
                        rank: '4',
                        name: 'Spicy Grilled Tilapia & Banku',
                        ordersCount: '64 orders',
                        revenue: 'GH₵3,520',
                        progress: 0.50,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // 4. Peak Ordering Hours in Konongo
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.schedule_rounded, size: 18, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text(
                            'Konongo Peak Demand Windows',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildPeakTimeRow('Lunch Rush', '11:45 AM - 2:30 PM', 'High (Office & Market workers)'),
                      const SizedBox(height: 6),
                      _buildPeakTimeRow('Dinner / Grills', '6:00 PM - 9:30 PM', 'Very High (Evening diners)'),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(height: 96 + MediaQuery.paddingOf(context).bottom),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDayBar(String day, double fraction, String amount, {bool isPeak = false}) {
    return Column(
      children: [
        Text(
          amount,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: isPeak ? AppColors.primary : AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 28,
          height: 90 * fraction,
          decoration: BoxDecoration(
            color: isPeak ? AppColors.primary : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          day,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isPeak ? FontWeight.w800 : FontWeight.w600,
            color: isPeak ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildKpiBox({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.soft,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Icon(icon, size: 16, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
        ],
      ),
    );
  }

  Widget _buildDishRankRow({
    required String rank,
    required String name,
    required String ordersCount,
    required String revenue,
    required double progress,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primarySubtle,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  rank,
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 11),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              revenue,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.surfaceElevated,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 5,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              ordersCount,
              style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPeakTimeRow(String label, String time, String desc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            Text(time, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primarySubtle,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            desc,
            style: const TextStyle(color: AppColors.primaryDark, fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
