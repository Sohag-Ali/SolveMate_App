import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../models/teacher_models.dart';
import '../models/problem_models.dart';
import '../models/notification_models.dart';
import '../utils/pinned_header_delegate.dart';
import '../widgets/app_header.dart';
import '../widgets/common_widgets.dart';
import '../widgets/request_cards.dart';

class RequestStatusPage extends StatelessWidget {
  const RequestStatusPage({
    super.key,
    required this.session,
    required this.onShowNotifications,
    required this.unreadNotificationCount,
    required this.sentRequests,
    required this.incomingRequests,
    required this.teacherSentRequests,
    required this.postedProblems,
    this.onAcceptTeacherRequest,
    this.onRejectTeacherRequest,
    this.onUpdateIncomingRequestStatus,
    this.onCancelSentRequest,
    this.onCancelTeacherSentRequest,
    required this.onRefresh,
  });

  final RoleSession session;
  final VoidCallback onShowNotifications;
  final int unreadNotificationCount;
  final List<TeacherRequest> sentRequests;
  final List<TeacherRequest> incomingRequests;
  final List<TeacherRequest> teacherSentRequests;
  final List<PostedProblemStatus> postedProblems;
  final void Function(PostedProblemStatus problem, String requestId)?
      onAcceptTeacherRequest;
  final void Function(PostedProblemStatus problem, String requestId)?
      onRejectTeacherRequest;
  final void Function(String requestId, TeacherRequestStatus status)?
      onUpdateIncomingRequestStatus;
  final void Function(String requestId)? onCancelSentRequest;
  final void Function(String requestId)? onCancelTeacherSentRequest;
  final Future<void> Function() onRefresh;

  List<TeacherRequest> _requestsForProblem(PostedProblemStatus problem) {
    return sentRequests
        .where(
          (request) =>
              request.problemTitle == problem.title &&
              request.initiatedByTeacher,
        )
        .toList(growable: false);
  }

