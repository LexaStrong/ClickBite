import 'package:flutter/material.dart';
import '../models/food_models.dart';
import '../models/vendor_models.dart';
import '../data/sample_data.dart';

/// Central state manager for the ClickBite Vendor Portal
class VendorState extends ChangeNotifier {
  static final VendorState _instance = VendorState._internal();
  factory VendorState() => _instance;

  VendorState._internal() {
    _initializeData();
  }

  late VendorProfile _profile;
  late List<VendorOrder> _orders;
  late List<VendorPayout> _payouts;
  late List<CuratedFoodGalleryItem> _curatedGallery;
  late List<VendorAddonOption> _availableAddons;
  late List<FoodItem> _vendorDishes;

  VendorProfile get profile => _profile;
  List<VendorOrder> get orders => _orders;
  List<VendorPayout> get payouts => _payouts;
  List<CuratedFoodGalleryItem> get curatedGallery => _curatedGallery;
  List<VendorAddonOption> get availableAddons => _availableAddons;
  List<FoodItem> get vendorDishes => _vendorDishes;

  // Filtered order getters
  List<VendorOrder> get activeOrders => _orders.where((o) =>
      o.status == VendorOrderStatus.pending ||
      o.status == VendorOrderStatus.preparing ||
      o.status == VendorOrderStatus.readyForPickup ||
      o.status == VendorOrderStatus.outForDelivery).toList();

  List<VendorOrder> get pendingOrders => _orders.where((o) => o.status == VendorOrderStatus.pending).toList();
  List<VendorOrder> get preparingOrders => _orders.where((o) => o.status == VendorOrderStatus.preparing).toList();
  List<VendorOrder> get readyOrders => _orders.where((o) => o.status == VendorOrderStatus.readyForPickup).toList();
  List<VendorOrder> get completedOrders => _orders.where((o) => o.status == VendorOrderStatus.completed).toList();

  // Metrics
  double get todaySales => _orders
      .where((o) => o.status != VendorOrderStatus.cancelled)
      .fold(0.0, (sum, o) => sum + o.subtotal);

  double get todayNetEarnings => _orders
      .where((o) => o.status != VendorOrderStatus.cancelled)
      .fold(0.0, (sum, o) => sum + o.netEarnings);

  int get todayOrdersCount => _orders.length;

