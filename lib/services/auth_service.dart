import '../models/app_user.dart';

/// Abstract auth service interface.
/// UI code depends only on this interface, never on Firebase directly.
abstract class AuthService {
  /// The currently signed-in user, or null.
  AppUser? get currentUser;

  /// Whether a user is currently signed in.
  bool get isLoggedIn;

  /// Stream of auth state changes.
  Stream<AppUser?> get authStateChanges;

  /// Sign in with Apple.
  Future<AppUser?> signInWithApple();

  /// Sign in with Google.
  Future<AppUser?> signInWithGoogle();

  /// Sign in with email magic link.
  Future<void> signInWithEmailMagicLink(String email);

  /// Sign out the current user.
  Future<void> signOut();

  /// Delete the current user's account.
  Future<void> deleteAccount();
}
