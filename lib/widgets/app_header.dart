import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Top header matching the Tortilla app reference design.
/// - Centered/left brand wordmark with symmetrical wing ornament.
/// - Circular notification bell button with badge.
/// - Circular user profile button.
class AppHeader extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final int notificationCount;

  const AppHeader({
    super.key,
    this.onNotificationTap,
    this.onProfileTap,
    this.notificationCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ClickBite Brand Logo Image + Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/clickbite_logo.webp',
                  height: 48,
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (context, error, stackTrace) {
                    return Text(
                      'ClickBite',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 14,
                      height: 1.5,
                      color: AppColors.primary.withValues(alpha: 0.6),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        Icons.diamond_rounded,
                        size: 8,
                        color: AppColors.primary,
                      ),
                    ),
                    Container(
                      width: 14,
                      height: 1.5,
                      color: AppColors.primary.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Konongo, Ashanti Region',
                      style: AppTypography.caption(context).copyWith(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons (Bell + Profile in circular soft cards)
          _buildCircularButton(
            icon: Icons.notifications_none_rounded,
            hasBadge: notificationCount > 0,
            onTap: onNotificationTap,
          ),
          const SizedBox(width: 8),
          _buildCircularButton(
            icon: Icons.person_outline_rounded,
            hasBadge: false,
            onTap: onProfileTap,
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required bool hasBadge,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              boxShadow: AppShadows.soft,
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Center(
              child: Icon(
                icon,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          if (hasBadge)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
