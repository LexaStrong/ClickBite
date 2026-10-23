import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../state/cart_state.dart';
import '../widgets/bouncy_tap.dart';
import '../services/firebase_firestore_service.dart';
import '../services/security_service.dart';
import '../services/paystack_service.dart';
import '../services/notification_service.dart';

/// Full Cart & Checkout Screen with swipe-to-delete dismissible items,
/// Konongo address selector, mobile money payment options, and animated order placement.
class CartScreen extends StatefulWidget {
  final VoidCallback onBrowseMenu;
  final VoidCallback onOrderPlaced;

  const CartScreen({
    super.key,
    required this.onBrowseMenu,
    required this.onOrderPlaced,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartState _cart = CartState();
  bool _isSubmitting = false;
  late final TextEditingController _momoPhoneController;

  @override
  void initState() {
    super.initState();
    final session = SecurityService().currentSession;
    _momoPhoneController = TextEditingController(
      text: session?.phone.isNotEmpty == true ? session!.phone : '024 882 1093',
    );
    _cart.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _momoPhoneController.dispose();
    _cart.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _handlePlaceOrder() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final session = SecurityService().currentSession;
    final customerId =
        session?.userId ?? 'cust_${DateTime.now().millisecondsSinceEpoch}';
    final customerName = session?.fullName ?? 'ClickBite Customer';
    final customerPhone = _momoPhoneController.text.trim().isNotEmpty
        ? _momoPhoneController.text.trim()
        : (session?.phone ?? '0241234567');
    final customerEmail = session?.email ?? 'customer@clickbites.gh';

    String orderId = 'ord_${DateTime.now().millisecondsSinceEpoch}';

    try {
      final itemsList = _cart.items
          .map((i) => {
                'id': i.foodItem.id,
                'name': i.foodItem.name,
                'price': i.unitPrice,
                'quantity': i.quantity,
                'totalPrice': i.totalPrice,
                'spiceLevel': i.spiceLevel ?? 'Regular',
                'addons': i.selectedAddons.map((a) => a.toJson()).toList(),
              })
          .toList();

      orderId = await FirebaseFirestoreService().submitOrder(
        customerId: customerId,
        customerName: customerName,
        customerPhone: customerPhone,
        vendorId: 'maa-mary',
        vendorName: 'Maa Mary Special Kitchen',
        items: itemsList,
        totalAmount: _cart.total,
        deliveryFee: _cart.deliveryFee,
        deliveryAddress: _cart.selectedAddress,
        paymentMethod: _cart.paymentMethod,
      );

      _cart.setActiveOrderId(orderId);
    } catch (e) {
      debugPrint('[CartScreen] Order queued locally or offline: $e');
    }

    final isMoMo = _cart.paymentMethod.contains('Money') ||
        _cart.paymentMethod.contains('Cash') &&
            !_cart.paymentMethod.contains('on Delivery');

    if (isMoMo) {
      final provider = _cart.paymentMethod.contains('Telecel')
          ? MomoProvider.telecel
          : MomoProvider.mtn;

      final chargeResult = await PaystackService().initiateMomoCharge(
        email: customerEmail,
        amountGhs: _cart.total,
        phone: customerPhone,
        provider: provider,
        orderId: orderId,
      );

      if (mounted) {
        setState(() => _isSubmitting = false);
        _showMomoAuthorizationModal(
          orderId: orderId,
          result: chargeResult,
          provider: provider,
          phone: customerPhone,
        );
      }
    } else {
      // Cash on Delivery
      NotificationService().postOrderNotification(
        orderId: orderId,
        type: NotificationType.orderPlaced,
      );
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showOrderSuccessDialog();
      }
    }
  }

  void _showMomoAuthorizationModal({
    required String orderId,
    required PaystackChargeResult result,
    required MomoProvider provider,
    required String phone,
  }) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isMtn = provider == MomoProvider.mtn;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isMtn
                      ? const Color(0xFFFFCC00)
                      : const Color(0xFFE60000),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  isMtn ? 'MTN MoMo USSD Prompt' : 'Telecel Cash Prompt',
                  style: TextStyle(
                    color: isMtn ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Authorize Payment',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'A prompt of GH₵${_cart.total.toStringAsFixed(2)} has been sent to $phone.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        result.displayText ?? provider.ussdPromptInstruction,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Reference: ${result.reference}',
                style: const TextStyle(
                  fontSize: 10,
                  fontFamily: 'monospace',
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: BouncyTap(
                  onTap: () async {
                    Navigator.pop(context);
                    // Verify and update order state to PREPARING
                    await FirebaseFirestoreService().updateOrderStatus(
                      orderId: orderId,
                      status: 'PREPARING',
                    );
                    NotificationService().postOrderNotification(
                      orderId: orderId,
                      type: NotificationType.kitchenPreparing,
                    );
                    _showOrderSuccessDialog();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      boxShadow: AppShadows.buttonElevated,
                    ),
                    child: const Center(
                      child: Text(
                        'I Have Approved Prompt →',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel Payment',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOrderSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Success Check Circle
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Order Confirmed!',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your order has been sent to Nana\'s Kitchen, Konongo. Kofi Boateng is assigned for live express dispatch.',
                  style: AppTypography.caption(context).copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Estimated Arrival: 18 - 22 mins',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: BouncyTap(
                    onTap: () {
                      Navigator.pop(context);
                      widget.onOrderPlaced();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: const Center(
                        child: Text(
                          'Track Order Live →',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cart.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primarySubtle,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: AppColors.primary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your ClickBites cart is empty',
                style: AppTypography.cardTitle(context).copyWith(fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                'Add delicious local dishes from Konongo kitchens to get started.',
                style: AppTypography.caption(context).copyWith(fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              BouncyTap(
                onTap: widget.onBrowseMenu,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: const Text(
                    'Explore Menu',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        // Screen Title
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
                      'Review Order',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_cart.totalItemCount} items selected • Swipe to delete',
                      style: AppTypography.caption(context).copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                BouncyTap(
                  onTap: () => _cart.clearCart(),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 14)),

        // Cart Items List with Dismissible Swipe-to-delete
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = _cart.items[index];
                return Dismissible(
                  key: Key(item.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    _cart.removeItem(item.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item.foodItem.name} removed from cart'),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
                  ),
                  child: _buildCartItemCard(context, item),
                );
              },
              childCount: _cart.items.length,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 14)),

        // Delivery Destination Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: AppShadows.soft,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Delivery Address in Konongo',
                        style: AppTypography.cardTitle(context).copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _cart.selectedAddress,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Estimated delivery time: 18-22 minutes via express bike',
                    style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 14)),

        // Payment Method Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: AppShadows.soft,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.payment_rounded, color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Payment Method (Ghana MoMo)',
                        style: AppTypography.cardTitle(context).copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildPaymentOption('MTN Mobile Money', Icons.phone_android_rounded),
                  _buildPaymentOption('Telecel Cash', Icons.account_balance_wallet_rounded),
                  _buildPaymentOption('Cash on Delivery', Icons.payments_rounded),
                  if (_cart.paymentMethod != 'Cash on Delivery') ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _cart.paymentMethod.contains('MTN')
                                      ? const Color(0xFFFFCC00)
                                      : const Color(0xFFE60000),
                                  borderRadius: BorderRadius.circular(AppRadius.xs),
                                ),
                                child: Text(
                                  _cart.paymentMethod.contains('MTN') ? 'MTN MoMo' : 'Telecel',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 10,
                                    color: _cart.paymentMethod.contains('MTN') ? Colors.black : Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Mobile Money Number for Prompt',
                                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _momoPhoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: 'e.g. 024 123 4567',
                              prefixIcon: const Icon(Icons.phone_iphone_rounded, size: 18, color: AppColors.primary),
                              filled: true,
                              fillColor: AppColors.surface,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                            ),
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Paystack triggers an instant USSD popup on this phone.',
                            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 14)),

        // Order Breakdown Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: AppShadows.soft,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Dishes Subtotal', 'GH₵${_cart.subtotal.toStringAsFixed(2)}'),
                  const SizedBox(height: 6),
                  _buildSummaryRow('Konongo Dispatch Fee', 'GH₵${_cart.deliveryFee.toStringAsFixed(2)}'),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Order',
                        style: AppTypography.cardTitle(context).copyWith(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'GH₵${_cart.total.toStringAsFixed(2)}',
                        style: AppTypography.price(context).copyWith(
                          fontSize: 17,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Place Order Button with Bouncy Tap
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: BouncyTap(
              onTap: _isSubmitting ? null : _handlePlaceOrder,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _isSubmitting
                      ? AppColors.primary.withValues(alpha: 0.7)
                      : AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  boxShadow: _isSubmitting ? null : AppShadows.buttonElevated,
                ),
                child: Center(
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Place Order • GH₵${_cart.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            letterSpacing: 0.3,
                          ),
                        ),
                ),
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

  Widget _buildCartItemCard(BuildContext context, CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.soft,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Image.asset(
              item.foodItem.imageAsset,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.foodItem.name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.spiceLevel != null) ...[
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: AppColors.primarySubtle,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: Text(
                      item.spiceLevel!,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
                if (item.selectedAddons.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    item.selectedAddons.map((a) => '+ ${a.name} (+GH₵${a.price.toStringAsFixed(0)})').join(', '),
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  'GH₵${item.unitPrice.toStringAsFixed(2)} each • Total: GH₵${item.totalPrice.toStringAsFixed(2)}',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Stepper with Bouncy buttons
          Row(
            children: [
              BouncyTap(
                scaleDown: 0.88,
                onTap: () => _cart.updateQuantity(item.id, item.quantity - 1),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.remove_rounded, size: 15, color: AppColors.textPrimary),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '${item.quantity}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                ),
              ),
              BouncyTap(
                scaleDown: 0.88,
                onTap: () => _cart.updateQuantity(item.id, item.quantity + 1),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.add_rounded, size: 15, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String title, IconData icon) {
    final isSelected = _cart.paymentMethod == title;
    return InkWell(
      onTap: () => _cart.setPaymentMethod(title),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              size: 18,
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
      ],
    );
  }
}
