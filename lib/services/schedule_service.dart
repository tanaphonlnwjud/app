import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/schedule_model.dart';

class ScheduleService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ScheduleService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _collection {
    final user = _auth.currentUser;
    if (user == null) throw StateError('กรุณาเข้าสู่ระบบก่อน');
    return _firestore.collection('users').doc(user.uid).collection('schedules');
  }

  Stream<List<ScheduleModel>> watchSchedules() {
    return _collection.snapshots().map((snapshot) {
      final schedules = snapshot.docs.map(ScheduleModel.fromDocument).toList();
      schedules.sort((first, second) {
        final weekday = first.weekday.compareTo(second.weekday);
        return weekday == 0
            ? first.startMinutes.compareTo(second.startMinutes)
            : weekday;
      });
      return schedules;
    });
  }

  Future<void> addSchedule(ScheduleModel schedule) {
    return _collection.add(schedule.toMap());
  }

  Future<void> deleteSchedule(String id) {
    return _collection.doc(id).delete();
  }
}
