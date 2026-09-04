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

  // Initialize Firebase (required for auth/firestore)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 10));
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }

  // Initialize Hive for local deadline storage
  try {
    await Hive.initFlutter().timeout(const Duration(seconds: 5));
  } catch (e) {
    debugPrint('Hive init failed: $e');
  }

  // Initialize SharedPreferences for app settings
  SharedPreferences? prefs;
  try {
    prefs = await SharedPreferences.getInstance().timeout(const Duration(seconds: 5));
  } catch (e) {
    debugPrint('SharedPreferences init failed: $e');
  }
  final storageService = LocalStorageService(prefs ?? (await SharedPreferences.getInstance()));

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

  // Remote repository
  final remoteDeadlineRepo = RemoteDeadlineRepository();

  // Sync service
  final syncService = SyncService(
    local: localDeadlineRepo,
    remote: remoteDeadlineRepo,
  );

  // Initialize WorkManager early (iOS requires BGTask handler registration at launch)
  try {
    await BackgroundService.initialize().timeout(const Duration(seconds: 3));
  } catch (e) {
    debugPrint('BackgroundService init failed: $e');
  }

  // Launch app immediately – defer non-critical init
  runApp(FristFixApp(
    storageService: storageService,
    localDeadlineRepo: localDeadlineRepo,
    authService: authService,
    paymentService: paymentService,
    notificationService: notificationService,
    syncService: syncService,
  ));

  // Deferred initialization (after UI is showing)
  _deferredInit(notificationService, paymentService);
}

/// Non-critical initialization that runs after the UI is visible.
Future<void> _deferredInit(
  NotificationService notificationService,
  RevenueCatPaymentService paymentService,
) async {
  // Small delay to let UI render first
  await Future.delayed(const Duration(milliseconds: 500));

  // Notifications
  try {
    await notificationService.initialize().timeout(const Duration(seconds: 5));
    await notificationService.requestPermission().timeout(const Duration(seconds: 3));
  } catch (_) {}

  // RevenueCat
  try {
    await paymentService.initialize().timeout(const Duration(seconds: 5));
  } catch (_) {}
}