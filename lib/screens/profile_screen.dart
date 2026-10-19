import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'legal/about_us_screen.dart';
import 'legal/terms_of_service_screen.dart';
import 'legal/privacy_policy_screen.dart';

/// User Profile & Account Screen featuring past Konongo orders, saved addresses,
/// Mobile Money payment methods, and local customer support.
class ProfileScreen extends StatelessWidget {
  final VoidCallback onReorder;

  const ProfileScreen({super.key, required this.onReorder});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        // User Avatar & Name Card
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
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.primarySubtle,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'KM',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kwame Mensah',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '+233 24 892 4102',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 12, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              'Post Office Rd, Konongo',
                              style: AppTypography.caption(context).copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primarySubtle,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Text(
                      'GOLD',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 18)),

        // Recent Orders Section Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Orders in Konongo',
                  style: AppTypography.cardTitle(context).copyWith(fontSize: 15),
                ),
                Text(
                  'View History',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 10)),

        // Recent Orders List
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Column(
              children: [
                _buildOrderHistoryCard(
                  context: context,
                  orderId: '#CK-8120',
                  dishName: 'Smoky Jollof & Grilled Chicken + Plantains',
                  date: 'Yesterday, 6:45 PM',
                  total: 'GH₵55.00',
                  status: 'DELIVERED',
                  onReorder: onReorder,
                ),
                _buildOrderHistoryCard(
                  context: context,
                  orderId: '#CK-7984',
                  dishName: 'Fufu & Goat Meat Light Soup',
                  date: 'Sep 6, 1:15 PM',
                  total: 'GH₵40.00',
                  status: 'DELIVERED',
                  onReorder: onReorder,
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 18)),


        // Account Options Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: AppShadows.soft,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildProfileTile(
                    icon: Icons.location_on_outlined,
                    title: 'Saved Delivery Spots',
                    subtitle: 'Post Office Rd, Market Circle, Station',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _buildProfileTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Mobile Money Accounts',
                    subtitle: 'MTN MoMo (024***4102)',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _buildProfileTile(
                    icon: Icons.headset_mic_outlined,
                    title: 'Konongo Help Desk',
                    subtitle: 'Direct rider & kitchen support hotline',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _buildProfileTile(
                    icon: Icons.info_outline_rounded,
                    title: 'About ClickBites Konongo',
                    subtitle: 'Mission, fleet & local community info',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AboutUsScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildProfileTile(
                    icon: Icons.gavel_outlined,
                    title: 'Terms of Service',
                    subtitle: 'Ordering, delivery & cancellation policy',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildProfileTile(
                    icon: Icons.security_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'Act 843 compliance & data protection',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 8),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/clickbite_logo.png',
                  height: 42,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Fresh Food Delivered Across Konongo, Ashanti',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'ClickBite v1.0.0+1 • Made for Konongo',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: SizedBox(height: 96 + MediaQuery.paddingOf(context).bottom),
        ),
      ],
    );
  }

  Widget _buildOrderHistoryCard({
    required BuildContext context,
    required String orderId,
    required String dishName,
    required String date,
    required String total,
    required String status,
    required VoidCallback onReorder,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
              Text(
                orderId,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            dishName,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$date • $total',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
              TextButton(
                onPressed: onReorder,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Reorder',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary, size: 20),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
        onTap: onTap,
      ),
    );
  }
}
