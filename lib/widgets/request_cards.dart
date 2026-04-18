import 'package:flutter/material.dart';
import '../models/teacher_models.dart';
import '../models/problem_models.dart';
import 'common_widgets.dart';

class TeacherIncomingRequestCard extends StatelessWidget {
  const TeacherIncomingRequestCard({
    super.key,
    required this.request,
    this.onAccept,
    this.onReject,
  });

  final TeacherRequest request;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCFE8DB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            request.problemTitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0E402C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'প্রেরক: ${request.studentName} | বাজেট: ${request.budget}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: const Color(0xFF475569)),
          ),
          const SizedBox(height: 6),
          Text(request.problemDetails, style: Theme.of(context).textTheme.bodySmall),
          if (request.imageName != null || request.imageBytes != null) ...[
            const SizedBox(height: 10),
            if (request.imageName != null)
              Text(
                'সংযুক্ত ছবি: ${request.imageName}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF475569),
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (request.imageBytes != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: double.infinity,
                  height: 150,
                  child: Image.memory(request.imageBytes!, fit: BoxFit.cover),
                ),
              ),
            ],
          ],
          const SizedBox(height: 10),
          if (request.status == TeacherRequestStatus.pending)
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: onReject,
                    style: FilledButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFFB91C1C),
                    ),
                    child: const Text('প্রত্যাখ্যান'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: onAccept,
                    child: const Text('গ্রহণ'),
                  ),
                ),
              ],
            )
          else
            MiniPill(label: statusLabel(request.status)),
        ],
      ),
    );
  }
}

class PostedProblemStatusCard extends StatelessWidget {
  const PostedProblemStatusCard({
    super.key,
    required this.problem,
    required this.relatedTeacherRequestCount,
    required this.onTap,
    required this.hasAcceptedTeacher,
  });

  final PostedProblemStatus problem;
  final int relatedTeacherRequestCount;
  final VoidCallback onTap;
  final bool hasAcceptedTeacher;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFCFE8DB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      problem.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0E402C),
                      ),
                    ),
                  ),
                  MiniPill(label: hasAcceptedTeacher ? 'নির্বাচিত' : 'পোস্ট করা'),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'বাজেট: ${problem.budget}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: const Color(0xFF475569)),
              ),
              const SizedBox(height: 4),
              Text(
                'আগত শিক্ষক অনুরোধ: $relatedTeacherRequestCount',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: const Color(0xFF475569)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RequestStatusCard extends StatelessWidget {
  const RequestStatusCard({
    super.key,
    required this.request,
    required this.forStudent,
    this.onTap,
  });

  final TeacherRequest request;
  final bool forStudent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFCFE8DB)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0B3A27).withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      request.problemTitle,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0E402C),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor(
                        request.status,
                      ).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon(request.status),
                          size: 14,
                          color: statusColor(request.status),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          statusLabel(request.status),
                          style: TextStyle(
                            color: statusColor(request.status),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                forStudent
                    ? 'শিক্ষক: ${request.teacherName} | বাজেট: ${request.budget}'
                    : 'শিক্ষার্থী: ${request.studentName} | বাজেট: ${request.budget}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: const Color(0xFF475569)),
              ),
              const SizedBox(height: 6),
              Text(
                request.problemDetails,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
