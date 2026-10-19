/// Food category model for the horizontal category selector
class FoodCategory {
  final String id;
  final String name;
  final String? iconAsset;
  final bool isSelected;

  const FoodCategory({
    required this.id,
    required this.name,
    this.iconAsset,
    this.isSelected = false,
  });

  FoodCategory copyWith({bool? isSelected}) {
    return FoodCategory(
      id: id,
      name: name,
      iconAsset: iconAsset,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

/// Food item model for menu cards
class FoodItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageAsset;
  final String categoryId;
  final double rating;
  final int prepTimeMinutes;
  final String? badgeText;
  final List<String> tags;

  const FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageAsset,
    required this.categoryId,
    this.rating = 4.8,
    this.prepTimeMinutes = 25,
    this.badgeText,
    this.tags = const [],
  });
}

/// Restaurant model for the Konongo restaurants directory
class Restaurant {
  final String id;
  final String name;
  final String cuisine;
  final String address;
  final double rating;
  final int reviewCount;
  final String deliveryTime;
  final double deliveryFee;
  final String imageAsset;
  final String badgeText;
  final bool isOpen;
  final String distanceKm;
  final List<String> featuredDishIds;

  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.address,
    this.rating = 4.8,
    this.reviewCount = 142,
    required this.deliveryTime,
    this.deliveryFee = 5.0,
    required this.imageAsset,
    this.badgeText = '',
    this.isOpen = true,
    this.distanceKm = '0.8',
    this.featuredDishIds = const [],
  });
}

/// Addon option for customizing meals (extra fish, plantains, eggs, wele, shito, etc.)
class DishAddon {
  final String id;
  final String name;
  final double price;
  final String category; // 'protein', 'side', 'sauce', 'snack', 'drink'
  final String? imageAsset;

  const DishAddon({
    required this.id,
    required this.name,
    required this.price,
    this.category = 'side',
    this.imageAsset,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'category': category,
    'imageAsset': imageAsset,
  };

  factory DishAddon.fromJson(Map<String, dynamic> json) => DishAddon(
    id: json['id'] as String,
    name: json['name'] as String,
    price: (json['price'] as num).toDouble(),
    category: json['category'] as String? ?? 'side',
    imageAsset: json['imageAsset'] as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DishAddon && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Standard authentic Ghanaian dish addons available for food customization,
/// including proteins, sides, sauces, snacks, pastries, wines, and chilled drinks.
final List<DishAddon> standardGhanaianAddons = [
  // Proteins & Traditional Sides
  const DishAddon(id: 'add-fish', name: 'Fried Fish / Tilapia Cut', price: 10.00, category: 'protein', imageAsset: 'assets/images/grilled_tilapia.png'),
  const DishAddon(id: 'add-egg', name: 'Boiled Farm Egg', price: 3.00, category: 'protein'),
  const DishAddon(id: 'add-wele', name: 'Seasoned Soft Wele', price: 5.00, category: 'protein'),
  const DishAddon(id: 'add-plantain', name: 'Golden Fried Plantains (Dodo)', price: 5.00, category: 'side'),
  const DishAddon(id: 'add-kelewele', name: 'Spicy Ginger Kelewele', price: 5.00, category: 'side'),
  const DishAddon(id: 'add-avocado', name: 'Fresh Ripe Pear (Avocado)', price: 4.00, category: 'side'),
  const DishAddon(id: 'add-shito', name: 'Extra Dark Smoked Fish Shito', price: 3.00, category: 'sauce'),
  const DishAddon(id: 'add-greensauce', name: 'Fiery Fresh Green Pepper Sauce', price: 3.00, category: 'sauce'),

  // Snacks & Fresh Pastries
  const DishAddon(id: 'add-meatpie', name: 'Golden Beef Meat Pie', price: 12.00, category: 'snack', imageAsset: 'assets/images/snacks and pastries/meat pie.jpg'),
  const DishAddon(id: 'add-donut', name: 'Fresh Glazed Donut', price: 8.00, category: 'snack', imageAsset: 'assets/images/snacks and pastries/Donuts.jpg'),
  const DishAddon(id: 'add-springrolls', name: 'Crispy Spring Rolls (2 pcs)', price: 10.00, category: 'snack', imageAsset: 'assets/images/snacks and pastries/spring_rolls.jpg'),
  const DishAddon(id: 'add-pancakes', name: 'Fluffy Honey Pancakes (2 pcs)', price: 12.00, category: 'snack', imageAsset: 'assets/images/snacks and pastries/pancakes.jpg'),
  const DishAddon(id: 'add-cookies', name: 'Chocolate Chip Cookies (2 pcs)', price: 8.00, category: 'snack', imageAsset: 'assets/images/snacks and pastries/chocolate cookies.jpg'),
  const DishAddon(id: 'add-cupcake', name: 'Frosted Vanilla Cupcake', price: 10.00, category: 'snack', imageAsset: 'assets/images/snacks and pastries/cupcakes.jpg'),

  // Wines & Chilled Drinks
  const DishAddon(id: 'add-sobolo', name: 'Chilled Zesty Sobolo Juice', price: 8.00, category: 'drink', imageAsset: 'assets/images/snacks and pastries/Sobolo Juice.jpg'),
  const DishAddon(id: 'add-smoothie', name: 'Tropical Mango Smoothie', price: 15.00, category: 'drink', imageAsset: 'assets/images/snacks and pastries/smoothies.jpg'),
  const DishAddon(id: 'add-milkshake', name: 'Strawberry Milkshake', price: 18.00, category: 'drink', imageAsset: 'assets/images/snacks and pastries/Milkshake.jpg'),
  const DishAddon(id: 'add-coke', name: 'Coca-Cola Can (330ml)', price: 7.00, category: 'drink', imageAsset: 'assets/images/snacks and pastries/coca_cola.jpg'),
  const DishAddon(id: 'add-fanta', name: 'Fanta Orange Can (330ml)', price: 7.00, category: 'drink', imageAsset: 'assets/images/snacks and pastries/fanta.jpg'),
  const DishAddon(id: 'add-sprite', name: 'Sprite Can (330ml)', price: 7.00, category: 'drink', imageAsset: 'assets/images/snacks and pastries/sprite.jpg'),
  const DishAddon(id: 'add-malta', name: 'Malta Guinness Can (330ml)', price: 9.00, category: 'drink', imageAsset: 'assets/images/snacks and pastries/malta guinness.jpg'),
  const DishAddon(id: 'add-heineken', name: 'Heineken Cold Beer (330ml)', price: 16.00, category: 'drink', imageAsset: 'assets/images/wines and drinks/Heineken.jpg'),
  const DishAddon(id: 'add-guinness', name: 'Guinness Extra Stout (330ml)', price: 15.00, category: 'drink', imageAsset: 'assets/images/wines and drinks/guinness.jpg'),
  const DishAddon(id: 'add-donsimon', name: 'Don Simon Sangria Wine (1L)', price: 35.00, category: 'drink', imageAsset: 'assets/images/wines and drinks/Don Simon.jpg'),
  const DishAddon(id: 'add-baileys', name: 'Baileys Original Irish Cream Glass', price: 30.00, category: 'drink', imageAsset: 'assets/images/wines and drinks/Baileys.jpg'),
];
