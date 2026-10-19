import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/food_models.dart';
import 'bouncy_tap.dart';

/// Food item card matching the Tortilla app reference design.
/// Enhanced with tactile `BouncyTap` micro-interactions, clean surfaces,
/// and responsive add-to-cart feedback.
class FoodItemCard extends StatelessWidget {
  final FoodItem item;
  final VoidCallback? onTap;
  final VoidCallback? onAddTap;

  const FoodItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncyTap(
      onTap: onTap,
      scaleDown: 0.97,
      child: Container(
        width: 156,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          boxShadow: AppShadows.card,
          border: Border.all(color: AppColors.border, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Photo with Badge
            Stack(
              children: [
                Container(
                  height: 125,
                  width: double.infinity,
                  color: AppColors.surfaceElevated,
                  child: Image.asset(
                    item.imageAsset,
                    fit: BoxFit.cover,
                  ),
                ),
                // Purposeful value badge (no emojis)
                if (item.badgeText != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        item.badgeText!,
                        style: AppTypography.caption(context).copyWith(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Card Body (Title, Price, Add Button)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item Name
                  SizedBox(
                    height: 34,
                    child: Text(
                      item.name,
                      style: AppTypography.cardTitle(context).copyWith(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Price + Add Button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Price
                      Text(
                        'GH₵${item.price.toStringAsFixed(2)}',
                        style: AppTypography.price(context).copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      // Circular Terracotta Add Button with Bouncy Feedback
                      BouncyTap(
                        onTap: onAddTap,
                        scaleDown: 0.85,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.35),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 19,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
