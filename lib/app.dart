import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/local_storage_service.dart';
import 'services/auth_service.dart';
import 'services/payment_service.dart';
import 'services/notification_service.dart';
import 'services/sync_service.dart';
import 'data/local_deadline_repository.dart';
import 'providers/deadline_provider.dart';
import 'providers/app_state_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/deadlines/deadlines_screen.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/add_deadline/add_deadline_screen.dart';
import 'screens/deadline_details/deadline_details_screen.dart';
import 'screens/deadline_details/edit_deadline_screen.dart';
import 'screens/premium/premium_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/settings/legal/terms_screen.dart';
import 'screens/settings/legal/privacy_policy_screen.dart';
import 'screens/settings/legal/imprint_screen.dart';
import 'screens/settings/legal/subscription_terms_screen.dart';
import 'screens/settings/legal/legal_overview_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'models/deadline.dart';
import 'models/deadline_suggestion.dart';
import 'widgets/notification_pre_prompt.dart';

class FristFixApp extends StatelessWidget {
  final LocalStorageService storageService;
  final LocalDeadlineRepository localDeadlineRepo;
  final AuthService authService;
  final PaymentService paymentService;
  final NotificationService notificationService;
  final SyncService syncService;

  const FristFixApp({
    super.key,
    required this.storageService,
    required this.localDeadlineRepo,
    required this.authService,
    required this.paymentService,
    required this.notificationService,
    required this.syncService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = DeadlineProvider(
              localRepo: localDeadlineRepo,
              syncService: syncService,
              notificationService: notificationService,
            );
            provider.loadDeadlines();
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => AppStateProvider(
            storage: storageService,
            paymentService: paymentService,
            authService: authService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) {
            final tp = ThemeProvider();
            tp.loadThemeMode();
            return tp;
          },
        ),
        // Provide services for screens that need direct access
        Provider<AuthService>.value(value: authService),
        Provider<PaymentService>.value(value: paymentService),
        Provider<SyncService>.value(value: syncService),
        Provider<NotificationService>.value(value: notificationService),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'FristFix',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('de', 'DE'),
            ],
            home: _AppShell(storageService: storageService),
          );
        },
      ),
    );
  }
}

class _AppShell extends StatefulWidget {
  final LocalStorageService storageService;

  const _AppShell({required this.storageService});

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  bool _showOnboarding = true;
  int _currentTab = 0;

  _OverlayScreen? _overlayScreen;
  String? _selectedDeadlineId;
  Deadline? _editingDeadline;
  DeadlineSuggestion? _pendingSuggestion;

