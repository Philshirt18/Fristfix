import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/deadline.dart';

/// Manages small app settings via SharedPreferences.
/// Deadline data is stored in Hive (see LocalDeadlineRepository).
///
/// This service handles:
/// - Onboarding state
/// - Signup/premium prompt dismissals
/// - Premium cache
/// - Login state cache
/// - Backup enabled flag
/// - App preferences
class LocalStorageService {
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _selectedCategoriesKey = 'selected_categories';
  static const String _isPremiumCacheKey = 'is_premium_cache';
  static const String _isLoggedInCacheKey = 'is_logged_in_cache';
  static const String _hasDismissedSignupPromptKey = 'has_dismissed_signup_prompt';
  static const String _hasSeenPremiumHintAtFiveKey = 'has_seen_premium_hint_at_five';
  static const String _backupEnabledKey = 'backup_enabled';
  static const String _introOfferEnabledKey = 'intro_offer_enabled';

  // Legacy key for migration
  static const String _legacyDeadlinesKey = 'deadlines';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  // --- Legacy migration ---

  /// Load deadlines from old SharedPreferences storage for migration to Hive.
  List<Deadline> loadLegacyDeadlines() {
    final jsonString = _prefs.getString(_legacyDeadlinesKey);
    if (jsonString == null) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => Deadline.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Remove legacy deadline data after migration.
  Future<void> clearLegacyDeadlines() async {
    await _prefs.remove(_legacyDeadlinesKey);
  }

  // --- Onboarding ---

  bool get isOnboardingComplete =>
      _prefs.getBool(_onboardingCompleteKey) ?? false;

  Future<void> setOnboardingComplete(bool value) async {
    await _prefs.setBool(_onboardingCompleteKey, value);
  }

  // --- Selected Categories ---

  List<String> get selectedCategories =>
      _prefs.getStringList(_selectedCategoriesKey) ?? [];

  Future<void> setSelectedCategories(List<String> categories) async {
    await _prefs.setStringList(_selectedCategoriesKey, categories);
  }

  // --- Premium Cache ---

  bool get isPremiumCache => _prefs.getBool(_isPremiumCacheKey) ?? false;

  Future<void> setIsPremiumCache(bool value) async {
    await _prefs.setBool(_isPremiumCacheKey, value);
  }

  // --- Login Cache ---

  bool get isLoggedInCache => _prefs.getBool(_isLoggedInCacheKey) ?? false;

  Future<void> setIsLoggedInCache(bool value) async {
    await _prefs.setBool(_isLoggedInCacheKey, value);
  }

  // --- Signup Prompt ---

  bool get hasDismissedSignupPrompt =>
      _prefs.getBool(_hasDismissedSignupPromptKey) ?? false;

  Future<void> setHasDismissedSignupPrompt(bool value) async {
    await _prefs.setBool(_hasDismissedSignupPromptKey, value);
  }

  // --- Premium Hint at 5 ---

  bool get hasSeenPremiumHintAtFive =>
      _prefs.getBool(_hasSeenPremiumHintAtFiveKey) ?? false;

  Future<void> setHasSeenPremiumHintAtFive(bool value) async {
    await _prefs.setBool(_hasSeenPremiumHintAtFiveKey, value);
  }

  // --- Backup ---

  bool get backupEnabled => _prefs.getBool(_backupEnabledKey) ?? false;

  Future<void> setBackupEnabled(bool value) async {
    await _prefs.setBool(_backupEnabledKey, value);
  }

  // --- Intro Offer ---

  bool get introOfferEnabled =>
      _prefs.getBool(_introOfferEnabledKey) ?? true;

  Future<void> setIntroOfferEnabled(bool value) async {
    await _prefs.setBool(_introOfferEnabledKey, value);
  }
}
