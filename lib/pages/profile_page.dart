import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_role.dart';
import '../utils/pinned_header_delegate.dart';
import '../widgets/app_header.dart';
import '../widgets/profile_value_box.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.session,
    required this.onLogout,
    required this.onShowNotifications,
    required this.unreadNotificationCount,
    required this.onRefresh,
  });

  final RoleSession session;
  final Future<void> Function() onLogout;
  final VoidCallback onShowNotifications;
  final int unreadNotificationCount;
  final Future<void> Function() onRefresh;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _institutionController = TextEditingController();
  Uint8List? _profileImageBytes;
  bool _isEditingProfile = false;
  String _gender = 'পুরুষ';

  String _dummyPhoneForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return '+8801912345678';
      case UserRole.teacher:
        return '+8801812345678';
      case UserRole.user:
        return '+8801712345678';
    }
  }

  String _dummyInstitutionForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Daffodil International University';
      case UserRole.teacher:
        return 'University of Dhaka';
      case UserRole.user:
        return 'Dhaka College';
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.session.name);
    _emailController = TextEditingController(text: widget.session.email);
    _phoneController.text = _dummyPhoneForRole(widget.session.role);
    _institutionController.text =
        _dummyInstitutionForRole(widget.session.role);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _institutionController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    try {
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() => _profileImageBytes = bytes);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('প্রোফাইল ছবি আপডেট করা যায়নি।')),
      );
    }
  }

  void _saveProfile() {
    setState(() => _isEditingProfile = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('প্রোফাইল তথ্য আপডেট করা হয়েছে।')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.session.role == UserRole.admin;

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: PinnedHeaderDelegate(
              height: 74,
              child: AppHeader(
                session: widget.session,
                onNotificationTap: widget.onShowNotifications,
                unreadNotificationCount: widget.unreadNotificationCount,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: () {
                          setState(
                            () => _isEditingProfile = !_isEditingProfile,
                          );
                        },
                        icon: Icon(
                          _isEditingProfile
                              ? Icons.check_rounded
                              : Icons.edit_rounded,
                          size: 16,
                        ),
                        label: Text(_isEditingProfile ? 'Done' : 'Edit'),
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          backgroundColor: const Color(0xFF1F8B5F),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 106,
                          height: 106,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E7A54), Color(0xFF2FBF95)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _profileImageBytes != null
                              ? Image.memory(
                                  _profileImageBytes!,
                                  fit: BoxFit.cover,
                                )
                              : Center(
                                  child: Text(
                                    _nameController.text.isEmpty
                                        ? 'S'
                                        : _nameController.text.characters.first
                                            .toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 38,
                                    ),
                                  ),
                                ),
                        ),
                        if (_isEditingProfile)
                          Positioned(
                            right: -6,
                            bottom: -6,
                            child: Material(
                              color: const Color(0xFF0D5A3C),
                              borderRadius: BorderRadius.circular(999),
                              child: InkWell(
                                onTap: _pickProfileImage,
                                borderRadius: BorderRadius.circular(999),
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.camera_alt_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          _nameController.text.isEmpty
                              ? 'নাম সেট করুন'
                              : _nameController.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: const Color(0xFF0E402C),
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          roleLabel(widget.session.role),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: const Color(0xFF5B6B63),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isEditingProfile) ...[
                    TextField(
                      controller: _nameController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'পূর্ণ নাম',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      onChanged: (_) => setState(() {}),
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'ইমেইল',
                        prefixIcon: Icon(Icons.alternate_email_rounded),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'ফোন নাম্বার',
                        prefixIcon: Icon(Icons.phone_rounded),
                      ),
                    ),
                    if (!isAdmin) ...[
                      const SizedBox(height: 10),
                      TextField(
                        controller: _institutionController,
                        decoration: const InputDecoration(
                          labelText: 'স্কুল/কলেজ/ইউনিভার্সিটি',
                          prefixIcon: Icon(Icons.school_rounded),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: _gender,
                        decoration: const InputDecoration(
                          labelText: 'জেন্ডার',
                          prefixIcon: Icon(Icons.wc_rounded),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'পুরুষ', child: Text('পুরুষ')),
                          DropdownMenuItem(value: 'নারী', child: Text('নারী')),
                          DropdownMenuItem(
                            value: 'অন্যান্য',
                            child: Text('অন্যান্য'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _gender = value);
                        },
                      ),
                    ],
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _saveProfile,
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('তথ্য সংরক্ষণ করুন'),
                      ),
                    ),
                  ] else ...[
                    ProfileValueBox(
                      title: 'নাম',
                      value: _nameController.text,
                      icon: Icons.person_rounded,
                    ),
                    const SizedBox(height: 10),
                    ProfileValueBox(
                      title: 'ইমেইল',
                      value: _emailController.text,
                      icon: Icons.email_rounded,
                    ),
                    const SizedBox(height: 10),
                    ProfileValueBox(
                      title: 'ফোন নাম্বার',
                      value: _phoneController.text,
                      icon: Icons.phone_rounded,
                    ),
                    if (!isAdmin) ...[
                      const SizedBox(height: 10),
                      ProfileValueBox(
                        title: 'স্কুল/কলেজ/ইউনিভার্সিটি',
                        value: _institutionController.text,
                        icon: Icons.school_rounded,
                      ),
                      const SizedBox(height: 10),
                      ProfileValueBox(
                        title: 'জেন্ডার',
                        value: _gender,
                        icon: Icons.wc_rounded,
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: widget.onLogout,
                        icon: const Icon(Icons.logout_rounded, size: 19),
                        label: const Text('লগআউট'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0D5A3C),
                          side: const BorderSide(color: Color(0xFFBFDDCE)),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
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
