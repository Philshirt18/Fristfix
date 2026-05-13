import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import '../models/app_user.dart';
import 'auth_service.dart';

/// Firebase Authentication implementation.
/// Uses popup-based auth on web, native SDKs on mobile.
class FirebaseAuthService implements AuthService {
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;
  late final GoogleSignIn _googleSignIn;

  FirebaseAuthService() {
    // Only initialize GoogleSignIn on non-web platforms
    if (!kIsWeb) {
      _googleSignIn = GoogleSignIn();
    }
  }

  @override
  AppUser? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return _mapUser(user);
  }

  @override
  bool get isLoggedIn => _firebaseAuth.currentUser != null;

  @override
  Stream<AppUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return _mapUser(user);
    });
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web: use Firebase popup
        final provider = fb.GoogleAuthProvider();
        provider.addScope('email');
        final userCredential =
            await _firebaseAuth.signInWithPopup(provider);
        if (userCredential.user == null) return null;
        return _mapUser(userCredential.user!);
      } else {
        // Mobile: use google_sign_in package
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null;

        final googleAuth = await googleUser.authentication;
        final credential = fb.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential =
            await _firebaseAuth.signInWithCredential(credential);
        if (userCredential.user == null) return null;
        return _mapUser(userCredential.user!);
      }
    } catch (e) {
      // ignore: avoid_print
      print('Google sign-in error: $e');
      return null;
    }
  }

  @override
  Future<AppUser?> signInWithApple() async {
    try {
      final appleProvider = fb.AppleAuthProvider();
      appleProvider.addScope('email');
      appleProvider.addScope('name');

      fb.UserCredential userCredential;
      if (kIsWeb) {
        userCredential = await _firebaseAuth.signInWithPopup(appleProvider);
      } else {
        userCredential =
            await _firebaseAuth.signInWithProvider(appleProvider);
      }
      if (userCredential.user == null) return null;
      return _mapUser(userCredential.user!);
    } catch (e) {
      // ignore: avoid_print
      print('Apple sign-in error: $e');
      return null;
    }
  }

  @override
  Future<void> signInWithEmailMagicLink(String email) async {
    // Not used in MVP – we use email/password instead
  }

  /// Sign in or register with email and password.
  /// If registering, sends a verification email automatically.
  Future<AppUser?> signInWithEmail(String email, String password) async {
    try {
      // Try sign in first
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user == null) return null;
      return _mapUser(userCredential.user!);
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        // User doesn't exist – create account
        final userCredential =
            await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        // Send verification email for new accounts
        if (userCredential.user != null &&
            !userCredential.user!.emailVerified) {
          await userCredential.user!.sendEmailVerification();
        }
        if (userCredential.user == null) return null;
        return _mapUser(userCredential.user!);
      }
      rethrow;
    }
  }

  /// Send a password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  /// Resend verification email for the current user.
  Future<void> resendVerificationEmail() async {
    final user = _firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// Whether the current user's email is verified.
  bool get isEmailVerified =>
      _firebaseAuth.currentUser?.emailVerified ?? false;

  @override
  Future<void> signOut() async {
    if (!kIsWeb) {
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
    }
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await _firebaseAuth.currentUser?.delete();
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        rethrow;
      }
    }
  }

  AppUser _mapUser(fb.User user) {
    return AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }
}
