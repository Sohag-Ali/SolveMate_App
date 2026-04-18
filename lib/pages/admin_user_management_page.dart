import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../models/notification_models.dart';
import '../utils/pinned_header_delegate.dart';
import '../widgets/app_header.dart';
import '../widgets/common_widgets.dart';

class AdminUserManagementPage extends StatelessWidget {
  const AdminUserManagementPage({
    super.key,
    required this.session,
    required this.onShowNotifications,
    required this.unreadNotificationCount,
    required this.pageTitle,
    required this.users,
    required this.bans,
    required this.onBanUser,
    required this.onUnbanUser,
    required this.onRefresh,
  });

  final RoleSession session;
  final VoidCallback onShowNotifications;
  final int unreadNotificationCount;
  final String pageTitle;
  final List<AuthUser> users;
  final Map<String, BanRecord> bans;
  final void Function({
    required String email,
    required String durationLabel,
    int? days,
  }) onBanUser;
  final void Function(String email) onUnbanUser;
  final Future<void> Function() onRefresh;

  Future<void> _showBanOptions(BuildContext context, AuthUser user) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFDFEFE),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFCFE8DB)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    '${user.name} - Ban Duration',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: const Icon(Icons.timer_rounded),
                    title: const Text('1 Day'),
                    onTap: () {
                      onBanUser(
                        email: user.email,
                        durationLabel: '1 day',
                        days: 1,
                      );
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.timer_rounded),
                    title: const Text('7 Days'),
                    onTap: () {
                      onBanUser(
                        email: user.email,
                        durationLabel: '7 days',
                        days: 7,
                      );
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.timer_rounded),
                    title: const Text('1 Month'),
                    onTap: () {
                      onBanUser(
                        email: user.email,
                        durationLabel: '1 month',
                        days: 30,
                      );
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.block_rounded),
                    title: const Text('Permanent'),
                    onTap: () {
                      onBanUser(
                        email: user.email,
                        durationLabel: 'permanent',
                      );
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
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
                  SectionTitle(
                    title: pageTitle,
                    subtitle:
                        'ইউজার ban/unban করুন: 1 day, 7 day, 1 month বা permanent।',
                    icon: Icons.gpp_bad_rounded,
                  ),
                  const SizedBox(height: 10),
                  if (users.isEmpty)
                    const EmptyStateCard(message: 'কোনো ইউজার পাওয়া যায়নি।')
                  else
                    for (int i = 0; i < users.length; i++) ...[
                      Builder(
                        builder: (context) {
                          final user = users[i];
                          final ban = bans[user.email.toLowerCase()];
                          final isBanned = ban != null && ban.isActive;

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isBanned
                                    ? const Color(0xFFF4B6C2)
                                    : const Color(0xFFCFE8DB),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        user.name,
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
                                      label: isBanned
                                          ? 'Banned (${ban.statusLabel})'
                                          : 'Active',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  user.email,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: const Color(0xFF475569),
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Phone: ${user.phone}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: const Color(0xFF475569),
                                      ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: FilledButton.tonalIcon(
                                        onPressed: () =>
                                            _showBanOptions(context, user),
                                        icon: const Icon(Icons.block_rounded),
                                        style: FilledButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFB91C1C),
                                          foregroundColor: Colors.white,
                                        ),
                                        label: const Text('Ban'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: FilledButton.tonalIcon(
                                        onPressed: isBanned
                                            ? () => onUnbanUser(user.email)
                                            : null,
                                        icon: const Icon(
                                          Icons.check_circle_rounded,
                                        ),
                                        label: const Text('Unban'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      if (i != users.length - 1) const SizedBox(height: 10),
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
