import 'food_models.dart';

/// Status enum for kitchen orders
enum VendorOrderStatus {
  pending,       // New incoming order requiring acceptance
  preparing,     // In the kitchen being cooked
  readyForPickup,// Cooked & packaged, waiting for dispatch rider
  outForDelivery,// Courier Kofi Boateng is on route
  completed,     // Delivered and payment settled
  cancelled,
}

/// Single item in a vendor order
class VendorOrderItem {
  final FoodItem foodItem;
  final int quantity;
  final String spiceLevel;
  final List<String> addons;
  final double extraPrice;

  const VendorOrderItem({
    required this.foodItem,
    this.quantity = 1,
    this.spiceLevel = 'Regular Shito',
    this.addons = const [],
    this.extraPrice = 0.0,
  });

  double get totalPrice => (foodItem.price + extraPrice) * quantity;
}

/// Vendor customer order
class VendorOrder {
  final String id;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final List<VendorOrderItem> items;
  final double subtotal;
  final double platformFee;
  final double deliveryFee;
  final double netEarnings;
  final String paymentMethod;
  final String? momoTransactionId;
  final VendorOrderStatus status;
  final DateTime orderTime;
  final String? riderName;
  final String? riderPhone;
  final String? notes;

  const VendorOrder({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.items,
    required this.subtotal,
    required this.platformFee,
    required this.deliveryFee,
    required this.netEarnings,
    this.paymentMethod = 'MTN Mobile Money',
    this.momoTransactionId,
    required this.status,
    required this.orderTime,
    this.riderName = 'Kofi Boateng',
    this.riderPhone = '+233 24 991 3042',
    this.notes,
  });

  VendorOrder copyWith({
    VendorOrderStatus? status,
    String? riderName,
    String? riderPhone,
  }) {
    return VendorOrder(
      id: id,
      customerName: customerName,
      customerPhone: customerPhone,
      deliveryAddress: deliveryAddress,
      items: items,
      subtotal: subtotal,
      platformFee: platformFee,
      deliveryFee: deliveryFee,
      netEarnings: netEarnings,
      paymentMethod: paymentMethod,
      momoTransactionId: momoTransactionId,
      status: status ?? this.status,
      orderTime: orderTime,
      riderName: riderName ?? this.riderName,
      riderPhone: riderPhone ?? this.riderPhone,
      notes: notes,
    );
  }
}

/// Vendor payout withdrawal log
class VendorPayout {
  final String id;
  final double amount;
  final double fee;
  final double netAmount;
  final String paymentMethod;
  final String momoNumber;
  final String referenceCode;
  final DateTime timestamp;
  final String status; // 'SETTLED', 'PROCESSING', 'FAILED'

  const VendorPayout({
    required this.id,
    required this.amount,
    required this.fee,
    required this.netAmount,
    required this.paymentMethod,
    required this.momoNumber,
    required this.referenceCode,
    required this.timestamp,
    required this.status,
  });
}

/// Curated food gallery item for vendor onboarding
class CuratedFoodGalleryItem {
  final String id;
  final String title;
  final String category;
  final String imageAsset;
  final double defaultPrice;
  final String description;
  final List<String> defaultAddons;

  const CuratedFoodGalleryItem({
    required this.id,
    required this.title,
    required this.category,
    required this.imageAsset,
    required this.defaultPrice,
    required this.description,
    this.defaultAddons = const [],
  });
}

/// A vendor's customized dish configured during onboarding or menu editing
class CustomizedVendorDish {
  final String id;
  final String curatedItemId;
  final String title;
  final String category;
  final String imageAsset;
  final bool isCustomImage;
  final double price;
  final String description;
  final List<DishAddon> selectedAddons;
  final bool isAvailable;

  const CustomizedVendorDish({
    required this.id,
    required this.curatedItemId,
    required this.title,
    required this.category,
    required this.imageAsset,
    this.isCustomImage = false,
    required this.price,
    required this.description,
    this.selectedAddons = const [],
    this.isAvailable = true,
  });

  CustomizedVendorDish copyWith({
    String? id,
    String? curatedItemId,
    String? title,
    String? category,
    String? imageAsset,
    bool? isCustomImage,
    double? price,
    String? description,
    List<DishAddon>? selectedAddons,
    bool? isAvailable,
  }) {
    return CustomizedVendorDish(
      id: id ?? this.id,
      curatedItemId: curatedItemId ?? this.curatedItemId,
      title: title ?? this.title,
      category: category ?? this.category,
      imageAsset: imageAsset ?? this.imageAsset,
      isCustomImage: isCustomImage ?? this.isCustomImage,
      price: price ?? this.price,
      description: description ?? this.description,
      selectedAddons: selectedAddons ?? this.selectedAddons,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  FoodItem toFoodItem() {
    return FoodItem(
      id: id,
      name: title,
      description: description,
      price: price,
      imageAsset: imageAsset,
      categoryId: category.toLowerCase().replaceAll(' ', '_'),
      availableAddons: selectedAddons,
      isAvailable: isAvailable,
    );
  }
}

/// Available addon modifier for vendor setup
class VendorAddonOption {
  final String id;
  final String name;
  final double price;
  final bool isDefaultSelected;

  const VendorAddonOption({
    required this.id,
    required this.name,
    required this.price,
    this.isDefaultSelected = false,
  });
}

/// Vendor kitchen profile
class VendorProfile {
  final String id;
  final String restaurantName;
  final String ownerName;
  final String phone;
  final String momoNumber;
  final String address;
  final String cuisineSummary;
  final String bannerAsset;
  final bool isOpen;
  final double rating;
  final int totalOrders;
  final double balanceAvailable;
  final double pendingSettlement;
  final double totalEarnings;

  const VendorProfile({
    required this.id,
    required this.restaurantName,
    required this.ownerName,
    required this.phone,
    required this.momoNumber,
    required this.address,
    required this.cuisineSummary,
    required this.bannerAsset,
    this.isOpen = true,
    this.rating = 4.9,
    this.totalOrders = 318,
    this.balanceAvailable = 1485.50,
    this.pendingSettlement = 320.00,
    this.totalEarnings = 18450.00,
  });

  VendorProfile copyWith({
    bool? isOpen,
    double? balanceAvailable,
    double? pendingSettlement,
    double? totalEarnings,
    int? totalOrders,
    String? restaurantName,
    String? address,
    String? phone,
    String? momoNumber,
    String? bannerAsset,
    String? cuisineSummary,
  }) {
    return VendorProfile(
      id: id,
      restaurantName: restaurantName ?? this.restaurantName,
      ownerName: ownerName,
      phone: phone ?? this.phone,
      momoNumber: momoNumber ?? this.momoNumber,
      address: address ?? this.address,
      cuisineSummary: cuisineSummary ?? this.cuisineSummary,
      bannerAsset: bannerAsset ?? this.bannerAsset,
      isOpen: isOpen ?? this.isOpen,
      rating: rating,
      totalOrders: totalOrders ?? this.totalOrders,
      balanceAvailable: balanceAvailable ?? this.balanceAvailable,
      pendingSettlement: pendingSettlement ?? this.pendingSettlement,
      totalEarnings: totalEarnings ?? this.totalEarnings,
    );
  }
}
