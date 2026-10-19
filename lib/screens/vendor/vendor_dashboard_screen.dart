import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../state/vendor_state.dart';
import '../../models/vendor_models.dart';
import '../../widgets/bouncy_tap.dart';
import '../restaurant_detail_screen.dart';
import 'vendor_onboarding_screen.dart';

/// Vendor Dashboard Screen
/// Live kitchen control hub for Konongo restaurant partners.
class VendorDashboardScreen extends StatelessWidget {
  final Function(int) onNavigateTab;

  const VendorDashboardScreen({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final vendor = VendorState();

    return ListenableBuilder(
      listenable: vendor,
      builder: (context, _) {
        final profile = vendor.profile;
        final pending = vendor.pendingOrders;
        final preparing = vendor.preparingOrders;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // 1. Store Online/Offline & Status Header Card with Eatery Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.xxl),
                    boxShadow: AppShadows.card,
                    border: Border.all(color: AppColors.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      // Banner preview with change action
                      Stack(
                        children: [
                          Image.asset(
                            profile.bannerAsset,
                            height: 100,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.15),
                                  Colors.black.withValues(alpha: 0.75),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: BouncyTap(
                              onTap: () => _showChangeBannerModal(context, vendor),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(AppRadius.full),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.photo_camera_rounded, size: 13, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text(
                                      'Change Banner',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 10.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 12,
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: profile.isOpen ? AppColors.success : AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  profile.isOpen ? 'Accepting Orders' : 'Store Offline (Closed)',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Kitchen details row
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.restaurantName,
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    profile.address,
                                    style: AppTypography.caption(context).copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // View Dedicated Public Page Button
                            BouncyTap(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RestaurantDetailScreen(
                                      restaurant: vendor.asRestaurant,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySubtle,
                                  borderRadius: BorderRadius.circular(AppRadius.full),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.visibility_outlined, size: 13, color: AppColors.primary),
                                    SizedBox(width: 4),
                                    Text(
                                      'Public Page',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Switch
                            Transform.scale(
                              scale: 0.8,
                              child: Switch.adaptive(
                                value: profile.isOpen,
                                activeTrackColor: AppColors.primary,
                                onChanged: (_) => vendor.toggleStoreOpen(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // 2. Financial & Kitchen Overview Metric Cards (Content-Driven Layout)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        title: "Today's Gross",
                        value: 'GH₵${vendor.todaySales.toStringAsFixed(2)}',
                        subtitle: '${vendor.todayOrdersCount} orders today',
                        icon: Icons.account_balance_wallet_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        title: 'Available MoMo',
                        value: 'GH₵${profile.balanceAvailable.toStringAsFixed(2)}',
                        subtitle: 'Tap to withdraw',
                        icon: Icons.payments_rounded,
                        color: AppColors.accent,
                        onTap: () => onNavigateTab(2), // go to payments tab
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        title: 'Active in Kitchen',
                        value: '${preparing.length} preparing',
                        subtitle: '${vendor.activeOrders.length} in pipeline',
                        icon: Icons.soup_kitchen_rounded,
                        color: AppColors.primaryLight,
                        onTap: () => onNavigateTab(1), // go to orders
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        title: 'Rating & Quality',
                        value: '${profile.rating} ★',
                        subtitle: 'Top Rated in Konongo',
                        icon: Icons.verified_rounded,
                        color: AppColors.success,
                        onTap: () => onNavigateTab(3), // go to analytics
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // 3. Urgent Incoming Orders Stream
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'New Incoming Orders',
                          style: AppTypography.cardTitle(context).copyWith(fontSize: 16),
                        ),
                        if (pending.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              '${pending.length} NEW',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10),
                            ),
                          ),
                        ],
                      ],
                    ),
                    TextButton(
                      onPressed: () => onNavigateTab(1),
                      child: const Text('View All Orders', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.primary)),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Pending Orders Queue
            pending.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: 8),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 24),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Kitchen orders are up to date',
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                  ),
                                  Text(
                                    'New orders from Konongo customers will appear here in real-time.',
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final order = pending[index];
                          return _buildIncomingOrderCard(context, order, vendor);
                        },
                        childCount: pending.length,
                      ),
                    ),
                  ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // 4. Quick Partner Actions & Onboarding Link
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                child: Text(
                  'Kitchen Operations',
                  style: AppTypography.cardTitle(context).copyWith(fontSize: 15),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                child: Column(
                  children: [
                    _buildActionTile(
                      context: context,
                      icon: Icons.add_business_rounded,
                      title: 'Onboard New Kitchen / Branch',
                      subtitle: 'Setup food categories, addons, and pick curated dish photos',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VendorOnboardingScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildActionTile(
                      context: context,
                      icon: Icons.soup_kitchen_rounded,
                      title: 'Live Kitchen Display (KDS)',
                      subtitle: 'Manage food prep timers and courier dispatch for Kofi Boateng',
                      onTap: () => onNavigateTab(1),
                    ),
                    const SizedBox(height: 10),
                    _buildActionTile(
                      context: context,
                      icon: Icons.insights_rounded,
                      title: 'Sales Performance & Analytics',
                      subtitle: 'View top selling dishes, customer repeat rate & revenue trends',
                      onTap: () => onNavigateTab(3),
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
      },
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return BouncyTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: AppShadows.card,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTypography.caption(context).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: onTap != null ? AppColors.primary : AppColors.textTertiary,
                fontSize: 10.5,
                fontWeight: onTap != null ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomingOrderCard(BuildContext context, VendorOrder order, VendorState vendor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    order.id,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${DateTime.now().difference(order.orderTime).inMinutes}m ago',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${order.customerName} • ${order.deliveryAddress}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
          ),
          const SizedBox(height: 6),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Items Summary
          ...order.items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.quantity}x ',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 12),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.foodItem.name,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                        ),
                        if (item.addons.isNotEmpty)
                          Text(
                            item.addons.join(', '),
                            style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    'GH₵${item.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ],
              ),
            );
          }),

          if (order.notes != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sticky_note_2_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Note: ${order.notes}',
                      style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Actions: Accept / Start Preparing
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Vendor Payout', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                    Text(
                      'GH₵${order.netEarnings.toStringAsFixed(2)}',
                      style: AppTypography.price(context).copyWith(color: AppColors.primary, fontSize: 14),
                    ),
                  ],
                ),
              ),
              BouncyTap(
                onTap: () {
                  vendor.acceptOrder(order.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Order ${order.id} accepted! Sent to kitchen display.'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    boxShadow: AppShadows.buttonElevated,
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.soup_kitchen_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Accept & Cook',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return BouncyTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: AppShadows.soft,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primarySubtle,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }

  void _showChangeBannerModal(BuildContext context, VendorState vendor) {
    final bannerOptions = const [
      {
        'title': 'Firewood Jollof & Spiced Chicken',
        'asset': 'assets/images/jollof_rice.png',
        'subtitle': 'Warm smoky terracotta tones & rich spice presentation',
      },
      {
        'title': 'Pounded Fufu & Goat Light Soup',
        'asset': 'assets/images/fufu_soup.png',
        'subtitle': 'Authentic mortar & pestle feast with rich soup broth',
      },
      {
        'title': 'Volta Charcoal Tilapia & Banku',
        'asset': 'assets/images/grilled_tilapia.png',
        'subtitle': 'Fresh river catch with hot shito and green pepper relish',
      },
      {
        'title': 'Royal Waakye & Shito Feast',
        'asset': 'assets/images/waakye.png',
        'subtitle': 'Brown rice, spaghetti, gari fortor & seasoned wele',
      },
      {
        'title': 'Red Red Stew & Golden Plantains',
        'asset': 'assets/images/red_red.png',
        'subtitle': 'Caramelized sweet plantains with palm oil bean stew',
      },
      {
        'title': 'Ampesi & Kontommire Stew',
        'asset': 'assets/images/ampesi_kontommire.png',
        'subtitle': 'Boiled yam and plantain with rich cocoyam leaf stew',
      },
      {
        'title': 'Assorted Fried Rice Platter',
        'asset': 'assets/images/assorted fried_rice.png',
        'subtitle': 'Seasoned rice with mixed vegetables, chicken, and shrimp',
      },
      {
        'title': 'Assorted Jollof Rice Supreme',
        'asset': 'assets/images/assorted_jollof.png',
        'subtitle': 'Party-style smoky jollof with assorted meats and kelewele',
      },
      {
        'title': 'Kokonte & Groundnut Soup',
        'asset': 'assets/images/kokonte_soup.png',
        'subtitle': 'Smooth dried cassava kokonte with rich groundnut soup',
      },
      {
        'title': 'Grilled Shawarma Wrap',
        'asset': 'assets/images/shawarma.png',
        'subtitle': 'Spiced grilled chicken shawarma with garlic sauce and fries',
      },
      {
        'title': 'Tuo Zaafi & Ayoyo Soup',
        'asset': 'assets/images/tuo_zaafi.png',
        'subtitle': 'Northern Ghana tuo zaafi with slimy ayoyo and dawadawa',
      },
      {
        'title': 'Supreme Waakye Festival',
        'asset': 'assets/images/waakye_2.png',
        'subtitle': 'Premium waakye overload with extra wele and fried fish',
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Eatery Banner',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Choose which banner appears at the top of your restaurant\'s dedicated page on the customer app.',
                  style: AppTypography.caption(context).copyWith(fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  itemCount: bannerOptions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final option = bannerOptions[index];
                    final isCurrent = vendor.profile.bannerAsset == option['asset'];
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: isCurrent ? AppColors.primary : AppColors.border,
                          width: isCurrent ? 2 : 1,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          vendor.updateRestaurantBanner(option['asset']!);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Eatery banner updated to ${option['title']}'),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                child: Image.asset(
                                  option['asset']!,
                                  width: 60,
                                  height: 48,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      option['title']!,
                                      style: TextStyle(
                                        fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w700,
                                        fontSize: 12.5,
                                        color: isCurrent ? AppColors.primary : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      option['subtitle']!,
                                      style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isCurrent ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                color: isCurrent ? AppColors.primary : AppColors.textTertiary,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
