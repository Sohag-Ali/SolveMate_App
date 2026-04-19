import 'package:flutter/material.dart';
import '../models/teacher_models.dart';
import '../models/problem_models.dart';
import '../models/notification_models.dart';

class AppStore {
  static final List<TeacherProfile> teachers = [
    const TeacherProfile(
      name: 'Sohag Ali',
      subject: 'গণিত | এইচএসসি ও ভর্তি',
      rating: 4.9,
      response: '১০ মিনিটে সাড়া',
      isActive: true,
      email: 'delowar.teacher@solvemate.test',
    ),
    const TeacherProfile(
      name: 'Nusrat Jahan',
      subject: 'পদার্থবিজ্ঞান | এইচএসসি',
      rating: 4.8,
      response: '১৫ মিনিটে সাড়া',
      isActive: true,
      email: 'nusrat.teacher@solvemate.test',
    ),
    const TeacherProfile(
      name: 'Rakib Hasan',
      subject: 'রসায়ন | এসএসসি ও এইচএসসি',
      rating: 4.7,
      response: '২০ মিনিটে সাড়া',
      isActive: false,
      email: 'rakib.teacher@solvemate.test',
    ),
  ];

  static final List<TeacherRequest> requests = [
    TeacherRequest(
      id: 'demo-request-1',
      studentName: 'Sohag Ali',
      studentEmail: 'student@gmail.com',
      teacherName: 'Sohag Ali',
      teacherEmail: 'delowar.teacher@solvemate.test',
      problemTitle: 'এইচএসসি গণিত: ইন্টিগ্রেশন সমস্যা',
      problemDetails: 'ইন্টিগ্রেশনের ধাপগুলো বুঝতে সমস্যা হচ্ছে।',
      budget: '৳500',
      requestedAtMs: DateTime.now().millisecondsSinceEpoch - 100000,
    ),
    TeacherRequest(
      id: 'demo-request-2',
      studentName: 'Sohag Ali',
      studentEmail: 'student@gmail.com',
      teacherName: 'Nusrat Jahan',
      teacherEmail: 'nusrat.teacher@solvemate.test',
      problemTitle: 'এইচএসসি গণিত: ইন্টিগ্রেশন সমস্যা',
      problemDetails: 'ডিফারেনশিয়াল ও ইন্টিগ্রেশন অংশ মিলাতে সমস্যা হচ্ছে।',
      budget: '৳500',
      requestedAtMs: DateTime.now().millisecondsSinceEpoch - 70000,
    ),
    TeacherRequest(
      id: 'demo-request-3',
      studentName: 'Sohag Ali',
      studentEmail: 'student@gmail.com',
      teacherName: 'Rakib Hasan',
      teacherEmail: 'rakib.teacher@solvemate.test',
      problemTitle: 'এইচএসসি গণিত: ইন্টিগ্রেশন সমস্যা',
      problemDetails: 'স্টেপ বাই স্টেপ হেল্প দরকার।',
      budget: '৳450',
      requestedAtMs: DateTime.now().millisecondsSinceEpoch - 50000,
    ),
    TeacherRequest(
      id: 'demo-request-4',
      studentName: 'Sohag Ali',
      studentEmail: 'student@gmail.com',
      teacherName: 'Sohag Ali',
      teacherEmail: 'delowar.teacher@solvemate.test',
      problemTitle: 'ভর্তি প্রস্তুতি: ইংরেজি গ্রামার সমস্যার সমাধান',
      problemDetails: 'টেন্স ও ভয়েস চেঞ্জের কিছু কনফিউশন আছে।',
      budget: '৳300',
      requestedAtMs: DateTime.now().millisecondsSinceEpoch - 20000,
      status: TeacherRequestStatus.accepted,
    ),
    TeacherRequest(
      id: 'demo-request-teacher-1',
      studentName: 'Sohag Ali',
      studentEmail: 'student@gmail.com',
      teacherName: 'Nusrat Jahan',
      teacherEmail: 'nusrat.teacher@solvemate.test',
      problemTitle: 'এইচএসসি গণিত: ইন্টিগ্রেশন সমস্যা',
      problemDetails: 'ইন্টিগ্রেশন শর্টকাট ও ধাপে ধাপে সমাধান করাতে পারব।',
      budget: '৳480',
      requestedAtMs: DateTime.now().millisecondsSinceEpoch - 16000,
      initiatedByTeacher: true,
    ),
    TeacherRequest(
      id: 'demo-request-teacher-2',
      studentName: 'Sohag Ali',
      studentEmail: 'student@gmail.com',
      teacherName: 'Rakib Hasan',
      teacherEmail: 'rakib.teacher@solvemate.test',
      problemTitle: 'ভর্তি প্রস্তুতি: ইংরেজি গ্রামার সমস্যার সমাধান',
      problemDetails: 'মডেল টেস্ট, ভুল বিশ্লেষণ ও দ্রুত রিভিশন প্ল্যান দিব।',
      budget: '৳300',
      requestedAtMs: DateTime.now().millisecondsSinceEpoch - 13000,
      initiatedByTeacher: true,
    ),
    TeacherRequest(
      id: 'demo-request-teacher-3',
      studentName: 'Sohag Ali',
      studentEmail: 'student@gmail.com',
      teacherName: 'Nusrat Jahan',
      teacherEmail: 'nusrat.teacher@solvemate.test',
      problemTitle: 'ভর্তি প্রস্তুতি: ইংরেজি গ্রামার সমস্যার সমাধান',
      problemDetails: 'গ্রামারের কঠিন অংশগুলো গাইডেড প্র্যাকটিসে শেষ করব।',
      budget: '৳320',
      requestedAtMs: DateTime.now().millisecondsSinceEpoch - 10000,
      initiatedByTeacher: true,
    ),
  ];

