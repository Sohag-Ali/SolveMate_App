// shell.dart
// Thin orchestrator for SolveMateShell.
// Business logic  → shell_actions.dart  (ShellActions mixin)
// Notification UI → shell_notification_panel.dart (showNotificationPanel)
// Drawer UI       → shell_drawer.dart  (ShellDrawer + tabsForRole)

import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'models/user_role.dart';
import 'models/teacher_models.dart';
import 'models/notification_models.dart';
import 'data/app_store.dart';
import 'shell_actions.dart';
import 'shell_drawer.dart';
import 'shell_notification_panel.dart';
import 'pages/home_page.dart';
import 'pages/teachers_page.dart';
import 'pages/request_status_page.dart';
import 'pages/profile_page.dart';
import 'pages/admin_pages.dart';

class SolveMateShell extends StatefulWidget {
  const SolveMateShell({
    super.key,
    required this.session,
    required this.onLogout,
  });

  final RoleSession session;
  final Future<void> Function() onLogout;

  @override
  State<SolveMateShell> createState() => _SolveMateShellState();
}

class _SolveMateShellState extends State<SolveMateShell>
    with ShellActions<SolveMateShell> {
  int _selectedIndex = 0;

  // ShellActions mixin requires this getter.
  @override
  RoleSession get session => widget.session;

  Future<void> _openNotifications() => showNotificationPanel(
    context: context,
    session: widget.session,
    sessionNotifications: sessionNotifications,
    teacherIncomingRequests: teacherIncomingRequests,
    onMarkAllRead: markAllNotificationsRead,
    onUpdateRequestStatus: updateTeacherRequestStatus,
  );

  List<Widget> _buildPages(bool isAdmin, bool isTeacher) {
    if (isAdmin) {
      return [
        AdminDashboardPage(
          session: widget.session,
          onShowNotifications: _openNotifications,
          unreadNotificationCount: unreadNotificationCount,
          totalTeachers: usersByRole(UserRole.teacher).length,
          totalStudents: usersByRole(UserRole.user).length,
          postedProblems: allPostedProblems,
          studentNameByEmail: nameByEmail,
          onDeleteProblem: deletePostedProblemAsAdmin,
          onRefresh: refreshShell,
        ),
        AdminUserManagementPage(
          session: widget.session,
          onShowNotifications: _openNotifications,
          unreadNotificationCount: unreadNotificationCount,
          pageTitle: 'শিক্ষক ম্যানেজমেন্ট',
          users: usersByRole(UserRole.teacher),
          bans: Map<String, BanRecord>.from(AppStore.bans),
          onBanUser: banUserAsAdmin,
          onUnbanUser: unbanUserAsAdmin,
          onRefresh: refreshShell,
        ),
        AdminUserManagementPage(
          session: widget.session,
          onShowNotifications: _openNotifications,
          unreadNotificationCount: unreadNotificationCount,
          pageTitle: 'শিক্ষার্থী ম্যানেজমেন্ট',
          users: usersByRole(UserRole.user),
          bans: Map<String, BanRecord>.from(AppStore.bans),
          onBanUser: banUserAsAdmin,
          onUnbanUser: unbanUserAsAdmin,
          onRefresh: refreshShell,
        ),
        ProfilePage(
          session: widget.session,
          onLogout: widget.onLogout,
          onShowNotifications: _openNotifications,
          unreadNotificationCount: unreadNotificationCount,
          onRefresh: refreshShell,
        ),
      ];
    }

    return [
      HomePage(
        session: widget.session,
        onViewTeachers: () => setState(() => _selectedIndex = 1),
        onShowNotifications: _openNotifications,
        unreadNotificationCount: unreadNotificationCount,
        onProblemPosted: recordPostedProblem,
        onTeacherSendRequestForProblem: sendRequestToStudentForProblem,
        onRefresh: refreshShell,
      ),
      if (!isTeacher)
        TeachersPage(
          session: widget.session,
          onShowNotifications: _openNotifications,
          unreadNotificationCount: unreadNotificationCount,
          teachers: sortedTeachers,
          onSendRequest:
              (
                TeacherProfile teacher,
                String title,
                String details,
                String budget,
                Uint8List? imageBytes,
                String? imageName,
              ) => sendRequestToTeacher(
                teacher,
                title,
                details,
                budget,
                imageBytes,
                imageName,
              ),
          sentRequestCount: studentRequests.length,
          onRefresh: refreshShell,
        ),
      RequestStatusPage(
        session: widget.session,
        onShowNotifications: _openNotifications,
        unreadNotificationCount: unreadNotificationCount,
        sentRequests: studentRequests,
        incomingRequests: teacherIncomingRequests,
        teacherSentRequests: teacherSentRequests,
        postedProblems: studentPostedProblems,
        onAcceptTeacherRequest: acceptTeacherForProblem,
        onRejectTeacherRequest: rejectTeacherForProblem,
        onUpdateIncomingRequestStatus: updateTeacherRequestStatus,
        onCancelSentRequest: cancelStudentPendingRequest,
        onCancelTeacherSentRequest: cancelTeacherPendingSentRequest,
        onRefresh: refreshShell,
      ),
      ProfilePage(
        session: widget.session,
        onLogout: widget.onLogout,
        onShowNotifications: _openNotifications,
        unreadNotificationCount: unreadNotificationCount,
        onRefresh: refreshShell,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.session.role == UserRole.admin;
    final isTeacher = widget.session.role == UserRole.teacher;
    final tabs = tabsForRole(widget.session.role);
    final pages = _buildPages(isAdmin, isTeacher);

    var selectedIndex = _selectedIndex;
    if (selectedIndex >= pages.length) selectedIndex = pages.length - 1;

    return Scaffold(
      drawer: ShellDrawer(
        session: widget.session,
        tabs: tabs,
        selectedIndex: selectedIndex,
        onTabSelected: (index) => setState(() => _selectedIndex = index),
        onLogout: widget.onLogout,
      ),
      body: SafeArea(
        child: IndexedStack(index: selectedIndex, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (value) =>
            setState(() => _selectedIndex = value),
        destinations: [
          for (final tab in tabs)
            NavigationDestination(icon: Icon(tab.icon), label: tab.label),
        ],
      ),
    );
  }
}
