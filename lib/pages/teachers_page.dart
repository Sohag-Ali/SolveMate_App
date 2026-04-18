import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_role.dart';
import '../models/teacher_models.dart';
import '../utils/pinned_header_delegate.dart';
import '../widgets/app_header.dart';
import '../widgets/common_widgets.dart';

class TeachersPage extends StatefulWidget {
  const TeachersPage({
    super.key,
    required this.session,
    required this.onShowNotifications,
    required this.unreadNotificationCount,
    required this.teachers,
    required this.onSendRequest,
    required this.sentRequestCount,
    required this.onRefresh,
  });

  final RoleSession session;
  final VoidCallback onShowNotifications;
  final int unreadNotificationCount;
  final List<TeacherProfile> teachers;
  final void Function(TeacherProfile, String, String, String, Uint8List?, String?) onSendRequest;
  final int sentRequestCount;
  final Future<void> Function() onRefresh;

  @override
  State<TeachersPage> createState() => _TeachersPageState();
}

class _TeachersPageState extends State<TeachersPage> {
  String? _selectedSubject;
  double? _minimumRating;

  String _subjectLabel(String subject) {
    final parts = subject.split('|');
    return parts.first.trim();
  }

  List<String> get _availableSubjects {
    final subjects = widget.teachers
        .map((t) => _subjectLabel(t.subject))
        .toSet()
        .toList();
    subjects.sort();
    return subjects;
  }

  List<TeacherProfile> get _filteredTeachers {
    final teachers = widget.teachers.where((teacher) {
      final matchesSubject = _selectedSubject == null ||
          _subjectLabel(teacher.subject) == _selectedSubject;
      final matchesRating =
          _minimumRating == null || teacher.rating >= _minimumRating!;
      return matchesSubject && matchesRating;
    }).toList();

    teachers.sort((left, right) {
      if (left.isActive != right.isActive) return left.isActive ? -1 : 1;
      return right.rating.compareTo(left.rating);
    });

    return teachers;
  }

  void _clearFilters() {
    setState(() {
      _selectedSubject = null;
      _minimumRating = null;
    });
  }

  Future<void> _resetAndRefresh() async {
    _clearFilters();
    await widget.onRefresh();
  }

