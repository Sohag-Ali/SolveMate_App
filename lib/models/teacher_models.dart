import 'dart:typed_data';
import 'package:flutter/material.dart';

enum TeacherRequestStatus { pending, accepted, rejected }

class TeacherProfile {
  const TeacherProfile({
    required this.name,
    required this.subject,
    required this.rating,
    required this.response,
    required this.isActive,
    required this.email,
  });

  final String name;
  final String subject;
  final double rating;
  final String response;
  final bool isActive;
  final String email;
}

class TeacherRequest {
  const TeacherRequest({
    required this.id,
    required this.studentName,
    required this.studentEmail,
    required this.teacherName,
    required this.teacherEmail,
    required this.problemTitle,
    required this.problemDetails,
    required this.budget,
    required this.requestedAtMs,
    this.imageBytes,
    this.imageName,
    this.initiatedByTeacher = false,
    this.status = TeacherRequestStatus.pending,
  });

  final String id;
  final String studentName;
  final String studentEmail;
  final String teacherName;
  final String teacherEmail;
  final String problemTitle;
  final String problemDetails;
  final String budget;
  final int requestedAtMs;
  final Uint8List? imageBytes;
  final String? imageName;
  final bool initiatedByTeacher;
  final TeacherRequestStatus status;

  TeacherRequest copyWith({TeacherRequestStatus? status}) {
    return TeacherRequest(
      id: id,
      studentName: studentName,
      studentEmail: studentEmail,
      teacherName: teacherName,
      teacherEmail: teacherEmail,
      problemTitle: problemTitle,
      problemDetails: problemDetails,
      budget: budget,
      requestedAtMs: requestedAtMs,
      imageBytes: imageBytes,
      imageName: imageName,
      initiatedByTeacher: initiatedByTeacher,
      status: status ?? this.status,
    );
  }
}

String statusLabel(TeacherRequestStatus status) {
  switch (status) {
    case TeacherRequestStatus.pending:
      return 'অপেক্ষমান';
    case TeacherRequestStatus.accepted:
      return 'গৃহীত';
    case TeacherRequestStatus.rejected:
      return 'বাতিল';
  }
}

Color statusColor(TeacherRequestStatus status) {
  switch (status) {
    case TeacherRequestStatus.pending:
      return const Color(0xFFD97706);
    case TeacherRequestStatus.accepted:
      return const Color(0xFF15803D);
    case TeacherRequestStatus.rejected:
      return const Color(0xFFB91C1C);
  }
}

IconData statusIcon(TeacherRequestStatus status) {
  switch (status) {
    case TeacherRequestStatus.pending:
      return Icons.hourglass_bottom_rounded;
    case TeacherRequestStatus.accepted:
      return Icons.check_circle_rounded;
    case TeacherRequestStatus.rejected:
      return Icons.cancel_rounded;
  }
}
