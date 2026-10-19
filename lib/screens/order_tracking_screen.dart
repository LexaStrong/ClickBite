import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../state/cart_state.dart';
import '../services/location_service.dart';
import '../services/firebase_firestore_service.dart';
import '../widgets/live_map_tracker.dart';
import '../widgets/bouncy_tap.dart';

/// Full-featured Live Order Tracking & Dispatch Screen.
/// Replaces the rewards page in the primary navigation, providing real-time GPS tracking,
/// animated route preview, courier communication, and delivery progress across Konongo.
class OrderTrackingScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  final bool showBackButton;

  const OrderTrackingScreen({
    super.key,
    this.onBackToHome,
    this.showBackButton = false,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final LocationService _locationService = LocationService();
  final CartState _cartState = CartState();

  @override
  void initState() {
    super.initState();
    _locationService.addListener(_onLocationChanged);
  }

  @override
  void dispose() {
    _locationService.removeListener(_onLocationChanged);
    super.dispose();
  }

  void _onLocationChanged() {
    if (mounted) setState(() {});
  }

  void _showLocationSwitcher() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xxl),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Live Delivery GPS Location',
                    style: AppTypography.cardTitle(context)
                        .copyWith(fontSize: 16),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _locationService.detectCurrentLocation();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'GPS locked to current Konongo position!',
                          ),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.my_location_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    label: const Text(
                      'Locate Me',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...LocationService.konongoLandmarks.map((landmark) {
                final isSelected =
                    landmark.name == _locationService.currentLocation.name;
                return Material(
                  type: MaterialType.transparency,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.location_on_rounded,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textTertiary,
                      size: 20,
                    ),
                    title: Text(
                      landmark.name,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      '${landmark.distanceKm} km from kitchen • ~${landmark.deliveryMinutes} mins',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                            size: 20,
                          )
                        : null,
                    onTap: () {
                      _locationService.setLocation(landmark);
                      _cartState.setAddress(landmark.name);
                      Navigator.pop(context);
                    },
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = _locationService.currentLocation;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Order Dispatch',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Real-time GPS tracking across Konongo, Ashanti',
                      style: AppTypography.caption(context)
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                _buildStatusBadge(),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // 1. Live Interactive Map Canvas
        SliverToBoxAdapter(child: LiveMapTracker(onRecenter: () {})),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // 2. Courier Rider Card (Featuring user's delivery_rider.png)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                boxShadow: AppShadows.card,
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  // Rider Image
                  Container(
                    width: 64,
                    height: 64,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Image.asset(
                      'assets/icons/delivery_rider.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kofi Boateng',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Konongo Express Dispatcher • Honda 125',
                          style: AppTypography.caption(context)
                              .copyWith(fontSize: 11),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 3),
                            const Text(
                              '4.9',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.speed_rounded,
                              size: 14,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 3),
                            const Text(
                              '28 km/h',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Call Action
                  BouncyTap(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Calling rider Kofi: +233 24 555 8920'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.buttonElevated,
                      ),
                      child: const Icon(
                        Icons.phone_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // 3. Current Destination & Switcher Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: InkWell(
              onTap: _showLocationSwitcher,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppShadows.soft,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.place_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Live Drop-off Spot',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            loc.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Row(
                        children: [
                          Text(
                            'Change',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // 4. Live Progress Timeline Steps
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                boxShadow: AppShadows.soft,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Journey ${_cartState.activeOrderId != null ? "#${_cartState.activeOrderId!.substring(0, _cartState.activeOrderId!.length > 8 ? 8 : _cartState.activeOrderId!.length).toUpperCase()}" : "#CK-8941"}',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  _buildTimelineItem(
                    title: 'Order Confirmed by Nana\'s Kitchen',
                    subtitle: 'Firewood jollof & tilapia placed on charcoal',
                    time: '1:12 PM',
                    isDone: true,
                  ),
                  _buildTimelineItem(
                    title: 'Packed & Inspected',
                    subtitle: 'Sealed with tamper-evident tape',
                    time: '1:24 PM',
                    isDone: true,
                  ),
                  _buildTimelineItem(
                    title: 'Rider Dispatched on Motorbike',
                    subtitle: 'Moving along Kumasi-Accra Road',
                    time: '1:31 PM',
                    isDone: true,
                    isCurrent: true,
                  ),
                  _buildTimelineItem(
                    title: 'Arriving at Destination',
                    subtitle: loc.name,
                    time: '~ ${loc.deliveryMinutes} mins',
                    isDone: false,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // 5. Active Order Summary Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Summary',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  ..._cartState.items.map((cartItem) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${cartItem.quantity}x ${cartItem.foodItem.name}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'GH₵${cartItem.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Paid (MTN MoMo)',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'GH₵${_cartState.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: SizedBox(height: 100 + MediaQuery.paddingOf(context).bottom),
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
    required String time,
    required bool isDone,
    bool isCurrent = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? AppColors.primary : AppColors.surfaceElevated,
                border: Border.all(
                  color: isDone ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: isDone
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 10,
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 34,
                color: isDone
                    ? AppColors.primary.withValues(alpha: 0.35)
                    : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 12.5,
                      color: isCurrent
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final activeId = _cartState.activeOrderId;
    if (activeId == null) {
      return _statusBadgeUi(statusText: 'ON ROUTE', color: AppColors.success);
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestoreService().streamActiveOrder(activeId),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final rawStatus = data?['orderStatus'] as String? ?? 'ON ROUTE';

        Color badgeColor;
        String label;
        switch (rawStatus.toUpperCase()) {
          case 'PENDING':
            badgeColor = AppColors.warning;
            label = 'RECEIVED';
            break;
          case 'ACCEPTED':
          case 'PREPARING':
            badgeColor = AppColors.accent;
            label = 'PREPARING';
            break;
          case 'OUT_FOR_DELIVERY':
          case 'ON ROUTE':
            badgeColor = AppColors.success;
            label = 'ON ROUTE';
            break;
          case 'DELIVERED':
            badgeColor = AppColors.success;
            label = 'DELIVERED';
            break;
          default:
            badgeColor = AppColors.success;
            label = rawStatus.toUpperCase();
        }

        return _statusBadgeUi(statusText: label, color: badgeColor);
      },
    );
  }

  Widget _statusBadgeUi({required String statusText, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            statusText,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

