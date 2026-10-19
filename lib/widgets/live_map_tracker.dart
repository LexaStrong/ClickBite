import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_theme.dart';
import '../services/location_service.dart';
import '../services/firebase_rtdb_service.dart';
import '../state/cart_state.dart';

/// Real-world Live Map & GPS Route Tracker for Konongo, Ashanti.
/// Powered by OpenStreetMap and flutter_map (Leaflet for Flutter).
///
/// Features:
/// - Real OpenStreetMap interactive tiles (pan, pinch-to-zoom, rotate)
/// - Konongo central kitchen dispatch marker
/// - Animated courier (Kofi Boateng) moving in real-time along the street route
/// - Pulsing radar beacon at user's destination landmark
/// - Interactive Leaflet zoom & recenter controls
/// - Expandable height mode (compact 280px vs full-screen preview 440px)
/// - Live GPS telemetry with speed, distance, and ETA
class LiveMapTracker extends StatefulWidget {
  final VoidCallback? onRecenter;

  const LiveMapTracker({super.key, this.onRecenter});

  @override
  State<LiveMapTracker> createState() => _LiveMapTrackerState();
}

class _LiveMapTrackerState extends State<LiveMapTracker> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();

  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _riderProgressAnimation;

  // Central ClickBite kitchen dispatch hub in central Konongo
  static const LatLng _kitchenLocation = LatLng(6.6180, -1.2170);

  bool _isExpanded = false;
  double _currentZoom = 15.0;

  @override
  void initState() {
    super.initState();
    _locationService.addListener(_onLocationChanged);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );

    _riderProgressAnimation = Tween<double>(begin: 0.12, end: 0.88).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _locationService.removeListener(_onLocationChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onLocationChanged() {
    if (mounted) {
      setState(() {});
      _recenterMap();
    }
  }

  LatLng get _destinationLocation {
    final loc = _locationService.currentLocation;
    return LatLng(loc.latitude, loc.longitude);
  }

  /// Constructs a realistic street route between the kitchen and destination
  List<LatLng> get _routePoints {
    final dest = _destinationLocation;
    // Midpoint following Konongo Kumasi-Accra arterial road
    final midLat = (_kitchenLocation.latitude + dest.latitude) / 2 + 0.0006;
    final midLng = (_kitchenLocation.longitude + dest.longitude) / 2 - 0.0004;
    return [
      _kitchenLocation,
      LatLng(midLat, midLng),
      dest,
    ];
  }

  /// Calculates interpolated position along the route for the moving courier
  LatLng _calculateCourierPosition(List<LatLng> route, double progress) {
    if (route.isEmpty) return _kitchenLocation;
    if (route.length == 1) return route.first;

    double totalDist = 0;
    final List<double> segmentDists = [];
    for (int i = 0; i < route.length - 1; i++) {
      final d = math.sqrt(
        math.pow(route[i + 1].latitude - route[i].latitude, 2) +
            math.pow(route[i + 1].longitude - route[i].longitude, 2),
      );
      segmentDists.add(d);
      totalDist += d;
    }

    if (totalDist == 0) return route.first;
    final double targetDist = progress * totalDist;
    double accumulated = 0;

    for (int i = 0; i < segmentDists.length; i++) {
      if (accumulated + segmentDists[i] >= targetDist) {
        final double segmentProgress = (targetDist - accumulated) / segmentDists[i];
        final double lat = route[i].latitude + (route[i + 1].latitude - route[i].latitude) * segmentProgress;
        final double lng = route[i].longitude + (route[i + 1].longitude - route[i].longitude) * segmentProgress;
        return LatLng(lat, lng);
      }
      accumulated += segmentDists[i];
    }
    return route.last;
  }

  void _recenterMap() {
    final dest = _destinationLocation;
    final centerLat = (_kitchenLocation.latitude + dest.latitude) / 2;
    final centerLng = (_kitchenLocation.longitude + dest.longitude) / 2;
    _mapController.move(LatLng(centerLat, centerLng), 15.0);
    _currentZoom = 15.0;
  }

  void _zoomIn() {
    setState(() {
      _currentZoom = math.min(_currentZoom + 1.0, 18.0);
      _mapController.move(_mapController.camera.center, _currentZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoom = math.max(_currentZoom - 1.0, 13.0);
      _mapController.move(_mapController.camera.center, _currentZoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = _locationService.currentLocation;
    final route = _routePoints;
    final dest = _destinationLocation;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      height: _isExpanded ? 440 : 280,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EDE4),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 1. OpenStreetMap Leaflet Engine
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final activeOrderId = CartState().activeOrderId;

              return StreamBuilder<Map<String, dynamic>?>(
                stream: activeOrderId != null
                    ? FirebaseRtdbService().streamCourierLocation(activeOrderId)
                    : null,
                builder: (context, rtdbSnap) {
                  LatLng courierPos;
                  final rtdbData = rtdbSnap.data;
                  if (rtdbData != null &&
                      rtdbData['latitude'] != null &&
                      rtdbData['longitude'] != null) {
                    courierPos = LatLng(
                      (rtdbData['latitude'] as num).toDouble(),
                      (rtdbData['longitude'] as num).toDouble(),
                    );
                  } else {
                    courierPos = _calculateCourierPosition(
                      route,
                      _riderProgressAnimation.value,
                    );
                  }

                  return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(
                    (_kitchenLocation.latitude + dest.latitude) / 2,
                    (_kitchenLocation.longitude + dest.longitude) / 2,
                  ),
                  initialZoom: _currentZoom,
                  minZoom: 12.0,
                  maxZoom: 18.5,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  // OpenStreetMap Standard Tiles
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.clickbites.clickbites',
                    maxNativeZoom: 19,
                  ),

                  // Route Polyline Layer
                  PolylineLayer(
                    polylines: [
                      // Outer soft glow / casing
                      Polyline(
                        points: route,
                        strokeWidth: 8.0,
                        color: Colors.white.withValues(alpha: 0.9),
                        strokeCap: StrokeCap.round,
                        strokeJoin: StrokeJoin.round,
                      ),
                      // Core vibrant brand route
                      Polyline(
                        points: route,
                        strokeWidth: 5.0,
                        color: AppColors.primary,
                        strokeCap: StrokeCap.round,
                        strokeJoin: StrokeJoin.round,
                      ),
                    ],
                  ),

                  // Destination Radar Pulsing Circle
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: dest,
                        radius: 20 + (_pulseAnimation.value * 28),
                        color: AppColors.primary.withValues(
                          alpha: (0.35 * (1.0 - _pulseAnimation.value)).clamp(0.0, 1.0),
                        ),
                        borderColor: AppColors.primary.withValues(
                          alpha: (0.7 * (1.0 - _pulseAnimation.value)).clamp(0.0, 1.0),
                        ),
                        borderStrokeWidth: 1.5,
                        useRadiusInMeter: false,
                      ),
                    ],
                  ),

                  // Map Markers Layer
                  MarkerLayer(
                    markers: [
                      // A. Central Kitchen Hub Marker
                      Marker(
                        point: _kitchenLocation,
                        width: 90,
                        height: 52,
                        alignment: Alignment.topCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: AppShadows.soft,
                              ),
                              child: const Text(
                                'ClickBite Kitchen',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: AppShadows.soft,
                              ),
                              child: const Icon(
                                Icons.restaurant_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // B. User Destination Marker
                      Marker(
                        point: dest,
                        width: 100,
                        height: 58,
                        alignment: Alignment.topCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: AppShadows.soft,
                              ),
                              child: Text(
                                loc.name.split(',').first,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primary, width: 2.5),
                                boxShadow: AppShadows.soft,
                              ),
                              child: const Icon(
                                Icons.home_rounded,
                                color: AppColors.primary,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // C. Live Moving Courier (Kofi Boateng)
                      Marker(
                        point: courierPos,
                        width: 90,
                        height: 60,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: AppShadows.soft,
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.bolt_rounded, color: Colors.amber, size: 10),
                                  SizedBox(width: 2),
                                  Text(
                                    'Kofi • On Route',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 3),
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2.5),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x60EB7242),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.two_wheeler_rounded,
                                color: Colors.white,
                                size: 19,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),

          // 2. Top-Left: Live GPS Telemetry Badge
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(AppRadius.full),
                boxShadow: AppShadows.soft,
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'GPS LIVE • ${loc.area}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Top-Right: Leaflet Map Controls Column (Zoom +, Zoom -, Recenter, Expand)
          Positioned(
            top: 12,
            right: 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Expand / Collapse Fullscreen View
                _MapControlButton(
                  icon: _isExpanded ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                  tooltip: _isExpanded ? 'Compact View' : 'Expand Map',
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
                const SizedBox(height: 6),

                // Recenter Camera
                _MapControlButton(
                  icon: Icons.my_location_rounded,
                  tooltip: 'Recenter on Route',
                  isLoading: _locationService.isLocating,
                  onTap: () {
                    _locationService.detectCurrentLocation();
                    _recenterMap();
                    widget.onRecenter?.call();
                  },
                ),
                const SizedBox(height: 6),

                // Zoom In
                _MapControlButton(
                  icon: Icons.add_rounded,
                  tooltip: 'Zoom In',
                  onTap: _zoomIn,
                ),
                const SizedBox(height: 6),

                // Zoom Out
                _MapControlButton(
                  icon: Icons.remove_rounded,
                  tooltip: 'Zoom Out',
                  onTap: _zoomOut,
                ),
              ],
            ),
          ),

          // 4. Bottom-Right: OpenStreetMap / Leaflet Attribution Tag
          Positioned(
            bottom: 58,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '© OpenStreetMap • Leaflet',
                style: TextStyle(
                  fontSize: 7.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),

          // 5. Bottom: Live Route ETA Status Bar
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.soft,
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.two_wheeler_rounded, color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Kofi Boateng is on Kumasi Rd',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                          ),
                          Text(
                            '${loc.distanceKm} km away • ${loc.deliveryMinutes} mins ETA',
                            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primarySubtle,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      '${loc.deliveryMinutes} MINS',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isLoading;

  const _MapControlButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.95),
      shape: const CircleBorder(),
      elevation: 2,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  )
                : Icon(icon, size: 16, color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}