  static final List<PostedProblemStatus> postedProblems = [
    PostedProblemStatus(
      id: 'demo-problem-1',
      studentEmail: 'student@gmail.com',
      title: 'এইচএসসি গণিত: ইন্টিগ্রেশন সমস্যা',
      budget: '৳500',
      postedAtMs: DateTime.now().millisecondsSinceEpoch - 120000,
    ),
    PostedProblemStatus(
      id: 'demo-problem-2',
      studentEmail: 'student@gmail.com',
      title: 'ভর্তি প্রস্তুতি: ইংরেজি গ্রামার সমস্যার সমাধান',
      budget: '৳300',
      postedAtMs: DateTime.now().millisecondsSinceEpoch - 240000,
    ),
  ];

  static final List<NotificationItem> notifications = [
    NotificationItem(
      title: 'Sohag Ali থেকে নতুন সরাসরি অনুরোধ',
      message: 'এইচএসসি গণিত: ইন্টিগ্রেশন সমস্যা',
      timeLabel: '২ মিনিট আগে',
      icon: Icons.mark_email_unread_rounded,
      recipientEmail: 'nusrat.teacher@solvemate.test',
    ),
    NotificationItem(
      title: 'Sohag Ali থেকে নতুন সরাসরি অনুরোধ',
      message: 'এইচএসসি গণিত: ইন্টিগ্রেশন সমস্যা',
      timeLabel: '২ মিনিট আগে',
      icon: Icons.mark_email_unread_rounded,
      recipientEmail: 'rakib.teacher@solvemate.test',
    ),
    NotificationItem(
      title: 'আপনার অনুরোধ গৃহীত হয়েছে',
      message: 'ভর্তি প্রস্তুতি: ইংরেজি গ্রামার সমস্যার সমাধান',
      timeLabel: 'এইমাত্র',
      icon: Icons.check_circle_rounded,
      recipientEmail: 'student@gmail.com',
    ),
  ];

  static final Map<String, BanRecord> bans = {};
}
