import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/food_models.dart';
import 'bouncy_tap.dart';

/// Category selector matching the Tortilla app reference design.
/// Features the user-provided icons (`rice_dish_icon.png`, `pizza_icon.png`, `plate_icon.png`).
/// Enhanced with `BouncyTap` tactile responses and `BouncingScrollPhysics()`.
class CategorySelector extends StatelessWidget {
  final List<FoodCategory> categories;
  final Function(int) onCategoryTap;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.isSelected;

          return BouncyTap(
            onTap: () => onCategoryTap(index),
            scaleDown: 0.94,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: isSelected ? AppShadows.soft : null,
                border: isSelected
                    ? Border.all(color: AppColors.border, width: 1)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Food Icon
                  SizedBox(
                    width: 38,
                    height: 38,
                    child: Center(
                      child: _buildCategoryIcon(category, isSelected),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Category Label
                  Text(
                    category.name,
                    style: AppTypography.caption(context).copyWith(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryIcon(FoodCategory category, bool isSelected) {
    if (category.iconAsset != null) {
      return Image.asset(
        category.iconAsset!,
        width: 32,
        height: 32,
        fit: BoxFit.contain,
      );
    }

    // Fallbacks
    IconData iconData = Icons.local_dining_rounded;
    if (category.id == 'drinks') iconData = Icons.local_cafe_rounded;
    if (category.id == 'soups') iconData = Icons.soup_kitchen_rounded;

    return Icon(
      iconData,
      color: isSelected ? AppColors.primary : AppColors.textSecondary,
      size: 24,
    );
  }
}
