import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'services/local_storage_service.dart';
import 'services/firebase_auth_service.dart';
import 'services/revenuecat_payment_service.dart';
import 'services/notification_service.dart';
import 'services/background_service.dart';
import 'services/sync_service.dart';
import 'data/local_deadline_repository.dart';
import 'data/remote_deadline_repository.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Hive for local deadline storage
  try {
    await Hive.initFlutter();
  } catch (e) {
    // Hive may fail in restricted environments (e.g. Incognito mode)
    // App will still work but local storage may be limited
    debugPrint('Hive init failed: $e');
  }

  // Initialize SharedPreferences for app settings
  final prefs = await SharedPreferences.getInstance();
  final storageService = LocalStorageService(prefs);

  // Initialize local deadline repository
  final localDeadlineRepo = LocalDeadlineRepository();

  // Migrate legacy SharedPreferences deadlines to Hive (one-time)
  try {
    final legacyDeadlines = storageService.loadLegacyDeadlines();
    if (legacyDeadlines.isNotEmpty) {
      await localDeadlineRepo.migrateFromList(legacyDeadlines);
      await storageService.clearLegacyDeadlines();
    }
  } catch (e) {
    debugPrint('Legacy migration failed: $e');
  }

  // Initialize services
  final authService = FirebaseAuthService();
  final paymentService = RevenueCatPaymentService();
  final notificationService = NotificationService();

  // Initialize notifications (no-op on web)
  try {
    await notificationService.initialize();
    await notificationService.requestPermission();
  } catch (_) {
    // Notification init failed – not critical
  }

  // Initialize background task for recurring notification refresh
  try {
    await BackgroundService.initialize();
  } catch (_) {
    // Background service init failed – not critical
  }

  // Remote repository (no user yet – will be updated after login)
  final remoteDeadlineRepo = RemoteDeadlineRepository();

  // Sync service
  final syncService = SyncService(
    local: localDeadlineRepo,
    remote: remoteDeadlineRepo,
  );

  // Initialize RevenueCat (non-blocking)
  try {
    await paymentService.initialize().timeout(const Duration(seconds: 5));
  } catch (_) {
    // RevenueCat init failed or timed out – app continues with free tier
  }

  runApp(FristFixApp(
    storageService: storageService,
    localDeadlineRepo: localDeadlineRepo,
    authService: authService,
    paymentService: paymentService,
    notificationService: notificationService,
    syncService: syncService,
  ));
}
