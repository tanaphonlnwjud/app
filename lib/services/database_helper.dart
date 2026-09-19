import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/nisit_record_model.dart';
import 'authentication_service.dart';

class DatabaseHelper {
  final collectionName = '${NisitRecordModel.collectionName}_${AuthenticationService.userName}';

  CollectionReference get collection =>
      FirebaseFirestore.instance.collection(collectionName);

    Future<DocumentReference> addNisitRecord(NisitRecordModel nisitRecord) async {
      return await collection.add(nisitRecord.toJson());
    }

    Future<void> updateNisitRecord(String id, NisitRecordModel nisitRecord) async {
      return await collection.doc(id).update(nisitRecord.toJson());
    }

    Future<void> deleteNisitRecord(String id) async {
      return await collection.doc(id).delete();
    }

    Stream<QuerySnapshot> getStreamNisitRecords() {
      return collection.snapshots();
    }
}