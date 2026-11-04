import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bouncy_tap.dart';
import 'vendor_dashboard_screen.dart';
import 'vendor_menu_screen.dart';
import 'vendor_orders_screen.dart';
import 'vendor_payments_screen.dart';
import 'vendor_analytics_screen.dart';

/// Vendor Portal Shell Container
class VendorShellScreen extends StatefulWidget {
  final VoidCallback? onSwitchToCustomer;

  const VendorShellScreen({super.key, this.onSwitchToCustomer});

  @override
  State<VendorShellScreen> createState() => _VendorShellScreenState();
}

class _VendorShellScreenState extends State<VendorShellScreen> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/clickbite_logo.webp',
              height: 38,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              errorBuilder: (_, _, _) => Text(
                'ClickBite',
                style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primarySubtle,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Text(
                'KITCHEN',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 9.5,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Switch to Customer App Button
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: BouncyTap(
              onTap: () {
                if (widget.onSwitchToCustomer != null) {
                  widget.onSwitchToCustomer!();
                } else {
                  Navigator.pop(context);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.person_outline_rounded, size: 14, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text(
                      'Customer View',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Stack(
              children: [
                // Active Screen
                Positioned.fill(
                  child: IndexedStack(
                    index: _currentNavIndex,
                    children: [
                      VendorDashboardScreen(onNavigateTab: (idx) => setState(() => _currentNavIndex = idx)),
                      const VendorMenuScreen(),
                      const VendorOrdersScreen(),
                      const VendorPaymentsScreen(),
                      const VendorAnalyticsScreen(),
                    ],
                  ),
                ),

                // Floating Vendor Dock Bottom Navigation Bar
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildVendorBottomNav(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVendorBottomNav() {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 12 + bottomInset),
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(34),
        boxShadow: AppShadows.floatingNav,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTabItem(0, Icons.dashboard_rounded, Icons.dashboard_outlined, 'Dashboard'),
            _buildTabItem(1, Icons.restaurant_menu_rounded, Icons.restaurant_menu_outlined, 'My Meals'),
            _buildTabItem(2, Icons.soup_kitchen_rounded, Icons.soup_kitchen_outlined, 'Orders'),
            _buildTabItem(3, Icons.payments_rounded, Icons.payments_outlined, 'Payouts'),
            _buildTabItem(4, Icons.insights_rounded, Icons.insights_outlined, 'Analytics'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, IconData unselectedIcon, String label) {
    final isSelected = _currentNavIndex == index;

    if (isSelected) {
      return BouncyTap(
        onTap: () => setState(() => _currentNavIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.28),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return BouncyTap(
      onTap: () => setState(() => _currentNavIndex = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(unselectedIcon, size: 20, color: AppColors.textSecondary),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
