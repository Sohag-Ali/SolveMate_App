import 'package:flutter/material.dart';
import '../models/user_role.dart';
import 'common_widgets.dart';

class HeroPanel extends StatelessWidget {
  const HeroPanel({
    super.key,
    required this.role,
    required this.onPostProblem,
    required this.onViewTeachers,
  });

  final UserRole role;
  final VoidCallback onPostProblem;
  final VoidCallback onViewTeachers;

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == UserRole.admin;
    final isTeacher = role == UserRole.teacher;
    final isWide = MediaQuery.of(context).size.width > 700;

    final heading = isAdmin
        ? 'শিক্ষক আবেদন যাচাই করুন, শিক্ষার্থী-শিক্ষক রিকোয়েস্ট মনিটর করুন এবং প্ল্যাটফর্মের মান নিশ্চিত করুন'
        : isTeacher
        ? 'শিক্ষার্থীদের সমস্যা বাছাই করুন, অনুরোধ পাঠান এবং ক্লাস নিয়ে আয় বৃদ্ধি করুন'
        : 'সমস্যা পোস্ট করুন, সেরা শিক্ষক বাছাই করুন এবং দ্রুত সমাধান শিখুন';

    final stats = isTeacher
        ? const [
            StatChip(value: '১৮৯৬', label: 'মোট শিক্ষার্থী'),
            StatChip(value: '৭৬', label: 'নতুন সমস্যা'),
          ]
        : const [
            StatChip(value: '৩২০', label: 'শিক্ষক'),
            StatChip(value: '১,২৪০', label: 'সমস্যা সমাধান'),
          ];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F5D3F),
            Color(0xFF1A8F5F),
            Color(0xFF2BA074),
            Color(0xFF1F7052),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A3A26).withValues(alpha: 0.35),
            offset: const Offset(0, 12),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: isWide ? 28 : 18,
              height: 1.3,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: stats),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              FilledButton.icon(
                onPressed: isTeacher ? onViewTeachers : onPostProblem,
                icon: Icon(
                  isTeacher
                      ? Icons.mark_email_read_rounded
                      : Icons.add_circle_outline_rounded,
                  size: 16,
                ),
                style: FilledButton.styleFrom(
                  foregroundColor: const Color(0xFF0F5D3F),
                  backgroundColor: Colors.white,
                  shadowColor: Colors.black.withValues(alpha: 0.3),
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 0.2,
                  ),
                ),
                label: Text(isTeacher ? 'রিকোয়েস্ট দেখুন' : 'পোস্ট করুন'),
              ),
              OutlinedButton.icon(
                onPressed: onViewTeachers,
                icon: Icon(
                  isTeacher
                      ? Icons.pending_actions_rounded
                      : Icons.groups_rounded,
                  size: 16,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 0.2,
                  ),
                ),
                label: Text(
                  isTeacher
                      ? 'স্ট্যাটাস দেখুন'
                      : isAdmin
                      ? 'শিক্ষক দেখুন'
                      : 'শিক্ষক দেখুন',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
