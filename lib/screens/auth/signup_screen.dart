import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/sync_service.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/deadline_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/primary_button.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onComplete;

  const SignupScreen({
    super.key,
    required this.onBack,
    required this.onComplete,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _showEmailForm = false;
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _showEmailForm
              ? () => setState(() { _showEmailForm = false; _errorText = null; })
              : widget.onBack,
        ),
        title: const Text('Fristen sichern'),
      ),
      body: _showEmailForm ? _buildEmailForm(context) : _buildMethodSelection(context),
    );
  }

  Widget _buildMethodSelection(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 16),
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: AppColors.primaryLightOf(context),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.cloud_outlined, size: 32, color: AppColors.primaryOf(context)),
        ),
        const SizedBox(height: 24),
        Text('Fristen kostenlos sichern',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textOf(context))),
        const SizedBox(height: 8),
        Text('Erstelle ein kostenloses Konto, damit deine Fristen beim Gerätewechsel erhalten bleiben.',
          style: TextStyle(fontSize: 15, color: AppColors.mutedOf(context), height: 1.5)),
        const SizedBox(height: 32),

        // Google
        _authButton(context, icon: Icons.g_mobiledata, label: 'Mit Google fortfahren',
          onTap: () => _handleGoogleSignIn(context)),
        const SizedBox(height: 12),

        // Apple
        _authButton(context, icon: Icons.apple, label: 'Mit Apple fortfahren',
          onTap: () => _handleAppleSignIn(context)),
        const SizedBox(height: 12),

        // Email
        _authButton(context, icon: Icons.mail_outline, label: 'Mit E-Mail sichern',
          onTap: () => setState(() => _showEmailForm = true)),

        const SizedBox(height: 32),
        _trustHint(context),
        const SizedBox(height: 16),
        _localHint(context),
        const SizedBox(height: 24),
        Center(
          child: TextButton(
            onPressed: widget.onBack,
            child: Text('Später', style: TextStyle(color: AppColors.mutedOf(context))),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildEmailForm(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 16),
        Text('Mit E-Mail sichern',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textOf(context))),
        const SizedBox(height: 8),
        Text('Gib deine E-Mail-Adresse und ein Passwort ein. Falls du noch kein Konto hast, wird automatisch eines erstellt.',
          style: TextStyle(fontSize: 14, color: AppColors.mutedOf(context), height: 1.5)),
        const SizedBox(height: 32),

        Text('E-Mail', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textOf(context))),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: const InputDecoration(hintText: 'deine@email.de'),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Text('Passwort', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textOf(context))),
            const Spacer(),
            GestureDetector(
              onTap: () => _handlePasswordReset(context),
              child: Text('Passwort vergessen?', style: TextStyle(fontSize: 13, color: AppColors.primaryOf(context), fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'Mindestens 6 Zeichen'),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleEmailSignIn(context),
        ),

        if (_errorText != null) ...[
          const SizedBox(height: 16),
          Text(_errorText!, style: TextStyle(fontSize: 14, color: AppColors.criticalOf(context))),
        ],

        const SizedBox(height: 32),
        PrimaryButton(
          label: 'Kostenlos sichern',
          isLoading: _isLoading,
          onPressed: () => _handleEmailSignIn(context),
        ),
        const SizedBox(height: 32),
        _trustHint(context),
        const SizedBox(height: 32),
      ],
    );
  }

  // --- Auth handlers ---

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      final authService = context.read<AuthService>();
      final user = await authService.signInWithGoogle();
      if (user != null && mounted) {
        await _onLoginSuccess(context);
      }
    } catch (e) {
      if (mounted) _showError(context, 'Das hat leider nicht geklappt. Bitte versuche es später erneut.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAppleSignIn(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      final authService = context.read<AuthService>();
      final user = await authService.signInWithApple();
      if (user != null && mounted) {
        await _onLoginSuccess(context);
      }
    } catch (e) {
      if (mounted) _showError(context, 'Das hat leider nicht geklappt. Bitte versuche es später erneut.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEmailSignIn(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      setState(() => _errorText = 'Bitte gib deine E-Mail-Adresse ein.');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorText = 'Das Passwort muss mindestens 6 Zeichen haben.');
      return;
    }

    setState(() { _isLoading = true; _errorText = null; });

    try {
      final authService = context.read<AuthService>() as FirebaseAuthService;
      final isNewUser = !authService.isLoggedIn;
      final user = await authService.signInWithEmail(email, password);
      if (user != null && mounted) {
        await _onLoginSuccess(context, showVerificationHint: !authService.isEmailVerified);
      }
    } catch (e) {
      if (mounted) {
        final msg = _mapAuthError(e);
        setState(() => _errorText = msg);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePasswordReset(BuildContext context) async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorText = 'Bitte gib zuerst deine E-Mail-Adresse ein.');
      return;
    }

    try {
      final authService = context.read<AuthService>() as FirebaseAuthService;
      await authService.sendPasswordResetEmail(email);
      if (mounted) {
        setState(() => _errorText = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('E-Mail zum Zurücksetzen wurde an $email gesendet.')),
        );
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().toLowerCase();
        if (msg.contains('user-not-found')) {
          setState(() => _errorText = 'Kein Konto mit dieser E-Mail-Adresse gefunden.');
        } else {
          setState(() => _errorText = 'Das hat leider nicht geklappt. Bitte versuche es später erneut.');
        }
      }
    }
  }

  Future<void> _onLoginSuccess(BuildContext context, {bool showVerificationHint = false}) async {
    final appState = context.read<AppStateProvider>();
    final syncService = context.read<SyncService>();
    final deadlineProvider = context.read<DeadlineProvider>();
    final authService = context.read<AuthService>();

    await appState.setLoggedIn(true);

    // Sync deadlines to/from cloud
    final user = authService.currentUser;
    if (user != null) {
      try {
        await syncService.connectUser(user.uid);
        await deadlineProvider.loadDeadlines();
      } catch (_) {
        // Sync failed – not critical, local data is still available
      }
    }

    if (mounted) {
      final message = showVerificationHint
          ? 'Konto erstellt. Bitte bestätige deine E-Mail-Adresse über den Link in deinem Postfach.'
          : 'Backup aktiviert. Deine Fristen wurden synchronisiert.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      widget.onComplete();
    }
  }

  String _mapAuthError(dynamic e) {
    if (e is! Exception) return 'Das hat leider nicht geklappt. Bitte versuche es später erneut.';
    final msg = e.toString().toLowerCase();
    if (msg.contains('email-already-in-use')) return 'Diese E-Mail wird bereits verwendet. Versuche dich anzumelden.';
    if (msg.contains('wrong-password') || msg.contains('invalid-credential')) return 'E-Mail oder Passwort ist nicht korrekt.';
    if (msg.contains('invalid-email')) return 'Bitte gib eine gültige E-Mail-Adresse ein.';
    if (msg.contains('weak-password')) return 'Das Passwort muss mindestens 6 Zeichen haben.';
    if (msg.contains('too-many-requests')) return 'Zu viele Versuche. Bitte warte einen Moment.';
    if (msg.contains('network')) return 'Keine Internetverbindung. Bitte prüfe dein Netzwerk.';
    return 'Das hat leider nicht geklappt. Bitte versuche es später erneut.';
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // --- UI helpers ---

  Widget _authButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return AppCard(
      onTap: _isLoading ? null : onTap,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 24, color: AppColors.textOf(context)),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textOf(context)))),
          Icon(Icons.chevron_right, color: AppColors.mutedOf(context)),
        ],
      ),
    );
  }

  Widget _trustHint(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLightOf(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline, size: 18, color: AppColors.primaryOf(context)),
          const SizedBox(width: 12),
          Expanded(child: Text('Deine Daten bleiben privat. Wir nutzen dein Konto nur für Backup und Sync.',
            style: TextStyle(fontSize: 13, color: AppColors.primaryOf(context), height: 1.4))),
        ],
      ),
    );
  }

  Widget _localHint(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerOf(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 16, color: AppColors.mutedOf(context)),
          const SizedBox(width: 10),
          Expanded(child: Text('Ohne Konto bleiben deine Fristen nur auf diesem Gerät gespeichert.',
            style: TextStyle(fontSize: 12, color: AppColors.mutedOf(context), height: 1.4))),
        ],
      ),
    );
  }
}
