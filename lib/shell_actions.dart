// shell_actions.dart
// Contains all business-logic actions for SolveMateShell as a mixin.
// The mixin is applied by _SolveMateShellState in shell.dart.

import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'models/user_role.dart';
import 'models/teacher_models.dart';
import 'models/problem_models.dart';
import 'models/notification_models.dart';
import 'data/app_store.dart';
import 'data/login_repository.dart';

mixin ShellActions<T extends StatefulWidget> on State<T> {
  // ── Must be provided by the host state ────────────────────────────────────
  RoleSession get session;

  // ── Data getters ──────────────────────────────────────────────────────────

  List<NotificationItem> get sessionNotifications => AppStore.notifications
      .where((item) => item.recipientEmail == session.email)
      .toList(growable: false);

  List<TeacherRequest> get studentRequests =>
      AppStore.requests
          .where((r) => r.studentEmail == session.email)
          .toList(growable: false)
        ..sort((a, b) => b.requestedAtMs.compareTo(a.requestedAtMs));

  List<PostedProblemStatus> get studentPostedProblems =>
      AppStore.postedProblems
          .where((p) => p.studentEmail == session.email)
          .toList(growable: false)
        ..sort((a, b) => b.postedAtMs.compareTo(a.postedAtMs));

  List<TeacherRequest> get teacherIncomingRequests =>
      AppStore.requests
          .where(
            (r) => r.teacherEmail == session.email && !r.initiatedByTeacher,
          )
          .toList(growable: false)
        ..sort((a, b) => b.requestedAtMs.compareTo(a.requestedAtMs));

  List<TeacherRequest> get teacherSentRequests =>
      AppStore.requests
          .where(
            (r) => r.teacherEmail == session.email && r.initiatedByTeacher,
          )
          .toList(growable: false)
        ..sort((a, b) => b.requestedAtMs.compareTo(a.requestedAtMs));

  List<TeacherProfile> get sortedTeachers {
    final items = [...AppStore.teachers];
    items.sort((a, b) {
      if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
      return b.rating.compareTo(a.rating);
    });
    return items;
  }

  List<AuthUser> usersByRole(UserRole role) => LoginRepository.demoUsers
      .where((u) => u.role == role)
      .toList(growable: false);

  List<PostedProblemStatus> get allPostedProblems =>
      [...AppStore.postedProblems]
        ..sort((a, b) => b.postedAtMs.compareTo(a.postedAtMs));

  String nameByEmail(String email) {
    final matched = LoginRepository.demoUsers
        .where((u) => u.email.toLowerCase() == email.toLowerCase())
        .firstOrNull;
    return matched?.name ?? email;
  }

  int get unreadNotificationCount =>
      sessionNotifications.where((item) => !item.isRead).length;

  Future<void> refreshShell() async =>
      Future<void>.delayed(const Duration(milliseconds: 250));

  // ── Notification actions ──────────────────────────────────────────────────

  void markAllNotificationsRead() {
    setState(() {
      for (int i = 0; i < AppStore.notifications.length; i++) {
        final n = AppStore.notifications[i];
        if (n.recipientEmail == session.email) {
          AppStore.notifications[i] = n.copyWith(isRead: true);
        }
      }
    });
  }

  // ── Student → Teacher request ─────────────────────────────────────────────

  void sendRequestToTeacher(
    TeacherProfile teacher,
    String title,
    String details,
    String budget,
    Uint8List? imageBytes,
    String? imageName,
  ) {
    final request = TeacherRequest(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      studentName: session.name,
      studentEmail: session.email,
      teacherName: teacher.name,
      teacherEmail: teacher.email,
      problemTitle: title,
      problemDetails: details,
      budget: budget,
      requestedAtMs: DateTime.now().millisecondsSinceEpoch,
      imageBytes: imageBytes,
      imageName: imageName,
    );

    setState(() {
      AppStore.requests.insert(0, request);
      AppStore.notifications.insert(
        0,
        NotificationItem(
          title: '${session.name} থেকে নতুন সরাসরি অনুরোধ',
          message: request.problemTitle,
          timeLabel: 'এইমাত্র',
          icon: Icons.mark_email_unread_rounded,
          recipientEmail: request.teacherEmail,
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${teacher.name}-কে অনুরোধ পাঠানো হয়েছে।')),
    );
  }

  // ── Teacher → Student request (for a posted problem) ─────────────────────

  void sendRequestToStudentForProblem(PostedProblem problem) {
    if (session.role != UserRole.teacher) return;

    final studentEmail = problem.posterEmail?.trim() ?? '';
    if (studentEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('এই সমস্যার শিক্ষার্থীর তথ্য পাওয়া যায়নি।'),
        ),
      );
      return;
    }

    if (studentEmail == session.email) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('নিজের সমস্যায় অনুরোধ পাঠানো যাবে না।'),
        ),
      );
      return;
    }

    final alreadyRequested = AppStore.requests.any(
      (r) =>
          r.initiatedByTeacher &&
          r.teacherEmail == session.email &&
          r.studentEmail == studentEmail &&
          r.problemTitle == problem.title &&
          r.status != TeacherRequestStatus.rejected,
    );

    if (alreadyRequested) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('এই সমস্যার জন্য আপনার অনুরোধ আগে থেকেই পাঠানো আছে।'),
        ),
      );
      return;
    }

    final request = TeacherRequest(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      studentName: (problem.posterName ?? '').trim().isEmpty
          ? 'শিক্ষার্থী'
          : problem.posterName!.trim(),
      studentEmail: studentEmail,
      teacherName: session.name,
      teacherEmail: session.email,
      problemTitle: problem.title,
      problemDetails: problem.description,
      budget: problem.budget,
      requestedAtMs: DateTime.now().millisecondsSinceEpoch,
      imageBytes: problem.imageBytes,
      initiatedByTeacher: true,
    );

    setState(() {
      AppStore.requests.insert(0, request);
      AppStore.notifications.insert(
        0,
        NotificationItem(
          title: '${session.name} আপনার সমস্যার সমাধানে অনুরোধ পাঠিয়েছে',
          message: request.problemTitle,
          timeLabel: 'এইমাত্র',
          icon: Icons.send_rounded,
          recipientEmail: studentEmail,
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('শিক্ষার্থীর কাছে সমাধান অনুরোধ পাঠানো হয়েছে।'),
      ),
    );
  }

  // ── Request status updates ────────────────────────────────────────────────

  void updateTeacherRequestStatus(
    String requestId,
    TeacherRequestStatus status,
  ) {
    final index = AppStore.requests.indexWhere((item) => item.id == requestId);
    if (index == -1) return;

    final current = AppStore.requests[index];
    if (current.status != TeacherRequestStatus.pending) return;

    setState(() {
      AppStore.requests[index] = current.copyWith(status: status);
      AppStore.notifications.insert(
        0,
        NotificationItem(
          title:
              '${current.teacherName} আপনার অনুরোধ ${statusLabel(status).toLowerCase()} করেছে',
          message: current.problemTitle,
          timeLabel: 'এইমাত্র',
          icon: status == TeacherRequestStatus.accepted
              ? Icons.check_circle_rounded
              : Icons.cancel_rounded,
          recipientEmail: current.studentEmail,
        ),
      );
    });
  }

  // ── Posted problem actions ────────────────────────────────────────────────

  void recordPostedProblem(PostedProblem problem) {
    setState(() {
      AppStore.postedProblems.insert(
        0,
        PostedProblemStatus(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          studentEmail: session.email,
          title: problem.title,
          budget: problem.budget,
          postedAtMs: problem.postedAtMs ?? DateTime.now().millisecondsSinceEpoch,
          problemDetails: problem.description,
          subject: problem.subject,
          problemType: problem.problemType,
          imageAsset: problem.imageAsset,
          imageBytes: problem.imageBytes,
        ),
      );
    });
  }

  void acceptTeacherForProblem(
    PostedProblemStatus problem,
    String selectedRequestId,
  ) {
    final relatedRequests = AppStore.requests
        .where(
          (r) =>
              r.studentEmail == session.email &&
              r.problemTitle == problem.title,
        )
        .toList(growable: false);

    if (relatedRequests.isEmpty) return;

    final selectedRequest =
        relatedRequests.where((r) => r.id == selectedRequestId).firstOrNull;
    if (selectedRequest == null) return;

    if (relatedRequests.length == 1 &&
        selectedRequest.status == TeacherRequestStatus.accepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('এই শিক্ষক আগে থেকেই নির্বাচিত।')),
      );
      return;
    }

    setState(() {
      for (final request in relatedRequests) {
        final isSelected = request.id == selectedRequestId;
        if (isSelected) {
          final index =
              AppStore.requests.indexWhere((item) => item.id == request.id);
          if (index != -1) {
            AppStore.requests[index] = AppStore.requests[index].copyWith(
              status: TeacherRequestStatus.accepted,
            );
          }
        }
        AppStore.notifications.insert(
          0,
          NotificationItem(
            title: isSelected
                ? '${session.name} আপনার অনুরোধ গ্রহণ করেছে'
                : '${session.name} অন্য শিক্ষক নির্বাচন করেছে',
            message: problem.title,
            timeLabel: 'এইমাত্র',
            icon: isSelected
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            recipientEmail: request.teacherEmail,
          ),
        );
      }
      AppStore.requests.removeWhere(
        (r) =>
            r.studentEmail == session.email &&
            r.problemTitle == problem.title &&
            r.id != selectedRequestId,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${selectedRequest.teacherName} নির্বাচন করা হয়েছে।'),
      ),
    );
  }

  void rejectTeacherForProblem(PostedProblemStatus problem, String requestId) {
    final index = AppStore.requests.indexWhere(
      (r) =>
          r.id == requestId &&
          r.studentEmail == session.email &&
          r.problemTitle == problem.title,
    );
    if (index == -1) return;

    final current = AppStore.requests[index];
    if (current.status != TeacherRequestStatus.pending) return;

    setState(() {
      AppStore.requests[index] =
          current.copyWith(status: TeacherRequestStatus.rejected);
      AppStore.notifications.insert(
        0,
        NotificationItem(
          title: '${session.name} আপনার অনুরোধ প্রত্যাখ্যান করেছে',
          message: problem.title,
          timeLabel: 'এইমাত্র',
          icon: Icons.cancel_rounded,
          recipientEmail: current.teacherEmail,
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${current.teacherName}-এর অনুরোধ প্রত্যাখ্যান করা হয়েছে।',
        ),
      ),
    );
  }

  void cancelStudentPendingRequest(String requestId) {
    final index = AppStore.requests.indexWhere(
      (r) => r.id == requestId && r.studentEmail == session.email,
    );
    if (index == -1) return;

    final current = AppStore.requests[index];
    if (current.status != TeacherRequestStatus.pending) return;

    setState(() {
      AppStore.requests.removeAt(index);
      AppStore.notifications.insert(
        0,
        NotificationItem(
          title: '${session.name} অনুরোধ বাতিল করেছে',
          message: current.problemTitle,
          timeLabel: 'এইমাত্র',
          icon: Icons.info_outline_rounded,
          recipientEmail: current.teacherEmail,
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('অপেক্ষমান অনুরোধ বাতিল করা হয়েছে।')),
    );
  }

  void cancelTeacherPendingSentRequest(String requestId) {
    final index = AppStore.requests.indexWhere(
      (r) =>
          r.id == requestId &&
          r.teacherEmail == session.email &&
          r.initiatedByTeacher,
    );
    if (index == -1) return;

    final current = AppStore.requests[index];
    if (current.status != TeacherRequestStatus.pending) return;

    setState(() {
      AppStore.requests.removeAt(index);
      AppStore.notifications.insert(
        0,
        NotificationItem(
          title: '${session.name} সমাধান অনুরোধ বাতিল করেছে',
          message: current.problemTitle,
          timeLabel: 'এইমাত্র',
          icon: Icons.info_outline_rounded,
          recipientEmail: current.studentEmail,
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('পাঠানো অনুরোধ বাতিল করা হয়েছে।')),
    );
  }

  // ── Admin actions ─────────────────────────────────────────────────────────

  void deletePostedProblemAsAdmin(PostedProblemStatus problem) {
    setState(() {
      AppStore.postedProblems.removeWhere((item) => item.id == problem.id);
      AppStore.requests.removeWhere(
        (r) =>
            r.studentEmail == problem.studentEmail &&
            r.problemTitle == problem.title,
      );
      AppStore.notifications.insert(
        0,
        NotificationItem(
          title: 'আপনার পোস্ট অ্যাডমিন দ্বারা মুছে ফেলা হয়েছে',
          message: problem.title,
          timeLabel: 'এইমাত্র',
          icon: Icons.delete_outline_rounded,
          recipientEmail: problem.studentEmail,
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('পোস্ট সফলভাবে মুছে ফেলা হয়েছে।')),
    );
  }

  void banUserAsAdmin({
    required String email,
    required String durationLabel,
    int? days,
  }) {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final untilMs = days == null
        ? null
        : DateTime.now().add(Duration(days: days)).millisecondsSinceEpoch;

    setState(() {
      AppStore.bans[email.toLowerCase()] = BanRecord(
        startedAtMs: nowMs,
        untilMs: untilMs,
        durationLabel: durationLabel,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$email ban করা হয়েছে ($durationLabel)।')),
    );
  }

  void unbanUserAsAdmin(String email) {
    setState(() => AppStore.bans.remove(email.toLowerCase()));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$email এর ban তুলে নেওয়া হয়েছে।')),
    );
  }
}
