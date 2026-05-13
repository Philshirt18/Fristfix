/// Utility functions for deadline limit logic.
class DeadlineLimitUtils {
  DeadlineLimitUtils._();

  static const int freeLimit = 5;
  static const int signupPromptThreshold = 3;

  /// Whether the user can add a new deadline.
  static bool canAddNewDeadline({
    required int activeCount,
    required bool isPremium,
  }) {
    return isPremium || activeCount < freeLimit;
  }

  /// Whether the signup prompt should be shown.
  static bool shouldShowSignupPrompt({
    required int activeCount,
    required bool isLoggedIn,
    required bool hasDismissedSignupPrompt,
  }) {
    return activeCount >= signupPromptThreshold &&
        !isLoggedIn &&
        !hasDismissedSignupPrompt;
  }

  /// Whether the premium hint card should be shown.
  static bool shouldShowPremiumHint({
    required int activeCount,
    required bool isPremium,
    required bool hasSeenPremiumHintAtFive,
  }) {
    return activeCount >= freeLimit &&
        !isPremium &&
        !hasSeenPremiumHintAtFive;
  }

  /// Number of free slots remaining.
  static int freeSlots(int activeCount) {
    final remaining = freeLimit - activeCount;
    return remaining > 0 ? remaining : 0;
  }
}
