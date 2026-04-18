import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/user_role.dart';
import 'data/login_repository.dart';
import 'pages/login_page.dart';
import 'shell.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  RoleSession? _session;
  bool _isRestoringSession = true;

  static const String _savedEmailKey = 'saved_session_email';

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedEmail = preferences.getString(_savedEmailKey);

      if (!mounted) return;

      if (savedEmail == null) return;

      final matchedUser = LoginRepository.findByEmail(savedEmail);

      setState(() {
        _session = matchedUser == null
            ? null
            : RoleSession(
                name: matchedUser.name,
                email: matchedUser.email,
                role: matchedUser.role,
              );
      });

      if (matchedUser == null) {
        await preferences.remove(_savedEmailKey);
      }
    } catch (_) {
      if (mounted) setState(() => _session = null);
    } finally {
      if (mounted) setState(() => _isRestoringSession = false);
    }
  }

  Future<void> _saveSession(RoleSession session) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_savedEmailKey, session.email);
  }

  Future<void> _clearSession() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_savedEmailKey);
  }

  @override
  Widget build(BuildContext context) {
    if (_isRestoringSession) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_session == null) {
      return LoginPage(
        onLogin: (session) async {
          await _saveSession(session);
          if (!mounted) return;
          setState(() => _session = session);
        },
      );
    }

    return SolveMateShell(
      session: _session!,
      onLogout: () async {
        await _clearSession();
        if (!mounted) return;
        setState(() => _session = null);
      },
    );
  }
}
