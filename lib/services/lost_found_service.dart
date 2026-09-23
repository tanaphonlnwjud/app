import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/lost_found_post.dart';

class LostFoundService {
	LostFoundService({FirebaseFirestore? firestore, FirebaseAuth? auth})
			: _firestore = firestore ?? FirebaseFirestore.instance,
				_auth = auth ?? FirebaseAuth.instance;

	final FirebaseFirestore _firestore;
	final FirebaseAuth _auth;

	CollectionReference<Map<String, dynamic>> get _posts =>
			_firestore.collection('lost_found_posts');

	Stream<List<LostFoundPost>> watchPosts({LostFoundType? type}) {
		Query<Map<String, dynamic>> query = _posts;
		if (type != null) {
			query = query.where('type', isEqualTo: type.name);
		}
		return query
				.orderBy('createdAt', descending: true)
				.limit(50)
				.snapshots()
				.map((snapshot) => snapshot.docs.map(LostFoundPost.fromSnapshot).toList());
	}

	Future<DocumentReference<Map<String, dynamic>>> addPost({
		required LostFoundType type,
		required String title,
		required String description,
		required DateTime date,
		required String location,
	}) async {
		final user = _auth.currentUser;
		if (user == null) throw StateError('กรุณาเข้าสู่ระบบก่อนโพสต์');

		return _posts.add({
			'authorId': user.uid,
			'alias': 'ผู้ใช้นิรนาม',
			'type': type.name,
			'title': title.trim(),
			'description': description.trim(),
			'date': Timestamp.fromDate(date),
			'location': location.trim(),
			'status': LostFoundStatus.searching.name,
			'createdAt': FieldValue.serverTimestamp(),
		});
	}

	Future<void> updateStatus(String postId, LostFoundStatus status) async {
		final user = _auth.currentUser;
		if (user == null) throw StateError('กรุณาเข้าสู่ระบบก่อนแก้ไขสถานะ');
		await _posts.doc(postId).update({'status': status.name});
	}

	Future<void> deletePost(String postId) async {
		final user = _auth.currentUser;
		if (user == null) throw StateError('กรุณาเข้าสู่ระบบก่อนลบโพสต์');
		await _posts.doc(postId).delete();
	}

	Stream<QuerySnapshot<Map<String, dynamic>>> watchComments(String postId) {
		return _posts
				.doc(postId)
				.collection('comments')
				.orderBy('createdAt')
				.snapshots();
	}

	Future<void> addComment(String postId, String content) async {
		final user = _auth.currentUser;
		if (user == null) throw StateError('กรุณาเข้าสู่ระบบก่อนคอมเมนต์');
		final trimmedContent = content.trim();
		if (trimmedContent.isEmpty) return;
		await _posts.doc(postId).collection('comments').add({
			'authorId': user.uid,
			'alias': 'ผู้ใช้นิรนาม',
			'content': trimmedContent,
			'createdAt': FieldValue.serverTimestamp(),
		});
	}
}
