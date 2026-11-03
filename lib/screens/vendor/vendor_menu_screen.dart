import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../state/vendor_state.dart';
import '../../models/food_models.dart';
import '../../widgets/bouncy_tap.dart';

/// Dedicated Vendor Meals & Menu Management Screen
/// Allows vendor to edit selected meals, adjust base prices, customize addons & addon prices,
/// switch images, toggle meal availability, and add new dishes from the curated gallery.
class VendorMenuScreen extends StatefulWidget {
  const VendorMenuScreen({super.key});

  @override
  State<VendorMenuScreen> createState() => _VendorMenuScreenState();
}

class _VendorMenuScreenState extends State<VendorMenuScreen> {
  String _selectedCategoryFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: VendorState(),
      builder: (context, _) {
        final vendor = VendorState();
        final dishes = vendor.vendorDishes;

        final categories = <String>{'All'};
        for (final d in dishes) {
          if (d.categoryId.isNotEmpty) {
            categories.add(d.categoryId.toUpperCase());
          }
        }

        final filteredDishes = _selectedCategoryFilter == 'All'
            ? dishes
            : dishes
                .where((d) =>
                    d.categoryId.toUpperCase() == _selectedCategoryFilter)
                .toList();

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Meals & Pricing',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${dishes.length} items configured on your Konongo menu',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        BouncyTap(
                          onTap: () => _openAddDishSheet(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_rounded,
                                    size: 16, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'Add Meal',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Category Filter Pills
                    if (categories.length > 2)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: categories.map((cat) {
                            final isSelected = _selectedCategoryFilter == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: BouncyTap(
                                onTap: () => setState(
                                    () => _selectedCategoryFilter = cat),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 6),
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
                                    ),
                                  ),
                                  child: Text(
                                    cat,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                      fontWeight: isSelected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Dishes List
            if (filteredDishes.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.restaurant_menu_rounded,
                            size: 48, color: AppColors.textTertiary),
                        const SizedBox(height: 12),
                        const Text(
                          'No meals found in this category',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Tap "+ Add Meal" to pick curated dishes from our gallery.',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final dish = filteredDishes[index];
                      return _buildDishManagementCard(context, dish, vendor);
                    },
                    childCount: filteredDishes.length,
                  ),
                ),
              ),

            // Bottom space for floating vendor dock
            SliverToBoxAdapter(
              child:
                  SizedBox(height: 96 + MediaQuery.paddingOf(context).bottom),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDishManagementCard(
      BuildContext context, FoodItem dish, VendorState vendor) {
    final addonsCount = dish.availableAddons.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.card,
        border: Border.all(
          color: dish.isAvailable
              ? AppColors.border
              : AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dish Header & Image Preview
          Stack(
            children: [
              Image.asset(
                dish.imageAsset,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 140,
                  color: AppColors.surfaceElevated,
                  child: const Center(
                    child: Icon(Icons.fastfood_rounded,
                        size: 36, color: AppColors.primary),
                  ),
                ),
              ),
              // Gradient Overlay
              Container(
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
              // Availability Switch Badge
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: dish.isAvailable
                        ? AppColors.success
                        : AppColors.textSecondary,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Text(
                    dish.isAvailable ? 'IN STOCK' : 'SOLD OUT',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              // Category tag
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Text(
                    dish.categoryId.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              // Dish Title over image
              Positioned(
                bottom: 10,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dish.name,
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (dish.description.isNotEmpty)
                      Text(
                        dish.description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),

          // Price Adjuster & Controls Bar
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price Stepper
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selling Price',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            // Quick Decrement
                            BouncyTap(
                              onTap: () {
                                if (dish.price > 5) {
                                  vendor.updateDishPrice(
                                      dish.id, dish.price - 5);
                                }
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceElevated,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: const Center(
                                  child: Icon(Icons.remove_rounded,
                                      size: 15, color: AppColors.primary),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'GH₵${dish.price.toStringAsFixed(2)}',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Quick Increment
                            BouncyTap(
                              onTap: () {
                                vendor.updateDishPrice(dish.id, dish.price + 5);
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceElevated,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: const Center(
                                  child: Icon(Icons.add_rounded,
                                      size: 15, color: AppColors.primary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Stock Toggle
                    Row(
                      children: [
                        Text(
                          dish.isAvailable ? 'Available' : 'Paused',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: dish.isAvailable
                                ? AppColors.success
                                : AppColors.textTertiary,
                          ),
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: dish.isAvailable,
                            activeTrackColor: AppColors.primary,
                            onChanged: (_) {
                              vendor.toggleDishAvailability(dish.id);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // Addons Summary & Edit Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.add_circle_outline_rounded,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          addonsCount > 0
                              ? '$addonsCount Add-on${addonsCount > 1 ? 's' : ''} configured'
                              : 'Standard Add-ons active',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    BouncyTap(
                      onTap: () => _openEditDishSheet(context, dish, vendor),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primarySubtle,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.tune_rounded,
                                size: 14, color: AppColors.primary),
                            SizedBox(width: 4),
                            Text(
                              'Edit & Add-ons',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
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
    );
  }

  void _openEditDishSheet(
      BuildContext context, FoodItem dish, VendorState vendor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditDishModal(dish: dish, vendor: vendor),
    );
  }

  void _openAddDishSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _AddDishFromGalleryModal(),
    );
  }
}

/// Modal for editing meal price, custom addons, addon pricing, and image
class _EditDishModal extends StatefulWidget {
  final FoodItem dish;
  final VendorState vendor;

  const _EditDishModal({required this.dish, required this.vendor});

  @override
  State<_EditDishModal> createState() => _EditDishModalState();
}

class _EditDishModalState extends State<_EditDishModal> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late double _price;
  late String _imageAsset;
  late List<DishAddon> _dishAddons;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.dish.name);
    _descController = TextEditingController(text: widget.dish.description);
    _price = widget.dish.price;
    _imageAsset = widget.dish.imageAsset;

    // Use current availableAddons or initialize from standardGhanaianAddons
    if (widget.dish.availableAddons.isNotEmpty) {
      _dishAddons = List.from(widget.dish.availableAddons);
    } else {
      _dishAddons = standardGhanaianAddons.take(6).toList();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final updated = widget.dish.copyWith(
      name: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : widget.dish.name,
      description: _descController.text.trim(),
      price: _price,
      imageAsset: _imageAsset,
      availableAddons: _dishAddons,
    );

    widget.vendor.updateDish(updated);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${updated.name} updated successfully!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableAddonPool = standardGhanaianAddons;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Meal & Pricing',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dish Name Field
                  const Text('Dish Title',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Base Price Stepper
                  const Text('Base Price (GH₵)',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'GH₵${_price.toStringAsFixed(2)}',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                        Row(
                          children: [
                            BouncyTap(
                              onTap: () {
                                if (_price > 5) {
                                  setState(() => _price -= 5);
                                }
                              },
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: const BoxDecoration(
                                  color: AppColors.surface,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(Icons.remove_rounded,
                                      size: 18, color: AppColors.primary),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            BouncyTap(
                              onTap: () => setState(() => _price += 5),
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(Icons.add_rounded,
                                      size: 18, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Image Selection
                  const Text('Food Photo',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        'assets/images/jollof_rice.png',
                        'assets/images/fufu_soup.png',
                        'assets/images/grilled_tilapia.png',
                        'assets/images/waakye.png',
                        'assets/images/red_red.png',
                        'assets/images/ampesi_kontommire.png',
                        'assets/images/assorted fried_rice.png',
                        'assets/images/assorted_jollof.png',
                        'assets/images/kokonte_soup.png',
                        'assets/images/shawarma.png',
                        'assets/images/tuo_zaafi.png',
                        'assets/images/waakye_2.png',
                      ].map((asset) {
                        final isSelected = _imageAsset == asset;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: InkWell(
                            onTap: () => setState(() => _imageAsset = asset),
                            child: Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: isSelected ? 2.5 : 1,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                children: [
                                  Image.asset(asset,
                                      fit: BoxFit.cover,
                                      width: 68,
                                      height: 68),
                                  if (isSelected)
                                    Container(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.3),
                                      child: const Center(
                                        child: Icon(Icons.check_circle_rounded,
                                            color: Colors.white, size: 20),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Addons Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Available Add-ons & Custom Pricing',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 13.5),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primarySubtle,
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: Text(
                          '${_dishAddons.length} active',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 10.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Select which add-ons appear when customers customize this dish, and adjust the price for each add-on.',
                    style:
                        TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),

                  // Addons List with inline price adjusters
                  ...availableAddonPool.map((poolAddon) {
                    final selectedIndex = _dishAddons
                        .indexWhere((a) => a.id == poolAddon.id);
                    final isSelected = selectedIndex != -1;
                    final currentAddon =
                        isSelected ? _dishAddons[selectedIndex] : poolAddon;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primarySubtle.withValues(alpha: 0.3)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isSelected,
                            activeColor: AppColors.primary,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _dishAddons.add(poolAddon);
                                } else {
                                  _dishAddons.removeWhere(
                                      (a) => a.id == poolAddon.id);
                                }
                              });
                            },
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  poolAddon.name,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    fontSize: 12.5,
                                  ),
                                ),
                                Text(
                                  poolAddon.category.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    color: AppColors.textTertiary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                BouncyTap(
                                  onTap: () {
                                    if (currentAddon.price > 1) {
                                      setState(() {
                                        _dishAddons[selectedIndex] =
                                            currentAddon.copyWith(
                                                price: currentAddon.price - 1);
                                      });
                                    }
                                  },
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      shape: BoxShape.circle,
                                      border:
                                          Border.all(color: AppColors.border),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.remove_rounded,
                                          size: 13, color: AppColors.primary),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6),
                                  child: Text(
                                    'GH₵${currentAddon.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primary,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                                BouncyTap(
                                  onTap: () {
                                    setState(() {
                                      _dishAddons[selectedIndex] =
                                          currentAddon.copyWith(
                                              price: currentAddon.price + 1);
                                    });
                                  },
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.add_rounded,
                                          size: 13, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            Text(
                              '+GH₵${poolAddon.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Save Changes Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save Meal Changes',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Modal for adding a new dish from the curated gallery
class _AddDishFromGalleryModal extends StatefulWidget {
  const _AddDishFromGalleryModal();

  @override
  State<_AddDishFromGalleryModal> createState() =>
      _AddDishFromGalleryModalState();
}

class _AddDishFromGalleryModalState extends State<_AddDishFromGalleryModal> {
  final Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    final vendor = VendorState();
    final gallery = vendor.curatedGallery;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add from Curated Gallery',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: gallery.length,
              itemBuilder: (context, index) {
                final item = gallery[index];
                final isSelected = _selectedIds.contains(item.id);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primarySubtle.withValues(alpha: 0.3)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedIds.remove(item.id);
                        } else {
                          _selectedIds.add(item.id);
                        }
                      });
                    },
                    child: Row(
                      children: [
                        Image.asset(
                          item.imageAsset,
                          width: 80,
                          height: 72,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w700,
                                  fontSize: 13,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.category,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'GH₵${item.defaultPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: Icon(
                            isSelected
                                ? Icons.check_circle_rounded
                                : Icons.add_circle_outline_rounded,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textTertiary,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _selectedIds.isEmpty
                    ? null
                    : () {
                        for (final id in _selectedIds) {
                          final g = gallery.firstWhere((x) => x.id == id);
                          vendor.updateDish(
                            FoodItem(
                              id: 'dish-${g.id}-${DateTime.now().millisecondsSinceEpoch}',
                              name: g.title,
                              description: g.description,
                              price: g.defaultPrice,
                              imageAsset: g.imageAsset,
                              categoryId: g.category
                                  .toLowerCase()
                                  .replaceAll(' ', '_'),
                              availableAddons: standardGhanaianAddons.take(5).toList(),
                              isAvailable: true,
                            ),
                          );
                        }
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Added ${_selectedIds.length} meal(s) to your menu!'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
                child: Text(
                  _selectedIds.isEmpty
                      ? 'Select Dishes to Add'
                      : 'Add ${_selectedIds.length} Selected Meal(s)',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
