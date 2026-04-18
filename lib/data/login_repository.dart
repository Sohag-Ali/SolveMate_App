import '../models/user_role.dart';

class LoginRepository {
  static final List<AuthUser> demoUsers = [
    const AuthUser(
      name: 'admin1',
      email: 'admin@gmail.com',
      phone: '01700000001',
      password: '123456',
      role: UserRole.admin,
    ),
    const AuthUser(
      name: 'Delowar Husain',
      email: 'student@gmail.com',
      phone: '01700000002',
      password: '123456',
      role: UserRole.user,
    ),
    const AuthUser(
      name: 'Delowar Husain',
      email: 'teacher@gmail.com',
      phone: '01700000003',
      password: '123456',
      role: UserRole.teacher,
    ),
    const AuthUser(
      name: 'Delowar Husain',
      email: 'delowar.teacher@solvemate.test',
      phone: '01700000004',
      password: '123456',
      role: UserRole.teacher,
    ),
    const AuthUser(
      name: 'Nusrat Jahan',
      email: 'nusrat.teacher@solvemate.test',
      phone: '01700000005',
      password: '123456',
      role: UserRole.teacher,
    ),
    const AuthUser(
      name: 'Rakib Hasan',
      email: 'rakib.teacher@solvemate.test',
      phone: '01700000006',
      password: '123456',
      role: UserRole.teacher,
    ),
  ];

  static AuthUser? findByEmail(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    for (final user in demoUsers) {
      if (user.email.toLowerCase() == normalizedEmail) {
        return user;
      }
    }
    return null;
  }
}
