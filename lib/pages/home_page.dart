import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_role.dart';
import '../models/problem_models.dart';
import '../models/teacher_models.dart';
import '../data/app_store.dart';
import '../utils/pinned_header_delegate.dart';
import '../widgets/app_header.dart';
import '../widgets/hero_panel.dart';
import '../widgets/common_widgets.dart';
import '../widgets/problem_card.dart';

enum _TimeSort { newest, oldest }

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.session,
    required this.onViewTeachers,
    required this.onShowNotifications,
    required this.unreadNotificationCount,
    required this.onProblemPosted,
    required this.onTeacherSendRequestForProblem,
    required this.onRefresh,
  });

  final RoleSession session;
  final VoidCallback onViewTeachers;
  final VoidCallback onShowNotifications;
  final int unreadNotificationCount;
  final ValueChanged<PostedProblem> onProblemPosted;
  final ValueChanged<PostedProblem> onTeacherSendRequestForProblem;
  final Future<void> Function() onRefresh;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<PostedProblem> _problems = [
    const PostedProblem(
      posterName: 'সামিহা',
      posterEmail: 'samiha.student@solvemate.test',
      posterAvatarUrl: 'https://i.pravatar.cc/120?u=samiha',
      postedAgo: '১০ মিনিট আগে',
      postedAtMs: 600,
      title: 'এসএসসি জীববিজ্ঞান: কোষ বিভাজন বুঝতে সাহায্য চাই',
      budget: '৳350',
      problemType: 'মাধ্যমিক',
      subject: 'জীববিজ্ঞান',
      imageAsset: 'assets/water.jpg',
      description: 'মাইটোসিস ও মাইওসিসের পার্থক্য সহজভাবে বুঝতে চাই।',
    ),
    const PostedProblem(
      posterName: 'ইফতেখার',
      posterEmail: 'ifte.student@solvemate.test',
      posterAvatarUrl: 'https://i.pravatar.cc/120?u=ifte',
      postedAgo: '৩৫ মিনিট আগে',
      postedAtMs: 500,
      title: 'এইচএসসি রসায়ন: অর্গানিক বিক্রিয়া শর্টকাট',
      budget: '৳450',
      problemType: 'এইচএসসি',
      subject: 'রসায়ন',
      imageAsset: 'assets/math.jpg',
      description: 'রিঅ্যাকশন মনে রাখার জন্য দ্রুত টেকনিক দরকার।',
    ),
    const PostedProblem(
      posterName: 'মেহজাবিন',
      posterEmail: 'mehjabin.student@solvemate.test',
      posterAvatarUrl: 'https://i.pravatar.cc/120?u=mehjabin',
      postedAgo: '১ ঘণ্টা আগে',
      postedAtMs: 400,
      title: 'ভর্তি প্রস্তুতি: ইংরেজি গ্রামার সমস্যার সমাধান',
      budget: '৳300',
      problemType: 'ভর্তি পরীক্ষা',
      subject: 'ইংরেজি',
      imageAsset: 'assets/function.jpg',
      description: 'টেন্স ও ভয়েস চেঞ্জের কিছু কনফিউশন আছে।',
    ),
    const PostedProblem(
      posterName: 'আয়েশা',
      posterEmail: 'ayesha.student@solvemate.test',
      posterAvatarUrl: 'https://i.pravatar.cc/120?u=ayesha',
      postedAgo: '২ ঘণ্টা আগে',
      postedAtMs: 300,
      title: 'এইচএসসি গণিত: ইন্টিগ্রেশন সমস্যা',
      budget: '৳500',
      problemType: 'এইচএসসি',
      subject: 'গণিত',
      imageAsset: 'assets/math.jpg',
      description: 'ইন্টিগ্রেশনের ধাপগুলো বুঝতে সমস্যা হচ্ছে।',
    ),
    const PostedProblem(
      posterName: 'রাফি',
      posterEmail: 'rafi.student@solvemate.test',
      posterAvatarUrl: 'https://i.pravatar.cc/120?u=rafi',
      postedAgo: '৩ ঘণ্টা আগে',
      postedAtMs: 200,
      title: 'এসএসসি আইসিটি: ফ্লোচার্ট ও অ্যালগরিদম',
      budget: '৳280',
      problemType: 'মাধ্যমিক',
      subject: 'আইসিটি',
      imageAsset: 'assets/function.jpg',
      description: 'ফ্লোচার্ট থেকে অ্যালগরিদম লেখার নিয়ম নিয়ে সমস্যা।',
    ),
    const PostedProblem(
      posterName: 'নাফি',
      posterEmail: 'nafi.student@solvemate.test',
      posterAvatarUrl: 'https://i.pravatar.cc/120?u=nafi',
      postedAgo: '৫ ঘণ্টা আগে',
      postedAtMs: 100,
      title: 'পদার্থবিজ্ঞান: নিউটনের সূত্র প্রয়োগ',
      budget: '৳400',
      problemType: 'মাধ্যমিক',
      subject: 'পদার্থবিজ্ঞান',
      imageAsset: 'assets/function.jpg',
      description: 'নিউটনের দ্বিতীয় সূত্র নিয়ে সমস্যায় পড়েছি।',
    ),
    const PostedProblem(
      posterName: 'তাসনিম',
      posterEmail: 'tasnim.student@solvemate.test',
      posterAvatarUrl: 'https://i.pravatar.cc/120?u=tasnim',
      postedAgo: '৮ ঘণ্টা আগে',
      postedAtMs: 50,
      title: 'জ্যামিতি: বৃত্তের উপপাদ্য নিয়ে প্রশ্ন',
      budget: '৳250',
      problemType: 'মাধ্যমিক',
      subject: 'গণিত',
      imageAsset: 'assets/water.jpg',
      description:
          'থিওরেম প্রমাণের ধাপগুলো কোথায় ভুল করছি বুঝতে পারছি না।',
    ),
  ];

  String? _subjectFilter;
  _TimeSort _timeSort = _TimeSort.newest;

  Future<void> _handlePostProblem() async {
    if (widget.session.role != UserRole.user) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'শুধু শিক্ষার্থী এই বাটন দিয়ে সমস্যা পোস্ট করতে পারবে।',
          ),
        ),
      );
      return;
    }

    final created = await showModalBottomSheet<PostedProblem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateProblemSheet(
        posterName: widget.session.name,
        posterEmail: widget.session.email,
        posterAvatarUrl:
            'https://i.pravatar.cc/120?u=${widget.session.email}',
      ),
    );

    if (created == null || !mounted) return;

    setState(() => _problems.insert(0, created));
    widget.onProblemPosted(created);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('সমস্যা সফলভাবে পোস্ট হয়েছে।')));
  }

  Future<void> _resetAndRefresh() async {
    setState(() {
      _subjectFilter = null;
      _timeSort = _TimeSort.newest;
    });
    await widget.onRefresh();
  }

  Future<void> _openFilterSheet() async {
    String? draftSubject = _subjectFilter;
    _TimeSort draftTime = _timeSort;
    const allSubjectsValue = '__all_subjects__';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final subjects = {for (final p in _problems) p.subject}.toList()
          ..sort();

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
                    Text(
                      'প্রশ্ন ফিল্টার',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: draftSubject ?? allSubjectsValue,
                      decoration:
                          const InputDecoration(labelText: 'বিষয়'),
                      items: [
                        const DropdownMenuItem<String>(
                          value: allSubjectsValue,
                          child: Text('সব বিষয়'),
                        ),
                        ...subjects.map(
                          (s) => DropdownMenuItem<String>(
                            value: s,
                            child: Text(s),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setSheetState(() {
                          if (value == null || value == allSubjectsValue) {
                            draftSubject = null;
                          } else {
                            draftSubject = value;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<_TimeSort>(
                      initialValue: draftTime,
                      decoration: const InputDecoration(
                        labelText: 'সময় অনুসারে সাজান',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: _TimeSort.newest,
                          child: Text('সর্বশেষ আগে'),
                        ),
                        DropdownMenuItem(
                          value: _TimeSort.oldest,
                          child: Text('পুরনো আগে'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setSheetState(() => draftTime = value);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _subjectFilter = null;
                                _timeSort = _TimeSort.newest;
                              });
                              Navigator.of(context).pop();
                            },
                            child: const Text('মুছুন'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              setState(() {
                                _subjectFilter = draftSubject;
                                _timeSort = draftTime;
                              });
                              Navigator.of(context).pop();
                            },
                            child: const Text('প্রয়োগ'),
                          ),
                        ),
                      ],
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

  List<PostedProblem> _filteredProblems() {
    final filtered = _problems.where((problem) {
      if (_subjectFilter == null) return true;
      return problem.subject == _subjectFilter;
    }).toList();

    filtered.sort((a, b) {
      final left = a.postedAtMs ?? 0;
      final right = b.postedAtMs ?? 0;
      if (_timeSort == _TimeSort.oldest) return left.compareTo(right);
      return right.compareTo(left);
    });

    return filtered;
  }

  List<Widget> _activeFilterChips() {
    final chips = <Widget>[];
    if (_subjectFilter != null) {
      chips.add(
        ActiveFilterChip(
          label: _subjectFilter!,
          onRemove: () => setState(() => _subjectFilter = null),
        ),
      );
    }
    if (_timeSort != _TimeSort.newest) {
      chips.add(
        ActiveFilterChip(
          label: _timeSort == _TimeSort.oldest ? 'পুরনো আগে' : 'সর্বশেষ আগে',
          onRemove: () => setState(() => _timeSort = _TimeSort.newest),
        ),
      );
    }
    return chips;
  }

  List<Widget> _problemWidgets(List<PostedProblem> problems) {
    final isTeacher = widget.session.role == UserRole.teacher;

    bool hasTeacherAlreadySent(PostedProblem problem) {
      if (!isTeacher) return false;
      final studentEmail = problem.posterEmail?.trim() ?? '';
      if (studentEmail.isEmpty) return false;
      return AppStore.requests.any(
        (request) =>
            request.initiatedByTeacher &&
            request.teacherEmail == widget.session.email &&
            request.studentEmail == studentEmail &&
            request.problemTitle == problem.title &&
            request.status != TeacherRequestStatus.rejected,
      );
    }

    final items = <Widget>[];
    for (int i = 0; i < problems.length; i++) {
      final problem = problems[i];
      final teacherAlreadySent = hasTeacherAlreadySent(problem);
      items.add(
        ProblemCard(
          posterName: problem.posterName,
          posterAvatarUrl: problem.posterAvatarUrl,
          postedAgo: problem.postedAgo,
          title: problem.title,
          budget: problem.budget,
          problemType: problem.problemType,
          subject: problem.subject,
          imageAsset: problem.imageAsset,
          imageBytes: problem.imageBytes,
          description: problem.description,
          showTeacherRequestAction: isTeacher,
          teacherRequestSent: teacherAlreadySent,
          onSendRequestToSolve: isTeacher
              ? () => widget.onTeacherSendRequestForProblem(problem)
              : null,
        ),
      );
      if (i != problems.length - 1) items.add(const SizedBox(height: 12));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final visibleProblems = _filteredProblems();

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
          SliverToBoxAdapter(
            child: HeroPanel(
              role: widget.session.role,
              onPostProblem: _handlePostProblem,
              onViewTeachers: widget.onViewTeachers,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 26),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDDF4E8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.quiz_rounded,
                              size: 18,
                              color: Color(0xFF1F6F4A),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'সকল প্রশ্ন',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0E402C),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.tonalIcon(
                      onPressed: _openFilterSheet,
                      icon: const Icon(Icons.filter_list_rounded),
                      label: const Text('Filter'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (_activeFilterChips().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _activeFilterChips(),
                    ),
                  ),
                if (visibleProblems.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFCFE8DB)),
                    ),
                    child: const Text(
                      'No problems found for selected filters.',
                    ),
                  )
                else
                  ..._problemWidgets(visibleProblems),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Create Problem Sheet ─────────────────────────────────────────────────────

class _CreateProblemSheet extends StatefulWidget {
  const _CreateProblemSheet({
    this.posterName,
    this.posterEmail,
    this.posterAvatarUrl,
  });

  final String? posterName;
  final String? posterEmail;
  final String? posterAvatarUrl;

  @override
  State<_CreateProblemSheet> createState() => _CreateProblemSheetState();
}

class _CreateProblemSheetState extends State<_CreateProblemSheet> {
  final _titleController = TextEditingController();
  final _budgetController = TextEditingController();
  final _detailsController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String _problemType = 'এইচএসসি';
  String _subject = 'গণিত';
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  @override
  void dispose() {
    _titleController.dispose();
    _budgetController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  String _assetForSubject(String subject) {
    switch (subject) {
      case 'পদার্থবিজ্ঞান':
        return 'assets/function.jpg';
      case 'বিজ্ঞান':
        return 'assets/water.jpg';
      default:
        return 'assets/math.jpg';
    }
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = picked.name;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ছবি নির্বাচন করা যায়নি। আবার চেষ্টা করুন।'),
        ),
      );
    }
  }

  void _submit() {
    final title = _titleController.text.trim();
    final budgetRaw = _budgetController.text.trim();
    final details = _detailsController.text.trim();

    if (title.isEmpty || budgetRaw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('শিরোনাম এবং বাজেট লিখুন।')),
      );
      return;
    }

    final budget = budgetRaw.startsWith('৳') ? budgetRaw : '৳$budgetRaw';
    Navigator.of(context).pop(
      PostedProblem(
        posterName: widget.posterName,
        posterEmail: widget.posterEmail,
        posterAvatarUrl: widget.posterAvatarUrl,
        postedAgo: 'Posted just now',
        postedAtMs: DateTime.now().millisecondsSinceEpoch,
        title: title,
        budget: budget,
        problemType: _problemType,
        subject: _subject,
        imageAsset: _assetForSubject(_subject),
        imageBytes: _selectedImageBytes,
        description: details.isEmpty
            ? 'ব্যবহারকারী নতুন একটি সমস্যা পোস্ট করেছেন।'
            : details,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          12,
          12,
          12,
          MediaQuery.of(context).viewInsets.bottom + 12,
        ),
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.post_add_rounded,
                      color: Color(0xFF1F6F4A),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'নতুন সমস্যা পোস্ট করুন',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'সমস্যার শিরোনাম',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'বাজেট (টাকা)',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _problemType,
                        decoration:
                            const InputDecoration(labelText: 'লেভেল'),
                        items: const [
                          DropdownMenuItem(
                            value: 'মাধ্যমিক',
                            child: Text('মাধ্যমিক'),
                          ),
                          DropdownMenuItem(
                            value: 'এইচএসসি',
                            child: Text('এইচএসসি'),
                          ),
                          DropdownMenuItem(
                            value: 'বিশ্ববিদ্যালয়',
                            child: Text('বিশ্ববিদ্যালয়'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _problemType = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _subject,
                        decoration:
                            const InputDecoration(labelText: 'বিষয়'),
                        items: const [
                          DropdownMenuItem(
                            value: 'গণিত',
                            child: Text('গণিত'),
                          ),
                          DropdownMenuItem(
                            value: 'পদার্থবিজ্ঞান',
                            child: Text('পদার্থবিজ্ঞান'),
                          ),
                          DropdownMenuItem(
                            value: 'বিজ্ঞান',
                            child: Text('বিজ্ঞান'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _subject = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _detailsController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'বিস্তারিত (ঐচ্ছিক)',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.upload_file_rounded),
                      label: const Text('ছবি আপলোড (ঐচ্ছিক)'),
                    ),
                    if (_selectedImageBytes != null) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedImageBytes = null;
                            _selectedImageName = null;
                          });
                        },
                        child: const Text('ছবি সরান'),
                      ),
                    ],
                  ],
                ),
                if (_selectedImageName != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'নির্বাচিত: $_selectedImageName',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ),
                if (_selectedImageBytes != null)
                  Container(
                    width: double.infinity,
                    height: 130,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: const Color(0xFFCFE8DB)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.memory(
                      _selectedImageBytes!,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('পোস্ট করুন'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