  @override
  void initState() {
    super.initState();
    _showOnboarding = !widget.storageService.isOnboardingComplete;
    // Auto-sync if user is already logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoSyncIfLoggedIn();
      _requestNotificationPermissionIfNeeded();
    });
  }

  Future<void> _requestNotificationPermissionIfNeeded() async {
    final notificationService = context.read<NotificationService>();
    if (!notificationService.isInitialized) return;
    if (!notificationService.permissionGranted) {
      // For returning users, request permission silently (no pre-prompt)
      await notificationService.requestPermission();
    }
  }

  Future<void> _autoSyncIfLoggedIn() async {
    final authService = context.read<AuthService>();
    if (authService.isLoggedIn && authService.currentUser != null) {
      final syncService = context.read<SyncService>();
      final deadlineProvider = context.read<DeadlineProvider>();
      try {
        await syncService.connectUser(authService.currentUser!.uid);
        await deadlineProvider.loadDeadlines();
      } catch (_) {
        // Sync failed – not critical
      }
    }
  }

  void _completeOnboarding() {
    widget.storageService.setOnboardingComplete(true);
    setState(() => _showOnboarding = false);
    // Show notification pre-prompt after onboarding
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showNotificationPrePrompt();
    });
  }

  Future<void> _showNotificationPrePrompt() async {
    final notificationService = context.read<NotificationService>();
    if (notificationService.permissionGranted) return; // Already granted

    final result = await NotificationPrePrompt.show(context);
    if (result == true) {
      await notificationService.requestPermission();
    }
  }

  void _openDetail(String id) {
    setState(() {
      _selectedDeadlineId = id;
      _overlayScreen = _OverlayScreen.detail;
    });
  }

  void _openEdit(Deadline deadline) {
    setState(() {
      _editingDeadline = deadline;
      _overlayScreen = _OverlayScreen.edit;
    });
  }

  void _openSettings() =>
      setState(() => _overlayScreen = _OverlayScreen.settings);

  void _openPremium() =>
      setState(() => _overlayScreen = _OverlayScreen.premium);

  void _openSignup() =>
      setState(() => _overlayScreen = _OverlayScreen.signup);

  void _openTerms() =>
      setState(() => _overlayScreen = _OverlayScreen.terms);

  void _openLegalOverview() =>
      setState(() => _overlayScreen = _OverlayScreen.legalOverview);

  void _openPrivacy() =>
      setState(() => _overlayScreen = _OverlayScreen.privacy);

  void _openImprint() =>
      setState(() => _overlayScreen = _OverlayScreen.imprint);

  void _openSubscriptionTerms() =>
      setState(() => _overlayScreen = _OverlayScreen.subscriptionTerms);

  void _openAddDeadline() {
    setState(() {
      _pendingSuggestion = null;
      _overlayScreen = _OverlayScreen.addDeadline;
    });
  }

  void _openAddDeadlineFromSuggestion(DeadlineSuggestion suggestion) {
    setState(() {
      _pendingSuggestion = suggestion;
      _overlayScreen = _OverlayScreen.addDeadline;
    });
  }

  void _closeOverlay() {
    setState(() {
      _overlayScreen = null;
      _selectedDeadlineId = null;
      _editingDeadline = null;
      _pendingSuggestion = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding) {
      return OnboardingScreen(onComplete: _completeOnboarding);
    }

    if (_overlayScreen != null) {
      switch (_overlayScreen!) {
        case _OverlayScreen.detail:
          return DeadlineDetailsScreen(
            deadlineId: _selectedDeadlineId!,
            onBack: _closeOverlay,
            onEdit: _openEdit,
          );
        case _OverlayScreen.edit:
          return EditDeadlineScreen(
            deadline: _editingDeadline!,
            onSaved: () {
              setState(() {
                _overlayScreen = _OverlayScreen.detail;
                _editingDeadline = null;
              });
            },
            onCancel: () {
              setState(() {
                _overlayScreen = _OverlayScreen.detail;
                _editingDeadline = null;
              });
            },
          );
        case _OverlayScreen.settings:
          return SettingsScreen(
            onBack: _closeOverlay,
            onOpenPremium: () =>
                setState(() => _overlayScreen = _OverlayScreen.premium),
            onOpenSignup: _openSignup,
            onOpenLegal: _openLegalOverview,
          );
        case _OverlayScreen.premium:
          return PremiumScreen(onBack: _closeOverlay);
        case _OverlayScreen.signup:
          return SignupScreen(
            onBack: _closeOverlay,
            onComplete: _closeOverlay,
          );
        case _OverlayScreen.legalOverview:
          return LegalOverviewScreen(
            onBack: _closeOverlay,
            onOpenImprint: _openImprint,
            onOpenPrivacy: _openPrivacy,
            onOpenTerms: _openTerms,
            onOpenSubscriptionTerms: _openSubscriptionTerms,
          );
        case _OverlayScreen.terms:
          return TermsScreen(onBack: _closeOverlay);
        case _OverlayScreen.privacy:
          return PrivacyPolicyScreen(onBack: _closeOverlay);
        case _OverlayScreen.imprint:
          return ImprintScreen(onBack: _closeOverlay);
        case _OverlayScreen.subscriptionTerms:
          return SubscriptionTermsScreen(onBack: _closeOverlay);
        case _OverlayScreen.addDeadline:
          return AddDeadlineScreen(
            key: ValueKey(_pendingSuggestion?.label ?? 'add'),
            onComplete: () {
              _closeOverlay();
              setState(() => _currentTab = 0);
            },
            onCancel: _closeOverlay,
            onOpenPremium: _openPremium,
            onOpenSignup: _openSignup,
            initialSuggestion: _pendingSuggestion,
          );
      }
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentTab,
        children: [
          DashboardScreen(
            onAddDeadline: _openAddDeadline,
            onOpenDetail: _openDetail,
            onOpenSettings: _openSettings,
            onOpenPremium: _openPremium,
            onOpenSignup: _openSignup,
            onAddFromSuggestion: _openAddDeadlineFromSuggestion,
          ),
          CalendarScreen(
            onOpenDetail: _openDetail,
            onOpenPremium: _openPremium,
            onOpenSettings: _openSettings,
          ),
          DeadlinesScreen(
            onOpenDetail: _openDetail,
            onOpenSettings: _openSettings,
            onAddDeadline: _openAddDeadline,
            onAddFromSuggestion: _openAddDeadlineFromSuggestion,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          boxShadow: Theme.of(context).brightness == Brightness.light
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))]
              : null,
        ),
        child: BottomNavigationBar(
        currentIndex: _currentTab > 2 ? 0 : _currentTab,
        onTap: (index) {
          if (index == 3) {
            _openAddDeadline();
          } else {
            setState(() => _currentTab = index);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Übersicht',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Kalender',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Fristen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Hinzufügen',
          ),
        ],
      ),
      ),
    );
  }
}

enum _OverlayScreen {
  detail,
  edit,
  settings,
  premium,
  signup,
  legalOverview,
  terms,
  privacy,
  imprint,
  subscriptionTerms,
  addDeadline,
}
