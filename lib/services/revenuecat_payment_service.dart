import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:purchases_flutter/purchases_flutter.dart';
import 'payment_service.dart';

/// RevenueCat payment service implementation.
///
/// Entitlement: "Fristfix Pro"
/// Product: fristfix_premium_yearly
class RevenueCatPaymentService implements PaymentService {
  static const String _googleApiKey = 'goog_IslOWNckkOdiInQtXcATEIjDxVV';
  static const String _appleApiKey = 'appl_MsIdePmVYdACClcfVjHXgauBODD';
  static const String _entitlementId = 'Fristfix Pro';

  bool _isPremium = false;
  bool _initialized = false;
  final bool _introOfferEnabled = true;
  final _premiumStatusController = StreamController<bool>.broadcast();

  /// Initialize RevenueCat. Call once at app startup.
  Future<void> initialize({String? userId}) async {
    if (kIsWeb) {
      _initialized = false;
      return;
    }

    try {
      await Purchases.setLogLevel(LogLevel.debug);

      final apiKey = Platform.isIOS ? _appleApiKey : _googleApiKey;
      PurchasesConfiguration config = PurchasesConfiguration(apiKey);
      if (userId != null) {
        config = PurchasesConfiguration(apiKey)..appUserID = userId;
      }

      await Purchases.configure(config);
      _initialized = true;

      // Listen to customer info updates
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        final isPremiumNow =
            customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;
        _updatePremiumStatus(isPremiumNow);
      });

      // Check current status
      await refreshSubscriptionStatus();
    } catch (e) {
      // RevenueCat init failed – app continues with free tier
      _initialized = false;
    }
  }

  @override
  Future<bool> isPremium() async {
    if (!_initialized) return _isPremium;
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;
    } catch (e) {
      return _isPremium;
    }
  }

  @override
  Stream<bool> get premiumStatusStream => _premiumStatusController.stream;

  @override
  bool get introOfferEnabled => _introOfferEnabled;

  @override
  Future<PurchaseResult> purchasePremium() async {
    if (!_initialized) {
      // Fallback: simulate purchase on web/unsupported platforms
      _updatePremiumStatus(true);
      return PurchaseResult.success;
    }

    try {
      final offerings = await Purchases.getOfferings();
      final currentOffering = offerings.current;
      if (currentOffering == null) return PurchaseResult.error;

      // Try annual package first
      final package = currentOffering.annual ?? currentOffering.availablePackages.firstOrNull;
      if (package == null) return PurchaseResult.error;

      final customerInfo = await Purchases.purchasePackage(package);
      final isPremiumNow =
          customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;
      _updatePremiumStatus(isPremiumNow);
      return isPremiumNow ? PurchaseResult.success : PurchaseResult.error;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        return PurchaseResult.cancelled;
      }
      return PurchaseResult.error;
    } catch (e) {
      return PurchaseResult.error;
    }
  }

  @override
  Future<RestoreResult> restorePurchases() async {
    if (!_initialized) return RestoreResult.noPurchaseFound;

    try {
      final customerInfo = await Purchases.restorePurchases();
      final isPremiumNow =
          customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;
      _updatePremiumStatus(isPremiumNow);
      return isPremiumNow
          ? RestoreResult.premiumRestored
          : RestoreResult.noPurchaseFound;
    } catch (e) {
      return RestoreResult.error;
    }
  }

  @override
  Future<void> refreshSubscriptionStatus() async {
    if (!_initialized) return;
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final isPremiumNow =
          customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;
      _updatePremiumStatus(isPremiumNow);
    } catch (e) {
      // Keep cached status
    }
  }

  /// Login user to RevenueCat (after Firebase auth).
  Future<void> loginUser(String userId) async {
    if (!_initialized) return;
    try {
      await Purchases.logIn(userId);
      await refreshSubscriptionStatus();
    } catch (e) {
      // Login failed – not critical
    }
  }

  /// Logout user from RevenueCat.
  Future<void> logoutUser() async {
    if (!_initialized) return;
    try {
      await Purchases.logOut();
    } catch (e) {
      // Logout failed – not critical
    }
  }

  void _updatePremiumStatus(bool value) {
    _isPremium = value;
    _premiumStatusController.add(value);
  }

  void dispose() {
    _premiumStatusController.close();
  }
}
