import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'security_service.dart';
import '../utils/ghana_phone.dart';

/// Firebase Authentication Service for ClickBite
/// Supports Ghanaian Mobile Phone SMS OTP (+233) and Email/Password credentials.
class FirebaseAuthService extends ChangeNotifier {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;

  FirebaseAuthService._internal() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SecurityService _security = SecurityService();

  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => _auth.currentUser != null;

  String? _verificationId;
  String? get verificationId => _verificationId;

  int? _resendToken;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Format Ghanaian phone numbers to E.164 standard (+233XXXXXXXXX).
  /// Accepts any common input format (see [GhanaPhone]).
  String formatGhanaianPhone(String rawPhone) {
    return GhanaPhone.toE164(rawPhone) ??
        '+233${rawPhone.replaceAll(RegExp(r'\D'), '')}';
  }

  /// Turns Firebase error codes into messages a customer can act on.
  static String friendlyAuthError(Object e) {
    final code = e is FirebaseAuthException ? e.code : '';
    final text = '${e is FirebaseAuthException ? e.message : e}';
    if (text.contains('BILLING_NOT_ENABLED') || code == 'billing-not-enabled') {
      return 'SMS verification is temporarily unavailable. Please use Email & Password for now.';
    }
    switch (code) {
      case 'invalid-phone-number':
        return 'That phone number is not valid. Please check and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a few minutes and try again.';
      case 'invalid-verification-code':
        return 'Incorrect code. Please check the SMS and try again.';
      case 'session-expired':
        return 'The code has expired. Please request a new one.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'operation-not-allowed':
        return 'Google Sign-In is not enabled in Firebase Console. Please enable it in Authentication -> Sign-in method.';
      case 'internal-error':
        return 'Google Sign-In configuration error: check that Google provider is enabled and your domain (or localhost) is in Firebase Authorized Domains.';
      case 'unauthorized-domain':
        return 'This domain is not authorized in Firebase Console -> Authentication -> Settings -> Authorized Domains.';
      case 'popup-blocked':
        return 'Sign-in popup was blocked by your browser. Please allow popups for this site.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using a different sign-in method.';
      case 'web-context-canceled':
      case 'canceled':
        return 'Sign-in was cancelled.';
    }
    return text.isNotEmpty && text != 'null' ? text : 'Something went wrong. Please try again.';
  }

  /// Sign in with Google or Apple using Firebase's provider flow.
  Future<UserCredential> signInWithSocial({
    required bool apple,
    UserRole role = UserRole.customer,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final AuthProvider provider = apple
          ? (AppleAuthProvider()..addScope('email')..addScope('name'))
          : (GoogleAuthProvider()..addScope('email'));
      final UserCredential userCred;
      if (kIsWeb) {
        try {
          userCred = await _auth.signInWithPopup(provider);
        } catch (popupError) {
          debugPrint('[FirebaseAuthService] Web popup error: $popupError');
          final code = popupError is FirebaseAuthException ? popupError.code : '';
          if (code == 'popup-blocked' || code == 'cancelled' || code == 'popup-closed-by-user') {
            rethrow;
          }
          // Attempt redirect if popup fails due to iframe/window context
          debugPrint('[FirebaseAuthService] Falling back to signInWithRedirect...');
          await _auth.signInWithRedirect(provider);
          return await _auth.getRedirectResult();
        }
      } else {
        userCred = await _auth.signInWithProvider(provider);
      }
      if (userCred.user != null) {
        await _createOrUpdateUserDoc(user: userCred.user!, role: role);
      }
      _isLoading = false;
      notifyListeners();
      return userCred;
    } catch (e) {
      _isLoading = false;
      _errorMessage = friendlyAuthError(e);
      notifyListeners();
      rethrow;
    }
  }

