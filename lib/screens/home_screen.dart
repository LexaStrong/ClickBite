import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../data/sample_data.dart';
import '../models/food_models.dart';
import '../state/cart_state.dart';
import '../services/location_service.dart';
import '../widgets/app_header.dart';
import '../widgets/delivery_address_bar.dart';
import '../widgets/hero_banner.dart';
import '../widgets/category_selector.dart';
import '../widgets/food_item_card.dart';
import '../widgets/express_delivery_card.dart';
import '../widgets/active_order_card.dart';
import '../widgets/section_header.dart';
import '../widgets/floating_bottom_nav.dart';
import '../widgets/bouncy_tap.dart';
import '../widgets/food_detail_sheet.dart';
import 'restaurants_screen.dart';
import 'restaurant_detail_screen.dart';
import 'cart_screen.dart';
// import 'order_tracking_screen.dart'; // Reserved for next version
import 'profile_screen.dart';

/// ClickBites Main App Controller & Shell
/// Clones the visual identity, warmth, and structure of the reference food app
/// tailored specifically for Konongo, Ashanti Region.
/// Houses Home, Menu, Live Tracking (replacing rewards), Profile, and Cart screens.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  int _currentNavIndex =
      0; // 0: Home, 1: Restaurants (Spots), 2: Track, 3: Profile, 4: Cart
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final CartState _cartState = CartState();
  final LocationService _locationService = LocationService();
  late List<FoodCategory> _categories;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _categories = [
      const FoodCategory(
        id: 'all',
        name: 'All Foods',
        iconAsset: 'assets/icons/rice_dish_icon.png',
        isSelected: true,
      ),
      ...sampleCategories.map((c) => c.copyWith(isSelected: false)),
    ];
    _cartState.addListener(_onStateUpdated);
    _locationService.addListener(_onStateUpdated);
  }

  @override
  void dispose() {
    _cartState.removeListener(_onStateUpdated);
    _locationService.removeListener(_onStateUpdated);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onStateUpdated() {
    if (mounted) setState(() {});
  }

  void _onCategoryTap(int index) {
    setState(() {
      _selectedCategoryIndex = index;
      _categories = _categories.asMap().entries.map((entry) {
        return entry.value.copyWith(isSelected: entry.key == index);
      }).toList();
    });
  }

  void _selectCategoryById(String catId) {
    final idx = _categories.indexWhere((c) => c.id == catId);
    if (idx != -1) {
      _onCategoryTap(idx);
    }
  }

  List<FoodItem> get _snackItems =>
      sampleFoodItems.where((item) => item.categoryId == 'snacks').toList();

  List<FoodItem> get _drinkItems =>
      sampleFoodItems.where((item) => item.categoryId == 'drinks').toList();

  List<FoodItem> get _popularDishes {
    if (_searchQuery.isNotEmpty) return _filteredItems;
    return sampleFoodItems
        .where(
          (item) => item.categoryId != 'drinks' && item.categoryId != 'snacks',
        )
        .toList();
  }

  List<FoodItem> get _filteredItems {
    final selectedCat = _categories[_selectedCategoryIndex];
    List<FoodItem> items = sampleFoodItems;
    if (selectedCat.id != 'all') {
      final matched = sampleFoodItems
          .where((item) => item.categoryId == selectedCat.id)
          .toList();
      if (matched.isNotEmpty) items = matched;
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      items = items.where((item) {
        return item.name.toLowerCase().contains(q) ||
            item.description.toLowerCase().contains(q) ||
            item.tags.any((t) => t.toLowerCase().contains(q));
      }).toList();
    }
    return items;
  }

  void _addToCart(FoodItem item) {
    _cartState.addItem(item);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${item.name} added to cart',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            Text(
              'GH₵${item.price.toStringAsFixed(2)}',
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
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAddressPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xxl),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Konongo Delivery Spot',
                    style: AppTypography.sectionTitle(context)
                        .copyWith(fontSize: 16),
                  ),
                  BouncyTap(
                    onTap: () {
                      _locationService.detectCurrentLocation();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'GPS located! Closest Konongo hub selected.',
                          ),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySubtle,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.my_location_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Locate Me',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...LocationService.konongoLandmarks.map((landmark) {
                final isSelected =
                    landmark.name == _locationService.currentLocation.name;
                return Material(
                  type: MaterialType.transparency,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.location_on_rounded,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textTertiary,
                      size: 20,
                    ),
                    title: Text(
                      landmark.name,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontSize: 13.5,
                      ),
                    ),
                    subtitle: Text(
                      '${landmark.distanceKm} km from kitchen • ~${landmark.deliveryMinutes} mins ETA',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                            size: 20,
                          )
                        : null,
                    onTap: () {
                      _locationService.setLocation(landmark);
                      _cartState.setAddress(landmark.name);
                      Navigator.pop(context);
                    },
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showFoodDetails(FoodItem item) {
    FoodDetailSheet.show(
      context,
      item,
      onAdded: (cartItem) {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: _buildAppBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBody() {
    return Stack(
      children: [
        // Tab Content Switcher
        Positioned.fill(
          child: IndexedStack(
            index: _currentNavIndex,
            children: [
              // Tab 0: Home Feed (with full menu integrated)
              _buildHomeFeed(),

              // Tab 1: Restaurants Screen (Most restaurants in Konongo)
              RestaurantsScreen(onShowDishDetails: _showFoodDetails),

              // Tab 2: Live Tracking Screen (Commented out for the next version)
              // const OrderTrackingScreen(),
              const SizedBox.shrink(),

              // Tab 3: Profile Screen
              ProfileScreen(
                onReorder: () {
                  setState(() => _currentNavIndex = 4);
                },
              ),

              // Tab 4: Cart & Checkout Screen
              CartScreen(
                onBrowseMenu: () => setState(() => _currentNavIndex = 0),
                onOrderPlaced: () {
                  // Direct to Profile -> View Older Orders while live tracking is reserved for next version
                  setState(() => _currentNavIndex = 3);
                },
              ),
            ],
          ),
        ),

        // Floating Bottom Navigation Bar (Docked at bottom with elevated center cart button)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: FloatingBottomNav(
            currentIndex: _currentNavIndex,
            cartCount: _cartState.totalItemCount,
            onTabSelected: (index) {
              setState(() => _currentNavIndex = index);
            },
            onCartTap: () {
              setState(() => _currentNavIndex = 4);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHomeFeed() {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 8)),

        // 1. Header with ClickBite Logo, bell and profile
        SliverToBoxAdapter(
          child: AppHeader(
            notificationCount: 2,
            onNotificationTap: () {
              setState(() => _currentNavIndex = 3);
            },
            onProfileTap: () => setState(() => _currentNavIndex = 3),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        // 2. Delivery Address Bar with Live GPS status
        SliverToBoxAdapter(
          child: DeliveryAddressBar(
            currentAddress: _locationService.currentLocation.name,
            onAddressTap: _showAddressPicker,
            onSearchTap: () {},
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        // 3. Quick Dish Search Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                boxShadow: AppShadows.soft,
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  icon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  hintText: 'Search jollof, soups, tilapia, waakye...',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textTertiary,
                  ),
                  border: InputBorder.none,
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear_rounded,
                            size: 18,
                            color: AppColors.textTertiary,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 14)),

        // 4. Hero Banner (4-slide carousel slideshow with auto-play and swipe)
        SliverToBoxAdapter(
          child: HeroBanner(
            onSlideCtaTap: (cat) {
              final catIdx = _categories.indexWhere((c) => c.id == cat);
              if (catIdx != -1) _onCategoryTap(catIdx);
            },
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 18)),

        // 5. Category Selector (Featuring user icons)
        SliverToBoxAdapter(
          child: CategorySelector(
            categories: _categories,
            onCategoryTap: _onCategoryTap,
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        // 6. Popular Picks Section
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'Popular Picks',
            actionText: 'See Spots',
            onActionTap: () => setState(() => _currentNavIndex = 1),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        // Horizontal scrollable Popular Picks food cards
        SliverToBoxAdapter(
          child: SizedBox(
            height: 234,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              itemCount: _popularDishes.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = _popularDishes[index];
                return FoodItemCard(
                  item: item,
                  onTap: () => _showFoodDetails(item),
                  onAddTap: () => _addToCart(item),
                );
              },
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 22)),

        // 6b. Snacks & Fresh Pastries Section
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'Snacks & Fresh Pastries',
            actionText: 'See All',
            onActionTap: () => _selectCategoryById('snacks'),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        // Horizontal scrollable Snacks & Pastries
        SliverToBoxAdapter(
          child: SizedBox(
            height: 234,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              itemCount: _snackItems.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = _snackItems[index];
                return FoodItemCard(
                  item: item,
                  onTap: () => _showFoodDetails(item),
                  onAddTap: () => _addToCart(item),
                );
              },
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 22)),

        // 7. Express Delivery Card (Featuring user's delivery_rider.png)
        SliverToBoxAdapter(
          child: ExpressDeliveryCard(
            onTap: () {
              setState(() => _currentNavIndex = 2);
            },
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        // 7b. Top Eateries & Chop Bars in Konongo
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'Top Eateries in Konongo',
            actionText: 'View All',
            onActionTap: () => setState(() => _currentNavIndex = 1),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        SliverToBoxAdapter(
          child: SizedBox(
            height: 205,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              itemCount: sampleRestaurants.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final rest = sampleRestaurants[index];
                return _buildHomeRestaurantCard(context, rest);
              },
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 22)),

        // 7c. Wines & Chilled Drinks Section
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'Wines & Chilled Drinks',
            actionText: 'See All',
            onActionTap: () => _selectCategoryById('drinks'),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        // Horizontal scrollable Wines & Drinks
        SliverToBoxAdapter(
          child: SizedBox(
            height: 234,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              itemCount: _drinkItems.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = _drinkItems[index];
                return FoodItemCard(
                  item: item,
                  onTap: () => _showFoodDetails(item),
                  onAddTap: () => _addToCart(item),
                );
              },
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        // 8. Full Menu Items List Section directly on Home
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'Konongo Dishes & Specials',
            actionText: '${_filteredItems.length} items',
            onActionTap: () {},
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        // Vertical List of Menu Dishes
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = _filteredItems[index];
              return _buildMenuRowCard(context, item);
            }, childCount: _filteredItems.length),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 18)),

        // 9. Active Order Live GPS Tracking Card
        SliverToBoxAdapter(
          child: ActiveOrderCard(
            onTrackTap: () {
              setState(() => _currentNavIndex = 2);
            },
          ),
        ),

        // Bottom space so items are not obscured by the floating nav bar
        SliverToBoxAdapter(
          child: SizedBox(height: 96 + MediaQuery.paddingOf(context).bottom),
        ),
      ],
    );
  }

  Widget _buildMenuRowCard(BuildContext context, FoodItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.soft,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showFoodDetails(item),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Dish Photo with badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: Image.asset(
                      item.imageAsset,
                      width: 78,
                      height: 78,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (item.badgeText != null)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          item.badgeText!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 7.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // Dish Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppTypography.cardTitle(
                        context,
                      ).copyWith(fontSize: 13.5, fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.description,
                      style: AppTypography.caption(
                        context,
                      ).copyWith(color: AppColors.textSecondary, fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'GH₵${item.price.toStringAsFixed(2)}',
                          style: AppTypography.price(context)
                              .copyWith(color: AppColors.primary, fontSize: 14),
                        ),
                        // Circular Terracotta Add Button
                        Material(
                          color: AppColors.primary,
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: () => _addToCart(item),
                            customBorder: const CircleBorder(),
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
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
      ),
    );
  }

  Widget _buildHomeRestaurantCard(BuildContext context, Restaurant restaurant) {
    return BouncyTap(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RestaurantDetailScreen(restaurant: restaurant),
          ),
        );
      },
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.soft,
          border: Border.all(color: AppColors.border, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner photo with overlay
            Stack(
              children: [
                Image.asset(
                  restaurant.imageAsset,
                  height: 105,
                  width: 220,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 105,
                  width: 220,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.05),
                        Colors.black.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                ),
                if (restaurant.badgeText.isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Text(
                        restaurant.badgeText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 7,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.timer_rounded,
                          color: Colors.white,
                          size: 11,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          restaurant.deliveryTime,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Card Body
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    restaurant.cuisine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.accent,
                        size: 13,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${restaurant.rating}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.location_on_rounded,
                        color: AppColors.textTertiary,
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${restaurant.distanceKm} km',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
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
