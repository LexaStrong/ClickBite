import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickbites/theme/app_theme.dart';
import 'package:clickbites/data/sample_data.dart';
import 'package:clickbites/models/food_models.dart';
import 'package:clickbites/state/cart_state.dart';
import 'package:clickbites/services/security_service.dart';
import 'package:clickbites/services/database_sync_service.dart';
import 'package:clickbites/screens/legal/about_us_screen.dart';
import 'package:clickbites/screens/legal/terms_of_service_screen.dart';
import 'package:clickbites/screens/legal/privacy_policy_screen.dart';
import 'package:clickbites/widgets/section_header.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  test('ClickBites data models and categories are loaded properly', () {
    expect(sampleCategories.isNotEmpty, true);
    expect(sampleFoodItems.length, 40);
    expect(sampleRestaurants.length, 10);
    expect(sampleFoodItems.first.name, 'Smoky Jollof & Grilled Chicken');
    expect(sampleRestaurants.first.name, "Nana's Kitchen Konongo");
    expect(sampleCategories.first.name, 'Jollof Bowls');
    expect(sampleCategories.any((c) => c.id == 'snacks'), true);
    expect(sampleCategories.any((c) => c.id == 'drinks'), true);
    expect(AppColors.primary, const Color(0xFFBD532B));
    expect(AppColors.background, const Color(0xFFF6EFE8));

    // Verify all food items have valid image assets (.png or .jpg)
    for (final item in sampleFoodItems) {
      expect(item.imageAsset.startsWith('assets/images/'), true);
      expect(item.imageAsset.endsWith('.png') || item.imageAsset.endsWith('.jpg'), true);
      expect(item.price > 0, true);
    }

    // Verify all restaurants have valid image assets
    for (final r in sampleRestaurants) {
      expect(r.imageAsset.startsWith('assets/images/'), true);
      expect(r.imageAsset.endsWith('.png'), true);
      expect(r.featuredDishIds.isNotEmpty, true);
    }
  });

  testWidgets('SectionHeader widget renders with action text', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SectionHeader(
            title: 'Popular Picks',
            actionText: 'View All',
          ),
        ),
      ),
    );

    expect(find.text('Popular Picks'), findsOneWidget);
    expect(find.text('View All'), findsOneWidget);
  });

  test('CartItem and CartState properly calculate prices with Ghanaian addons', () {
    final cart = CartState();
    cart.clearCart();

    final dish = sampleFoodItems.first; // Price: 45.00
    final addonFish = standardGhanaianAddons[0]; // +10.00
    final addonEgg = standardGhanaianAddons[1]; // +3.00

    cart.addItem(
      dish,
      quantity: 2,
      selectedAddons: [addonFish, addonEgg],
      spiceLevel: 'Regular Pepper',
    );

    expect(cart.items.length, 1);
    final item = cart.items.first;
    expect(item.unitPrice, 45.00 + 10.00 + 3.00); // 58.00
    expect(item.totalPrice, 58.00 * 2); // 116.00
    expect(cart.subtotal, 116.00);
    expect(cart.total, 116.00 + 10.00); // 126.00 with flat delivery fee
  });

  test('Snacks, pastries, wines, and drinks are available as addons and calculate properly', () {
    final cart = CartState();
    cart.clearCart();

    // Verify presence of snacks and drinks in standard addons
    final snackAddon = standardGhanaianAddons.firstWhere((a) => a.category == 'snack');
    final drinkAddon = standardGhanaianAddons.firstWhere((a) => a.category == 'drink');
    expect(snackAddon.name.isNotEmpty, true);
    expect(drinkAddon.name.isNotEmpty, true);
    expect(snackAddon.imageAsset != null, true);
    expect(drinkAddon.imageAsset != null, true);

    // Pick a main dish (e.g. Banku & Okro or Jollof)
    final mainDish = sampleFoodItems.firstWhere((i) => i.id == '13'); // Banku & Fresh Okro (42.00)
    cart.addItem(
      mainDish,
      quantity: 1,
      selectedAddons: [snackAddon, drinkAddon],
      spiceLevel: 'Regular Pepper',
      notes: 'Pack pastry in warm paper wrap',
    );

    expect(cart.items.length, 1);
    final item = cart.items.first;
    expect(item.unitPrice, mainDish.price + snackAddon.price + drinkAddon.price);
    expect(item.notes, 'Pack pastry in warm paper wrap');
    expect(item.selectedAddons.length, 2);
  });

  test('SecurityService enforces password strength and Ghanaian phone validation', () {
    final sec = SecurityService();

    // Password validation tests
    expect(sec.validatePasswordStrength('short'), isNotNull);
    expect(sec.validatePasswordStrength('alllettersonly'), isNotNull);
    expect(sec.validatePasswordStrength('Password123!'), isNull);

    // Ghanaian phone validation tests
    expect(sec.isValidGhanaianPhone('0245550192'), true);
    expect(sec.isValidGhanaianPhone('+233245550192'), true);
    expect(sec.isValidGhanaianPhone('0551234567'), true);
    expect(sec.isValidGhanaianPhone('12345'), false);

    // Salted hashing determinism
    final hash1 = sec.hashPassword('SecretPass123', 'user_salt_1');
    final hash2 = sec.hashPassword('SecretPass123', 'user_salt_1');
    final hashDifferentSalt = sec.hashPassword('SecretPass123', 'user_salt_2');
    expect(hash1, hash2);
    expect(hash1 != hashDifferentSalt, true);

    // Price tampering detection
    final tampered = sec.verifyOrderPricing(
      items: [sampleFoodItems.first],
      addonsPerItem: [[]],
      quantities: [1],
      claimedSubtotal: 10.00, // Should be 45.00!
    );
    expect(tampered, false);

    final legitimate = sec.verifyOrderPricing(
      items: [sampleFoodItems.first],
      addonsPerItem: [[]],
      quantities: [1],
      claimedSubtotal: sampleFoodItems.first.price,
    );
    expect(legitimate, true);
  });

  test('DatabaseSyncService enqueues offline mutations and manages optimistic local state', () async {
    final sync = DatabaseSyncService();
    sync.clearLocalData();

    await sync.enqueueMutation(
      operation: SyncOperationType.insert,
      entityTable: 'Order',
      entityId: 'test_order_1',
      payload: {
        'customerId': 'cust_123',
        'totalAmount': 65.0,
      },
    );

    expect(sync.getLocalEntity('Order', 'test_order_1'), isNotNull);
    expect(sync.getLocalEntity('Order', 'test_order_1')!['totalAmount'], 65.0);
  });

  testWidgets('AboutUsScreen, TermsOfServiceScreen, and PrivacyPolicyScreen render properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AboutUsScreen(),
      ),
    );
    expect(find.text('About ClickBites'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: TermsOfServiceScreen(),
      ),
    );
    expect(find.text('Terms of Service'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: PrivacyPolicyScreen(),
      ),
    );
    expect(find.text('Privacy Policy'), findsOneWidget);
  });
}
