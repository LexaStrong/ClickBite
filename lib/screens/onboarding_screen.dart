import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'auth_screen.dart';

/// ClickBite Onboarding Flow
/// Page 0: Splash — orange background, white logo centered
/// Page 1: "Discover places around you" — store illustration
/// Page 2: "Discover tasty meals" — burger illustration
/// Page 3: "Enjoy fast delivery" — rider illustration
/// After page 3, navigates to Auth screen.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Splash auto-advance
  bool _splashDone = false;

  late AnimationController _logoFadeController;
  late Animation<double> _logoFadeAnim;
  late Animation<double> _logoScaleAnim;

  @override
  void initState() {
    super.initState();

    // Logo entrance animation
    _logoFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoFadeAnim = CurvedAnimation(
      parent: _logoFadeController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _logoScaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoFadeController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _logoFadeController.forward();

    // Auto-advance splash after 2.5s
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted && _currentPage == 0) {
        _splashDone = true;
        _pageController.animateToPage(
          1,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _logoFadeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    // Update status bar style based on page
    if (page == 0) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ));
    } else {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ));
    }
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      // Navigate to auth
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const AuthScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  void _skipToAuth() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AuthScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page View
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: _currentPage == 0 && !_splashDone
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            children: [
              _buildSplashPage(),
              _buildFeaturePage(
                imagePath: 'assets/images/onboarding_store.png',
                title: 'Discover places\naround you',
                subtitle:
                    'Browse the best restaurants and local food spots in Konongo, all in one place.',
              ),
              _buildFeaturePage(
                imagePath: 'assets/images/onboarding_burger.png',
                title: 'Discover\ntasty meals',
                subtitle:
                    'From classic Ghanaian favourites to everyday cravings, find meals you will love.',
              ),
              _buildFeaturePage(
                imagePath: 'assets/images/onboarding_rider.png',
                title: 'Enjoy fast\ndelivery',
                subtitle:
                    'Get your food delivered hot and fresh, right to your doorstep in minutes.',
              ),
            ],
          ),

          // Bottom controls (hidden on splash)
          if (_currentPage > 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomControls(),
            ),
        ],
      ),
    );
  }

  // ─── Splash Page ───────────────────────────────────────────────
  Widget _buildSplashPage() {
    return Container(
      color: AppColors.primary,
      child: Center(
        child: AnimatedBuilder(
          animation: _logoFadeController,
          builder: (context, child) {
            return Opacity(
              opacity: _logoFadeAnim.value,
              child: Transform.scale(
                scale: _logoScaleAnim.value,
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 72),
            child: Image.asset(
              'assets/images/clickbite_logo_white.png',
              fit: BoxFit.contain,
              width: 220,
            ),
          ),
        ),
      ),
    );
  }

  // ─── Feature Page ──────────────────────────────────────────────
  Widget _buildFeaturePage({
    required String imagePath,
    required String title,
    required String subtitle,
  }) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.md,
                  right: AppSpacing.lg,
                ),
                child: TextButton(
                  onPressed: _skipToAuth,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.base,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  child: Text(
                    'Skip',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),

            // Illustration
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                ),
                child: Center(
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Text Content
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl + AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                        letterSpacing: -0.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        height: 1.55,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Spacing for bottom controls
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ─── Bottom Controls ───────────────────────────────────────────
  Widget _buildBottomControls() {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xl,
        top: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background.withValues(alpha: 0.0),
            AppColors.background.withValues(alpha: 0.9),
            AppColors.background,
          ],
          stops: const [0.0, 0.3, 0.6],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Page Indicators
          Row(
            children: List.generate(3, (index) {
              final isActive = index == (_currentPage - 1);
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.only(right: 8),
                width: isActive ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),

          // Next / Get Started Button
          GestureDetector(
            onTap: _nextPage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(
                horizontal: _currentPage == 3 ? 28 : 20,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                boxShadow: AppShadows.buttonElevated,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _currentPage == 3 ? 'Get Started' : 'Next',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
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