  void _initializeData() {
    _profile = const VendorProfile(
      id: 'vendor-main',
      restaurantName: "My Restaurant",
      ownerName: 'Vendor Partner',
      phone: '',
      momoNumber: '',
      address: 'Konongo, Ashanti Region',
      cuisineSummary: 'Local Dishes & Refreshments',
      bannerAsset: 'assets/images/jollof_rice.webp',
      isOpen: true,
      rating: 5.0,
      totalOrders: 0,
      balanceAvailable: 0.0,
      pendingSettlement: 0.0,
      totalEarnings: 0.0,
    );

    _vendorDishes = List.from(sampleFoodItems);
    _orders = [];
    _payouts = [];

    // Curated gallery items for onboarding and dish creation
    _curatedGallery = [
      const CuratedFoodGalleryItem(
        id: 'gal-1',
        title: 'Smoky Firewood Jollof',
        category: 'Jollof Bowls',
        imageAsset: 'assets/images/jollof_rice.webp',
        defaultPrice: 45.00,
        description: 'Authentic firewood party jollof with spicy quarter chicken and sweet plantains',
        defaultAddons: ['Extra Kelewele (+GH₵5)', 'Boiled Egg (+GH₵3)', 'Coleslaw (+GH₵4)'],
      ),
      const CuratedFoodGalleryItem(
        id: 'gal-2',
        title: 'Pounded Fufu & Goat Light Soup',
        category: 'Local Soups',
        imageAsset: 'assets/images/fufu_soup.webp',
        defaultPrice: 40.00,
        description: 'Smooth pounded cassava & plantain fufu in aromatic fresh goat light soup',
        defaultAddons: ['Extra Goat Meat (+GH₵12)', 'Smoked Fish (+GH₵8)', 'Boiled Egg (+GH₵3)'],
      ),
      const CuratedFoodGalleryItem(
        id: 'gal-3',
        title: 'Volta Grilled Tilapia & Banku',
        category: 'Grills & Fish',
        imageAsset: 'assets/images/grilled_tilapia.webp',
        defaultPrice: 55.00,
        description: 'Fresh seasoned whole tilapia grilled on hot coals with spicy pepper & Banku',
        defaultAddons: ['Extra Banku Ball (+GH₵4)', 'Hot Green Pepper Sauce (+GH₵3)', 'Fried Eggs (+GH₵4)'],
      ),
      const CuratedFoodGalleryItem(
        id: 'gal-4',
        title: 'Loaded Waakye Royal',
        category: 'Street Specialties',
        imageAsset: 'assets/images/waakye.webp',
        defaultPrice: 35.00,
        description: 'Rich sorghum leaf waakye with dark shito, spaghetti, gari fortor & wele',
        defaultAddons: ['Wele (+GH₵5)', 'Boiled Egg (+GH₵3)', 'Fried Fish (+GH₵10)', 'Avocado (+GH₵4)'],
      ),
      const CuratedFoodGalleryItem(
        id: 'gal-5',
        title: 'Red Red & Ripe Plantains',
        category: 'Comfort Stews',
        imageAsset: 'assets/images/red_red.webp',
        defaultPrice: 30.00,
        description: 'Slow-simmered black-eyed beans in spiced palm oil with sweet fried plantains',
        defaultAddons: ['Fried Fish (+GH₵8)', 'Boiled Egg (+GH₵3)', 'Gari Sprinkle (+GH₵2)'],
      ),
      const CuratedFoodGalleryItem(
        id: 'gal-6',
        title: 'Ampesi & Kontommire Stew',
        category: 'Local Soups',
        imageAsset: 'assets/images/ampesi_kontommire.webp',
        defaultPrice: 35.00,
        description: 'Boiled yam and plantain with rich cocoyam leaf kontommire stew and smoked fish',
        defaultAddons: ['Extra Smoked Fish (+GH₵8)', 'Boiled Egg (+GH₵3)', 'Agushi Paste (+GH₵5)'],
      ),
      const CuratedFoodGalleryItem(
        id: 'gal-7',
        title: 'Assorted Fried Rice Platter',
        category: 'Jollof Bowls',
        imageAsset: 'assets/images/assorted fried_rice.webp',
        defaultPrice: 50.00,
        description: 'Stir-fried seasoned rice with mixed vegetables, chicken, shrimp, and fried egg',
        defaultAddons: ['Extra Shrimp (+GH₵10)', 'Grilled Chicken (+GH₵8)', 'Coleslaw (+GH₵4)'],
      ),
      const CuratedFoodGalleryItem(
        id: 'gal-8',
        title: 'Assorted Jollof Rice',
        category: 'Jollof Bowls',
        imageAsset: 'assets/images/assorted_jollof.webp',
        defaultPrice: 48.00,
        description: 'Party-style smoky jollof rice with assorted meats, fried chicken, and kelewele',
        defaultAddons: ['Extra Kelewele (+GH₵5)', 'Coleslaw (+GH₵4)', 'Fried Plantains (+GH₵4)'],
      ),
      const CuratedFoodGalleryItem(
        id: 'gal-9',
        title: 'Kokonte & Groundnut Soup',
        category: 'Local Soups',
        imageAsset: 'assets/images/kokonte_soup.webp',
        defaultPrice: 38.00,
        description: 'Smooth dried cassava kokonte served with rich groundnut soup and assorted meats',
        defaultAddons: ['Extra Goat Meat (+GH₵12)', 'Cow Skin (+GH₵5)', 'Smoked Fish (+GH₵8)'],
      ),
      const CuratedFoodGalleryItem(
        id: 'gal-10',
        title: 'Grilled Shawarma Wrap',
        category: 'Street Specialties',
        imageAsset: 'assets/images/shawarma.webp',
        defaultPrice: 42.00,
        description: 'Spiced grilled chicken shawarma wrap with fresh vegetables, garlic sauce, and fries',
        defaultAddons: ['Extra Fries (+GH₵5)', 'Cheese (+GH₵4)', 'Chili Sauce (+GH₵2)'],
      ),
      const CuratedFoodGalleryItem(
        id: 'gal-11',
        title: 'Tuo Zaafi & Ayoyo Soup',
        category: 'Local Soups',
        imageAsset: 'assets/images/tuo_zaafi.webp',
        defaultPrice: 36.00,
        description: 'Northern Ghana tuo zaafi with slimy ayoyo soup, dawadawa, and smoked meat',
        defaultAddons: ['Extra Dawadawa (+GH₵3)', 'Smoked Fish (+GH₵8)', 'Guinea Fowl (+GH₵15)'],
      ),
      const CuratedFoodGalleryItem(
        id: 'gal-12',
        title: 'Supreme Waakye Festival',
        category: 'Street Specialties',
        imageAsset: 'assets/images/waakye_2.webp',
        defaultPrice: 40.00,
        description: 'Premium waakye overload with extra wele, gari fortor, spaghetti, fried fish, and stew',
        defaultAddons: ['Wele (+GH₵5)', 'Fried Fish (+GH₵10)', 'Avocado (+GH₵4)', 'Boiled Egg (+GH₵3)'],
      ),
    ];

    _availableAddons = [
      const VendorAddonOption(id: 'add-1', name: 'Extra Kelewele / Plantains', price: 5.00, isDefaultSelected: true),
      const VendorAddonOption(id: 'add-2', name: 'Hard Boiled Egg', price: 3.00, isDefaultSelected: true),
      const VendorAddonOption(id: 'add-3', name: 'Extra Shito Chili Jam', price: 3.00, isDefaultSelected: true),
      const VendorAddonOption(id: 'add-4', name: 'Fried Tilapia / Fish Cut', price: 10.00, isDefaultSelected: true),
      const VendorAddonOption(id: 'add-5', name: 'Extra Goat Meat Chunk', price: 12.00, isDefaultSelected: false),
      const VendorAddonOption(id: 'add-6', name: 'Soft Stewed Wele', price: 5.00, isDefaultSelected: true),
      const VendorAddonOption(id: 'add-7', name: 'Seasoned Gari Fortor', price: 3.00, isDefaultSelected: false),
      const VendorAddonOption(id: 'add-8', name: 'Spaghetti / Macaroni Slaw', price: 4.00, isDefaultSelected: false),
      const VendorAddonOption(id: 'add-9', name: 'Chilled Soft Drinks (Coke / Fanta / Sprite)', price: 8.00, isDefaultSelected: true),
      const VendorAddonOption(id: 'add-10', name: 'Bottled Mineral Water (500ml Chilled)', price: 3.00, isDefaultSelected: true),
    ];
  }