  Future<void> _showTeacherFilterSheet(BuildContext context) async {
    String? draftSubject = _selectedSubject;
    double? draftRating = _minimumRating;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.tune_rounded, color: Color(0xFF0F6A47)),
                        const SizedBox(width: 8),
                        Text(
                          'শিক্ষক ফিল্টার',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setSheetState(() {
                              draftSubject = null;
                              draftRating = null;
                            });
                          },
                          child: const Text('মুছুন'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String?>(
                      initialValue: draftSubject,
                      decoration: const InputDecoration(labelText: 'বিষয়'),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('সব বিষয়'),
                        ),
                        ..._availableSubjects.map(
                          (s) => DropdownMenuItem<String?>(
                            value: s,
                            child: Text(s),
                          ),
                        ),
                      ],
                      onChanged: (value) =>
                          setSheetState(() => draftSubject = value),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<double?>(
                      initialValue: draftRating,
                      decoration: const InputDecoration(
                        labelText: 'সর্বনিম্ন রেটিং',
                      ),
                      items: const [
                        DropdownMenuItem<double?>(
                          value: null,
                          child: Text('যেকোনো রেটিং'),
                        ),
                        DropdownMenuItem<double?>(
                          value: 4.0,
                          child: Text('4.0 এবং তার বেশি'),
                        ),
                        DropdownMenuItem<double?>(
                          value: 4.5,
                          child: Text('4.5 এবং তার বেশি'),
                        ),
                        DropdownMenuItem<double?>(
                          value: 4.8,
                          child: Text('4.8 এবং তার বেশি'),
                        ),
                      ],
                      onChanged: (value) =>
                          setSheetState(() => draftRating = value),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          setState(() {
                            _selectedSubject = draftSubject;
                            _minimumRating = draftRating;
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text('ফিল্টার প্রয়োগ করুন'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showDirectRequestSheet(
    BuildContext context,
    TeacherProfile teacher,
  ) async {
    final titleController = TextEditingController();
    final detailsController = TextEditingController();
    final budgetController = TextEditingController();
    final picker = ImagePicker();
    Uint8List? selectedImageBytes;
    String? selectedImageName;

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
            child: StatefulBuilder(
              builder: (context, setSheetState) {
                Future<void> pickAttachment() async {
                  try {
                    final picked = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 85,
                    );
                    if (picked == null) return;
                    final bytes = await picked.readAsBytes();
                    if (!context.mounted) return;
                    setSheetState(() {
                      selectedImageBytes = bytes;
                      selectedImageName = picked.name;
                    });
                  } catch (_) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Image attachment could not be selected.'),
                      ),
                    );
                  }
                }

                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDFEFE),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFCFE8DB)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0B3A27).withValues(alpha: 0.14),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF0F6A47),
                                      Color(0xFF2BA074),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'সরাসরি অনুরোধ পাঠান',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF0E402C),
                                          ),
                                    ),
                                    Text(
                                      teacher.name,
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
                              IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.close_rounded),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: titleController,
                            decoration: const InputDecoration(
                              labelText: 'Problem title',
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: detailsController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'সমস্যার বিবরণ',
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: budgetController,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'Budget'),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              OutlinedButton.icon(
                                onPressed: pickAttachment,
                                icon: const Icon(Icons.photo_library_rounded),
                                label: const Text('Attach image (optional)'),
                              ),
                              if (selectedImageBytes != null) ...[
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () {
                                    setSheetState(() {
                                      selectedImageBytes = null;
                                      selectedImageName = null;
                                    });
                                  },
                                  child: const Text('Remove'),
                                ),
                              ],
                            ],
                          ),
                          if (selectedImageName != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Selected: $selectedImageName',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: const Color(0xFF475569)),
                            ),
                          ],
                          if (selectedImageBytes != null) ...[
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: SizedBox(
                                width: double.infinity,
                                height: 150,
                                child: Image.memory(
                                  selectedImageBytes!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () {
                                final title = titleController.text.trim();
                                final details = detailsController.text.trim();
                                final budgetRaw = budgetController.text.trim();

                                if (title.isEmpty ||
                                    details.isEmpty ||
                                    budgetRaw.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please fill all request fields.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final budget = budgetRaw.startsWith('৳')
                                    ? budgetRaw
                                    : '৳$budgetRaw';
                                widget.onSendRequest(
                                  teacher,
                                  title,
                                  details,
                                  budget,
                                  selectedImageBytes,
                                  selectedImageName,
                                );
                                Navigator.of(context).pop();
                              },
                              child: const Text('Send Request'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.session.role == UserRole.admin;
    final isStudent = widget.session.role == UserRole.user;
    final filteredTeachers = _filteredTeachers;
    final activeTeacherCount =
        filteredTeachers.where((t) => t.isActive).length;

    return RefreshIndicator(
      onRefresh: _resetAndRefresh,
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
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F6A47), Color(0xFF2BA074)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0A3A26).withValues(alpha: 0.28),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAdmin
                            ? 'এসএসসি, এইচএসসি ও ভর্তি বিষয়ের যাচাইকৃত শিক্ষকদের অনুমোদন দিন।'
                            : 'সক্রিয় শিক্ষকরা হাইলাইট করা হয়েছে। সর্বোচ্চ রেটিংপ্রাপ্ত শিক্ষকরা আগে দেখানো হচ্ছে।',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          MiniPill(label: 'মোট: ${filteredTeachers.length}'),
                          MiniPill(label: 'সক্রিয়: $activeTeacherCount'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.school_rounded,
                            size: 20,
                            color: Color(0xFF1F6F4A),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'সকল শিক্ষক',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1F6F4A),
                                    fontSize: 18,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.tonalIcon(
                      onPressed: () => _showTeacherFilterSheet(context),
                      icon: const Icon(Icons.filter_list_rounded),
                      label: const Text('ফিল্টার'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_selectedSubject != null || _minimumRating != null) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (_selectedSubject != null)
                        ActiveFilterChip(
                          label: 'বিষয়: $_selectedSubject',
                          onRemove: _clearFilters,
                        ),
                      if (_minimumRating != null)
                        ActiveFilterChip(
                          label: 'রেটিং: ${_minimumRating!.toStringAsFixed(1)}+',
                          onRemove: _clearFilters,
                        ),
                      TextButton(
                        onPressed: _clearFilters,
                        child: const Text('ফিল্টার মুছুন'),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                if (filteredTeachers.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFCFE8DB)),
                    ),
                    child: const Text(
                      'No teachers found for selected filters.',
                    ),
                  ),
                for (int i = 0; i < filteredTeachers.length; i++) ...[
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFFFFF), Color(0xFFF3FBF7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: filteredTeachers[i].isActive
                            ? const Color(0xFFBFE5D2)
                            : const Color(0xFFD6E7DF),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0B3A27).withValues(alpha: 0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF0F6A47), Color(0xFF2BA074)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  filteredTeachers[i].name[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    filteredTeachers[i].name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF0E402C),
                                        ),
                                  ),
                                  Text(
                                    filteredTeachers[i].subject,
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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCF4E8),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: const Color(0xFFBEE5D1),
                                ),
                              ),
                              child: Text(
                                '★ ${filteredTeachers[i].rating.toStringAsFixed(1)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color: const Color(0xFF0E6A45),
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: filteredTeachers[i].isActive
                                    ? const Color(0xFFDCFCE7)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: filteredTeachers[i].isActive
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFF94A3B8),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    filteredTeachers[i].isActive
                                        ? 'এখন সক্রিয়'
                                        : 'বর্তমানে অফলাইনে',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: filteredTeachers[i].isActive
                                              ? const Color(0xFF166534)
                                              : const Color(0xFF64748B),
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Text(
                              filteredTeachers[i].response,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: const Color(0xFF475569)),
                            ),
                          ],
                        ),
                        if (isStudent) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () => _showDirectRequestSheet(
                                context,
                                filteredTeachers[i],
                              ),
                              icon: const Icon(Icons.send_rounded, size: 18),
                              label: const Text('সরাসরি অনুরোধ পাঠান'),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF2C8C57),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (i != filteredTeachers.length - 1)
                    const SizedBox(height: 12),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
