// shell_drawer.dart
// The side navigation drawer for SolveMateShell.

import 'package:flutter/material.dart';

import 'models/user_role.dart';
import 'widgets/common_widgets.dart';

/// A data class representing a single bottom-nav / drawer tab entry.
class TabItem {
  const TabItem({required this.label, required this.icon});
  final String label;
  final IconData icon;
}

/// Returns the tab list for a given [role].
List<TabItem> tabsForRole(UserRole role) {
  if (role == UserRole.admin) {
    return const [
      TabItem(label: 'অ্যাডমিন হোম', icon: Icons.admin_panel_settings_rounded),
      TabItem(label: 'শিক্ষক', icon: Icons.school_rounded),
      TabItem(label: 'শিক্ষার্থী', icon: Icons.groups_rounded),
      TabItem(label: 'প্রোফাইল', icon: Icons.person_rounded),
    ];
  }
  if (role == UserRole.teacher) {
    return const [
      TabItem(label: 'হোম', icon: Icons.home_rounded),
      TabItem(label: 'স্ট্যাটাস', icon: Icons.pending_actions_rounded),
      TabItem(label: 'প্রোফাইল', icon: Icons.person_rounded),
    ];
  }
  return const [
    TabItem(label: 'হোম', icon: Icons.home_rounded),
    TabItem(label: 'শিক্ষকবৃন্দ', icon: Icons.groups_rounded),
    TabItem(label: 'স্ট্যাটাস', icon: Icons.pending_actions_rounded),
    TabItem(label: 'প্রোফাইল', icon: Icons.person_rounded),
  ];
}

/// The slide-out navigation drawer shown via the hamburger / swipe gesture.
class ShellDrawer extends StatelessWidget {
  const ShellDrawer({
    super.key,
    required this.session,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.onLogout,
  });

  final RoleSession session;
  final List<TabItem> tabs;
  final int selectedIndex;
  final void Function(int index) onTabSelected;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      width: 320,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFF4FBF7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          border: Border.all(color: const Color(0xFFD8EBDD)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0B3A27).withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          child: Column(
            children: [
              // ── User header ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDF4E8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          session.name.characters.first.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF0F5D3F),
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: const Color(0xFF0E402C),
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            roleLabel(session.role),
                            style:
                                Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: const Color(0xFF64748B),
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Nav tiles ─────────────────────────────────────────────────
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: tabs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: DrawerNavTile(
                        label: tabs[index].label,
                        icon: tabs[index].icon,
                        selected: selectedIndex == index,
                        onTap: () {
                          onTabSelected(index);
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  },
                ),
              ),

              // ── Footer: logout + tagline ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: onLogout,
                        icon: const Icon(Icons.logout_rounded, size: 19),
                        label: const Text('লগআউট'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0D5A3C),
                          backgroundColor: Colors.white.withValues(alpha: 0.4),
                          side: const BorderSide(color: Color(0xFFBFDDCE)),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Solve Mate দিয়ে দ্রুত শিখুন, বুদ্ধিমত্তায় সমাধান করুন',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF4B6B5A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
