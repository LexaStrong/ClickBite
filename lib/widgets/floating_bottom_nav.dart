import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'bouncy_tap.dart';

/// Floating dock bottom navigation bar matching the Tortilla app reference design.
/// - Active 'Home' pill with terracotta background and white text.
/// - Tab 2 updated to 'Track' (replacing rewards) with delivery moped icon.
/// - Center elevated circular terracotta cart button with tactile bouncy feedback.
class FloatingBottomNav extends StatelessWidget {
  final int currentIndex;
  final int cartCount;
  final Function(int) onTabSelected;
  final VoidCallback? onCartTap;

  const FloatingBottomNav({
    super.key,
    required this.currentIndex,
    required this.cartCount,
    required this.onTabSelected,
    this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Tab 0: Home (Terracotta Pill when active)
            _buildTabPill(
              context: context,
              index: 0,
              icon: Icons.home_rounded,
              unselectedIcon: Icons.home_outlined,
              label: 'Home',
            ),

            // Tab 1: Restaurants
            _buildTabPill(
              context: context,
              index: 1,
              icon: Icons.storefront_rounded,
              unselectedIcon: Icons.storefront_outlined,
              label: 'Spots',
            ),

            // Center Elevated Cart Button
            _buildCenterCartButton(context),

            // Tab 2: Track (Replaced Rewards with Live Tracking)
            _buildTabPill(
              context: context,
              index: 2,
              icon: Icons.moped_rounded,
              unselectedIcon: Icons.moped_outlined,
              label: 'Track',
            ),

            // Tab 3: Profile
            _buildTabPill(
              context: context,
              index: 3,
              icon: Icons.person_rounded,
              unselectedIcon: Icons.person_outline_rounded,
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPill({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData unselectedIcon,
    required String label,
  }) {
    final isActive = currentIndex == index;

    if (isActive) {
      return BouncyTap(
        onTap: () => onTabSelected(index),
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
              Icon(icon, color: Colors.white, size: 19),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return BouncyTap(
      onTap: () => onTabSelected(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              unselectedIcon,
              size: 20,
              color: AppColors.textSecondary,
            ),
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

  Widget _buildCenterCartButton(BuildContext context) {
    return BouncyTap(
      onTap: onCartTap ?? () => onTabSelected(4),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: AppShadows.buttonElevated,
            ),
            child: const Center(
              child: Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          if (cartCount > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Center(
                  child: Text(
                    '$cartCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
