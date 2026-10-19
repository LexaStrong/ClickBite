import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../state/vendor_state.dart';
import '../../widgets/bouncy_tap.dart';

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

  // Step 3: Addons Selection
  final Set<String> _selectedAddonIds = {'add-1', 'add-2', 'add-3', 'add-4', 'add-6'};

  // Step 4: Curated Gallery Selection
  final Set<String> _selectedGalleryItemIds = {'gal-1', 'gal-2', 'gal-3', 'gal-4'};

  // Eatery Banner Selection
  String _selectedBannerAsset = 'assets/images/jollof_rice.png';

  final List<Map<String, String>> _bannerOptions = const [
    {
      'title': 'Firewood Jollof & Spiced Chicken',
      'asset': 'assets/images/jollof_rice.png',
      'subtitle': 'Warm smoky terracotta tones & rich spice presentation',
    },
    {
      'title': 'Pounded Fufu & Goat Light Soup',
      'asset': 'assets/images/fufu_soup.png',
      'subtitle': 'Authentic mortar & pestle feast with rich soup broth',
    },
    {
      'title': 'Volta Charcoal Tilapia & Banku',
      'asset': 'assets/images/grilled_tilapia.png',
      'subtitle': 'Fresh river catch with hot shito and green pepper relish',
    },
    {
      'title': 'Royal Waakye & Shito Feast',
      'asset': 'assets/images/waakye.png',
      'subtitle': 'Brown rice, spaghetti, gari fortor & seasoned wele',
    },
    {
      'title': 'Red Red Stew & Golden Plantains',
      'asset': 'assets/images/red_red.png',
      'subtitle': 'Caramelized sweet plantains with palm oil bean stew',
    },
    {
      'title': 'Ampesi & Kontommire Stew',
      'asset': 'assets/images/ampesi_kontommire.png',
      'subtitle': 'Boiled yam and plantain with rich cocoyam leaf stew',
    },
    {
      'title': 'Assorted Fried Rice Platter',
      'asset': 'assets/images/assorted fried_rice.png',
      'subtitle': 'Seasoned rice with mixed vegetables, chicken, and shrimp',
    },
    {
      'title': 'Assorted Jollof Rice Supreme',
      'asset': 'assets/images/assorted_jollof.png',
      'subtitle': 'Party-style smoky jollof with assorted meats and kelewele',
    },
    {
      'title': 'Kokonte & Groundnut Soup',
      'asset': 'assets/images/kokonte_soup.png',
      'subtitle': 'Smooth dried cassava kokonte with rich groundnut soup',
    },
    {
      'title': 'Grilled Shawarma Wrap',
      'asset': 'assets/images/shawarma.png',
      'subtitle': 'Spiced grilled chicken shawarma with garlic sauce and fries',
    },
    {
      'title': 'Tuo Zaafi & Ayoyo Soup',
      'asset': 'assets/images/tuo_zaafi.png',
      'subtitle': 'Northern Ghana tuo zaafi with slimy ayoyo and dawadawa',
    },
    {
      'title': 'Supreme Waakye Festival',
      'asset': 'assets/images/waakye_2.png',
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

    final chosenGalleryItems = vendor.curatedGallery
        .where((item) => _selectedGalleryItemIds.contains(item.id))
        .toList();

    final chosenAddons = vendor.availableAddons
        .where((item) => _selectedAddonIds.contains(item.id))
        .toList();

    vendor.onboardNewKitchen(
      restaurantName: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Nana Kitchen',
      ownerName: _ownerController.text.trim().isNotEmpty ? _ownerController.text.trim() : 'Akua Mansa',
      phone: _phoneController.text,
      momoNumber: _momoController.text,
      address: _selectedLocation,
      cuisineSummary: _selectedCategories.join(' • '),
      bannerAsset: _selectedBannerAsset,
      selectedDishes: chosenGalleryItems,
      selectedAddons: chosenAddons,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${_nameController.text} is now LIVE on ClickBite Konongo!',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
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

  // Step 4: Curated Food Image Gallery
  Widget _buildStep4Gallery() {
    final vendor = VendorState();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 4: Select Curated Dishes',
          style: GoogleFonts.playfairDisplay(fontSize: 19, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          'Pick from our curated gallery of authentic food photos to feature on your menu.',
          style: AppTypography.caption(context).copyWith(fontSize: 12),
        ),
        const SizedBox(height: 18),

        ...vendor.curatedGallery.map((item) {
          final isSelected = _selectedGalleryItemIds.contains(item.id);

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: AppShadows.card,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Image.asset(
                      item.imageAsset,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSelected ? Icons.check_rounded : Icons.add_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          item.category,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.description,
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
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
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primarySubtle : AppColors.primary,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            isSelected ? 'Selected' : 'Select Dish',
                            style: TextStyle(
                              color: isSelected ? AppColors.primary : Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
