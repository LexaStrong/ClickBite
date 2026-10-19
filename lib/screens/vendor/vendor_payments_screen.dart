import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../state/vendor_state.dart';
import '../../models/vendor_models.dart';
import '../../widgets/bouncy_tap.dart';

/// Vendor Payments, Wallet, and Mobile Money Payouts Hub
class VendorPaymentsScreen extends StatefulWidget {
  const VendorPaymentsScreen({super.key});

  @override
  State<VendorPaymentsScreen> createState() => _VendorPaymentsScreenState();
}

class _VendorPaymentsScreenState extends State<VendorPaymentsScreen> {
  void _showPayoutDialog(BuildContext context, VendorState vendor) {
    final amountController = TextEditingController(text: vendor.profile.balanceAvailable.toStringAsFixed(0));
    final momoController = TextEditingController(text: vendor.profile.momoNumber);
    String provider = 'MTN MoMo';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final enteredAmount = double.tryParse(amountController.text) ?? 0.0;
            final fee = enteredAmount * 0.01;
            final netReceived = (enteredAmount - fee).clamp(0.0, double.infinity);

            return Container(
              padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
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
                  Text(
                    'Instant Mobile Money Payout',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Direct withdrawal to your Konongo vendor MoMo wallet.',
                    style: AppTypography.caption(context).copyWith(fontSize: 11.5),
                  ),
                  const SizedBox(height: 16),

                  // Provider Selectors
                  Row(
                    children: ['MTN MoMo', 'Telecel Cash', 'AT Money'].map((p) {
                      final isSel = provider == p;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: BouncyTap(
                          onTap: () => setModalState(() => provider = p),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSel ? AppColors.primary : AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(color: isSel ? AppColors.primary : AppColors.border),
                            ),
                            child: Text(
                              p,
                              style: TextStyle(
                                color: isSel ? Colors.white : AppColors.textPrimary,
                                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 14),

                  // Amount Field
                  const Text('Withdrawal Amount (GH₵)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setModalState(() {}),
                    decoration: InputDecoration(
                      prefixText: 'GH₵ ',
                      filled: true,
                      fillColor: AppColors.surfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // MoMo Number Field
                  const Text('Mobile Money Phone Number', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: momoController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.phone_android_rounded, size: 18),
                      filled: true,
                      fillColor: AppColors.surfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Fee Summary
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primarySubtle,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('MoMo Network Fee (1%)', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            Text('GH₵${fee.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Net Payout Sent to MoMo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
                            Text('GH₵${netReceived.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Confirm Button
                  SizedBox(
                    width: double.infinity,
                    child: BouncyTap(
                      onTap: () {
                        if (enteredAmount <= 0 || enteredAmount > vendor.profile.balanceAvailable) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a valid payout amount within available balance.'),
                              backgroundColor: AppColors.error,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        vendor.requestPayout(
                          amount: enteredAmount,
                          momoNumber: momoController.text,
                          provider: provider,
                        );

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Payout of GH₵${netReceived.toStringAsFixed(2)} sent to ${momoController.text}!'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
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
                            'Confirm Payout',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vendor = VendorState();

    return ListenableBuilder(
      listenable: vendor,
      builder: (context, _) {
        final profile = vendor.profile;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payments & Settlements',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mobile Money payouts, transparent platform fees & withdrawal logs.',
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

            // Balance Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.xxl),
                    boxShadow: AppShadows.buttonElevated,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'AVAILABLE TO WITHDRAW',
                            style: AppTypography.caption(context).copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              fontSize: 10,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(AppRadius.full),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.flash_on_rounded, color: Colors.white, size: 12),
                                SizedBox(width: 2),
                                Text('Instant MoMo', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'GH₵${profile.balanceAvailable.toStringAsFixed(2)}',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lifetime Earnings',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11),
                                ),
                                Text(
                                  'GH₵${profile.totalEarnings.toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          BouncyTap(
                            onTap: () => _showPayoutDialog(context, vendor),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(AppRadius.full),
                              ),
                              child: const Text(
                                'Request Payout',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Platform Fee Transparency Notice
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'ClickBite charges a flat 10% platform fee on menu items. Delivery fees are 100% passed to local Konongo couriers.',
                          style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Payout History
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                child: Text(
                  'Payout History & MoMo Transfers',
                  style: AppTypography.cardTitle(context).copyWith(fontSize: 15),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final payout = vendor.payouts[index];
                    return _buildPayoutTile(context, payout);
                  },
                  childCount: vendor.payouts.length,
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

  Widget _buildPayoutTile(BuildContext context, VendorPayout payout) {
    final isSettled = payout.status == 'SETTLED';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.soft,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSettled ? AppColors.success.withValues(alpha: 0.12) : AppColors.accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSettled ? Icons.check_circle_rounded : Icons.hourglass_top_rounded,
              color: isSettled ? AppColors.success : AppColors.accent,
              size: 20,
            ),
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
                      payout.id,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                    Text(
                      'GH₵${payout.netAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${payout.paymentMethod} • ${payout.momoNumber}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ref: ${payout.referenceCode}',
                      style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isSettled ? AppColors.success.withValues(alpha: 0.12) : AppColors.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        payout.status,
                        style: TextStyle(
                          color: isSettled ? AppColors.success : AppColors.accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
