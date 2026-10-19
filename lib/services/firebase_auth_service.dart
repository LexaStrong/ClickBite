import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'security_service.dart';

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

  /// Format Ghanaian phone numbers to E.164 standard (+233XXXXXXXXX)
  String formatGhanaianPhone(String rawPhone) {
    String clean = rawPhone.replaceAll(RegExp(r'[\s\-()]'), '').trim();
    if (clean.startsWith('+233')) {
      return clean;
    }
    if (clean.startsWith('233')) {
      return '+$clean';
    }
    if (clean.startsWith('0')) {
      return '+233${clean.substring(1)}';
    }
    return '+233$clean';
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

        final token = await user.getIdToken() ?? '';
        final session = UserSession(
          userId: user.uid,
          email: user.email ?? '${user.phoneNumber}@clickbites.gh',
          fullName: data?['fullName'] as String? ?? user.displayName ?? 'Customer',
          phone: user.phoneNumber ?? data?['phone'] as String? ?? '',
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
          _errorMessage = e.message ?? 'Phone verification failed';
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
      _errorMessage = e.toString();
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
      await userRef.update(updates);
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    _security.clearSession();
    notifyListeners();
  }
}