  Future<void> _showProblemRequestsSheet(
    BuildContext context,
    PostedProblemStatus problem,
  ) async {
    final requests = _requestsForProblem(problem);
    final hasAccepted = requests.any(
      (r) => r.status == TeacherRequestStatus.accepted,
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              14,
              14,
              14,
              MediaQuery.of(context).viewInsets.bottom + 14,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFDFEFE),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFCFE8DB)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.groups_rounded, color: Color(0xFF1F6F4A)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'সমাধান অনুরোধ',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    Text(
                      problem.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (requests.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FCFA),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFD8EBDD)),
                        ),
                        child: const Text(
                          'এখনো কোনো শিক্ষক এই সমস্যার জন্য অনুরোধ পাঠায়নি।',
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: requests.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final request = requests[index];
                            final isAccepted =
                                request.status == TeacherRequestStatus.accepted;
                            final canAccept = !hasAccepted &&
                                onAcceptTeacherRequest != null &&
                                request.status == TeacherRequestStatus.pending;
                            final canReject = onRejectTeacherRequest != null &&
                                request.status == TeacherRequestStatus.pending;

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isAccepted
                                      ? const Color(0xFFBEE5D1)
                                      : const Color(0xFFD8EBDD),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          request.teacherName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                                color: const Color(0xFF0E402C),
                                              ),
                                        ),
                                      ),
                                      MiniPill(
                                        label: statusLabel(request.status),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'বাজেট: ${request.budget}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: const Color(0xFF475569),
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    request.problemDetails,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 10),
                                  if (canAccept || canReject)
                                    Row(
                                      children: [
                                        if (canReject)
                                          Expanded(
                                            child: FilledButton.tonalIcon(
                                              onPressed: () {
                                                onRejectTeacherRequest?.call(
                                                  problem,
                                                  request.id,
                                                );
                                                Navigator.of(context).pop();
                                              },
                                              icon: const Icon(Icons.close_rounded),
                                              style: FilledButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                backgroundColor:
                                                    const Color(0xFFB91C1C),
                                              ),
                                              label: const Text('প্রত্যাখ্যান'),
                                            ),
                                          ),
                                        if (canReject && canAccept)
                                          const SizedBox(width: 8),
                                        if (canAccept)
                                          Expanded(
                                            child: FilledButton.icon(
                                              onPressed: () {
                                                onAcceptTeacherRequest?.call(
                                                  problem,
                                                  request.id,
                                                );
                                                Navigator.of(context).pop();
                                              },
                                              icon: const Icon(
                                                Icons.check_circle_rounded,
                                              ),
                                              label: const Text('গ্রহণ করুন'),
                                            ),
                                          ),
                                      ],
                                    )
                                  else if (isAccepted)
                                    const Text(
                                      'এই শিক্ষক নির্বাচিত হয়েছে।',
                                      style: TextStyle(
                                        color: Color(0xFF15803D),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  else if (hasAccepted)
                                    const Text(
                                      'অন্য শিক্ষক ইতোমধ্যে নির্বাচিত হয়েছে।',
                                      style: TextStyle(
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showRequestDetailsSheet(
    BuildContext context,
    TeacherRequest request, {
    required bool forStudent,
  }) async {
    final canTeacherAcceptReject = !forStudent &&
        !request.initiatedByTeacher &&
        request.status == TeacherRequestStatus.pending &&
        onUpdateIncomingRequestStatus != null;
    final canTeacherCancelSent = !forStudent &&
        request.initiatedByTeacher &&
        request.status == TeacherRequestStatus.pending &&
        onCancelTeacherSentRequest != null;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              14,
              14,
              14,
              MediaQuery.of(context).viewInsets.bottom + 14,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFDFEFE),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFCFE8DB)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            request.problemTitle,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      forStudent
                          ? 'শিক্ষক: ${request.teacherName}'
                          : 'শিক্ষার্থী: ${request.studentName}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'বাজেট: ${request.budget}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      request.problemDetails,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (request.imageBytes != null) ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          width: double.infinity,
                          height: 160,
                          child: Image.memory(
                            request.imageBytes!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    MiniPill(label: statusLabel(request.status)),
                    if (forStudent &&
                        request.status == TeacherRequestStatus.pending &&
                        onCancelSentRequest != null) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.tonalIcon(
                          onPressed: () {
                            onCancelSentRequest?.call(request.id);
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.cancel_rounded),
                          style: FilledButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFFB91C1C),
                          ),
                          label: const Text('অপেক্ষমান অনুরোধ বাতিল করুন'),
                        ),
                      ),
                    ],
                    if (canTeacherAcceptReject) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.tonalIcon(
                              onPressed: () {
                                onUpdateIncomingRequestStatus?.call(
                                  request.id,
                                  TeacherRequestStatus.rejected,
                                );
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.close_rounded),
                              style: FilledButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: const Color(0xFFB91C1C),
                              ),
                              label: const Text('প্রত্যাখ্যান'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {
                                onUpdateIncomingRequestStatus?.call(
                                  request.id,
                                  TeacherRequestStatus.accepted,
                                );
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.check_circle_rounded),
                              label: const Text('গ্রহণ'),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (canTeacherCancelSent) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.tonalIcon(
                          onPressed: () {
                            onCancelTeacherSentRequest?.call(request.id);
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.cancel_rounded),
                          style: FilledButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFFB91C1C),
                          ),
                          label: const Text('পাঠানো অনুরোধ বাতিল করুন'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = session.role == UserRole.user;
    final pendingSent = sentRequests
        .where((r) => r.status == TeacherRequestStatus.pending)
        .length;
    final teacherPendingSent = teacherSentRequests
        .where((r) => r.status == TeacherRequestStatus.pending)
        .length;

    final topStats = isStudent
        ? [
            DashboardStat(
              label: 'পোস্টকৃত সমস্যা',
              value: '${postedProblems.length}',
              icon: Icons.post_add_rounded,
            ),
            DashboardStat(
              label: 'পাঠানো অনুরোধ',
              value: '${sentRequests.length}',
              icon: Icons.send_rounded,
            ),
            DashboardStat(
              label: 'অপেক্ষমান',
              value: '$pendingSent',
              icon: Icons.hourglass_bottom_rounded,
            ),
          ]
        : [
            DashboardStat(
              label: 'আগত',
              value: '${incomingRequests.length}',
              icon: Icons.inbox_rounded,
            ),
            DashboardStat(
              label: 'পাঠানো',
              value: '${teacherSentRequests.length}',
              icon: Icons.send_rounded,
            ),
            DashboardStat(
              label: 'অপেক্ষমান পাঠানো',
              value: '$teacherPendingSent',
              icon: Icons.hourglass_bottom_rounded,
            ),
          ];

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
                  for (int i = 0; i < topStats.length; i++) ...[
                    ModernStatusStatCard(
                      label: topStats[i].label,
                      value: topStats[i].value,
                      icon: topStats[i].icon,
                    ),
                    if (i != topStats.length - 1) const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 14),
                  if (isStudent) ...[
                    const SectionTitle(
                      title: 'পোস্টকৃত সমস্যা',
                      icon: Icons.post_add_rounded,
                    ),
                    const SizedBox(height: 10),
                    if (postedProblems.isEmpty)
                      const EmptyStateCard(
                        message: 'এখনো কোনো সমস্যা পোস্ট করা হয়নি।',
                      )
                    else
                      for (int i = 0; i < postedProblems.length; i++) ...[
                        PostedProblemStatusCard(
                          problem: postedProblems[i],
                          relatedTeacherRequestCount:
                              _requestsForProblem(postedProblems[i]).length,
                          hasAcceptedTeacher: _requestsForProblem(
                            postedProblems[i],
                          ).any(
                            (r) => r.status == TeacherRequestStatus.accepted,
                          ),
                          onTap: () => _showProblemRequestsSheet(
                            context,
                            postedProblems[i],
                          ),
                        ),
                        if (i != postedProblems.length - 1)
                          const SizedBox(height: 10),
                      ],
                    const SizedBox(height: 14),
                    const SectionTitle(
                      title: 'শিক্ষক অনুরোধ',
                      icon: Icons.mark_email_read_rounded,
                    ),
                    const SizedBox(height: 10),
                    if (sentRequests.isEmpty)
                      const EmptyStateCard(
                        message:
                            'এখনো কোনো অনুরোধ পাঠানো হয়নি। শিক্ষকবৃন্দ ট্যাব থেকে পাঠান।',
                      )
                    else
                      for (int i = 0; i < sentRequests.length; i++) ...[
                        RequestStatusCard(
                          request: sentRequests[i],
                          forStudent: true,
                          onTap: () => _showRequestDetailsSheet(
                            context,
                            sentRequests[i],
                            forStudent: true,
                          ),
                        ),
                        if (i != sentRequests.length - 1)
                          const SizedBox(height: 12),
                      ],
                  ] else ...[
                    const SectionTitle(
                      title: 'আগত অনুরোধ',
                      icon: Icons.inbox_rounded,
                    ),
                    const SizedBox(height: 10),
                    if (incomingRequests.isEmpty)
                      const EmptyStateCard(
                        message: 'আপনার জন্য কোনো আগত অনুরোধ নেই।',
                      )
                    else
                      for (int i = 0; i < incomingRequests.length; i++) ...[
                        RequestStatusCard(
                          request: incomingRequests[i],
                          forStudent: false,
                          onTap: () => _showRequestDetailsSheet(
                            context,
                            incomingRequests[i],
                            forStudent: false,
                          ),
                        ),
                        if (i != incomingRequests.length - 1)
                          const SizedBox(height: 12),
                      ],
                    const SizedBox(height: 14),
                    const SectionTitle(
                      title: 'পাঠানো সমাধান অনুরোধ',
                      icon: Icons.send_rounded,
                    ),
                    const SizedBox(height: 10),
                    if (teacherSentRequests.isEmpty)
                      const EmptyStateCard(
                        message:
                            'এখনো কোনো সমাধান অনুরোধ পাঠানো হয়নি। হোম ট্যাবের সমস্যা থেকে পাঠান।',
                      )
                    else
                      for (int i = 0; i < teacherSentRequests.length; i++) ...[
                        RequestStatusCard(
                          request: teacherSentRequests[i],
                          forStudent: false,
                          onTap: () => _showRequestDetailsSheet(
                            context,
                            teacherSentRequests[i],
                            forStudent: false,
                          ),
                        ),
                        if (i != teacherSentRequests.length - 1)
                          const SizedBox(height: 12),
                      ],
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
