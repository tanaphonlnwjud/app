import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleModel {
  const ScheduleModel({
    this.id,
    required this.weekday,
    required this.startMinutes,
    required this.endMinutes,
    required this.courseName,
    required this.courseCode,
    required this.room,
    required this.section,
  });

  final String? id;
  final int weekday;
  final int startMinutes;
  final int endMinutes;
  final String courseName;
  final String courseCode;
  final String room;
  final String section;

  factory ScheduleModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data() ?? <String, dynamic>{};
    return ScheduleModel(
      id: document.id,
      weekday: (data['weekday'] as num?)?.toInt() ?? 1,
      startMinutes: (data['startMinutes'] as num?)?.toInt() ?? 0,
      endMinutes: (data['endMinutes'] as num?)?.toInt() ?? 0,
      courseName: data['courseName'] as String? ?? '',
      courseCode: data['courseCode'] as String? ?? '',
      room: data['room'] as String? ?? '',
      section: data['section'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weekday': weekday,
      'startMinutes': startMinutes,
      'endMinutes': endMinutes,
      'courseName': courseName,
      'courseCode': courseCode,
      'room': room,
      'section': section,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
