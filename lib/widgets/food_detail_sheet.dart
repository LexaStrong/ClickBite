import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/food_models.dart';
import '../state/cart_state.dart';
import '../theme/app_theme.dart';
import 'bouncy_tap.dart';

/// Modal bottom sheet for customizing a food item with Ghanaian addons,
/// spice level, special cooking notes, and quantity before adding to cart.
class FoodDetailSheet extends StatefulWidget {
  final FoodItem item;
  final Function(CartItem)? onAdded;

  const FoodDetailSheet({
    super.key,
    required this.item,
    this.onAdded,
  });

  /// Static helper to open the FoodDetailSheet anywhere
  static Future<void> show(BuildContext context, FoodItem item, {Function(CartItem)? onAdded}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => FoodDetailSheet(item: item, onAdded: onAdded),
    );
  }

  @override
  State<FoodDetailSheet> createState() => _FoodDetailSheetState();
}

class _FoodDetailSheetState extends State<FoodDetailSheet> {
  final CartState _cart = CartState();
  final TextEditingController _notesController = TextEditingController();

  int _quantity = 1;
  String _selectedSpice = 'Regular Pepper';
  final Set<DishAddon> _selectedAddons = {};

  final List<String> _spiceOptions = const [
    'Mild Shito',
    'Regular Pepper',
    'Extra Hot Green Sauce',
    'No Pepper',
  ];

  String _selectedAddonCategory = 'all';

