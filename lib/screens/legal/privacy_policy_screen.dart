import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bouncy_tap.dart';

/// Privacy Policy Screen
/// Detailed data collection disclosures, encryption policies, GPS tracking limits,
/// and data subject rights under Ghana Data Protection Act, 2012 (Act 843).
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
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
                  const Icon(Icons.security_rounded, color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Compliant with Ghana Data Protection Act 843 • Zero Sale of Customer Data',
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

            _buildSection(
              '1. Information We Collect',
              'We collect minimal personal data essential to fulfill your meals:\n'
              '• Profile Data: Full name, phone number, and encrypted authentication token.\n'
              '• Delivery Coordinates: Physical street addresses and landmark coordinates in Konongo (e.g. Post Office Rd, Lorry Station).\n'
              '• Transaction Records: Mobile Money transaction IDs, payment channel (MTN / Telecel), and order receipts. Note: We NEVER request, record, or store your 4-digit MoMo PIN.',
            ),

            _buildSection(
              '2. How We Use Your Data',
              'Your information is used strictly to:\n'
              '• Transmit order meal specifications and dish addons to the vendor’s kitchen.\n'
              '• Provide our motorbike riders with turn-by-turn dispatch navigation.\n'
              '• Send SMS order tracking updates and automated digital receipts.\n'
              '• Prevent fraud, bot abuse, and unauthorized order submissions.',
            ),

            _buildSection(
              '3. Role-Based Data Isolation',
              'Our system implements strict role-based data partitioning:\n'
              '• Riders only see your first name, delivery landmark, and contact phone until the delivery is marked completed.\n'
              '• Kitchen vendors only receive dish preparation notes and order numbers.\n'
              '• Neither riders nor vendors can access your complete order history, password hashes, or financial records.',
            ),

            _buildSection(
              '4. Cryptographic Encryption & Storage',
              'All data transmitted between your device and our cloud servers is protected with TLS 1.3 encryption. Offline cached data stored on your device utilizes secure encrypted key-value databases protected by device-level sandboxing.',
            ),

            _buildSection(
              '5. Zero Third-Party Selling',
              'ClickBites does not sell, rent, monetize, or disclose your personal information to third-party ad brokers or data marketers. Data is only shared with licensed payment gateways (MTN Mobile Money / Telecel Cash) exclusively to process meal payments.',
            ),

            _buildSection(
              '6. Your Rights & Data Deletion',
              'Under Act 843, you hold the right to request access to your stored records, rectify incorrect phone numbers, or request complete permanent deletion of your profile. To delete your account and associated records, email privacy@clickbites.com.gh with your registered phone number.',
            ),

            const SizedBox(height: 24),
            Center(
              child: Text(
                'Data Protection Officer • help@clickbitegh.com • +233535548343',
                style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String body) {
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
