import 'dart:typed_data';

class PostedProblem {
  const PostedProblem({
    this.posterName,
    this.posterEmail,
    this.posterAvatarUrl,
    this.postedAgo,
    this.postedAtMs,
    required this.title,
    required this.budget,
    required this.problemType,
    required this.subject,
    required this.imageAsset,
    this.imageBytes,
    required this.description,
  });

  final String? posterName;
  final String? posterEmail;
  final String? posterAvatarUrl;
  final String? postedAgo;
  final int? postedAtMs;
  final String title;
  final String budget;
  final String problemType;
  final String subject;
  final String imageAsset;
  final Uint8List? imageBytes;
  final String description;
}

class PostedProblemStatus {
  const PostedProblemStatus({
    required this.id,
    required this.studentEmail,
    required this.title,
    required this.budget,
    required this.postedAtMs,
    this.problemDetails,
    this.subject,
    this.problemType,
    this.imageAsset,
    this.imageBytes,
  });

  final String id;
  final String studentEmail;
  final String title;
  final String budget;
  final int postedAtMs;
  final String? problemDetails;
  final String? subject;
  final String? problemType;
  final String? imageAsset;
  final Uint8List? imageBytes;
}
