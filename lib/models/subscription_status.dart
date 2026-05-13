/// Represents the user's subscription status.
enum SubscriptionTier {
  free,
  premium,
}

class SubscriptionStatus {
  final SubscriptionTier tier;
  final DateTime? expiresAt;
  final bool isIntroOffer;

  const SubscriptionStatus({
    this.tier = SubscriptionTier.free,
    this.expiresAt,
    this.isIntroOffer = false,
  });

  bool get isPremium => tier == SubscriptionTier.premium;
  bool get isFree => tier == SubscriptionTier.free;

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  static const SubscriptionStatus free = SubscriptionStatus();

  static SubscriptionStatus premium({DateTime? expiresAt, bool isIntroOffer = false}) =>
      SubscriptionStatus(
        tier: SubscriptionTier.premium,
        expiresAt: expiresAt,
        isIntroOffer: isIntroOffer,
      );
}
