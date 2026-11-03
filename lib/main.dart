import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/vendor/vendor_shell_screen.dart';
import 'screens/vendor/vendor_onboarding_screen.dart';
import 'services/telemetry_service.dart';
import 'services/cache_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  TelemetryService().initialize();
  await CacheService().init();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization info: $e');
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const ClickBitesApp());
}

class ClickBitesApp extends StatelessWidget {
  const ClickBitesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClickBite',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.light,
      home: const AppRoot(),
    );
  }
}

/// Root widget that dynamically routes to the appropriate screen
/// without losing user sessions or repeating onboarding on app reopen.
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final cache = CacheService();
    final session = cache.getCachedSession();

    // 1. If an active session exists, show the animated splash screen with logo first before loading home
    if (session != null && !session.isExpired) {
      final targetScreen = session.isVendor
          ? (cache.isVendorOnboarded()
              ? const VendorShellScreen()
              : const VendorOnboardingScreen())
          : const HomeScreen();

      return SplashScreen(nextScreen: targetScreen);
    }

    // 2. If user already saw onboarding intro, take them straight to Auth
    if (cache.hasSeenOnboarding()) {
      return const AuthScreen();
    }

    // 3. First time app install/launch: show the onboarding carousel
    return const OnboardingScreen();
  }
}