  // Actions
  void toggleStoreOpen() {
    _profile = _profile.copyWith(isOpen: !_profile.isOpen);
    notifyListeners();
  }

  void updateDishPrice(String dishId, double newPrice) {
    final idx = _vendorDishes.indexWhere((d) => d.id == dishId);
    if (idx != -1) {
      _vendorDishes[idx] = _vendorDishes[idx].copyWith(price: newPrice);
      final sampleIdx = sampleFoodItems.indexWhere((d) => d.id == dishId);
      if (sampleIdx != -1) {
        sampleFoodItems[sampleIdx] = sampleFoodItems[sampleIdx].copyWith(price: newPrice);
      }
      notifyListeners();
    }
  }

  void toggleDishAvailability(String dishId) {
    final idx = _vendorDishes.indexWhere((d) => d.id == dishId);
    if (idx != -1) {
      final current = _vendorDishes[idx];
      _vendorDishes[idx] = current.copyWith(isAvailable: !current.isAvailable);
      final sampleIdx = sampleFoodItems.indexWhere((d) => d.id == dishId);
      if (sampleIdx != -1) {
        sampleFoodItems[sampleIdx] = sampleFoodItems[sampleIdx].copyWith(isAvailable: !current.isAvailable);
      }
      notifyListeners();
    }
  }

