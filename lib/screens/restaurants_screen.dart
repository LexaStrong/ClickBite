import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../data/sample_data.dart';
import '../models/food_models.dart';
import '../widgets/bouncy_tap.dart';
import '../services/firebase_firestore_service.dart';
import 'restaurant_detail_screen.dart';

/// Konongo Restaurants Directory Screen
/// Highlights the most popular and authentic restaurants, chop bars, and eateries in Konongo, Ashanti.
/// Powered by Cloud Firestore real-time streams with seamless offline fallback.
class RestaurantsScreen extends StatefulWidget {
  final Function(FoodItem) onShowDishDetails;

  const RestaurantsScreen({super.key, required this.onShowDishDetails});

  @override
  State<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  final FirebaseFirestoreService _firestoreService =
      FirebaseFirestoreService();
  String _searchQuery = '';
  String _selectedFilter = 'all';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _filters = const [
    {'id': 'all', 'label': 'All Spots'},
    {'id': 'jollof', 'label': 'Jollof & Grills'},
    {'id': 'soups', 'label': 'Soups & Fufu'},
    {'id': 'grills', 'label': 'Tilapia & Fish'},
    {'id': 'fast', 'label': 'Fast ETA (<15m)'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Restaurant> _filterRestaurants(List<Restaurant> source) {
    return source.where((restaurant) {
      final matchesSearch = _searchQuery.isEmpty ||
          restaurant.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          restaurant.cuisine.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          restaurant.address.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      if (_selectedFilter == 'all') return true;
      if (_selectedFilter == 'jollof') {
        return restaurant.cuisine.toLowerCase().contains('jollof') ||
            restaurant.cuisine.toLowerCase().contains('grill');
      }
      if (_selectedFilter == 'soups') {
        return restaurant.cuisine.toLowerCase().contains('soup') ||
            restaurant.cuisine.toLowerCase().contains('fufu') ||
            restaurant.cuisine.toLowerCase().contains('stew');
      }
      if (_selectedFilter == 'grills') {
        return restaurant.cuisine.toLowerCase().contains('tilapia') ||
            restaurant.cuisine.toLowerCase().contains('fish');
      }
      if (_selectedFilter == 'fast') {
        return restaurant.deliveryTime.contains('10-15') ||
            restaurant.deliveryTime.contains('15-20');
      }
      return true;
    }).toList();
  }

  void _openRestaurantDetail(Restaurant restaurant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RestaurantDetailScreen(restaurant: restaurant),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Restaurant>>(
      stream: _firestoreService.streamVendors(),
      initialData: sampleRestaurants,
      builder: (context, snapshot) {
        final allRestaurants = snapshot.data ?? sampleRestaurants;
        final filteredRestaurants = _filterRestaurants(allRestaurants);

        return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        // Screen Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Konongo Restaurants',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Top chop bars, kitchens & local spots delivering in Konongo.',
                  style: AppTypography.caption(context).copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Search Input Bar
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
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  icon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                  hintText: 'Search restaurants, waakye, fufu spots...',
                  hintStyle: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
                  border: InputBorder.none,
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textTertiary),
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

        // Filter Pills
        SliverToBoxAdapter(
          child: SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: BouncyTap(
                    onTap: () => setState(() => _selectedFilter = filter['id']!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: 1,
                        ),
                        boxShadow: isSelected ? AppShadows.buttonElevated : null,
                      ),
                      child: Text(
                        filter['label']!,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Restaurant Count Indicator
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Text(
              '${filteredRestaurants.length} verified spots delivering now',
              style: AppTypography.caption(context).copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 10)),

        // Restaurants List
        filteredRestaurants.isEmpty
            ? SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.storefront_outlined, size: 48, color: AppColors.textTertiary),
                        const SizedBox(height: 12),
                        Text(
                          'No restaurants matching "$_searchQuery"',
                          style: AppTypography.cardTitle(context),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Try searching for "Nana", "Waakye", or "Palace"',
                          style: AppTypography.caption(context),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final restaurant = filteredRestaurants[index];
                      return _buildRestaurantCard(context, restaurant);
                    },
                    childCount: filteredRestaurants.length,
                  ),
                ),
              ),

        // Bottom space so floating nav doesn't cover content
        SliverToBoxAdapter(
          child: SizedBox(height: 96 + MediaQuery.paddingOf(context).bottom),
        ),
      ],
    );
      },
    );
  }

  Widget _buildRestaurantCard(BuildContext context, Restaurant restaurant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openRestaurantDetail(restaurant),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Banner Photo
            Stack(
              children: [
                Image.asset(
                  restaurant.imageAsset,
                  height: 135,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                // Gradient overlay
                Container(
                  height: 135,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.45),
                      ],
                    ),
                  ),
                ),
                // Value badge
                if (restaurant.badgeText.isNotEmpty)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        restaurant.badgeText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                // ETA Pill
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_rounded, color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          restaurant.deliveryTime,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
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
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Rating
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppColors.accent, size: 16),
                          const SizedBox(width: 3),
                          Text(
                            '${restaurant.rating}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12.5,
                            ),
                          ),
                          Text(
                            ' (${restaurant.reviewCount})',
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    restaurant.cuisine,
                    style: AppTypography.caption(context).copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 13, color: AppColors.primary),
                      const SizedBox(width: 3),
                      Text(
                        restaurant.address,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const Spacer(),
                      Text(
                        'GH₵${restaurant.deliveryFee.toStringAsFixed(2)} delivery',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
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
