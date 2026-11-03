import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Splash Screen that displays the ClickBite orange background and centered white logo
/// (identical to the first onboarding page), animates entrance, displays a smooth
/// loading indicator, and transitions to [nextScreen] after [duration].
class SplashScreen extends StatefulWidget {
  final Widget nextScreen;
  final Duration duration;

  const SplashScreen({
    super.key,
    required this.nextScreen,
    this.duration = const Duration(milliseconds: 2400),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _logoFadeController;
  late Animation<double> _logoFadeAnim;
  late Animation<double> _logoScaleAnim;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    // Entrance animation matching the onboarding splash
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

    // Auto-advance after the specified duration
    _timer = Timer(widget.duration, _navigateToNext);
  }

  void _navigateToNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            widget.nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _logoFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // Centered Animated White Logo
          Center(
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

          // Loading spinner at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 64,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.white70,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