  void updateDish(FoodItem updatedDish) {
    final idx = _vendorDishes.indexWhere((d) => d.id == updatedDish.id);
    if (idx != -1) {
      _vendorDishes[idx] = updatedDish;
    } else {
      _vendorDishes.add(updatedDish);
    }
    final sampleIdx = sampleFoodItems.indexWhere((d) => d.id == updatedDish.id);
    if (sampleIdx != -1) {
      sampleFoodItems[sampleIdx] = updatedDish;
    } else {
      sampleFoodItems.insert(0, updatedDish);
    }
    notifyListeners();
  }

  void removeDish(String dishId) {
    _vendorDishes.removeWhere((d) => d.id == dishId);
    sampleFoodItems.removeWhere((d) => d.id == dishId);
    notifyListeners();
  }

  void onboardNewKitchen({
    required String restaurantName,
    required String ownerName,
    required String phone,
    required String momoNumber,
    required String address,
    required String cuisineSummary,
    String? bannerAsset,
    List<CuratedFoodGalleryItem>? selectedDishes,
    List<CustomizedVendorDish>? customizedDishes,
    required List<VendorAddonOption> selectedAddons,
  }) {
    final chosenBanner = (bannerAsset != null && bannerAsset.isNotEmpty)
        ? bannerAsset
        : (customizedDishes != null && customizedDishes.isNotEmpty
            ? customizedDishes.first.imageAsset
            : (selectedDishes != null && selectedDishes.isNotEmpty
                ? selectedDishes.first.imageAsset
                : 'assets/images/jollof_rice.webp'));

    _profile = VendorProfile(
      id: 'vendor-${DateTime.now().millisecondsSinceEpoch}',
      restaurantName: restaurantName,
      ownerName: ownerName,
      phone: phone,
      momoNumber: momoNumber,
      address: address,
      cuisineSummary: cuisineSummary,
      bannerAsset: chosenBanner,
      isOpen: true,
      rating: 5.0,
      totalOrders: 0,
      balanceAvailable: 0.0,
      pendingSettlement: 0.0,
      totalEarnings: 0.0,
    );

    // Populate vendor dishes from customized dishes or gallery selections
    if (customizedDishes != null && customizedDishes.isNotEmpty) {
      _vendorDishes = customizedDishes.map((c) => c.toFoodItem()).toList();
    } else if (selectedDishes != null && selectedDishes.isNotEmpty) {
      _vendorDishes = selectedDishes.map((g) {
        return FoodItem(
          id: 'custom-${g.id}',
          name: g.title,
          description: g.description,
          price: g.defaultPrice,
          imageAsset: g.imageAsset,
          categoryId: 'jollof',
          rating: 5.0,
          prepTimeMinutes: 20,
          badgeText: 'KITCHEN FRESH',
        );
      }).toList();
    }

    // Register into the active sampleRestaurants directory
    final newRest = Restaurant(
      id: _profile.id,
      name: restaurantName,
      cuisine: cuisineSummary.isNotEmpty ? cuisineSummary : 'Authentic Konongo Delicacies',
      address: address,
      rating: 5.0,
      reviewCount: 1,
      deliveryTime: '15-25 min',
      deliveryFee: 5.00,
      imageAsset: chosenBanner,
      badgeText: 'NEW KITCHEN',
      isOpen: true,
      distanceKm: '0.5',
      featuredDishIds: _vendorDishes.map((d) => d.id).toList(),
    );

    sampleRestaurants.removeWhere((r) => r.id == _profile.id || r.name == restaurantName);
    sampleRestaurants.insert(0, newRest);

    // Prepend newly customized dishes to sampleFoodItems
    for (final dish in _vendorDishes) {
      sampleFoodItems.removeWhere((f) => f.id == dish.id);
      sampleFoodItems.insert(0, dish);
    }

    notifyListeners();
  }

