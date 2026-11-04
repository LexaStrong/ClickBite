import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'bouncy_tap.dart';

/// Single Carousel Slide Data Model
class HeroSlideData {
  final String title;
  final String subtitle;
  final String ctaText;
  final String imageAsset;
  final Color primaryColor;
  final Color secondaryColor;
  final String categoryTarget;

  const HeroSlideData({
    required this.title,
    required this.subtitle,
    required this.ctaText,
    required this.imageAsset,
    required this.primaryColor,
    required this.secondaryColor,
    required this.categoryTarget,
  });
}

/// Hero Banner featuring four distinct carousel slideshows with auto-advance,
/// smooth swipe physics, and animated pagination indicators.
class HeroBanner extends StatefulWidget {
  final Function(String category)? onSlideCtaTap;

  const HeroBanner({super.key, this.onSlideCtaTap});

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  static const List<HeroSlideData> _slides = [
    HeroSlideData(
      title: 'FRESH.\nKONONGO.\nFEARLESS.',
      subtitle: 'Firewood Jollof & Spiced Grilled Chicken',
      ctaText: 'Order Jollof',
      imageAsset: 'assets/images/jollof_rice.webp',
      primaryColor: Color(0xFFBD532B),
      secondaryColor: Color(0xFFA5411B),
      categoryTarget: 'jollof',
    ),
    HeroSlideData(
      title: 'SMOKY.\nVOLTA.\nSIZZLE.',
      subtitle: 'Fresh Grilled Tilapia with Hot Pepper Banku',
      ctaText: 'Taste Tilapia',
      imageAsset: 'assets/images/grilled_tilapia.webp',
      primaryColor: Color(0xFFA34720),
      secondaryColor: Color(0xFF8B3614),
      categoryTarget: 'grills',
    ),
    HeroSlideData(
      title: 'RICH.\nTRADITIONAL.\nSAVORY.',
      subtitle: 'Pounded Fufu in Goat Meat Light Soup',
      ctaText: 'Explore Soups',
      imageAsset: 'assets/images/fufu_soup.webp',
      primaryColor: Color(0xFFB05624),
      secondaryColor: Color(0xFF913E14),
      categoryTarget: 'soups',
    ),
    HeroSlideData(
      title: 'LOADED.\nSTREETS.\nROYAL.',
      subtitle: 'Waakye with Shito, Egg, Spaghetti & Wele',
      ctaText: 'Get Waakye',
      imageAsset: 'assets/images/waakye.webp',
      primaryColor: Color(0xFF943D1D),
      secondaryColor: Color(0xFF7A2E12),
      categoryTarget: 'jollof',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(milliseconds: 4800), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _slides.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        child: Stack(
          children: [
            // PageView Carousel
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const BouncingScrollPhysics(),
              itemCount: _slides.length,
              itemBuilder: (context, index) {
                final slide = _slides[index];
                return _buildSlide(slide);
              },
            ),

            // Pagination Dots Indicator at bottom center
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (index) {
                  final isSelected = index == _currentPage;
                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 5,
                      width: isSelected ? 20 : 6,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(HeroSlideData slide) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        // Allocate ~42% of width to the image on smaller screens, capped at 180px
        final imageWidth = (totalWidth * 0.42).clamp(130.0, 180.0);
        final isSmallScreen = totalWidth < 360;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [slide.primaryColor, slide.secondaryColor],
            ),
          ),
          child: Stack(
            children: [
              // Background subtle ambient rings
              Positioned(
                right: -40,
                top: -30,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),

              // Food Image on the right half with clean responsive boundary
              Positioned(
                right: -8,
                top: 10,
                bottom: 10,
                width: imageWidth,
                child: Transform.rotate(
                  angle: 0.03,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.xxl),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.28),
                          blurRadius: 16,
                          offset: const Offset(-4, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.xxl),
                      child: Image.asset(
                        slide.imageAsset,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

              // Left-side Content - guaranteed to stop before the food image
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                right: imageWidth + 10,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isSmallScreen ? 16 : 20,
                    14,
                    8,
                    16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Headline (Clean bold uppercase text with strong contrast)
                      Text(
                        slide.title,
                        style: AppTypography.heroTitle(context).copyWith(
                          fontSize: isSmallScreen ? 18.5 : 20.5,
                          letterSpacing: 0.2,
                          height: 1.06,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Subtitle with clean natural wrap
                      Text(
                        slide.subtitle,
                        style: AppTypography.caption(context).copyWith(
                          color: Colors.white.withValues(alpha: 0.94),
                          fontSize: isSmallScreen ? 10.5 : 11.5,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      // White Pill CTA Button with Bouncy Feedback
                      BouncyTap(
                        onTap: () {
                          widget.onSlideCtaTap?.call(slide.categoryTarget);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 6.5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                slide.ctaText,
                                style: AppTypography.button(context).copyWith(
                                  color: slide.primaryColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: slide.primaryColor,
                                size: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
