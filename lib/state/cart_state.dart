import 'package:flutter/material.dart';
import '../models/food_models.dart';
import '../data/sample_data.dart';

/// Single item in the shopping cart with customizations and addons
class CartItem {
  final String id;
  final FoodItem foodItem;
  int quantity;
  final List<DishAddon> selectedAddons;
  String? spiceLevel;
  String? notes;

  CartItem({
    String? id,
    required this.foodItem,
    this.quantity = 1,
    this.selectedAddons = const [],
    this.spiceLevel,
    this.notes,
  }) : id = id ?? '${foodItem.id}_${DateTime.now().microsecondsSinceEpoch}';

  double get addonsPrice =>
      selectedAddons.fold(0.0, (sum, a) => sum + (a.price * a.quantity));
  double get unitPrice => foodItem.price + addonsPrice;
  double get totalPrice => unitPrice * quantity;
}

/// Global Cart Controller & State
/// Manages cart items, totals, delivery fees, and order dispatch
class CartState extends ChangeNotifier {
  static final CartState _instance = CartState._internal();
  factory CartState() => _instance;

  CartState._internal() {
    // Pre-populate with initial items matching the badge "2" in the reference design
    if (sampleFoodItems.isNotEmpty) {
      _items.add(CartItem(
        foodItem: sampleFoodItems[0],
        quantity: 1,
        selectedAddons: [standardGhanaianAddons[0]], // Extra fried fish
        spiceLevel: 'Regular Pepper',
      ));
      if (sampleFoodItems.length > 2) {
        _items.add(CartItem(
          foodItem: sampleFoodItems[2],
          quantity: 1,
          selectedAddons: [standardGhanaianAddons[3]], // Fried plantains
          spiceLevel: 'Mild Shito',
        ));
      }
    }
  }

  final List<CartItem> _items = [];
  String _selectedAddress = 'Post Office Rd, Konongo';
  String _paymentMethod = 'MTN Mobile Money';
  String? _activeOrderId;

  // Order for someone else
  bool _isForSomeoneElse = false;
  String _recipientName = '';
  String _recipientPhone = '';
  String _recipientNote = '';

  List<CartItem> get items => List.unmodifiable(_items);
  String get selectedAddress => _selectedAddress;
  String get paymentMethod => _paymentMethod;
  String? get activeOrderId => _activeOrderId;

  bool get isForSomeoneElse => _isForSomeoneElse;
  String get recipientName => _recipientName;
  String get recipientPhone => _recipientPhone;
  String get recipientNote => _recipientNote;

  void setForSomeoneElse(bool value) {
    _isForSomeoneElse = value;
    notifyListeners();
  }

  void setRecipientDetails({
    required String name,
    required String phone,
    String note = '',
  }) {
    _recipientName = name;
    _recipientPhone = phone;
    _recipientNote = note;
    notifyListeners();
  }

  void setActiveOrderId(String? id) {
    _activeOrderId = id;
    notifyListeners();
  }

  int get totalItemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get deliveryFee => _items.isEmpty ? 0.0 : 10.00; // Flat 10 GH₵ delivery across Konongo
  double get total => subtotal + deliveryFee;

  void setAddress(String address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void addItem(
    FoodItem foodItem, {
    int quantity = 1,
    List<DishAddon> selectedAddons = const [],
    String? spiceLevel,
    String? notes,
  }) {
    final existingIndex = _items.indexWhere((i) {
      if (i.foodItem.id != foodItem.id) return false;
      if (i.spiceLevel != spiceLevel) return false;
      if (i.selectedAddons.length != selectedAddons.length) return false;
      final existingAddonIds = i.selectedAddons.map((a) => a.id).toSet();
      final newAddonIds = selectedAddons.map((a) => a.id).toSet();
      return existingAddonIds.containsAll(newAddonIds);
    });

    if (existingIndex != -1) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(
        CartItem(
          foodItem: foodItem,
          quantity: quantity,
          selectedAddons: List.from(selectedAddons),
          spiceLevel: spiceLevel,
          notes: notes,
        ),
      );
    }
    notifyListeners();
  }

  void updateQuantity(String itemId, int newQuantity) {
    final index = _items.indexWhere((i) => i.id == itemId || i.foodItem.id == itemId);
    if (index != -1) {
      if (newQuantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = newQuantity;
      }
      notifyListeners();
    }
  }

  void removeItem(String itemId) {
    _items.removeWhere((i) => i.id == itemId || i.foodItem.id == itemId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
