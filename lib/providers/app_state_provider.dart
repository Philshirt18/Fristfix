import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/local_storage_service.dart';
import '../services/payment_service.dart';
import '../services/auth_service.dart';
import '../utils/deadline_limit_utils.dart';

/// Manages app-wide state: premium, login, prompt dismissals.
/// Delegates to PaymentService and AuthService – never touches
/// Firebase or RevenueCat directly.
class AppStateProvider extends ChangeNotifier {
  final LocalStorageService _storage;
  final PaymentService _paymentService;
  final AuthService _authService;

  StreamSubscription<bool>? _premiumSub;
  StreamSubscription? _authSub;

  AppStateProvider({
    required LocalStorageService storage,
    required PaymentService paymentService,
    required AuthService authService,
  })  : _storage = storage,
        _paymentService = paymentService,
        _authService = authService {
    // Listen to premium status changes from PaymentService
    _premiumSub = _paymentService.premiumStatusStream.listen((isPremium) {
      _storage.setIsPremiumCache(isPremium);
      notifyListeners();
    });

    // Listen to auth state changes
    _authSub = _authService.authStateChanges.listen((user) {
      _storage.setIsLoggedInCache(user != null);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _premiumSub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }

  // --- Getters ---

  bool get isPremium => _storage.isPremiumCache;
  bool get isLoggedIn => _authService.isLoggedIn || _storage.isLoggedInCache;
  bool get hasDismissedSignupPrompt => _storage.hasDismissedSignupPrompt;
  bool get hasSeenPremiumHintAtFive => _storage.hasSeenPremiumHintAtFive;
  bool get backupEnabled => _storage.backupEnabled;
  bool get introOfferEnabled => _paymentService.introOfferEnabled;

  // --- Computed helpers using DeadlineLimitUtils ---

  bool shouldShowSignupPrompt(int activeCount) {
    return DeadlineLimitUtils.shouldShowSignupPrompt(
      activeCount: activeCount,
      isLoggedIn: isLoggedIn,
      hasDismissedSignupPrompt: hasDismissedSignupPrompt,
    );
  }

  bool shouldShowPremiumHint(int activeCount) {
    return DeadlineLimitUtils.shouldShowPremiumHint(
      activeCount: activeCount,
      isPremium: isPremium,
      hasSeenPremiumHintAtFive: hasSeenPremiumHintAtFive,
    );
  }

  bool canAddNewDeadline(int activeCount) {
    return DeadlineLimitUtils.canAddNewDeadline(
      activeCount: activeCount,
      isPremium: isPremium,
    );
  }

  // --- Actions ---

  Future<void> dismissSignupPrompt() async {
    await _storage.setHasDismissedSignupPrompt(true);
    notifyListeners();
  }

  Future<void> dismissPremiumHintAtFive() async {
    await _storage.setHasSeenPremiumHintAtFive(true);
    notifyListeners();
  }

  /// Purchase premium via PaymentService.
  Future<PurchaseResult> purchasePremium() async {
    final result = await _paymentService.purchasePremium();
    if (result == PurchaseResult.success) {
      await _storage.setIsPremiumCache(true);
      notifyListeners();
    }
    return result;
  }

  /// Restore purchases via PaymentService.
  Future<RestoreResult> restorePurchases() async {
    final result = await _paymentService.restorePurchases();
    if (result == RestoreResult.premiumRestored) {
      await _storage.setIsPremiumCache(true);
      notifyListeners();
    }
    return result;
  }

  /// Refresh premium status from PaymentService.
  Future<void> refreshPremiumStatus() async {
    final isPremium = await _paymentService.isPremium();
    await _storage.setIsPremiumCache(isPremium);
    notifyListeners();
  }

  Future<void> setLoggedIn(bool value) async {
    await _storage.setIsLoggedInCache(value);
    notifyListeners();
  }

  Future<void> setBackupEnabled(bool value) async {
    await _storage.setBackupEnabled(value);
    notifyListeners();
  }

  /// Activate premium via promo code (bypasses payment).
  Future<void> activatePromoCode() async {
    await _storage.setIsPremiumCache(true);
    notifyListeners();
  }
}
