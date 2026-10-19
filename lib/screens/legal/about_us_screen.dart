import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bouncy_tap.dart';

/// About ClickBites Screen
/// Details the mission, Konongo local food culture, rider fleet, kitchen partners,
/// and support contacts for Asante Akim Central.
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

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
          'About ClickBites',
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
            // Hero Brand Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                boxShadow: AppShadows.card,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/clickbite_logo.png',
                      height: 72,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Taste of Asante Akim, Delivered Hot',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ClickBites is Konongo’s premier hyper-local food ordering & delivery platform, connecting food lovers with top chop bars, grill spots, and modern kitchens across Ashanti.',
                    textAlign: TextAlign.center,
                    style: AppTypography.caption(context).copyWith(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primarySubtle,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: const Text(
                      'Konongo, Ashanti Region • Version 1.0.0 (Secure Build)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Mission Statement
            _buildSectionHeader('Our Mission'),
            const SizedBox(height: 10),
            _buildInfoCard(
              context,
              icon: Icons.local_fire_department_rounded,
              title: 'Empowering Local Ghanaian Kitchens',
              body:
                  'We preserve and celebrate local culinary heritage by equipping Aunties, chop bars, and independent food entrepreneurs with digital ordering, kitchen inventory management, and fast MoMo payouts.',
            ),

            const SizedBox(height: 14),
            _buildInfoCard(
              context,
              icon: Icons.moped_rounded,
              title: 'Express Delivery Across Konongo',
              body:
                  'Our trained local motorcycle & bike fleet navigates Post Office Road, Lorry Station, Market Circle, and Low Cost in 15–25 minutes. Thermal insulated bags guarantee piping-hot soups and crispy plantains.',
            ),

            const SizedBox(height: 14),
            _buildInfoCard(
              context,
              icon: Icons.verified_user_rounded,
              title: 'Strict Hygiene & Temperature Standards',
              body:
                  'Every partnered kitchen undergoes health inspection and food handling certification. Real-time food prep monitoring ensures orders are cooked fresh upon checkout.',
            ),

            const SizedBox(height: 24),

            // Key Statistics
            _buildSectionHeader('Konongo Community Impact'),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatTile(context, '10+', 'Partner Eateries'),
                const SizedBox(width: 10),
                _buildStatTile(context, '15-25m', 'Average ETA'),
                const SizedBox(width: 10),
                _buildStatTile(context, '99.4%', 'On-Time Rate'),
              ],
            ),

            const SizedBox(height: 24),

            // Contact & Help Desk
            _buildSectionHeader('Contact & Help Desk'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.soft,
              ),
              child: Column(
                children: [
                  _buildContactRow(
                    Icons.location_city_rounded,
                    'Operational Hub',
                    'Asante Akim Central Municipal, Konongo, Ghana',
                  ),
                  const Divider(height: 20),
                  _buildContactRow(
                    Icons.phone_in_talk_rounded,
                    'Customer Hotline',
                    '+233 (0) 24 555 0192 / +233 (0) 50 123 4567',
                  ),
                  const Divider(height: 20),
                  _buildContactRow(
                    Icons.email_outlined,
                    'Support Email',
                    'support@clickbites.com.gh',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            Center(
              child: Text(
                '© 2026 ClickBites Delivery Ltd. All rights reserved.',
                style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.playfairDisplay(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(BuildContext context, String stat, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          children: [
            Text(
              stat,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