  void acceptOrder(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      _orders[idx] = _orders[idx].copyWith(status: VendorOrderStatus.preparing);
      notifyListeners();
    }
  }

  void markReadyForDispatch(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      _orders[idx] = _orders[idx].copyWith(status: VendorOrderStatus.readyForPickup);
      notifyListeners();
    }
  }

  void completeOrder(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      final order = _orders[idx];
      _orders[idx] = order.copyWith(status: VendorOrderStatus.completed);
      _profile = _profile.copyWith(
        balanceAvailable: _profile.balanceAvailable + order.netEarnings,
        totalEarnings: _profile.totalEarnings + order.netEarnings,
        totalOrders: _profile.totalOrders + 1,
      );
      notifyListeners();
    }
  }

  void requestPayout({required double amount, required String momoNumber, required String provider}) {
    if (amount <= 0 || amount > _profile.balanceAvailable) return;
    final fee = amount * 0.01; // 1% MoMo processing fee
    final net = amount - fee;

    final newPayout = VendorPayout(
      id: '#PO-${1000 + _payouts.length + 1}',
      amount: amount,
      fee: fee,
      netAmount: net,
      paymentMethod: provider,
      momoNumber: momoNumber,
      referenceCode: 'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      timestamp: DateTime.now(),
      status: 'PROCESSING',
    );

    _payouts.insert(0, newPayout);
    _profile = _profile.copyWith(
      balanceAvailable: _profile.balanceAvailable - amount,
    );
    notifyListeners();
  }

  void updateRestaurantBanner(String newBanner) {
    _profile = _profile.copyWith(bannerAsset: newBanner);

    // Also update banner in sampleRestaurants if the restaurant exists
    final idx = sampleRestaurants.indexWhere((r) => r.id == _profile.id || r.name == _profile.restaurantName);
    if (idx != -1) {
      final old = sampleRestaurants[idx];
      sampleRestaurants[idx] = Restaurant(
        id: old.id,
        name: old.name,
        cuisine: old.cuisine,
        address: old.address,
        rating: old.rating,
        reviewCount: old.reviewCount,
        deliveryTime: old.deliveryTime,
        deliveryFee: old.deliveryFee,
        imageAsset: newBanner,
        badgeText: old.badgeText,
        isOpen: old.isOpen,
        distanceKm: old.distanceKm,
        featuredDishIds: old.featuredDishIds,
      );
    }

    notifyListeners();
  }

  /// Get the current vendor profile as a customer-facing Restaurant model
  Restaurant get asRestaurant {
    return Restaurant(
      id: _profile.id,
      name: _profile.restaurantName,
      cuisine: _profile.cuisineSummary.isNotEmpty ? _profile.cuisineSummary : 'Authentic Ghanaian Cuisine',
      address: _profile.address,
      rating: _profile.rating,
      reviewCount: _profile.totalOrders > 0 ? _profile.totalOrders : 142,
      deliveryTime: '15-20 min',
      deliveryFee: 5.00,
      imageAsset: _profile.bannerAsset,
      badgeText: 'KITCHEN PARTNER',
      isOpen: _profile.isOpen,
      distanceKm: '0.6',
      featuredDishIds: _vendorDishes.map((d) => d.id).toList(),
    );
  }
}
