import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/location_service.dart';
import '../services/security_service.dart';
import '../services/cache_service.dart';
import '../services/firebase_auth_service.dart';
import 'home_screen.dart';
import 'vendor/vendor_shell_screen.dart';
import 'vendor/vendor_onboarding_screen.dart';

/// Mandatory Live Location Confirmation Screen
/// Displayed after successful sign-up. Ensures every customer has a confirmed
/// delivery landmark in Konongo before accessing the app.
class LiveLocationScreen extends StatefulWidget {
  final bool isVendor;
  final bool isMandatory;

  const LiveLocationScreen({
    super.key,
    this.isVendor = false,
    this.isMandatory = true,
  });

  @override
  State<LiveLocationScreen> createState() => _LiveLocationScreenState();
}

class _LiveLocationScreenState extends State<LiveLocationScreen>
    with SingleTickerProviderStateMixin {
  final LocationService _locationService = LocationService();
  final SecurityService _securityService = SecurityService();
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  final CacheService _cacheService = CacheService();

  late KonongoLocation _selectedLocation;
  final TextEditingController _customNoteController = TextEditingController();

  late AnimationController _radarController;
  bool _isScanning = true;
  String _statusText = 'Pinpointing GPS location in Konongo...';

  @override
  void initState() {
    super.initState();
    _selectedLocation = _locationService.currentLocation;

    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _runLocationScan();
  }

  @override
  void dispose() {
    _radarController.dispose();
    _customNoteController.dispose();
    super.dispose();
  }

  Future<void> _runLocationScan() async {
    setState(() {
      _isScanning = true;
      _statusText = 'Scanning Ashanti GPS satellites...';
    });

    await Future.delayed(const Duration(milliseconds: 1400));
    await _locationService.detectCurrentLocation();

    if (mounted) {
      setState(() {
        _selectedLocation = _locationService.currentLocation;
        _isScanning = false;
        _statusText = 'Live Location Acquired (Accuracy: ±5m)';
      });
    }
  }

  Future<void> _confirmAndProceed() async {
    final note = _customNoteController.text.trim();
    final fullAddress = note.isNotEmpty
        ? '${_selectedLocation.name} ($note)'
        : _selectedLocation.name;

    // 1. Update LocationService
    _locationService.setLocation(_selectedLocation);

    // 2. Cache location & address
    await _cacheService.cacheLocation(_selectedLocation);

    // 3. Update active session & Firestore profile
    _securityService.updateSessionProfile(address: fullAddress);

    final currentUser = _securityService.currentSession;
    if (currentUser != null) {
      await _firebaseAuthService.updateUserProfile(
        fullName: currentUser.fullName,
        phone: currentUser.phone,
        address: fullAddress,
      );
    }

    if (!mounted) return;

    // Navigate to Home or Vendor
    final Widget destination = widget.isVendor
        ? (_cacheService.isVendorOnboarded()
            ? const VendorShellScreen()
            : const VendorOnboardingScreen())
        : const HomeScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.isMandatory,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.xl),

                      // Brand badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primarySubtle,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🇬🇭', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              'Konongo Live Geo-Verification',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      Text(
                        'Set Your Delivery Spot',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ClickBite riders use your live spot to ensure fast delivery right to your door in Konongo.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.45,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Animated Radar / Location Visualizer
                      _buildRadarVisualizer(),

                      const SizedBox(height: AppSpacing.lg),

                      // Status pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: _isScanning
                              ? AppColors.primarySubtle
                              : AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(
                            color: _isScanning
                                ? AppColors.primary.withValues(alpha: 0.3)
                                : AppColors.success.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _isScanning ? AppColors.primary : AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _statusText,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _isScanning ? AppColors.primary : AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Landmark Selection Header
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Choose Your Primary Konongo Landmark:',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Landmark selection cards
                      ...LocationService.konongoLandmarks.map((loc) {
                        final isSelected = _selectedLocation.name == loc.name;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primarySubtle
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: isSelected ? 1.8 : 1,
                            ),
                            boxShadow: isSelected ? AppShadows.soft : null,
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedLocation = loc;
                              });
                            },
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked_rounded
                                        : Icons.radio_button_off_rounded,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textTertiary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          loc.name,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          '${loc.area} • ~${loc.deliveryMinutes} mins delivery',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${loc.distanceKm} km',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 12),

                      // Optional street / house / landmark note
                      TextFormField(
                        controller: _customNoteController,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Add house no., gate color or street note (Optional)',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: AppColors.textTertiary,
                          ),
                          prefixIcon: const Icon(
                            Icons.home_work_outlined,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          filled: true,
                          fillColor: AppColors.surface,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),

              // Bottom Confirmation Button
              Container(
                padding: EdgeInsets.only(
                  left: AppSpacing.xl,
                  right: AppSpacing.xl,
                  top: AppSpacing.md,
                  bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: AppShadows.card,
                  border: const Border(top: BorderSide(color: AppColors.border)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _confirmAndProceed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Confirm Location & Enter App',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadarVisualizer() {
    return SizedBox(
      height: 120,
      width: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _radarController,
            builder: (context, child) {
              return Container(
                width: 120 * _radarController.value,
                height: 120 * _radarController.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(
                    alpha: (1.0 - _radarController.value) * 0.35,
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _radarController,
            builder: (context, child) {
              final val = (_radarController.value + 0.5) % 1.0;
              return Container(
                width: 120 * val,
                height: 120 * val,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(
                    alpha: (1.0 - val) * 0.25,
                  ),
                ),
              );
            },
          ),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: AppShadows.buttonElevated,
            ),
            child: const Icon(
              Icons.my_location_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
