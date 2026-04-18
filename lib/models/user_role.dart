enum UserRole { admin, teacher, user }

class RoleSession {
  const RoleSession({
    required this.name,
    required this.email,
    required this.role,
  });

  final String name;
  final String email;
  final UserRole role;
}

class AuthUser {
  const AuthUser({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
  });

  final String name;
  final String email;
  final String phone;
  final String password;
  final UserRole role;
}

String roleLabel(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return 'অ্যাডমিন';
    case UserRole.teacher:
      return 'শিক্ষক';
    case UserRole.user:
      return 'শিক্ষার্থী';
  }
}
