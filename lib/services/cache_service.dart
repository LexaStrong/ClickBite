import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/security_service.dart';
import '../services/location_service.dart';

/// Centralized Local Cache & Persistence Service for ClickBite
/// Enhances UX with offline-first speed, caching user profile, confirmed GPS location,
/// recent orders, and recipient gift preferences.
class CacheService extends ChangeNotifier {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;

  CacheService._internal();

  SharedPreferences? _prefs;

  static const String _keySession = 'cb_cached_session';
  static const String _keyLocation = 'cb_cached_location';
  static const String _keyRecipient = 'cb_cached_recipient';
  static const String _keyOrders = 'cb_cached_orders';
  static const String _keyHasSeenOnboarding = 'cb_has_seen_onboarding';
  static const String _keyVendorOnboarded = 'cb_vendor_onboarded';

  Future<void> init() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CacheService] Error initializing SharedPreferences: $e');
      }
    }
  }

  // ─── Session Caching ───────────────────────────────────────────
  Future<void> cacheSession(UserSession session) async {
    await init();
    try {
      final map = {
        'userId': session.userId,
        'email': session.email,
        'fullName': session.fullName,
        'phone': session.phone,
        'address': session.address,
        'role': session.role.name,
        'token': session.token,
        'issuedAt': session.issuedAt.toIso8601String(),
        'expiresAt': session.expiresAt.toIso8601String(),
      };
      await _prefs?.setString(_keySession, jsonEncode(map));
      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('[CacheService] Error caching session: $e');
    }
  }

  UserSession? getCachedSession() {
    try {
      final raw = _prefs?.getString(_keySession);
      if (raw == null) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final roleStr = map['role'] as String? ?? 'customer';
      UserRole role = UserRole.customer;
      if (roleStr == 'vendor') role = UserRole.vendor;
      if (roleStr == 'rider') role = UserRole.rider;
      if (roleStr == 'admin') role = UserRole.admin;

      return UserSession(
        userId: map['userId'] ?? '',
        email: map['email'] ?? '',
        fullName: map['fullName'] ?? 'Customer',
        phone: map['phone'] ?? '',
        address: map['address'] ?? 'Post Office Rd, Konongo',
        role: role,
        token: map['token'] ?? '',
        issuedAt: DateTime.tryParse(map['issuedAt'] ?? '') ?? DateTime.now(),
        expiresAt: DateTime.tryParse(map['expiresAt'] ?? '') ??
            DateTime.now().add(const Duration(days: 30)),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[CacheService] Error reading cached session: $e');
      return null;
    }
  }

  Future<void> clearCachedSession() async {
    await init();
    await _prefs?.remove(_keySession);
    notifyListeners();
  }

  // ─── Onboarding & Vendor Status ───────────────────────────────
  bool hasSeenOnboarding() {
    try {
      return _prefs?.getBool(_keyHasSeenOnboarding) ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> setHasSeenOnboarding(bool value) async {
    await init();
    await _prefs?.setBool(_keyHasSeenOnboarding, value);
    notifyListeners();
  }

  bool isVendorOnboarded() {
    try {
      return _prefs?.getBool(_keyVendorOnboarded) ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> setVendorOnboarded(bool value) async {
    await init();
    await _prefs?.setBool(_keyVendorOnboarded, value);
    notifyListeners();
  }

  // ─── Location Caching ──────────────────────────────────────────
  Future<void> cacheLocation(KonongoLocation loc) async {
    await init();
    try {
      final map = {
        'name': loc.name,
        'area': loc.area,
        'latitude': loc.latitude,
        'longitude': loc.longitude,
        'distanceKm': loc.distanceKm,
        'deliveryMinutes': loc.deliveryMinutes,
      };
      await _prefs?.setString(_keyLocation, jsonEncode(map));
      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('[CacheService] Error caching location: $e');
    }
  }

  KonongoLocation? getCachedLocation() {
    try {
      final raw = _prefs?.getString(_keyLocation);
      if (raw == null) return null;
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return KonongoLocation(
        name: m['name'] ?? 'Post Office Rd, Konongo',
        area: m['area'] ?? 'Central District',
        latitude: (m['latitude'] as num?)?.toDouble() ?? 6.6190,
        longitude: (m['longitude'] as num?)?.toDouble() ?? -1.2185,
        distanceKm: (m['distanceKm'] as num?)?.toDouble() ?? 0.8,
        deliveryMinutes: (m['deliveryMinutes'] as num?)?.toInt() ?? 16,
      );
    } catch (e) {
      return null;
    }
  }

  // ─── Recipient (Order for someone else) Caching ────────────────
  Future<void> cacheLastRecipient({
    required String name,
    required String phone,
    String? note,
  }) async {
    await init();
    try {
      final map = {
        'name': name,
        'phone': phone,
        'note': note ?? '',
      };
      await _prefs?.setString(_keyRecipient, jsonEncode(map));
    } catch (e) {
      if (kDebugMode) debugPrint('[CacheService] Error caching recipient: $e');
    }
  }

  Map<String, String>? getLastRecipient() {
    try {
      final raw = _prefs?.getString(_keyRecipient);
      if (raw == null) return null;
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return {
        'name': m['name'] as String? ?? '',
        'phone': m['phone'] as String? ?? '',
        'note': m['note'] as String? ?? '',
      };
    } catch (e) {
      return null;
    }
  }

  // ─── Order History Caching ─────────────────────────────────────
  Future<void> cacheOrders(List<Map<String, dynamic>> orders) async {
    await init();
    try {
      await _prefs?.setString(_keyOrders, jsonEncode(orders));
      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('[CacheService] Error caching orders: $e');
    }
  }

  List<Map<String, dynamic>> getCachedOrders() {
    try {
      final raw = _prefs?.getString(_keyOrders);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      return [];
    }
  }
}
