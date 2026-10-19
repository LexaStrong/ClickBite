import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/location_service.dart';
import 'bouncy_tap.dart';

/// Delivery address bar matching the Tortilla app reference design.
/// Enhanced with live GPS status indicator, tactile BouncyTap interactions,
/// and live location detection.
class DeliveryAddressBar extends StatelessWidget {
  final String currentAddress;
  final VoidCallback? onAddressTap;
  final VoidCallback? onSearchTap;

  const DeliveryAddressBar({
    super.key,
    this.currentAddress = 'Post Office Rd, Konongo',
    this.onAddressTap,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    final locationService = LocationService();
    final loc = locationService.currentLocation;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: AppShadows.soft,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          // Terracotta Location Pin with Pulse
          BouncyTap(
            onTap: onAddressTap,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primarySubtle,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.location_on_rounded,
                  color: AppColors.primary,
                  size: 19,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Address Label & Dropdown
          Expanded(
            child: BouncyTap(
              onTap: onAddressTap,
              scaleDown: 0.98,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'Deliver to',
                        style: AppTypography.caption(context).copyWith(
                          fontSize: 10,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${loc.distanceKm} km',
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          currentAddress,
                          style: AppTypography.cardTitle(context).copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textPrimary,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Search Icon Button with Bouncy Tap
          BouncyTap(
            onTap: onSearchTap,
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: AppColors.surfaceElevated,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_rounded,
                color: AppColors.textPrimary,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