  List<DishAddon> get _filteredAddons {
    if (_selectedAddonCategory == 'all') return standardGhanaianAddons;
    if (_selectedAddonCategory == 'protein') {
      return standardGhanaianAddons
          .where((a) => a.category == 'protein' || a.category == 'side' || a.category == 'sauce')
          .toList();
    }
    if (_selectedAddonCategory == 'snack') {
      return standardGhanaianAddons.where((a) => a.category == 'snack').toList();
    }
    if (_selectedAddonCategory == 'drink') {
      return standardGhanaianAddons.where((a) => a.category == 'drink').toList();
    }
    return standardGhanaianAddons;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double get _addonsTotal =>
      _selectedAddons.fold(0.0, (sum, addon) => sum + addon.price);

  double get _unitPrice => widget.item.price + _addonsTotal;

  double get _totalPrice => _unitPrice * _quantity;

  void _toggleAddon(DishAddon addon) {
    setState(() {
      if (_selectedAddons.contains(addon)) {
        _selectedAddons.remove(addon);
      } else {
        _selectedAddons.add(addon);
      }
    });
  }

  void _submitAddToCart() {
    final cartItem = CartItem(
      foodItem: widget.item,
      quantity: _quantity,
      selectedAddons: _selectedAddons.toList(),
      spiceLevel: _selectedSpice,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    _cart.addItem(
      widget.item,
      quantity: _quantity,
      selectedAddons: _selectedAddons.toList(),
      spiceLevel: _selectedSpice,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    Navigator.pop(context);

    if (widget.onAdded != null) {
      widget.onAdded!(cartItem);
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$_quantity x ${widget.item.name} added to cart',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            Text(
              'GH₵${_totalPrice.toStringAsFixed(2)}',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        duration: const Duration(milliseconds: 2200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxSheetHeight = MediaQuery.of(context).size.height * 0.90;

    return Container(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Image Header with Gradient & Close Button
                  Stack(
                    children: [
                      Image.asset(
                        widget.item.imageAsset,
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        height: 220,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.35),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.45),
                            ],
                          ),
                        ),
                      ),
                      // Close button
                      Positioned(
                        top: 14,
                        right: 14,
                        child: BouncyTap(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      // Badge
                      if (widget.item.badgeText != null &&
                          widget.item.badgeText!.isNotEmpty)
                        Positioned(
                          top: 14,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(AppRadius.xs),
                            ),
                            child: Text(
                              widget.item.badgeText!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Dish Details Section
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Base Price
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.item.name,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'GH₵${widget.item.price.toStringAsFixed(2)}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Ratings & Preparation Time
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: AppColors.accent, size: 17),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.item.rating}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.access_time_rounded,
                                color: AppColors.textTertiary, size: 15),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.item.prepTimeMinutes} mins prep',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Description
                        Text(
                          widget.item.description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 20),
                        const Divider(height: 1),
                        const SizedBox(height: 16),

                        // Spice Preference Selector
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pepper & Spice Preference',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primarySubtle,
                                borderRadius: BorderRadius.circular(AppRadius.xs),
                              ),
                              child: const Text(
                                'REQUIRED',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _spiceOptions.map((spice) {
                            final isSelected = _selectedSpice == spice;
                            return BouncyTap(
                              onTap: () => setState(() => _selectedSpice = spice),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.surface,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.full),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: 1.2,
                                  ),
                                  boxShadow: isSelected
                                      ? AppShadows.buttonElevated
                                      : AppShadows.soft,
                                ),
                                child: Text(
                                  spice,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 20),
                        const Divider(height: 1),
                        const SizedBox(height: 16),

                        // Ghanaian Addons & Drinks Selector Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Add Extras, Snacks & Drinks',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(AppRadius.xs),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                '${_selectedAddons.length} SELECTED',
                                style: const TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Filter chips for addon types
                        _buildAddonCategoryChips(),
                        const SizedBox(height: 8),

                        // Filtered Addons List
                        ..._filteredAddons.map((addon) => _buildAddonRow(addon)),

                        const SizedBox(height: 18),
                        const Divider(height: 1),
                        const SizedBox(height: 16),

                        // Cooking Notes Field
                        Text(
                          'Special Instructions for Kitchen',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: AppColors.border),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: TextField(
                            controller: _notesController,
                            maxLines: 2,
                            style: const TextStyle(fontSize: 12.5),
                            decoration: const InputDecoration(
                              hintText:
                                  'e.g. Please pack the shito separately, fry plantain soft...',
                              hintStyle: TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Bar with Stepper & Add to Cart
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              14 + MediaQuery.paddingOf(context).bottom,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
              border: const Border(
                top: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Row(
              children: [
                // Quantity Stepper
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      BouncyTap(
                        scaleDown: 0.85,
                        onTap: () {
                          if (_quantity > 1) {
                            setState(() => _quantity--);
                          }
                        },
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.remove_rounded,
                              size: 16, color: AppColors.textPrimary),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      BouncyTap(
                        scaleDown: 0.85,
                        onTap: () => setState(() => _quantity++),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add_rounded,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 14),

                // Add to Cart Button
                Expanded(
                  child: BouncyTap(
                    onTap: _submitAddToCart,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        boxShadow: AppShadows.buttonElevated,
                      ),
                      child: Center(
                        child: Text(
                          'Add To Cart • GH₵${_totalPrice.toStringAsFixed(2)}',
                          style: AppTypography.button(context).copyWith(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddonCategoryChips() {
    final categories = [
      {'id': 'all', 'label': 'All Extras'},
      {'id': 'protein', 'label': 'Proteins & Sides'},
      {'id': 'snack', 'label': 'Snacks & Pastries'},
      {'id': 'drink', 'label': 'Wines & Drinks'},
    ];

    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final cat = categories[idx];
          final isSelected = _selectedAddonCategory == cat['id'];
          return BouncyTap(
            onTap: () => setState(() => _selectedAddonCategory = cat['id']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Center(
                child: Text(
                  cat['label']!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddonRow(DishAddon addon) {
    final isChecked = _selectedAddons.contains(addon);
    String categoryLabel = 'Side Extra';
    if (addon.category == 'protein') categoryLabel = 'Protein';
    if (addon.category == 'sauce') categoryLabel = 'Sauce / Shito';
    if (addon.category == 'snack') categoryLabel = 'Pastry / Snack';
    if (addon.category == 'drink') categoryLabel = 'Wine / Drink';

    return InkWell(
      onTap: () => _toggleAddon(addon),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isChecked
              ? AppColors.primarySubtle.withValues(alpha: 0.35)
              : AppColors.surfaceElevated.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isChecked
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.border.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isChecked ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isChecked ? AppColors.primary : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: isChecked
                  ? const Icon(
                      Icons.check_rounded,
                      size: 15,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 10),

            // Thumbnail Image if available
            if (addon.imageAsset != null)
              Container(
                width: 42,
                height: 42,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  addon.imageAsset!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.fastfood_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
              ),

            // Title & Category tag
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    addon.name,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isChecked ? FontWeight.w700 : FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    categoryLabel,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            // Addon Price
            Text(
              '+GH₵${addon.price.toStringAsFixed(2)}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: isChecked ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
