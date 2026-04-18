import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../models/problem_models.dart';
import '../utils/pinned_header_delegate.dart';
import '../widgets/app_header.dart';
import '../widgets/common_widgets.dart';
import '../widgets/problem_card.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({
    super.key,
    required this.session,
    required this.onShowNotifications,
    required this.unreadNotificationCount,
    required this.totalTeachers,
    required this.totalStudents,
    required this.postedProblems,
    required this.studentNameByEmail,
    required this.onDeleteProblem,
    required this.onRefresh,
  });

  final RoleSession session;
  final VoidCallback onShowNotifications;
  final int unreadNotificationCount;
  final int totalTeachers;
  final int totalStudents;
  final List<PostedProblemStatus> postedProblems;
  final String Function(String email) studentNameByEmail;
  final void Function(PostedProblemStatus problem) onDeleteProblem;
  final Future<void> Function() onRefresh;

  String _postedAgoLabel(int postedAtMs) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final diffMs = now - postedAtMs;
    if (diffMs < Duration.millisecondsPerMinute) return 'এইমাত্র';
    if (diffMs < Duration.millisecondsPerHour) {
      final mins = (diffMs / Duration.millisecondsPerMinute).floor();
      return '$mins মিনিট আগে';
    }
    if (diffMs < Duration.millisecondsPerDay) {
      final hours = (diffMs / Duration.millisecondsPerHour).floor();
      return '$hours ঘণ্টা আগে';
    }
    final days = (diffMs / Duration.millisecondsPerDay).floor();
    return '$days দিন আগে';
  }

  Future<void> _showPostDetails(
    BuildContext context,
    PostedProblemStatus problem,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProblemDetailsPage(
          posterName: studentNameByEmail(problem.studentEmail),
          posterAvatarUrl: null,
          postedAgo: _postedAgoLabel(problem.postedAtMs),
          title: problem.title,
          budget: problem.budget,
          problemType: (problem.problemType ?? '').trim().isEmpty
              ? 'সাধারণ'
              : problem.problemType!,
          subject: (problem.subject ?? '').trim().isEmpty
              ? 'সাধারণ'
              : problem.subject!,
          imageAsset: (problem.imageAsset ?? '').trim().isEmpty
              ? 'assets/math.jpg'
              : problem.imageAsset!,
          imageBytes: problem.imageBytes,
          description: (problem.problemDetails ?? '').trim().isEmpty
              ? 'বিস্তারিত দেয়া হয়নি।'
              : problem.problemDetails!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: PinnedHeaderDelegate(
              height: 74,
              child: AppHeader(
                session: session,
                onNotificationTap: onShowNotifications,
                unreadNotificationCount: unreadNotificationCount,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ModernStatusStatCard(
                    label: 'মোট শিক্ষক',
                    value: '$totalTeachers',
                    icon: Icons.school_rounded,
                  ),
                  const SizedBox(height: 10),
                  ModernStatusStatCard(
                    label: 'মোট শিক্ষার্থী',
                    value: '$totalStudents',
                    icon: Icons.groups_rounded,
                  ),
                  const SizedBox(height: 10),
                  ModernStatusStatCard(
                    label: 'মোট পোস্ট',
                    value: '${postedProblems.length}',
                    icon: Icons.post_add_rounded,
                  ),
                  const SizedBox(height: 14),
                  const SectionTitle(
                    title: 'সকল পোস্ট',
                    subtitle:
                        'পোস্টে ট্যাপ করলে ডিটেইলস দেখুন, প্রয়োজনে মুছে দিন।',
                    icon: Icons.delete_outline_rounded,
                  ),
                  const SizedBox(height: 10),
                  if (postedProblems.isEmpty)
                    const EmptyStateCard(message: 'কোনো পোস্ট পাওয়া যায়নি।')
                  else
                    for (int i = 0; i < postedProblems.length; i++) ...[
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () =>
                              _showPostDetails(context, postedProblems[i]),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFCFE8DB),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        postedProblems[i].title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF0E402C),
                                            ),
                                      ),
                                    ),
                                    FilledButton.tonalIcon(
                                      onPressed: () =>
                                          onDeleteProblem(postedProblems[i]),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: const Color(0xFFB91C1C),
                                        foregroundColor: Colors.white,
                                      ),
                                      icon: const Icon(Icons.delete_rounded),
                                      label: const Text('ডিলিট'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'শিক্ষার্থী: ${studentNameByEmail(postedProblems[i].studentEmail)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: const Color(0xFF475569),
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'বাজেট: ${postedProblems[i].budget}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: const Color(0xFF475569),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (i != postedProblems.length - 1)
                        const SizedBox(height: 10),
                    ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
