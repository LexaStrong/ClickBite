import 'package:firebase_database/firebase_database.dart';

/// Service managing ultra-low-latency real-time telemetry (courier GPS coordinates,
/// dispatch tracking, and live pings) via Firebase Realtime Database.
class FirebaseRtdbService {
  static final FirebaseRtdbService _instance = FirebaseRtdbService._internal();
  factory FirebaseRtdbService() => _instance;
  FirebaseRtdbService._internal();

  final FirebaseDatabase _db = FirebaseDatabase.instance;

  /// Database reference to active order telemetry
  DatabaseReference get _ordersRef => _db.ref('orders');

  /// Database reference to courier riders
  DatabaseReference get _couriersRef => _db.ref('couriers');

  /// Stream live GPS coordinate updates for an active order in Konongo
  /// Returns a stream of map data containing `latitude`, `longitude`, `heading`, `speed`, and `timestamp`
  Stream<Map<String, dynamic>?> streamCourierLocation(String orderId) {
    return _ordersRef.child('$orderId/courier_location').onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null || value is! Map) {
        return null;
      }
      return Map<String, dynamic>.from(value);
    });
  }

  /// Broadcast live courier location for an active delivery
  /// Called by the dispatch rider / courier app on movement
  Future<void> updateCourierLocation({
    required String orderId,
    required double latitude,
    required double longitude,
    double? heading,
    double? speedKmh,
    String? riderName,
    String? riderPhone,
  }) async {
    final Map<String, dynamic> locationData = {
      'latitude': latitude,
      'longitude': longitude,
      'heading': heading ?? 0.0,
      'speedKmh': speedKmh ?? 25.0,
      'updatedAt': ServerValue.timestamp,
    };
    if (riderName != null) locationData['riderName'] = riderName;
    if (riderPhone != null) locationData['riderPhone'] = riderPhone;

    await _ordersRef.child('$orderId/courier_location').set(locationData);
  }

  /// Broadcast global rider coordinates to the couriers registry
  Future<void> updateRiderPosition({
    required String courierId,
    required double latitude,
    required double longitude,
    double? speedKmh,
    bool isAvailable = true,
  }) async {
    await _couriersRef.child(courierId).set({
      'latitude': latitude,
      'longitude': longitude,
      'speedKmh': speedKmh ?? 20.0,
      'isAvailable': isAvailable,
      'updatedAt': ServerValue.timestamp,
    });
  }

  /// Broadcast order delivery event (e.g. "PICKED_UP", "APPROACHING", "ARRIVED")
  Future<void> postDeliveryEvent({
    required String orderId,
    required String event,
    required String message,
  }) async {
    await _ordersRef.child('$orderId/events').push().set({
      'event': event,
      'message': message,
      'timestamp': ServerValue.timestamp,
    });
  }
}
