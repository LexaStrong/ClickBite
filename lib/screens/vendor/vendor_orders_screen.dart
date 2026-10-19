import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../state/vendor_state.dart';
import '../../models/vendor_models.dart';
import '../../widgets/bouncy_tap.dart';

/// Kitchen Order Management & Kitchen Display System (KDS)
class VendorOrdersScreen extends StatefulWidget {
  const VendorOrdersScreen({super.key});

  @override
  State<VendorOrdersScreen> createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends State<VendorOrdersScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final vendor = VendorState();

    return ListenableBuilder(
      listenable: vendor,
      builder: (context, _) {
        List<VendorOrder> displayedOrders;
        if (_selectedFilter == 'pending') {
          displayedOrders = vendor.pendingOrders;
        } else if (_selectedFilter == 'preparing') {
          displayedOrders = vendor.preparingOrders;
        } else if (_selectedFilter == 'ready') {
          displayedOrders = vendor.readyOrders;
        } else if (_selectedFilter == 'completed') {
          displayedOrders = vendor.completedOrders;
        } else {
          displayedOrders = vendor.orders;
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Screen Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kitchen Orders',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage preparation times, addons, and courier dispatch.',
                      style: AppTypography.caption(context).copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Filter Chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                  children: [
                    _buildFilterPill('All Orders (${vendor.orders.length})', 'all'),
                    _buildFilterPill('New (${vendor.pendingOrders.length})', 'pending'),
                    _buildFilterPill('In Kitchen (${vendor.preparingOrders.length})', 'preparing'),
                    _buildFilterPill('Ready for Rider (${vendor.readyOrders.length})', 'ready'),
                    _buildFilterPill('Completed (${vendor.completedOrders.length})', 'completed'),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Orders list
            displayedOrders.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.textTertiary),
                            const SizedBox(height: 12),
                            Text(
                              'No orders in this category',
                              style: AppTypography.cardTitle(context),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'New incoming tickets will show up automatically.',
                              style: AppTypography.caption(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final order = displayedOrders[index];
                          return _buildOrderCard(context, order, vendor);
                        },
                        childCount: displayedOrders.length,
                      ),
                    ),
                  ),

            SliverToBoxAdapter(
              child: SizedBox(height: 96 + MediaQuery.paddingOf(context).bottom),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterPill(String label, String id) {
    final isSelected = _selectedFilter == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: BouncyTap(
        onTap: () => setState(() => _selectedFilter = id),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1,
            ),
            boxShadow: isSelected ? AppShadows.buttonElevated : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, VendorOrder order, VendorState vendor) {
    Color statusColor;
    String statusLabel;
    if (order.status == VendorOrderStatus.pending) {
      statusColor = AppColors.primary;
      statusLabel = 'NEW INCOMING';
    } else if (order.status == VendorOrderStatus.preparing) {
      statusColor = AppColors.accent;
      statusLabel = 'IN KITCHEN';
    } else if (order.status == VendorOrderStatus.readyForPickup) {
      statusColor = AppColors.success;
      statusLabel = 'READY FOR RIDER';
    } else {
      statusColor = AppColors.textTertiary;
      statusLabel = 'COMPLETED';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    order.id,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 9.5,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                'GH₵${order.subtotal.toStringAsFixed(2)}',
                style: AppTypography.price(context).copyWith(fontSize: 15),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Text(
            '${order.customerName} • ${order.customerPhone}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
          ),
          Text(
            'Drop-off: ${order.deliveryAddress}',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Dishes List
          ...order.items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${item.quantity}x',
                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.foodItem.name,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                        ),
                        Text(
                          'Spice: ${item.spiceLevel}${item.addons.isNotEmpty ? ' • ${item.addons.join(", ")}' : ""}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'GH₵${item.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ],
              ),
            );
          }),

          if (order.notes != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primarySubtle,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                'Kitchen Note: ${order.notes}',
                style: const TextStyle(color: AppColors.primaryDark, fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Courier & Payout Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.two_wheeler_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Rider: ${order.riderName}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Text(
                'Net: GH₵${order.netEarnings.toStringAsFixed(2)} (10% fee)',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // State action buttons
          Row(
            children: [
              if (order.status == VendorOrderStatus.pending)
                Expanded(
                  child: BouncyTap(
                    onTap: () => vendor.acceptOrder(order.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: const Center(
                        child: Text(
                          'Accept Order & Cook',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ),

              if (order.status == VendorOrderStatus.preparing)
                Expanded(
                  child: BouncyTap(
                    onTap: () => vendor.markReadyForDispatch(order.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: const Center(
                        child: Text(
                          'Mark Ready for Courier',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ),

              if (order.status == VendorOrderStatus.readyForPickup)
                Expanded(
                  child: BouncyTap(
                    onTap: () => vendor.completeOrder(order.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: const Center(
                        child: Text(
                          'Hand to Rider (Complete)',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ),

              if (order.status == VendorOrderStatus.completed)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: const Center(
                      child: Text(
                        'Delivered & Settled to Wallet',
                        style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 11),
                      ),
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
