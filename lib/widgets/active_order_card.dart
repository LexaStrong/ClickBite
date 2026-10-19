import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/location_service.dart';
import '../services/firebase_firestore_service.dart';
import '../state/cart_state.dart';
import 'bouncy_tap.dart';

/// Live active order banner card for the home screen feed, replacing
/// the rewards card and providing a live GPS gateway to order dispatch tracking.
class ActiveOrderCard extends StatelessWidget {
  final VoidCallback onTrackTap;

  const ActiveOrderCard({super.key, required this.onTrackTap});

  @override
  Widget build(BuildContext context) {
    final locationService = LocationService();
    final loc = locationService.currentLocation;
    final activeId = CartState().activeOrderId;
    final orderDisplayId = activeId != null
        ? '#${activeId.substring(0, activeId.length > 8 ? 8 : activeId.length).toUpperCase()}'
        : '#CK-8941';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Live Pulse Beacon
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primarySubtle,
                    ),
                    child: const Icon(
                      Icons.two_wheeler_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              // Dispatch Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'ACTIVE ORDER $orderDisplayId',
                          style: AppTypography.caption(context).copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (activeId != null)
                          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestoreService().streamActiveOrder(activeId),
                            builder: (context, snapshot) {
                              final status = (snapshot.data?.data()?['orderStatus'] as String? ?? 'ON ROUTE').toUpperCase();
                              final isDelivered = status == 'DELIVERED';
                              final isPrep = status == 'PREPARING' || status == 'ACCEPTED';
                              final color = isDelivered
                                  ? AppColors.success
                                  : isPrep
                                      ? AppColors.accent
                                      : AppColors.success;
                              final label = isPrep
                                  ? 'PREPARING'
                                  : isDelivered
                                      ? 'DELIVERED'
                                      : 'ON ROUTE';
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 8.5,
                                  ),
                                ),
                              );
                            },
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: const Text(
                              'ON ROUTE',
                              style: TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w800,
                                fontSize: 8.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Kofi is delivering via Kumasi Rd',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'To ${loc.name} • ~${loc.deliveryMinutes} mins away',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.gps_fixed_rounded, size: 13, color: AppColors.textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    'Live GPS Connected',
                    style: AppTypography.caption(context).copyWith(fontSize: 11),
                  ),
                ],
              ),
              BouncyTap(
                onTap: onTrackTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'Track Live',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 13),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
