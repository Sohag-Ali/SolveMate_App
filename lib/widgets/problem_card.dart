import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'common_widgets.dart';

class ProblemCard extends StatelessWidget {
  const ProblemCard({
    super.key,
    this.posterName,
    this.posterAvatarUrl,
    this.postedAgo,
    required this.title,
    required this.budget,
    required this.problemType,
    required this.subject,
    required this.imageAsset,
    this.imageBytes,
    this.description = 'সমস্যার বিস্তারিত এবং প্রসঙ্গ এখানে দেখা যাবে।',
    this.showTeacherRequestAction = false,
    this.teacherRequestSent = false,
    this.onSendRequestToSolve,
  });

  final String? posterName;
  final String? posterAvatarUrl;
  final String? postedAgo;
  final String title;
  final String budget;
  final String problemType;
  final String subject;
  final String imageAsset;
  final Uint8List? imageBytes;
  final String description;
  final bool showTeacherRequestAction;
  final bool teacherRequestSent;
  final VoidCallback? onSendRequestToSolve;

  @override
  Widget build(BuildContext context) {
    final resolvedPosterName = ((posterName ?? '').trim().isEmpty)
        ? 'শিক্ষার্থী'
        : posterName!.trim();
    final resolvedPosterAvatar = (posterAvatarUrl ?? '').trim();
    final resolvedPostedAgo = ((postedAgo ?? '').trim().isEmpty)
        ? 'সম্প্রতি পোস্ট হয়েছে'
        : postedAgo!.trim();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF2FBF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFC9E7D8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A4A31).withValues(alpha: 0.12),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.65),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFDDF4E8),
                backgroundImage: resolvedPosterAvatar.isEmpty
                    ? null
                    : NetworkImage(resolvedPosterAvatar),
                onBackgroundImageError: resolvedPosterAvatar.isEmpty
                    ? null
                    : (_, _) {},
                child: Text(
                  resolvedPosterName[0],
                  style: const TextStyle(
                    color: Color(0xFF0E5E3F),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resolvedPosterName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0E402C),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      resolvedPostedAgo,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E7B53),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  budget,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0E402C),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [MiniPill(label: problemType), MiniPill(label: subject)],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: double.infinity,
              height: 170,
              child: imageBytes != null
                  ? Image.memory(imageBytes!, fit: BoxFit.cover)
                  : Image.asset(
                      imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const ColoredBox(
                          color: Color(0xFFECF9F1),
                          child: Center(
                            child: Icon(
                              Icons.broken_image_rounded,
                              size: 48,
                              color: Color(0xFF2E8B57),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProblemDetailsPage(
                      posterName: resolvedPosterName,
                      posterAvatarUrl: resolvedPosterAvatar,
                      postedAgo: resolvedPostedAgo,
                      title: title,
                      budget: budget,
                      problemType: problemType,
                      subject: subject,
                      imageAsset: imageAsset,
                      imageBytes: imageBytes,
                      description: description,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.visibility_rounded),
              label: const Text('বিস্তারিত দেখুন'),
              style: FilledButton.styleFrom(
                foregroundColor: const Color(0xFF0E5E3F),
                backgroundColor: const Color(0xFFDDF4E8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (showTeacherRequestAction) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: teacherRequestSent ? null : onSendRequestToSolve,
                icon: Icon(
                  teacherRequestSent
                      ? Icons.check_circle_rounded
                      : Icons.send_rounded,
                ),
                label: Text(
                  teacherRequestSent
                      ? 'পাঠানো হয়েছে'
                      : 'সমাধানের অনুরোধ পাঠান',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ProblemDetailsPage extends StatelessWidget {
  const ProblemDetailsPage({
    super.key,
    this.posterName,
    this.posterAvatarUrl,
    this.postedAgo,
    required this.title,
    required this.budget,
    required this.problemType,
    required this.subject,
    required this.imageAsset,
    required this.imageBytes,
    required this.description,
  });

  final String? posterName;
  final String? posterAvatarUrl;
  final String? postedAgo;
  final String title;
  final String budget;
  final String problemType;
  final String subject;
  final String imageAsset;
  final Uint8List? imageBytes;
  final String description;

  @override
  Widget build(BuildContext context) {
    final resolvedPosterName = ((posterName ?? '').trim().isEmpty)
        ? 'শিক্ষার্থী'
        : posterName!.trim();
    final resolvedPosterAvatar = (posterAvatarUrl ?? '').trim();
    final resolvedPostedAgo = ((postedAgo ?? '').trim().isEmpty)
        ? 'সম্প্রতি পোস্ট হয়েছে'
        : postedAgo!.trim();

    return Scaffold(
      backgroundColor: const Color(0xFFEAF7F0),
      appBar: AppBar(
        title: const Text('সমস্যার বিস্তারিত'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F6A47), Color(0xFF23A275)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.2),
                          backgroundImage: resolvedPosterAvatar.isEmpty
                              ? null
                              : NetworkImage(resolvedPosterAvatar),
                          onBackgroundImageError:
                              resolvedPosterAvatar.isEmpty ? null : (_, _) {},
                          child: Text(
                            resolvedPosterName[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                resolvedPosterName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              Text(
                                resolvedPostedAgo,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.white
                                          .withValues(alpha: 0.85),
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
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            budget,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        MiniPill(label: problemType),
                        MiniPill(label: subject),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  width: double.infinity,
                  height: 230,
                  child: imageBytes != null
                      ? Image.memory(imageBytes!, fit: BoxFit.cover)
                      : Image.asset(
                          imageAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const ColoredBox(
                              color: Color(0xFFCEEADB),
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFCFE8DB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'সমস্যার বিবরণ',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0E402C),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF334155),
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('হোমে ফিরুন'),
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
