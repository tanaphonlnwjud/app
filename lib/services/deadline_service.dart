import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/deadline_record.model.dart';

class DeadlineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('กรุณาเข้าสู่ระบบก่อน');
    return _firestore.collection('users').doc(user.uid).collection('deadlines');
  }

  Stream<List<DeadlineRecord>> watchDeadlines() {
    return _collection.orderBy('deadline').snapshots().map(
          (snapshot) => snapshot.docs.map(DeadlineRecord.fromDocument).toList(),
        );
  }

  Future<DocumentReference<Map<String, dynamic>>> addDeadline(DeadlineRecord record) {
    return _collection.add(record.toJson());
  }

  Future<void> updateDeadline(String id, DeadlineRecord record) {
    return _collection.doc(id).update(record.toJson());
  }

  Future<void> deleteDeadline(String id) {
    return _collection.doc(id).delete();
  }
}