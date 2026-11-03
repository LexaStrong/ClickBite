import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/ghana_phone.dart';
import '../theme/app_theme.dart';
import '../services/security_service.dart';
import '../services/firebase_auth_service.dart';
import 'home_screen.dart';
import 'vendor/vendor_shell_screen.dart';
import 'vendor/vendor_onboarding_screen.dart';
import 'legal/terms_of_service_screen.dart';
import 'legal/privacy_policy_screen.dart';
import 'live_location_screen.dart';
import '../services/cache_service.dart';

/// ClickBite Authentication Screen
/// Clean, premium design with vendor/customer sign-in branching.
/// Features Ghanaian Phone SMS OTP verification and Email/Password credentials.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final SecurityService _security = SecurityService();
  final FirebaseAuthService _firebaseAuth = FirebaseAuthService();

  // Auth mode - default to Sign Up so every new user is welcomed with Create Account
  bool _isSignUp = true;
  bool _isVendor = false;
  bool _isPhoneAuth = false; // Default to Email & Password (SMS OTP still available)
  bool _otpSent = false;
  String? _verificationId;
  int _resendCountdown = 60;
  Timer? _countdownTimer;
  String _detectedNetwork = '';

  // Form
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _agreedToTerms = false;

  // Animation
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _fadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _resendCountdown = 60;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  void _detectNetwork(String val) {
    setState(() {
      _detectedNetwork = GhanaPhone.networkOf(val);
    });
  }

  Future<void> _socialSignIn({required bool apple}) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await _firebaseAuth.signInWithSocial(
        apple: apple,
        role: _isVendor ? UserRole.vendor : UserRole.customer,
      );
      if (!mounted) return;
      setState(() => _isLoading = false);
      _navigateToApp();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            FirebaseAuthService.friendlyAuthError(e),
            style: GoogleFonts.plusJakartaSans(),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _otpSent = false;
      _verificationId = null;
      _formKey.currentState?.reset();
    });
    _fadeController.reset();
    _fadeController.forward();
  }

  void _navigateToApp({bool? forceSignUp}) {
    final isNewAccount = forceSignUp ?? _isSignUp;
    Widget destination;
    if (_isVendor) {
      if (isNewAccount || !CacheService().isVendorOnboarded()) {
        destination = const VendorOnboardingScreen();
      } else {
        destination = const VendorShellScreen();
      }
    } else {
      destination = isNewAccount
          ? LiveLocationScreen(isVendor: false, isMandatory: true)
          : const HomeScreen();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  Future<void> _sendOtp() async {
    final rawPhone = _phoneController.text.trim();
    if (!_security.isValidGhanaianPhone(rawPhone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a valid Ghanaian phone number (e.g. 024 XXX XXXX)',
            style: GoogleFonts.plusJakartaSans(),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_isSignUp && !_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please agree to the Terms of Service & Privacy Policy',
            style: GoogleFonts.plusJakartaSans(),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    await _firebaseAuth.sendPhoneOtp(
      phoneNumber: rawPhone,
      onCodeSent: (verificationId) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _verificationId = verificationId;
          _otpSent = true;
        });
        _startCountdown();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '6-digit verification code sent to $rawPhone',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onAutoVerified: (credential) async {
        if (!mounted) return;
        setState(() => _isLoading = false);
        _navigateToApp();
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error,
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  Future<void> _verifyOtp() async {
    final code = _otpController.text.trim();
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter the full 6-digit code received via SMS',
            style: GoogleFonts.plusJakartaSans(),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _firebaseAuth.verifySmsOtp(
        verificationId: _verificationId ?? '',
        smsCode: code,
        fullName: _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : (_isVendor ? 'Vendor Partner' : 'ClickBite Customer'),
        role: _isVendor ? UserRole.vendor : UserRole.customer,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);
      _navigateToApp();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
            style: GoogleFonts.plusJakartaSans(),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _submit() async {
    if (_isPhoneAuth) {
      if (_otpSent) {
        await _verifyOtp();
      } else {
        await _sendOtp();
      }
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    if (_isSignUp && !_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please agree to the Terms of Service & Privacy Policy',
            style: GoogleFonts.plusJakartaSans(),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isSignUp) {
        await _firebaseAuth.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          role: _isVendor ? UserRole.vendor : UserRole.customer,
        );
      } else {
        await _firebaseAuth.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      if (!mounted) return;
      setState(() => _isLoading = false);
      _navigateToApp();
    } catch (firebaseErr) {
      // Graceful offline fallback to local security session
      try {
        final session = await _security.authenticate(
          email: _emailController.text,
          password: _passwordController.text,
          isVendorLogin: _isVendor,
          fullName: _nameController.text.trim().isNotEmpty
              ? _nameController.text.trim()
              : null,
          phone: _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : null,
        );

        if (!mounted) return;
        setState(() => _isLoading = false);

        if (_isVendor && !session.isVendor) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Access Denied: Account lacks vendor authorization.'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }

        _navigateToApp();
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              firebaseErr.toString().replaceAll('Exception: ', ''),
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.xxl),

                    // Logo
                    Image.asset(
                      'assets/images/clickbite_logo.png',
                      width: 160,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: AppSpacing.huge),

                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl),
                      child: Text(
                        _isSignUp ? 'Create your account' : 'Welcome back',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                          letterSpacing: -0.3,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxl),
                      child: Text(
                        _isSignUp
                            ? 'Join ClickBite to order your favourite meals in Konongo'
                            : 'Sign in to continue ordering delicious meals',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Role Switcher
                    _buildRoleSwitcher(),

                    const SizedBox(height: AppSpacing.xl),

                    // Form Card
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(AppRadius.xxl),
                          boxShadow: AppShadows.card,
                          border: Border.all(
                            color: AppColors.border,
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Auth Method Switcher
                              _buildAuthMethodSwitcher(),
                              const SizedBox(height: AppSpacing.lg),

                              if (_isPhoneAuth) ...[
                                if (!_otpSent) ...[
                                  // Name Field (Sign Up only)
                                  if (_isSignUp) ...[
                                    _buildTextField(
                                      controller: _nameController,
                                      label: _isVendor ? 'Business Name' : 'Full Name',
                                      hint: _isVendor
                                          ? 'e.g. Auntie Ama\'s Kitchen'
                                          : 'Enter your full name',
                                      icon: Icons.person_outline_rounded,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Please enter your name';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: AppSpacing.base),
                                  ],

                                  // Ghanaian Phone Number Field
                                  _buildPhoneField(),
                                ] else ...[
                                  // OTP Verification Banner & 6-Digit Code Input
                                  _buildOtpVerificationSection(),
                                ],
                              ] else ...[
                                // Name Field (Sign Up only)
                                if (_isSignUp) ...[
                                  _buildTextField(
                                    controller: _nameController,
                                    label: _isVendor
                                        ? 'Business Name'
                                        : 'Full Name',
                                    hint: _isVendor
                                        ? 'e.g. Auntie Ama\'s Kitchen'
                                        : 'Enter your full name',
                                    icon: Icons.person_outline_rounded,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter your name';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.base),
                                ],

                                // Phone Field (Sign Up only)
                                if (_isSignUp) ...[
                                  _buildTextField(
                                    controller: _phoneController,
                                    label: 'Phone Number',
                                    hint: '024 XXX XXXX',
                                    icon: Icons.phone_outlined,
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter your phone number';
                                      }
                                      if (value.trim().length < 10) {
                                        return 'Enter a valid phone number';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.base),
                                ],

                                // Email Field
                                _buildTextField(
                                  controller: _emailController,
                                  label: 'Email Address',
                                  hint: 'you@example.com',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!RegExp(
                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                        .hasMatch(value)) {
                                      return 'Enter a valid email address';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppSpacing.base),

                                // Password Field
                                _buildTextField(
                                  controller: _passwordController,
                                  label: 'Password',
                                  hint: 'Min. 8 characters',
                                  icon: Icons.lock_outline_rounded,
                                  isPassword: true,
                                  obscure: _obscurePassword,
                                  onToggleObscure: () {
                                    setState(() =>
                                        _obscurePassword = !_obscurePassword);
                                  },
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    if (value.length < 8) {
                                      return 'Password must be at least 8 characters';
                                    }
                                    if (_isSignUp) {
                                      if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                        return 'Include at least one uppercase letter';
                                      }
                                      if (!RegExp(r'[0-9]').hasMatch(value)) {
                                        return 'Include at least one number';
                                      }
                                    }
                                    return null;
                                  },
                                ),

                                // Confirm Password (Sign Up only)
                                if (_isSignUp) ...[
                                  const SizedBox(height: AppSpacing.base),
                                  _buildTextField(
                                    controller: _confirmPasswordController,
                                    label: 'Confirm Password',
                                    hint: 'Re-enter your password',
                                    icon: Icons.lock_outline_rounded,
                                    isPassword: true,
                                    obscure: _obscureConfirmPassword,
                                    onToggleObscure: () {
                                      setState(() =>
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword);
                                    },
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please confirm your password';
                                      }
                                      if (value != _passwordController.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                  ),
                                ],

                                // Forgot Password (Sign In only)
                                if (!_isSignUp) ...[
                                  const SizedBox(height: AppSpacing.sm),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {},
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.xs,
                                          vertical: AppSpacing.xs,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        'Forgot password?',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],

                              // Terms checkbox (Sign Up only)
                              if (_isSignUp) ...[
                                const SizedBox(height: AppSpacing.base),
                                GestureDetector(
                                  onTap: () {
                                    setState(() =>
                                        _agreedToTerms =
                                            !_agreedToTerms);
                                  },
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(
                                            milliseconds: 200),
                                        width: 22,
                                        height: 22,
                                        margin:
                                            const EdgeInsets.only(
                                                top: 1),
                                        decoration: BoxDecoration(
                                          color: _agreedToTerms
                                              ? AppColors.primary
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(
                                                  6),
                                          border: Border.all(
                                            color: _agreedToTerms
                                                ? AppColors.primary
                                                : AppColors
                                                    .textTertiary,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: _agreedToTerms
                                            ? const Icon(
                                                Icons.check_rounded,
                                                size: 15,
                                                color: Colors.white,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: RichText(
                                          text: TextSpan(
                                            style: GoogleFonts
                                                .plusJakartaSans(
                                              fontSize: 12.5,
                                              fontWeight:
                                                  FontWeight.w400,
                                              height: 1.5,
                                              color: AppColors
                                                  .textSecondary,
                                            ),
                                            children: [
                                              const TextSpan(
                                                  text:
                                                      'I agree to the '),
                                              TextSpan(
                                                text:
                                                    'Terms of Service',
                                                recognizer: TapGestureRecognizer()
                                                  ..onTap = () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            const TermsOfServiceScreen(),
                                                      ),
                                                    );
                                                  },
                                                style: GoogleFonts
                                                    .plusJakartaSans(
                                                  fontWeight:
                                                      FontWeight.w700,
                                                  color: AppColors
                                                      .primary,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                              const TextSpan(
                                                  text: ' and '),
                                              TextSpan(
                                                text:
                                                    'Privacy Policy',
                                                recognizer: TapGestureRecognizer()
                                                  ..onTap = () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            const PrivacyPolicyScreen(),
                                                      ),
                                                    );
                                                  },
                                                style: GoogleFonts
                                                    .plusJakartaSans(
                                                  fontWeight:
                                                      FontWeight.w700,
                                                  color: AppColors
                                                      .primary,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: AppSpacing.xl),

                              // Submit Button
                              _buildSubmitButton(),

                              const SizedBox(height: AppSpacing.lg),

                              // Divider
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: AppColors.border,
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 16),
                                    child: Text(
                                      'or continue with',
                                      style: GoogleFonts
                                          .plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: AppColors.border,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: AppSpacing.lg),

                              // Social Sign-In
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildSocialButton(
                                      logoAsset: 'assets/icons/google_logo.svg',
                                      label: 'Google',
                                      onTap: () => _socialSignIn(apple: false),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: _buildSocialButton(
                                      logoAsset: 'assets/icons/apple_logo.svg',
                                      label: 'Apple',
                                      onTap: () => _socialSignIn(apple: true),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Toggle Sign In / Sign Up
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isSignUp
                              ? 'Already have an account?'
                              : 'Don\'t have an account?',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: _toggleMode,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6),
                            minimumSize: Size.zero,
                            tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            _isSignUp ? 'Sign In' : 'Sign Up',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                        height: bottomPadding + AppSpacing.xxl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Role Switcher ─────────────────────────────────────────────
  Widget _buildRoleSwitcher() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        height: 52,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildRoleTab(
                label: 'Customer',
                icon: Icons.restaurant_rounded,
                isActive: !_isVendor,
                onTap: () => setState(() => _isVendor = false),
              ),
            ),
            Expanded(
              child: _buildRoleTab(
                label: 'Vendor',
                icon: Icons.storefront_rounded,
                isActive: _isVendor,
                onTap: () => setState(() => _isVendor = true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleTab({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isActive ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: isActive ? AppShadows.soft : null,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive
                    ? AppColors.primary
                    : AppColors.textTertiary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Text Field ────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? obscure : false,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textTertiary,
            ),
            prefixIcon: Icon(icon,
                size: 20, color: AppColors.textTertiary),
            suffixIcon: isPassword
                ? GestureDetector(
                    onTap: onToggleObscure,
                    child: Icon(
                      obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                  )
                : null,
            filled: true,
            fillColor: AppColors.surfaceElevated,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: AppColors.border,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: AppColors.border,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: AppColors.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: AppColors.error,
                width: 1.5,
              ),
            ),
            errorStyle: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.error,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Auth Method Switcher ─────────────────────────────────────
  Widget _buildAuthMethodSwitcher() {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isPhoneAuth = true;
                  _otpSent = false;
                  _verificationId = null;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _isPhoneAuth ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  boxShadow: _isPhoneAuth ? AppShadows.soft : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.phone_android_rounded,
                        size: 16,
                        color: _isPhoneAuth
                            ? AppColors.primary
                            : AppColors.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Phone (SMS OTP)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight:
                              _isPhoneAuth ? FontWeight.w700 : FontWeight.w500,
                          color: _isPhoneAuth
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isPhoneAuth = false;
                  _otpSent = false;
                  _verificationId = null;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: !_isPhoneAuth ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  boxShadow: !_isPhoneAuth ? AppShadows.soft : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 16,
                        color: !_isPhoneAuth
                            ? AppColors.primary
                            : AppColors.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Email & Password',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight:
                              !_isPhoneAuth ? FontWeight.w700 : FontWeight.w500,
                          color: !_isPhoneAuth
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Ghanaian Phone Field with Network Detection ──────────────
  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ghana Mobile Number',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (_detectedNetwork.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _detectedNetwork == 'MTN'
                      ? const Color(0xFFFFCC00).withValues(alpha: 0.2)
                      : (_detectedNetwork == 'Telecel'
                          ? const Color(0xFFE60000).withValues(alpha: 0.15)
                          : const Color(0xFF0055AA).withValues(alpha: 0.15)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _detectedNetwork == 'MTN'
                            ? const Color(0xFFFFB300)
                            : (_detectedNetwork == 'Telecel'
                                ? const Color(0xFFE60000)
                                : const Color(0xFF0055AA)),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _detectedNetwork,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          onChanged: _detectNetwork,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: '024 123 4567',
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
              color: AppColors.textTertiary,
            ),
            prefixIcon: Container(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🇬🇭', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Text(
                    '+233',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    height: 20,
                    width: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    color: AppColors.border,
                  ),
                ],
              ),
            ),
            filled: true,
            fillColor: AppColors.surfaceElevated,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: AppColors.border, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: AppColors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ─── OTP Verification UI Section ──────────────────────────────
  Widget _buildOtpVerificationSection() {
    final phone = _phoneController.text.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sent Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.mark_email_read_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Code sent to $phone',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _otpSent = false;
                    _otpController.clear();
                  });
                },
                child: Text(
                  'Change',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.base),

        // OTP Code Input Field
        Text(
          'Enter 6-Digit SMS Code',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 8,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            counterText: '',
            hintText: '••••••',
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              letterSpacing: 8,
              color: AppColors.textTertiary,
            ),
            filled: true,
            fillColor: AppColors.surfaceElevated,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: AppColors.border, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: AppColors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Resend Timer
        Align(
          alignment: Alignment.center,
          child: _resendCountdown > 0
              ? Text(
                  'Resend code in ${_resendCountdown}s',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                )
              : TextButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  child: Text(
                    'Resend SMS Code',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  // ─── Submit Button ─────────────────────────────────────────────
  Widget _buildSubmitButton() {
    String buttonText = 'Sign In';
    if (_isPhoneAuth) {
      buttonText = _otpSent
          ? 'Verify & Sign In'
          : (_isSignUp ? 'Send Verification Code' : 'Sign In with Phone');
    } else {
      buttonText = _isSignUp
          ? (_isVendor ? 'Create Vendor Account' : 'Create Account')
          : (_isVendor ? 'Sign In as Vendor' : 'Sign In');
    }

    return GestureDetector(
      onTap: _isLoading ? null : _submit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          color: _isLoading
              ? AppColors.primary.withValues(alpha: 0.7)
              : AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: _isLoading ? null : AppShadows.buttonElevated,
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isPhoneAuth
                          ? (_otpSent
                              ? Icons.verified_user_rounded
                              : Icons.send_rounded)
                          : (_isVendor
                              ? Icons.storefront_rounded
                              : Icons.restaurant_rounded),
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      buttonText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ─── Social Button ─────────────────────────────────────────────
  Widget _buildSocialButton({
    required String logoAsset,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
      onTap: _isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(logoAsset, width: 20, height: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

