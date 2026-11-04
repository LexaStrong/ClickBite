import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../state/vendor_state.dart';
import '../../models/vendor_models.dart';
import '../../models/food_models.dart';
import '../../services/cache_service.dart';
import '../../widgets/bouncy_tap.dart';
import 'vendor_shell_screen.dart';

/// Helper state for configuring curated dish prices, images, and addons
class _DishCustomizationConfig {
  double price;
  bool isCustomImage;
  String customImage;
  final Set<String> addonIds;
  final Map<String, double> addonPrices;

  _DishCustomizationConfig({
    required this.price,
    this.isCustomImage = false,
    required this.customImage,
    required this.addonIds,
    required this.addonPrices,
  });
}

/// Interactive Vendor Onboarding Wizard for new Konongo restaurants
class VendorOnboardingScreen extends StatefulWidget {
  const VendorOnboardingScreen({super.key});

  @override
  State<VendorOnboardingScreen> createState() => _VendorOnboardingScreenState();
}

class _VendorOnboardingScreenState extends State<VendorOnboardingScreen> {
  int _currentStep = 0;

  // Step 1 Controllers
  final _nameController = TextEditingController(text: "Auntie Akua's Konongo Spot");
  final _ownerController = TextEditingController(text: 'Akua Mansa');
  final _phoneController = TextEditingController(text: '+233 24 551 8920');
  final _momoController = TextEditingController(text: '0245518920');
  String _selectedLocation = 'Post Office Rd, Konongo';

  // Step 2: Food Categories Selection
  final Set<String> _selectedCategories = {'Jollof Bowls', 'Grills & Fish', 'Local Soups'};

  final List<String> _availableCategories = const [
    'Jollof Bowls',
    'Grills & Fish',
    'Local Soups',
    'Street Waakye',
    'Comfort Stews',
    'Artisan Pizza',
    'Ghanaian Breakfast',
    'Chilled Beverages',
  ];

  // Step 3: Addons Selection (Includes Soft Drinks and Bottled Water)
  final Set<String> _selectedAddonIds = {
    'add-1',
    'add-2',
    'add-3',
    'add-4',
    'add-6',
    'add-9',
    'add-10',
  };

  // Step 4: Curated Gallery Selection & Per-Dish Configurations
  final Set<String> _selectedGalleryItemIds = {'gal-1', 'gal-2', 'gal-3', 'gal-4'};
  final Map<String, _DishCustomizationConfig> _dishConfigs = {};

  _DishCustomizationConfig _getDishConfig(CuratedFoodGalleryItem item) {
    return _dishConfigs.putIfAbsent(
      item.id,
      () => _DishCustomizationConfig(
        price: item.defaultPrice,
        isCustomImage: false,
        customImage: item.imageAsset,
        addonIds: Set.from(_selectedAddonIds),
        addonPrices: {
          for (final a in VendorState().availableAddons) a.id: a.price,
        },
      ),
    );
  }

  // Eatery Banner Selection
  String _selectedBannerAsset = 'assets/images/jollof_rice.webp';

