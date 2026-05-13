/// Abstract payment service interface.
/// UI code depends only on this interface, never on RevenueCat directly.
abstract class PaymentService {
  /// Whether the user currently has an active premium subscription.
  Future<bool> isPremium();

  /// Stream of premium status changes.
  Stream<bool> get premiumStatusStream;

  /// Whether an intro offer is currently available.
  bool get introOfferEnabled;

  /// Purchase the premium subscription.
  /// Returns a [PurchaseResult] indicating success, cancellation, or error.
  Future<PurchaseResult> purchasePremium();

  /// Restore previous purchases.
  /// Returns a [RestoreResult] indicating what was found.
  Future<RestoreResult> restorePurchases();

  /// Refresh the subscription status from the payment provider.
  Future<void> refreshSubscriptionStatus();
}

enum PurchaseResult {
  success,
  cancelled,
  error,
}

enum RestoreResult {
  premiumRestored,
  noPurchaseFound,
  error,
}
