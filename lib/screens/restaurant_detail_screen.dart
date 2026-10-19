import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/food_models.dart';
import '../data/sample_data.dart';
import '../state/cart_state.dart';
import '../state/vendor_state.dart';
import '../theme/app_theme.dart';
import '../widgets/bouncy_tap.dart';
import '../widgets/food_detail_sheet.dart';
import 'cart_screen.dart';

/// Full-page dedicated screen for a specific restaurant/eatery
/// Shows the eatery's chosen hero banner, credentials, ratings, operating stats,
/// and full interactive menu items underneath.
class RestaurantDetailScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurant,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  final CartState _cart = CartState();
  bool _isFavorite = false;
  String _selectedMenuTab = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cart.addListener(_onCartUpdated);
  }

  @override
  void dispose() {
    _cart.removeListener(_onCartUpdated);
    _searchController.dispose();
    super.dispose();
  }

  void _onCartUpdated() {
    if (mounted) setState(() {});
  }

  List<FoodItem> _getRestaurantDishes() {
    // Check if this restaurant matches vendor kitchen dishes
    final vendor = VendorState();
    List<FoodItem> dishes;

    if (widget.restaurant.id == vendor.profile.id ||
        widget.restaurant.name == vendor.profile.restaurantName) {
      dishes = List.from(vendor.vendorDishes);
    } else {
      // Look for featured dishes first, then include the rest of the sample dishes
      final featured = sampleFoodItems
          .where((item) => widget.restaurant.featuredDishIds.contains(item.id))
          .toList();
      final others = sampleFoodItems
          .where((item) => !widget.restaurant.featuredDishIds.contains(item.id))
          .toList();
      dishes = [...featured, ...others];
    }

    // Apply search filter
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      dishes = dishes.where((d) =>
          d.name.toLowerCase().contains(q) ||
          d.description.toLowerCase().contains(q)).toList();
    }

    // Apply category filter tab
    if (_selectedMenuTab == 'featured') {
      dishes = dishes.where((d) =>
          widget.restaurant.featuredDishIds.contains(d.id) ||
          (d.badgeText != null && d.badgeText!.isNotEmpty)).toList();
    } else if (_selectedMenuTab == 'jollof') {
      dishes = dishes.where((d) =>
          d.categoryId == 'jollof' ||
          d.name.toLowerCase().contains('jollof') ||
          d.name.toLowerCase().contains('waakye')).toList();
    } else if (_selectedMenuTab == 'soups') {
      dishes = dishes.where((d) =>
          d.categoryId == 'soups' ||
          d.name.toLowerCase().contains('fufu') ||
          d.name.toLowerCase().contains('soup') ||
          d.name.toLowerCase().contains('stew')).toList();
    } else if (_selectedMenuTab == 'grills') {
      dishes = dishes.where((d) =>
          d.categoryId == 'grills' ||
          d.name.toLowerCase().contains('tilapia') ||
          d.name.toLowerCase().contains('shawarma') ||
          d.name.toLowerCase().contains('khebab')).toList();
    }

    return dishes;
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = widget.restaurant;
    final dishes = _getRestaurantDishes();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Hero Image Banner with custom Navigation & Badges
              _buildSliverBanner(restaurant),

              // 2. Restaurant Identity & Info Header
              SliverToBoxAdapter(
                child: _buildRestaurantHeader(restaurant),
              ),

              // 3. Quick Stats Cards (ETA, Fee, Hygiene)
              SliverToBoxAdapter(
                child: _buildQuickStats(restaurant),
              ),

              // 4. Menu Section Header & Filter Tabs
              SliverToBoxAdapter(
                child: _buildMenuFilterSection(restaurant),
              ),

              // 5. Dish Items List Under the Restaurant
              if (dishes.isEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Icon(Icons.restaurant_menu_rounded,
                            size: 48, color: AppColors.textTertiary),
                        const SizedBox(height: 12),
                        Text(
                          'No dishes found matching "$_searchQuery"',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base,
                    vertical: 8,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final dish = dishes[index];
                        return _buildDishCard(dish, restaurant);
                      },
                      childCount: dishes.length,
                    ),
                  ),
                ),

              // Bottom buffer so sticky cart doesn't cover content
              SliverToBoxAdapter(
                child: SizedBox(
                  height: (_cart.items.isNotEmpty ? 90 : 32) +
                      MediaQuery.paddingOf(context).bottom,
                ),
              ),
            ],
          ),

          // Sticky Bottom Mini Cart Bar when user has items
          if (_cart.items.isNotEmpty)
            Positioned(
              left: AppSpacing.base,
              right: AppSpacing.base,
              bottom: MediaQuery.paddingOf(context).bottom + 14,
              child: _buildStickyCartBar(),
            ),
        ],
      ),
    );
  }

  Widget _buildSliverBanner(Restaurant restaurant) {
    return SliverAppBar(
      expandedHeight: 240.0,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.surface,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BouncyTap(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: BouncyTap(
            onTap: () {
              setState(() => _isFavorite = !_isFavorite);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isFavorite
                      ? 'Saved ${restaurant.name} to favorites'
                      : 'Removed from favorites'),
                  duration: const Duration(milliseconds: 1400),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Icon(
                _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: _isFavorite ? AppColors.accent : Colors.white,
                size: 19,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Selected Hero Banner Image
            Image.asset(
              restaurant.imageAsset,
              fit: BoxFit.cover,
            ),

            // Top gradient for status bar contrast
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Bottom gradient for text readability
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ),

            // Banner badges
            Positioned(
              left: AppSpacing.base,
              bottom: 14,
              child: Row(
                children: [
                  if (restaurant.badgeText.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        restaurant.badgeText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: restaurant.isOpen
                          ? AppColors.success.withValues(alpha: 0.9)
                          : AppColors.error.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          restaurant.isOpen ? 'Open Now' : 'Closed',
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantHeader(Restaurant restaurant) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Restaurant Name
          Text(
            restaurant.name,
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),

          // Cuisine subtitle
          Text(
            restaurant.cuisine,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),

          // Rating, review count & location address
          Row(
            children: [
              const Icon(Icons.star_rounded, color: AppColors.accent, size: 18),
              const SizedBox(width: 4),
              Text(
                '${restaurant.rating}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                '(${restaurant.reviewCount}+ reviews)',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 3,
                height: 3,
                decoration: const BoxDecoration(
                  color: AppColors.textTertiary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 15),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  restaurant.address,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(Restaurant restaurant) {
    return Container(
      margin: const EdgeInsets.only(top: 1),
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.timer_outlined,
              label: 'Delivery ETA',
              value: restaurant.deliveryTime,
            ),
          ),
          Container(width: 1, height: 32, color: AppColors.border),
          Expanded(
            child: _buildStatItem(
              icon: Icons.two_wheeler_rounded,
              label: 'Courier Fee',
              value: 'GH₵${restaurant.deliveryFee.toStringAsFixed(2)}',
            ),
          ),
          Container(width: 1, height: 32, color: AppColors.border),
          Expanded(
            child: _buildStatItem(
              icon: Icons.place_outlined,
              label: 'Distance',
              value: '${restaurant.distanceKm} km',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuFilterSection(Restaurant restaurant) {
    final tabs = [
      {'id': 'all', 'label': 'Full Menu'},
      {'id': 'featured', 'label': "House Specials"},
      {'id': 'jollof', 'label': 'Jollof & Waakye'},
      {'id': 'soups', 'label': 'Soups & Stews'},
      {'id': 'grills', 'label': 'Grills & Shawarma'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.base, 18, AppSpacing.base, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Menu & Dishes',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Prepared Fresh',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Search Field
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search dishes at ${restaurant.name}...',
                hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textTertiary),
                prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.primary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Horizontal Filter Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: tabs.map((tab) {
                final isSelected = _selectedMenuTab == tab['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: BouncyTap(
                    onTap: () => setState(() => _selectedMenuTab = tab['id']!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                        boxShadow: isSelected ? AppShadows.buttonElevated : AppShadows.soft,
                      ),
                      child: Text(
                        tab['label']!,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 12,
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
    );
  }

  void _openDishCustomization(FoodItem dish) {
    FoodDetailSheet.show(
      context,
      dish,
      onAdded: (_) {
        if (mounted) setState(() {});
      },
    );
  }

  Widget _buildDishCard(FoodItem dish, Restaurant restaurant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openDishCustomization(dish),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dish Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppRadius.xl)),
              child: Stack(
                children: [
                  Image.asset(
                    dish.imageAsset,
                    width: 105,
                    height: 105,
                    fit: BoxFit.cover,
                  ),
                  if (dish.badgeText != null && dish.badgeText!.isNotEmpty)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: Text(
                          dish.badgeText!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Dish Content & Pricing
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dish.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      dish.description,
                      style: AppTypography.caption(context).copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'GH₵${dish.price.toStringAsFixed(2)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: AppColors.primary,
                          ),
                        ),
                        BouncyTap(
                          onTap: () => _openDishCustomization(dish),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(AppRadius.full),
                              boxShadow: AppShadows.buttonElevated,
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_rounded, size: 14, color: Colors.white),
                                SizedBox(width: 3),
                                Text(
                                  'Addons',
                                  style: TextStyle(
                                    color: Colors.white,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyCartBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(AppRadius.full),
        boxShadow: AppShadows.floatingNav,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              '${_cart.totalItemCount} items',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 11.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Order Subtotal',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'GH₵${_cart.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          BouncyTap(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CartScreen(
                    onBrowseMenu: () => Navigator.pop(context),
                    onOrderPlaced: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View Cart',
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: AppColors.primaryDark,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