  final List<Map<String, String>> _bannerOptions = const [
    {
      'title': 'Firewood Jollof & Spiced Chicken',
      'asset': 'assets/images/jollof_rice.webp',
      'subtitle': 'Warm smoky terracotta tones & rich spice presentation',
    },
    {
      'title': 'Pounded Fufu & Goat Light Soup',
      'asset': 'assets/images/fufu_soup.webp',
      'subtitle': 'Authentic mortar & pestle feast with rich soup broth',
    },
    {
      'title': 'Volta Charcoal Tilapia & Banku',
      'asset': 'assets/images/grilled_tilapia.webp',
      'subtitle': 'Fresh river catch with hot shito and green pepper relish',
    },
    {
      'title': 'Royal Waakye & Shito Feast',
      'asset': 'assets/images/waakye.webp',
      'subtitle': 'Brown rice, spaghetti, gari fortor & seasoned wele',
    },
    {
      'title': 'Red Red Stew & Golden Plantains',
      'asset': 'assets/images/red_red.webp',
      'subtitle': 'Caramelized sweet plantains with palm oil bean stew',
    },
    {
      'title': 'Ampesi & Kontommire Stew',
      'asset': 'assets/images/ampesi_kontommire.webp',
      'subtitle': 'Boiled yam and plantain with rich cocoyam leaf stew',
    },
    {
      'title': 'Assorted Fried Rice Platter',
      'asset': 'assets/images/assorted fried_rice.webp',
      'subtitle': 'Seasoned rice with mixed vegetables, chicken, and shrimp',
    },
    {
      'title': 'Assorted Jollof Rice Supreme',
      'asset': 'assets/images/assorted_jollof.webp',
      'subtitle': 'Party-style smoky jollof with assorted meats and kelewele',
    },
    {
      'title': 'Kokonte & Groundnut Soup',
      'asset': 'assets/images/kokonte_soup.webp',
      'subtitle': 'Smooth dried cassava kokonte with rich groundnut soup',
    },
    {
      'title': 'Grilled Shawarma Wrap',
      'asset': 'assets/images/shawarma.webp',
      'subtitle': 'Spiced grilled chicken shawarma with garlic sauce and fries',
    },
    {
      'title': 'Tuo Zaafi & Ayoyo Soup',
      'asset': 'assets/images/tuo_zaafi.webp',
      'subtitle': 'Northern Ghana tuo zaafi with slimy ayoyo and dawadawa',
    },
    {
      'title': 'Supreme Waakye Festival',
      'asset': 'assets/images/waakye_2.webp',
      'subtitle': 'Premium waakye overload with extra wele and fried fish',
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _ownerController.dispose();
    _phoneController.dispose();
    _momoController.dispose();
    super.dispose();
  }

  void _submitOnboarding() {
    final vendor = VendorState();

    final chosenDishes = <CustomizedVendorDish>[];

    for (final itemId in _selectedGalleryItemIds) {
      final curated = vendor.curatedGallery.firstWhere(
        (item) => item.id == itemId,
        orElse: () => vendor.curatedGallery.first,
      );

      final config = _getDishConfig(curated);

      // Collect configured addons for this meal
      final dishAddons = <DishAddon>[];
      for (final addonId in config.addonIds) {
        final opt = vendor.availableAddons.firstWhere(
          (a) => a.id == addonId,
          orElse: () => VendorAddonOption(id: addonId, name: 'Addon', price: 5.0),
        );
        final customPrice = config.addonPrices[addonId] ?? opt.price;
        String cat = 'side';
        if (opt.id == 'add-4' || opt.id == 'add-5') cat = 'protein';
        if (opt.id == 'add-2') cat = 'protein';
        if (opt.id == 'add-3') cat = 'sauce';
        if (opt.id == 'add-9' || opt.id == 'add-10') cat = 'drink';

        dishAddons.add(DishAddon(
          id: opt.id,
          name: opt.name,
          price: customPrice,
          category: cat,
          imageAsset: null,
          quantity: 1,
        ));
      }

      chosenDishes.add(CustomizedVendorDish(
        id: 'custom-${curated.id}-${DateTime.now().millisecondsSinceEpoch}',
        curatedItemId: curated.id,
        title: curated.title,
        category: curated.category,
        imageAsset: config.isCustomImage ? config.customImage : curated.imageAsset,
        isCustomImage: config.isCustomImage,
        price: config.price,
        description: curated.description,
        selectedAddons: dishAddons,
        isAvailable: true,
      ));
    }

    final chosenAddons = vendor.availableAddons
        .where((item) => _selectedAddonIds.contains(item.id))
        .toList();

    vendor.onboardNewKitchen(
      restaurantName: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : 'Nana Kitchen',
      ownerName: _ownerController.text.trim().isNotEmpty
          ? _ownerController.text.trim()
          : 'Akua Mansa',
      phone: _phoneController.text,
      momoNumber: _momoController.text,
      address: _selectedLocation,
      cuisineSummary: _selectedCategories.join(' • '),
      bannerAsset: _selectedBannerAsset,
      customizedDishes: chosenDishes,
      selectedAddons: chosenAddons,
    );

    CacheService().setVendorOnboarded(true);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const VendorShellScreen()),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${_nameController.text} is now LIVE on ClickBite Konongo! You can edit meals anytime from the My Meals tab.',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Vendor Onboarding',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Step Bar
            _buildProgressBar(),

            // Wizard Step Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.base),
                child: _buildStepContent(),
              ),
            ),

            // Bottom Navigation Controls
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(4, (index) {
          final isCompleted = index <= _currentStep;
          final isCurrent = index == _currentStep;

          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.primary : AppColors.surfaceElevated,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isCompleted ? Colors.white : AppColors.textTertiary,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                if (index < 3)
                  Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      color: isCurrent || index < _currentStep ? AppColors.primary : AppColors.border,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    if (_currentStep == 0) return _buildStep1Profile();
    if (_currentStep == 1) return _buildStep2Categories();
    if (_currentStep == 2) return _buildStep3Addons();
    return _buildStep4Gallery();
  }

  // Step 1: Restaurant Info & Location
  Widget _buildStep1Profile() {
    final konongoSpots = [
      'Post Office Rd, Konongo',
      'Konongo Lorry Station Hub',
      'Low Cost Residential, Konongo',
      'Market Circle, Konongo',
      'High Street, Konongo Central',
      'Anyaano Junction, Konongo',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 1: Kitchen Details',
          style: GoogleFonts.playfairDisplay(fontSize: 19, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          'Provide your kitchen credentials and Konongo address for local couriers.',
          style: AppTypography.caption(context).copyWith(fontSize: 12),
        ),
        const SizedBox(height: 18),

        _buildTextField(label: 'Restaurant / Kitchen Name', controller: _nameController, icon: Icons.storefront_rounded),
        const SizedBox(height: 14),
        _buildTextField(label: 'Owner / Head Cook Name', controller: _ownerController, icon: Icons.person_outline_rounded),
        const SizedBox(height: 14),
        _buildTextField(label: 'Contact Phone Number', controller: _phoneController, icon: Icons.phone_outlined),
        const SizedBox(height: 14),
        _buildTextField(label: 'Mobile Money Number (For Payouts)', controller: _momoController, icon: Icons.payments_outlined),
        const SizedBox(height: 14),

        const Text('Konongo Location / Hub', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedLocation,
              isExpanded: true,
              items: konongoSpots.map((spot) {
                return DropdownMenuItem(value: spot, child: Text(spot, style: const TextStyle(fontSize: 13)));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedLocation = val);
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Divider(height: 1),
        const SizedBox(height: 18),

        // Eatery Banner Selector Headline
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Dedicated Eatery Banner',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primarySubtle,
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: const Text(
                'Public Page Banner',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Select the high-resolution photo banner that appears at the top of your dedicated restaurant page.',
          style: AppTypography.caption(context).copyWith(fontSize: 12),
        ),
        const SizedBox(height: 14),

        // Live Banner Preview
        _buildBannerLivePreview(),
        const SizedBox(height: 14),

        // Banner Choices List
        _buildBannerOptionsList(),
      ],
    );
  }

  Widget _buildBannerLivePreview() {
    final currentTitle = _bannerOptions.firstWhere(
      (b) => b['asset'] == _selectedBannerAsset,
      orElse: () => _bannerOptions.first,
    )['title']!;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Image.asset(
            _selectedBannerAsset,
            height: 135,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          // Dark gradient overlay
          Container(
            height: 135,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: const Text(
                'LIVE PAGE BANNER PREVIEW',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 9,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 14,
            right: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _nameController.text.trim().isNotEmpty
                      ? _nameController.text.trim()
                      : "Your Kitchen / Eatery",
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Theme: $currentTitle',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerOptionsList() {
    return Column(
      children: _bannerOptions.map((option) {
        final isSelected = _selectedBannerAsset == option['asset'];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected ? AppShadows.soft : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => setState(() => _selectedBannerAsset = option['asset']!),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Image.asset(
                      option['asset']!,
                      width: 64,
                      height: 52,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option['title']!,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                            fontSize: 12.5,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          option['subtitle']!,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    color: isSelected ? AppColors.primary : AppColors.textTertiary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Step 2: Kinds of Food to be Served
  Widget _buildStep2Categories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 2: Choose Kinds of Food',
          style: GoogleFonts.playfairDisplay(fontSize: 19, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          'Select the food categories your kitchen will prepare for customers.',
          style: AppTypography.caption(context).copyWith(fontSize: 12),
        ),
        const SizedBox(height: 18),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _availableCategories.map((cat) {
            final isSelected = _selectedCategories.contains(cat);
            return BouncyTap(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    if (_selectedCategories.length > 1) _selectedCategories.remove(cat);
                  } else {
                    _selectedCategories.add(cat);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                  boxShadow: isSelected ? AppShadows.buttonElevated : AppShadows.soft,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Step 3: Addons & Modifiers Selection
  Widget _buildStep3Addons() {
    final vendor = VendorState();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 3: Select Available Add-ons',
          style: GoogleFonts.playfairDisplay(fontSize: 19, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          'Configure optional side items and extras customers can add to their meal.',
          style: AppTypography.caption(context).copyWith(fontSize: 12),
        ),
        const SizedBox(height: 18),

        ...vendor.availableAddons.map((addon) {
          final isSelected = _selectedAddonIds.contains(addon.id);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: isSelected,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedAddonIds.add(addon.id);
                      } else {
                        _selectedAddonIds.remove(addon.id);
                      }
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    addon.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                Text(
                  '+GH₵${addon.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 13),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // Step 4: Curated Food Image Gallery & Dish Customization
  Widget _buildStep4Gallery() {
    final vendor = VendorState();

    // Filter curated dishes based on selected categories from Step 2
    final matchingDishes = vendor.curatedGallery.where((item) {
      if (_selectedCategories.isEmpty) return true;
      return _selectedCategories.any((cat) =>
          cat.toLowerCase().contains(item.category.toLowerCase()) ||
          item.category.toLowerCase().contains(cat.toLowerCase()) ||
          (cat.contains('Jollof') && item.title.contains('Jollof')) ||
          (cat.contains('Fish') && item.title.contains('Tilapia')) ||
          (cat.contains('Waakye') && item.title.contains('Waakye')) ||
          (cat.contains('Soup') && item.category.contains('Soup')));
    }).toList();

    final displayItems =
        matchingDishes.isNotEmpty ? matchingDishes : vendor.curatedGallery;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 4: Curated Dishes & Pricing',
          style: GoogleFonts.playfairDisplay(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          'Customize prices, configure add-ons & add-on pricing, and select curated or custom photos for each meal.',
          style: AppTypography.caption(context).copyWith(fontSize: 12),
        ),
        const SizedBox(height: 12),

        // Cuisines indicator badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primarySubtle.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              const Icon(Icons.restaurant_rounded,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cuisines: ${_selectedCategories.join(', ')}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${displayItems.length} available',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        ...displayItems.map((item) {
          final isSelected = _selectedGalleryItemIds.contains(item.id);
          final config = _getDishConfig(item);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: isSelected ? AppShadows.card : AppShadows.soft,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dish Image Header
                Stack(
                  children: [
                    Image.asset(
                      config.isCustomImage
                          ? config.customImage
                          : item.imageAsset,
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 130,
                        color: AppColors.surfaceElevated,
                        child: const Center(
                          child: Icon(Icons.fastfood_rounded,
                              size: 36, color: AppColors.primary),
                        ),
                      ),
                    ),
                    // Image Badge
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: config.isCustomImage
                              ? AppColors.accent
                              : Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: Text(
                          config.isCustomImage
                              ? 'CUSTOM PHOTO'
                              : 'CURATED PHOTO',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                    // Category Badge
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          item.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Main Info Row & Selection Toggle
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.description,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      BouncyTap(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedGalleryItemIds.remove(item.id);
                            } else {
                              _selectedGalleryItemIds.add(item.id);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surfaceElevated,
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.check_rounded
                                    : Icons.add_rounded,
                                size: 14,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isSelected ? 'Selected' : 'Select Dish',
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Expanded Customization Section if Selected
                if (isSelected) ...[
                  const Divider(height: 1),
                  Container(
                    color: AppColors.surfaceElevated.withValues(alpha: 0.4),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Price Adjustment Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Your Menu Price:',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12.5,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Row(
                              children: [
                                BouncyTap(
                                  onTap: () {
                                    if (config.price > 5) {
                                      setState(() => config.price -= 5);
                                    }
                                  },
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppColors.border),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.remove_rounded,
                                          size: 16,
                                          color: AppColors.primary),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    'GH₵${config.price.toStringAsFixed(2)}',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                BouncyTap(
                                  onTap: () {
                                    setState(() => config.price += 5);
                                  },
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.add_rounded,
                                          size: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // 2. Photo Decision (Curated vs Custom)
                        const Text(
                          'Food Photo:',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            BouncyTap(
                              onTap: () => setState(
                                  () => config.isCustomImage = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: !config.isCustomImage
                                      ? AppColors.primary
                                      : AppColors.surface,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                  border: Border.all(
                                    color: !config.isCustomImage
                                        ? AppColors.primary
                                        : AppColors.border,
                                  ),
                                ),
                                child: Text(
                                  'Use Curated Photo',
                                  style: TextStyle(
                                    color: !config.isCustomImage
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            BouncyTap(
                              onTap: () => setState(
                                  () => config.isCustomImage = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: config.isCustomImage
                                      ? AppColors.primary
                                      : AppColors.surface,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                  border: Border.all(
                                    color: config.isCustomImage
                                        ? AppColors.primary
                                        : AppColors.border,
                                  ),
                                ),
                                child: Text(
                                  'Pick Alternative Photo',
                                  style: TextStyle(
                                    color: config.isCustomImage
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Alternative Photos Palette if Custom Selected
                        if (config.isCustomImage) ...[
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: [
                                'assets/images/jollof_rice.webp',
                                'assets/images/fufu_soup.webp',
                                'assets/images/grilled_tilapia.webp',
                                'assets/images/waakye.webp',
                                'assets/images/red_red.webp',
                                'assets/images/ampesi_kontommire.webp',
                                'assets/images/assorted fried_rice.webp',
                                'assets/images/assorted_jollof.webp',
                                'assets/images/kokonte_soup.webp',
                                'assets/images/shawarma.webp',
                                'assets/images/tuo_zaafi.webp',
                                'assets/images/waakye_2.webp',
                              ].map((assetPath) {
                                final isCurSelected =
                                    config.customImage == assetPath;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: InkWell(
                                    onTap: () => setState(() =>
                                        config.customImage = assetPath),
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.sm),
                                        border: Border.all(
                                          color: isCurSelected
                                              ? AppColors.primary
                                              : AppColors.border,
                                          width: isCurSelected ? 2 : 1,
                                        ),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Image.asset(assetPath,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),

                        // 3. Add-ons & Custom Addon Pricing for this Meal
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Add-ons for this Meal:',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${config.addonIds.length} enabled',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Only selected add-ons will appear on the customer meal sheet with your pricing.',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Addons check & price adjuster list
                        ...vendor.availableAddons.map((addon) {
                          final isAddonActive =
                              config.addonIds.contains(addon.id);
                          final currentPrice =
                              config.addonPrices[addon.id] ?? addon.price;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isAddonActive
                                  ? AppColors.primarySubtle
                                      .withValues(alpha: 0.35)
                                  : AppColors.surface,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: isAddonActive
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isAddonActive,
                                  activeColor: AppColors.primary,
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        config.addonIds.add(addon.id);
                                        config.addonPrices[addon.id] =
                                            addon.price;
                                      } else {
                                        config.addonIds.remove(addon.id);
                                      }
                                    });
                                  },
                                ),
                                Expanded(
                                  child: Text(
                                    addon.name,
                                    style: TextStyle(
                                      fontWeight: isAddonActive
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                if (isAddonActive)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      BouncyTap(
                                        onTap: () {
                                          if (currentPrice > 1) {
                                            setState(() =>
                                                config.addonPrices[addon.id] =
                                                    currentPrice - 1);
                                          }
                                        },
                                        child: Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            color: AppColors.surface,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: AppColors.border),
                                          ),
                                          child: const Center(
                                            child: Icon(
                                                Icons.remove_rounded,
                                                size: 12,
                                                color: AppColors.primary),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6),
                                        child: Text(
                                          'GH₵${currentPrice.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.primary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      BouncyTap(
                                        onTap: () {
                                          setState(() =>
                                              config.addonPrices[addon.id] =
                                                  currentPrice + 1);
                                        },
                                        child: Container(
                                          width: 22,
                                          height: 22,
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Center(
                                            child: Icon(Icons.add_rounded,
                                                size: 12,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Text(
                                    '+GH₵${addon.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: AppColors.textTertiary,
                                      fontSize: 11.5,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
      ],
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.floatingNav,
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: BouncyTap(
                  onTap: () => setState(() => _currentStep--),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Center(
                      child: Text(
                        'Back',
                        style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            flex: 2,
            child: BouncyTap(
              onTap: () {
                if (_currentStep < 3) {
                  setState(() => _currentStep++);
                } else {
                  _submitOnboarding();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  boxShadow: AppShadows.buttonElevated,
                ),
                child: Center(
                  child: Text(
                    _currentStep == 3 ? 'Publish & Launch Kitchen' : 'Next Step',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13.5),
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
