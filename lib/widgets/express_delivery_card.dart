import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Express delivery card proudly featuring the user's provided
/// courier rider illustration (`assets/icons/delivery_rider.webp`).
class ExpressDeliveryCard extends StatelessWidget {
  final VoidCallback? onTap;

  const ExpressDeliveryCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          // The User's Courier Illustration
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Image.asset(
              'assets/icons/delivery_rider.webp',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Delivery Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primarySubtle,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        'EXPRESS DISPATCH',
                        style: AppTypography.caption(context).copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Fast Delivery Across Konongo',
                  style: AppTypography.cardTitle(context).copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Hot meals delivered in 20-30 mins.',
                  style: AppTypography.caption(context).copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textTertiary,
            size: 24,
          ),
        ],
      ),
    );
  }
}
