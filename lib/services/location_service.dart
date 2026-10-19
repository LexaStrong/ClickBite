import 'dart:async';
import 'package:flutter/material.dart';

/// Konongo Landmark Location Model
class KonongoLocation {
  final String name;
  final String area;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final int deliveryMinutes;

  const KonongoLocation({
    required this.name,
    required this.area,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.deliveryMinutes,
  });
}

/// Global Live Location Service for ClickBites Konongo
class LocationService extends ChangeNotifier {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;

  LocationService._internal();

  static const List<KonongoLocation> konongoLandmarks = [
    KonongoLocation(
      name: 'Post Office Rd, Konongo',
      area: 'Central District',
      latitude: 6.6190,
      longitude: -1.2185,
      distanceKm: 0.8,
      deliveryMinutes: 16,
    ),
    KonongoLocation(
      name: 'Market Circle, Konongo',
      area: 'Commercial Hub',
      latitude: 6.6165,
      longitude: -1.2150,
      distanceKm: 1.2,
      deliveryMinutes: 18,
    ),
    KonongoLocation(
      name: 'Konongo Zongo High St',
      area: 'North Sector',
      latitude: 6.6230,
      longitude: -1.2210,
      distanceKm: 1.7,
      deliveryMinutes: 22,
    ),
    KonongoLocation(
      name: 'Railway Station Area',
      area: 'South District',
      latitude: 6.6130,
      longitude: -1.2140,
      distanceKm: 1.5,
      deliveryMinutes: 20,
    ),
    KonongoLocation(
      name: 'Low Cost Residential',
      area: 'East Ridge',
      latitude: 6.6150,
      longitude: -1.2260,
      distanceKm: 2.1,
      deliveryMinutes: 25,
    ),
    KonongoLocation(
      name: 'Accra-Kumasi Highway Junction',
      area: 'Expressway Stop',
      latitude: 6.6210,
      longitude: -1.2110,
      distanceKm: 2.4,
      deliveryMinutes: 28,
    ),
  ];

  KonongoLocation _currentLocation = konongoLandmarks[0];
  bool _isLocating = false;

  KonongoLocation get currentLocation => _currentLocation;
  bool get isLocating => _isLocating;

  /// Select a landmark location
  void setLocation(KonongoLocation location) {
    _currentLocation = location;
    notifyListeners();
  }

  /// Simulate live GPS geolocation detection with radar scan
  Future<void> detectCurrentLocation() async {
    _isLocating = true;
    notifyListeners();

    // Realistic GPS scan latency
    await Future.delayed(const Duration(milliseconds: 1200));

    // Choose the closest GPS fix
    _currentLocation = konongoLandmarks[0];
    _isLocating = false;
    notifyListeners();
  }
}
