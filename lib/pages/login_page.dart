import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../data/app_store.dart';
import '../data/login_repository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.onLogin});

  final Future<void> Function(RoleSession) onLogin;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginIdentifierController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPhoneController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();

  static const List<UserRole> _selfRegistrationRoles = [
    UserRole.user,
    UserRole.teacher,
  ];

  final List<AuthUser> _registeredUsers = [...LoginRepository.demoUsers];

  UserRole _registerRole = UserRole.user;
  bool _isRegisterMode = false;
  String? _error;
  String? _success;

  @override
  void dispose() {
    _loginIdentifierController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPhoneController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  void _switchMode(bool registerMode) {
    setState(() {
      _isRegisterMode = registerMode;
      _error = null;
      _success = null;
    });
  }

  void _login() {
    final identifier = _loginIdentifierController.text.trim();
    final password = _loginPasswordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      setState(() {
        _error = 'Email/phone and password are required.';
        _success = null;
      });
      return;
    }

    final normalizedIdentifier = identifier.toLowerCase();
    final foundUser = _registeredUsers.where((user) {
      final emailMatch = user.email.toLowerCase() == normalizedIdentifier;
      final phoneMatch = user.phone == identifier;
      return emailMatch || phoneMatch;
    }).firstOrNull;

    if (foundUser == null || foundUser.password != password) {
      setState(() {
        _error = 'Invalid credentials. Try again.';
        _success = null;
      });
      return;
    }

    final banRecord = AppStore.bans[foundUser.email.toLowerCase()];
    if (banRecord != null && banRecord.isActive) {
      setState(() {
        _error = 'This account is banned (${banRecord.durationLabel}).';
        _success = null;
      });
      return;
    }

    widget.onLogin(
      RoleSession(
        name: foundUser.name,
        email: foundUser.email,
        role: foundUser.role,
      ),
    );
  }

  void _register() {
    final name = _registerNameController.text.trim();
    final email = _registerEmailController.text.trim().toLowerCase();
    final phone = _registerPhoneController.text.trim();
    final password = _registerPasswordController.text;
    final confirmPassword = _registerConfirmPasswordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() {
        _error = 'Please fill in all registration fields.';
        _success = null;
      });
      return;
    }

    if (!email.contains('@')) {
      setState(() {
        _error = 'Please enter a valid email address.';
        _success = null;
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _error = 'Password must be at least 6 characters.';
        _success = null;
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _error = 'Confirm password does not match.';
        _success = null;
      });
      return;
    }

    if (_registerRole == UserRole.admin) {
      setState(() {
        _error = 'Admin account is fixed and cannot be self-registered.';
        _success = null;
      });
      return;
    }

    final emailExists = _registeredUsers.any(
      (user) => user.email.toLowerCase() == email,
    );
    if (emailExists) {
      setState(() {
        _error = 'This email is already registered.';
        _success = null;
      });
      return;
    }

    final phoneExists = _registeredUsers.any((user) => user.phone == phone);
    if (phoneExists) {
      setState(() {
        _error = 'This phone number is already registered.';
        _success = null;
      });
      return;
    }

    setState(() {
      _registeredUsers.insert(
        0,
        AuthUser(
          name: name,
          email: email,
          phone: phone,
          password: password,
          role: _registerRole,
        ),
      );

      _loginIdentifierController.text = email;
      _loginPasswordController.text = password;

      _registerNameController.clear();
      _registerEmailController.clear();
      _registerPhoneController.clear();
      _registerPasswordController.clear();
      _registerConfirmPasswordController.clear();

      _isRegisterMode = false;
      _error = null;
      _success = 'Registration successful. You can now log in.';
    });
  }

  void _showForgotInfo() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('পাসওয়ার্ড ভুলে গেছেন'),
          content: const Text(
            'ডেমো ব্যবহারকারীদের জন্য পাসওয়ার্ড 123456।\nনতুন নিবন্ধিত ব্যবহারকারীরা নিবন্ধনের সময় সেট করা পাসওয়ার্ড ব্যবহার করবেন।',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ঠিক আছে'),
            ),
          ],
        );
      },
    );
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'অ্যাডমিন';
      case UserRole.teacher:
        return 'শিক্ষক';
      case UserRole.user:
        return 'শিক্ষার্থী';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE6F7EE),
                  Color(0xFFD6F0E2),
                  Color(0xFFF1FAF5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: -80,
            right: -40,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                color: const Color(0xFF8CCFAF).withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -70,
            left: -40,
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                color: const Color(0xFF8EDFC2).withValues(alpha: 0.32),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFDFEFE), Color(0xFFF5FBF8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: const Color(0xFFCFE7D9).withValues(alpha: 0.9),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F5132).withValues(alpha: 0.12),
                            blurRadius: 24,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDFF3E8),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: const Color(0xFFBFE3CE),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 16,
                                    color: Color(0xFF0E6A45),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'একাডেমিক সহায়তা প্ল্যাটফর্ম',
                                    style: TextStyle(
                                      color: Color(0xFF0E6A45),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Solve Mate এ স্বাগতম',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF113326),
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isRegisterMode
                                  ? 'এক ধাপে অ্যাকাউন্ট তৈরি করে শেখা শুরু করুন।'
                                  : 'আপনার ইমেইল বা ফোন নম্বর এবং পাসওয়ার্ড দিয়ে লগইন করুন।',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: const Color(0xFF475569)),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5EE),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: const Color(0xFFCEE7DA),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: FilledButton.tonal(
                                      onPressed: () => _switchMode(false),
                                      style: FilledButton.styleFrom(
                                        elevation: 0,
                                        foregroundColor:
                                            const Color(0xFF1F6F4A),
                                        backgroundColor: !_isRegisterMode
                                            ? const Color(0xFFD2EDDE)
                                            : Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                      ),
                                      child: const Text('লগইন'),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: FilledButton.tonal(
                                      onPressed: () => _switchMode(true),
                                      style: FilledButton.styleFrom(
                                        elevation: 0,
                                        foregroundColor:
                                            const Color(0xFF1F6F4A),
                                        backgroundColor: _isRegisterMode
                                            ? const Color(0xFFD2EDDE)
                                            : Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                      ),
                                      child: const Text('নিবন্ধন'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (!_isRegisterMode) ...[
                              TextField(
                                controller: _loginIdentifierController,
                                decoration: const InputDecoration(
                                  labelText: 'ইমেইল বা ফোন নম্বর',
                                  prefixIcon: Icon(Icons.mail_rounded),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _loginPasswordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'পাসওয়ার্ড',
                                  prefixIcon: Icon(Icons.lock_rounded),
                                ),
                              ),
                            ] else ...[
                              TextField(
                                controller: _registerNameController,
                                decoration: const InputDecoration(
                                  labelText: 'নাম',
                                  prefixIcon: Icon(Icons.person_rounded),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _registerEmailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'ইমেইল',
                                  prefixIcon: Icon(Icons.email_rounded),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _registerPhoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  labelText: 'ফোন নম্বর',
                                  prefixIcon: Icon(Icons.phone_rounded),
                                ),
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<UserRole>(
                                initialValue: _registerRole,
                                decoration: const InputDecoration(
                                  labelText: 'ভূমিকা',
                                  prefixIcon: Icon(Icons.badge_rounded),
                                ),
                                items: _selfRegistrationRoles
                                    .map(
                                      (role) => DropdownMenuItem<UserRole>(
                                        value: role,
                                        child: Text(_roleLabel(role)),
                                      ),
                                    )
                                    .toList(growable: false),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _registerRole = value);
                                  }
                                },
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _registerPasswordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'পাসওয়ার্ড',
                                  prefixIcon: Icon(Icons.lock_rounded),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _registerConfirmPasswordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'পাসওয়ার্ড নিশ্চিত করুন',
                                  prefixIcon:
                                      Icon(Icons.lock_outline_rounded),
                                ),
                              ),
                            ],
                            if (_success != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                _success!,
                                style: const TextStyle(
                                  color: Color(0xFF0B7A4D),
                                ),
                              ),
                            ],
                            if (_error != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                _error!,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed:
                                    _isRegisterMode ? _register : _login,
                                icon: Icon(
                                  _isRegisterMode
                                      ? Icons.person_add_alt_1_rounded
                                      : Icons.login_rounded,
                                ),
                                label: Text(
                                  _isRegisterMode
                                      ? 'অ্যাকাউন্ট তৈরি করুন'
                                      : 'লগইন করুন',
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFF1F7A50),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (!_isRegisterMode)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _showForgotInfo,
                                  child: const Text(
                                    'পাসওয়ার্ড ভুলে গেছেন?',
                                  ),
                                ),
                              )
                            else
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => _switchMode(false),
                                  child:
                                      const Text('লগইনে ফিরে যান'),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
