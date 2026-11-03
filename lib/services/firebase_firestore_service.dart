import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/food_models.dart';
import '../data/sample_data.dart';

/// Cloud Firestore Database Service for ClickBite
/// Handles restaurant catalog, menu items, live order dispatch, and courier telemetry.
/// Utilizes Firestore's automatic offline persistence for seamless offline queueing.
class FirebaseFirestoreService {
  static final FirebaseFirestoreService _instance =
      FirebaseFirestoreService._internal();
  factory FirebaseFirestoreService() => _instance;

  FirebaseFirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _vendorsCol =>
      _firestore.collection('vendors');
  CollectionReference<Map<String, dynamic>> get _menuItemsCol =>
      _firestore.collection('menu_items');
  CollectionReference<Map<String, dynamic>> get _ordersCol =>
      _firestore.collection('orders');

  /// Seed initial Konongo restaurants and food items if collection is empty
  Future<void> seedInitialDataIfEmpty() async {
    try {
      final vendorsSnapshot = await _vendorsCol.limit(1).get();
      if (vendorsSnapshot.docs.isEmpty) {
        if (kDebugMode) {
          debugPrint('[FirebaseFirestoreService] Seeding initial Konongo restaurants...');
        }
        final batch = _firestore.batch();

        for (final r in sampleRestaurants) {
          final docRef = _vendorsCol.doc(r.id);
          batch.set(docRef, {
            'id': r.id,
            'name': r.name,
            'cuisine': r.cuisine,
            'address': r.address,
            'rating': r.rating,
            'reviewCount': r.reviewCount,
            'deliveryTime': r.deliveryTime,
            'deliveryFee': r.deliveryFee,
            'imageAsset': r.imageAsset,
            'badgeText': r.badgeText,
            'isOpen': r.isOpen,
            'distanceKm': r.distanceKm,
            'featuredDishIds': r.featuredDishIds,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        for (final item in sampleFoodItems) {
          final docRef = _menuItemsCol.doc(item.id);
          batch.set(docRef, {
            'id': item.id,
            'name': item.name,
            'description': item.description,
            'price': item.price,
            'imageAsset': item.imageAsset,
            'categoryId': item.categoryId,
            'rating': item.rating,
            'prepTimeMinutes': item.prepTimeMinutes,
            'badgeText': item.badgeText ?? '',
            'tags': item.tags,
            'isAvailable': true,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        await batch.commit();
        if (kDebugMode) {
          debugPrint('[FirebaseFirestoreService] Seeding completed successfully.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FirebaseFirestoreService] Seeding bypassed or offline: $e');
      }
    }
  }

  /// Real-time stream of all approved vendors
  Stream<List<Restaurant>> streamVendors() {
    return _vendorsCol.snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        // Fallback to sample data if Firestore has not finished populating
        return sampleRestaurants;
      }
      return snapshot.docs.map((doc) {
        final d = doc.data();
        return Restaurant(
          id: doc.id,
          name: d['name'] as String? ?? 'Restaurant',
          cuisine: d['cuisine'] as String? ?? 'Local Cuisine',
          address: d['address'] as String? ?? 'Konongo',
          rating: (d['rating'] as num?)?.toDouble() ?? 4.8,
          reviewCount: (d['reviewCount'] as num?)?.toInt() ?? 100,
          deliveryTime: d['deliveryTime'] as String? ?? '20-30 min',
          deliveryFee: (d['deliveryFee'] as num?)?.toDouble() ?? 5.0,
          imageAsset: d['imageAsset'] as String? ?? 'assets/images/jollof_rice.png',
          badgeText: d['badgeText'] as String? ?? '',
          isOpen: d['isOpen'] as bool? ?? true,
          distanceKm: d['distanceKm'] as String? ?? '0.8',
          featuredDishIds: List<String>.from(d['featuredDishIds'] as List? ?? []),
        );
      }).toList();
    });
  }

  /// Real-time stream of food menu items (optionally filtered by category)
  Stream<List<FoodItem>> streamFoodItems({String? categoryId}) {
    Query<Map<String, dynamic>> query = _menuItemsCol;
    if (categoryId != null && categoryId.isNotEmpty && categoryId != 'all') {
      query = query.where('categoryId', isEqualTo: categoryId);
    }

    return query.snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return sampleFoodItems.where((i) {
          if (categoryId == null || categoryId.isEmpty || categoryId == 'all') {
            return true;
          }
          return i.categoryId == categoryId;
        }).toList();
      }
      return snapshot.docs.map((doc) {
        final d = doc.data();
        return FoodItem(
          id: doc.id,
          name: d['name'] as String? ?? '',
          description: d['description'] as String? ?? '',
          price: (d['price'] as num?)?.toDouble() ?? 0.0,
          imageAsset: d['imageAsset'] as String? ?? 'assets/images/jollof_rice.png',
          categoryId: d['categoryId'] as String? ?? 'jollof',
          rating: (d['rating'] as num?)?.toDouble() ?? 4.8,
          prepTimeMinutes: (d['prepTimeMinutes'] as num?)?.toInt() ?? 25,
          badgeText: (d['badgeText'] as String?)?.isNotEmpty == true
              ? d['badgeText'] as String
              : null,
          tags: List<String>.from(d['tags'] as List? ?? []),
        );
      }).toList();
    });
  }

  /// Submit a new customer order with automatic offline queuing
  /// Submit a new customer order with automatic offline queuing
  Future<String> submitOrder({
    required String customerId,
    required String customerName,
    required String customerPhone,
    required String vendorId,
    required String vendorName,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required double deliveryFee,
    required String deliveryAddress,
    required String paymentMethod,
    String? deliveryNotes,
    String? momoReference,
    bool isForSomeoneElse = false,
    String? recipientName,
    String? recipientPhone,
    String? recipientNote,
  }) async {
    final orderDoc = _ordersCol.doc();
    final orderId = orderDoc.id;

    final orderData = {
      'orderId': orderId,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'items': items,
      'totalAmount': totalAmount,
      'deliveryFee': deliveryFee,
      'deliveryAddress': deliveryAddress,
      'paymentMethod': paymentMethod,
      'paymentStatus': 'PENDING',
      'orderStatus': 'PENDING',
      'deliveryNotes': deliveryNotes ?? '',
      'momoReference': momoReference ?? '',
      'isForSomeoneElse': isForSomeoneElse,
      'recipientName': recipientName ?? '',
      'recipientPhone': recipientPhone ?? '',
      'recipientNote': recipientNote ?? '',
      'courierId': null,
      'courierLocation': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await orderDoc.set(orderData);
    return orderId;
  }

  /// Real-time listener for a single active order (e.g. for OrderTrackingScreen)
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamActiveOrder(
      String orderId) {
    return _ordersCol.doc(orderId).snapshots();
  }

  /// Real-time stream of all orders for a customer
  Stream<List<Map<String, dynamic>>> streamCustomerOrders(String customerId) {
    return _ordersCol
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  /// Real-time stream of incoming orders for a kitchen/vendor
  Stream<List<Map<String, dynamic>>> streamVendorOrders(String vendorId) {
    return _ordersCol
        .where('vendorId', isEqualTo: vendorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  /// Transition order status (PENDING -> ACCEPTED -> PREPARING -> OUT_FOR_DELIVERY -> DELIVERED)
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    await _ordersCol.doc(orderId).update({
      'orderStatus': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update courier real-time GPS coordinate for live tracking in Konongo
  Future<void> updateCourierLocation({
    required String orderId,
    required double latitude,
    required double longitude,
  }) async {
    await _ordersCol.doc(orderId).update({
      'courierLocation': {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': DateTime.now().toIso8601String(),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
