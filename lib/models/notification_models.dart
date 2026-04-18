import 'package:flutter/material.dart';

class NotificationItem {
  const NotificationItem({
    required this.title,
    required this.message,
    required this.timeLabel,
    required this.icon,
    required this.recipientEmail,
    this.isRead = false,
  });

  final String title;
  final String message;
  final String timeLabel;
  final IconData icon;
  final String recipientEmail;
  final bool isRead;

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      title: title,
      message: message,
      timeLabel: timeLabel,
      icon: icon,
      recipientEmail: recipientEmail,
      isRead: isRead ?? this.isRead,
    );
  }
}

class BanRecord {
  const BanRecord({
    required this.startedAtMs,
    required this.durationLabel,
    this.untilMs,
  });

  final int startedAtMs;
  final int? untilMs;
  final String durationLabel;

  bool get isActive {
    if (untilMs == null) return true;
    return untilMs! > DateTime.now().millisecondsSinceEpoch;
  }

  String get statusLabel {
    if (untilMs == null) return 'Permanent';
    final remainingMs = untilMs! - DateTime.now().millisecondsSinceEpoch;
    if (remainingMs <= 0) return 'Expired';
    final remainingDays = (remainingMs / Duration.millisecondsPerDay).ceil();
    return '$remainingDays day left';
  }
}

class DashboardStat {
  const DashboardStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

class TabItem {
  const TabItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
