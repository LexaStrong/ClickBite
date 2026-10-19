import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bouncy_tap.dart';

/// Terms of Service Screen
/// Outlines user responsibilities, order placements, cancellations, MoMo escrow,
/// and delivery protocols for ClickBites in Konongo, Ashanti Region.
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: BouncyTap(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
        ),
        title: Text(
          'Terms of Service',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primarySubtle,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.gavel_rounded, color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Effective Date: September 2026 • Governed under the Laws of the Republic of Ghana',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _buildClause(
              '1. Acceptance of Terms',
              'By creating an account, accessing, or placing orders on ClickBites (the "Application"), you agree to be bound by these Terms of Service. If you disagree with any portion, you must cease using our food ordering and delivery services immediately.',
            ),

            _buildClause(
              '2. Account Eligibility & Security',
              'You must be at least 18 years old or under guardian supervision to use this service. You are responsible for safeguarding your login credentials and Mobile Money PIN. Any orders dispatched from your authenticated profile are presumed authorized by you.',
            ),

            _buildClause(
              '3. Ordering, Prep & Food Addons',
              'When you submit an order, your request is transmitted to the selected Konongo eatery. Customizations (spice preferences, addons, portions) are prepared strictly per your specification. Once the kitchen accepts the order and starts fire preparation, cancellations or alterations are not permitted.',
            ),

            _buildClause(
              '4. Pricing, Currency & Mobile Money (MoMo)',
              'All prices are quoted in Ghana Cedis (GH₵) and include applicable municipal taxes. Payments made through MTN MoMo, Telecel Cash, or Cash on Delivery are verified against our real-time merchant escrow. In the event of an unfulfilled dish or out-of-stock item, full prompt refunds are credited to your MoMo wallet within 30 minutes.',
            ),

            _buildClause(
              '5. Delivery Protocols in Konongo',
              'Deliveries are dispatched to designated landmarks and residential addresses within Asante Akim Central. While we strive for 15–25 minute delivery, adverse weather, road works, or peak rush hours may alter timelines. Our dispatchers will notify you by phone call or live GPS in such instances.',
            ),

            _buildClause(
              '6. Food Safety & Vendor Responsibility',
              'Partnered restaurants and chop bars are independent food preparation businesses legally responsible for ingredient quality, hygiene, and allergen disclaimers. If you have specific dietary allergies (e.g. peanuts, seafood), you must note them in the special instructions field prior to checkout.',
            ),

            _buildClause(
              '7. Prohibited Uses & Security Violations',
              'Users may not attempt reverse engineering, unauthorized API access, automated bot scraping, or credential stuffing. Any attempted security breach or fraudulent order submission results in immediate account termination and reporting to the Ghana Cyber Security Authority.',
            ),

            _buildClause(
              '8. Contact for Legal Inquiries',
              'For questions regarding these terms, contact legal@clickbites.com.gh or visit our local management desk at Asante Akim Central Municipal, Konongo, Ghana.',
            ),

            const SizedBox(height: 24),
            Center(
              child: Text(
                'ClickBites Delivery Ltd. • Asante Akim Central',
                style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildClause(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
