// shell_notification_panel.dart
// Slide-in notification panel shown when the bell icon is tapped.

import 'package:flutter/material.dart';

import 'models/user_role.dart';
import 'models/teacher_models.dart';
import 'models/notification_models.dart';
import 'widgets/common_widgets.dart';
import 'widgets/request_cards.dart';

/// Shows the slide-in notification panel as a general dialog.
///
/// [session]                  – current user session
/// [sessionNotifications]     – pre-filtered notifications for this user
/// [teacherIncomingRequests]  – pending direct requests (teacher role only)
/// [onMarkAllRead]            – callback to mark all notifications read
/// [onAcceptRequest]          – callback when teacher accepts a request
/// [onRejectRequest]          – callback when teacher rejects a request
Future<void> showNotificationPanel({
  required BuildContext context,
  required RoleSession session,
  required List<NotificationItem> sessionNotifications,
  required List<TeacherRequest> teacherIncomingRequests,
  required VoidCallback onMarkAllRead,
  required void Function(String requestId, TeacherRequestStatus status)
      onUpdateRequestStatus,
}) async {
  var sheetNotifications = sessionNotifications
      .map((item) => item.copyWith())
      .toList(growable: false);

  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'নোটিফিকেশনসমূহ',
    barrierColor: Colors.black.withValues(alpha: 0.25),
    transitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (ctx, animation, secondaryAnimation) {
      return SafeArea(
        child: Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(ctx).size.width > 700
                  ? 420
                  : MediaQuery.of(ctx).size.width * 0.9,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
                border: Border.all(color: const Color(0xFFCFE8DB)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: StatefulBuilder(
                  builder: (ctx2, setSheetState) {
                    final pendingRequests = teacherIncomingRequests
                        .where((r) => r.status == TeacherRequestStatus.pending)
                        .toList(growable: false);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Header ──────────────────────────────────────────
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFFDDF4E8),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.notifications_active_rounded,
                                color: Color(0xFF1F6F4A),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'নোটিফিকেশনসমূহ',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(ctx2)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0E402C),
                                    ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(ctx2).pop(),
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // ── Mark all read button ─────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.tonalIcon(
                            onPressed: () {
                              onMarkAllRead();
                              setSheetState(() {
                                sheetNotifications = sheetNotifications
                                    .map((n) => n.copyWith(isRead: true))
                                    .toList(growable: false);
                              });
                            },
                            icon: const Icon(Icons.done_all_rounded),
                            label: const Text('সবগুলো পড়া হিসেবে চিহ্নিত করুন'),
                            style: FilledButton.styleFrom(
                              foregroundColor: const Color(0xFF0F5D3F),
                              backgroundColor: const Color(0xFFEAF7F0),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ── List ─────────────────────────────────────────────
                        Expanded(
                          child: ListView(
                            children: [
                              // Pending direct requests (teacher only)
                              if (session.role == UserRole.teacher &&
                                  pendingRequests.isNotEmpty) ...[
                                Text(
                                  'সরাসরি অনুরোধ',
                                  style: Theme.of(ctx2)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF0E402C),
                                      ),
                                ),
                                const SizedBox(height: 8),
                                for (final request in pendingRequests)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: TeacherIncomingRequestCard(
                                      request: request,
                                      onAccept: () {
                                        onUpdateRequestStatus(
                                          request.id,
                                          TeacherRequestStatus.accepted,
                                        );
                                        setSheetState(() {
                                          sheetNotifications =
                                              sessionNotifications
                                                  .map((n) => n.copyWith())
                                                  .toList(growable: false);
                                        });
                                      },
                                      onReject: () {
                                        onUpdateRequestStatus(
                                          request.id,
                                          TeacherRequestStatus.rejected,
                                        );
                                        setSheetState(() {
                                          sheetNotifications =
                                              sessionNotifications
                                                  .map((n) => n.copyWith())
                                                  .toList(growable: false);
                                        });
                                      },
                                    ),
                                  ),
                                const SizedBox(height: 6),
                              ],

                              // Empty state
                              if (sheetNotifications.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FCFA),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFD8EBDD),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDDF4E8),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.notifications_none_rounded,
                                          color: Color(0xFF1F6F4A),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'এখনো কোনো নোটিফিকেশন নেই।',
                                          style: Theme.of(ctx2)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: const Color(0xFF475569),
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                for (int i = 0;
                                    i < sheetNotifications.length;
                                    i++) ...[
                                  NotificationTile(
                                      item: sheetNotifications[i]),
                                  if (i != sheetNotifications.length - 1)
                                    const SizedBox(height: 10),
                                ],
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (ctx, animation, secondaryAnimation, child) {
      final tween = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}