  /// Listen to Firebase Auth state and sync with SecurityService session
  Future<void> _onAuthStateChanged(User? user) async {
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        final data = doc.data();

        final roleStr = data?['role'] as String? ?? 'customer';
        UserRole role = UserRole.customer;
        if (roleStr == 'vendor') {
          role = UserRole.vendor;
        } else if (roleStr == 'rider') {
          role = UserRole.rider;
        } else if (roleStr == 'admin') {
          role = UserRole.admin;
        }

        final address = data?['address'] as String? ?? 'Post Office Rd, Konongo';
        final token = await user.getIdToken() ?? '';

        final rawDocName = data?['fullName'] as String? ?? user.displayName ?? '';
        final String resolvedName;
        if (rawDocName.trim().isNotEmpty &&
            rawDocName != 'Customer' &&
            rawDocName != 'Customer Account') {
          resolvedName = rawDocName.trim();
        } else if (_security.currentSession?.fullName.isNotEmpty == true &&
            _security.currentSession!.fullName != 'Customer' &&
            _security.currentSession!.fullName != 'Customer Account') {
          resolvedName = _security.currentSession!.fullName;
        } else if (user.email != null && user.email!.contains('@')) {
          final prefix = user.email!.split('@').first;
          final words = prefix
              .replaceAll(RegExp(r'[._\-]'), ' ')
              .split(' ')
              .where((w) => w.isNotEmpty)
              .map((w) => w[0].toUpperCase() + (w.length > 1 ? w.substring(1) : ''))
              .toList();
          resolvedName = words.isNotEmpty ? words.join(' ') : 'ClickBite Customer';
        } else {
          resolvedName = role == UserRole.vendor ? 'Vendor Partner' : 'ClickBite Customer';
        }

        final rawPhone = user.phoneNumber ?? data?['phone'] as String? ?? '';
        final resolvedPhone = rawPhone.trim().isNotEmpty
            ? rawPhone.trim()
            : (_security.currentSession?.phone ?? '');

        final session = UserSession(
          userId: user.uid,
          email: user.email ?? '${user.phoneNumber}@clickbites.gh',
          fullName: resolvedName,
          phone: resolvedPhone,
          address: address,
          role: role,
          token: token,
          issuedAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(days: 30)),
        );
        _security.setSession(session);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[FirebaseAuthService] Error syncing user session: $e');
        }
      }
    }
    notifyListeners();
  }

  /// Start Ghanaian Phone Number Verification (SMS OTP)
  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(PhoneAuthCredential credential) onAutoVerified,
    required void Function(String error) onError,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final e164Phone = formatGhanaianPhone(phoneNumber);
    if (kDebugMode) {
      debugPrint('[FirebaseAuthService] Initiating Phone OTP to $e164Phone');
    }

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: e164Phone,
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          _isLoading = false;
          notifyListeners();
          onAutoVerified(credential);
          await signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          _isLoading = false;
          _errorMessage = friendlyAuthError(e);
          notifyListeners();
          onError(_errorMessage!);
        },
        codeSent: (String verificationId, int? resendToken) {
          _isLoading = false;
          _verificationId = verificationId;
          _resendToken = resendToken;
          notifyListeners();
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _isLoading = false;
      _errorMessage = friendlyAuthError(e);
      notifyListeners();
      onError(_errorMessage!);
    }
  }

  /// Verify 6-digit SMS OTP code entered by user
  Future<UserCredential> verifySmsOtp({
    required String verificationId,
    required String smsCode,
    String? fullName,
    UserRole role = UserRole.customer,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode.trim(),
      );
      final userCred = await _auth.signInWithCredential(credential);

      // Create or update Firestore user document
      if (userCred.user != null) {
        await _createOrUpdateUserDoc(
          user: userCred.user!,
          fullName: fullName,
          role: role,
        );
        final token = await userCred.user!.getIdToken() ?? '';
        final session = UserSession(
          userId: userCred.user!.uid,
          email: userCred.user!.email ?? '${userCred.user!.phoneNumber}@clickbites.gh',
          fullName: (fullName != null && fullName.trim().isNotEmpty)
              ? fullName.trim()
              : (role == UserRole.vendor ? 'Vendor Partner' : 'ClickBite Customer'),
          phone: userCred.user!.phoneNumber ?? '',
          address: 'Post Office Rd, Konongo',
          role: role,
          token: token,
          issuedAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(days: 30)),
        );
        _security.setSession(session);
      }

      _isLoading = false;
      notifyListeners();
      return userCred;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = e.message ?? 'Invalid verification code';
      notifyListeners();
      rethrow;
    }
  }

  /// Sign In with PhoneAuthCredential
  Future<UserCredential> signInWithCredential(PhoneAuthCredential credential) async {
    final userCred = await _auth.signInWithCredential(credential);
    if (userCred.user != null) {
      await _createOrUpdateUserDoc(user: userCred.user!);
    }
    return userCred;
  }

  /// Sign in with Email and Password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userCred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (userCred.user != null) {
        try {
          final doc = await _firestore.collection('users').doc(userCred.user!.uid).get();
          final data = doc.data();
          final roleStr = data?['role'] as String? ?? 'customer';
          final token = await userCred.user!.getIdToken() ?? '';
          final session = UserSession(
            userId: userCred.user!.uid,
            email: userCred.user!.email ?? email,
            fullName: data?['fullName'] as String? ?? userCred.user!.displayName ?? 'ClickBite Customer',
            phone: data?['phone'] as String? ?? userCred.user!.phoneNumber ?? '',
            address: data?['address'] as String? ?? 'Post Office Rd, Konongo',
            role: roleStr == 'vendor' ? UserRole.vendor : UserRole.customer,
            token: token,
            issuedAt: DateTime.now(),
            expiresAt: DateTime.now().add(const Duration(days: 30)),
          );
          _security.setSession(session);
        } catch (_) {}
      }
      _isLoading = false;
      notifyListeners();
      return userCred;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = e.message ?? 'Login failed';
      notifyListeners();
      rethrow;
    }
  }

  /// Sign up with Email and Password
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    UserRole role = UserRole.customer,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCred.user != null) {
        await userCred.user!.updateDisplayName(fullName);
        await _createOrUpdateUserDoc(
          user: userCred.user!,
          fullName: fullName,
          phone: phone,
          role: role,
        );

        final token = await userCred.user!.getIdToken() ?? '';
        final session = UserSession(
          userId: userCred.user!.uid,
          email: userCred.user!.email ?? email,
          fullName: fullName.trim(),
          phone: phone.trim(),
          address: 'Post Office Rd, Konongo',
          role: role,
          token: token,
          issuedAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(days: 30)),
        );
        _security.setSession(session);
      }

      _isLoading = false;
      notifyListeners();
      return userCred;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = e.message ?? 'Registration failed';
      notifyListeners();
      rethrow;
    }
  }

  /// Create or update user profile document in Firestore
  Future<void> _createOrUpdateUserDoc({
    required User user,
    String? fullName,
    String? phone,
    String? address,
    UserRole role = UserRole.customer,
  }) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final snapshot = await userRef.get();

    final roleName = role.name;

    if (!snapshot.exists) {
      await userRef.set({
        'uid': user.uid,
        'email': user.email ?? '',
        'fullName': fullName ?? user.displayName ?? 'Customer',
        'phone': phone ?? user.phoneNumber ?? '',
        'address': address ?? 'Post Office Rd, Konongo',
        'role': roleName,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });
    } else {
      final Map<String, dynamic> updates = {
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (fullName != null) updates['fullName'] = fullName;
      if (phone != null) updates['phone'] = phone;
      if (address != null) updates['address'] = address;
      await userRef.update(updates);
    }
  }

  /// Update user profile details (Name, Ghana phone, Delivery address)
  Future<void> updateUserProfile({
    required String fullName,
    required String phone,
    required String address,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(fullName);
        await _createOrUpdateUserDoc(
          user: user,
          fullName: fullName,
          phone: phone,
          address: address,
        );
      }
      _security.updateSessionProfile(
        fullName: fullName,
        phone: phone,
        address: address,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = friendlyAuthError(e);
      notifyListeners();
      // Even if Firestore update fails (e.g. offline), update local session immediately
      _security.updateSessionProfile(
        fullName: fullName,
        phone: phone,
        address: address,
      );
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    _security.clearSession();
    notifyListeners();
  }
}
