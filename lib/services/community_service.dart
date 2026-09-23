import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/community_post.dart';

class CommunityService {
  CommunityService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _posts =>
      _firestore.collection('community_posts');

  Stream<List<CommunityPost>> watchPosts({required bool trending}) {
    final query = trending
        ? _posts.orderBy('trendScore', descending: true).limit(50)
        : _posts.orderBy('createdAt', descending: true).limit(50);
    return query.snapshots().map(
          (snapshot) => snapshot.docs.map(CommunityPost.fromSnapshot).toList(),
        );
  }

  Stream<bool> watchLiked(String postId) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(false);
    return _posts.doc(postId).collection('likes').doc(uid).snapshots().map((doc) => doc.exists);
  }

  Future<void> addPost(String content) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('กรุณาเข้าสู่ระบบก่อนโพสต์');
    await _posts.add({
      'authorId': user.uid,
      'alias': 'ผู้ใช้นิรนาม',
      'content': content.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'likesCount': 0,
      'commentsCount': 0,
      'sharesCount': 0,
      'trendScore': 0,
    });
  }

  Future<void> deletePost(String postId) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('กรุณาเข้าสู่ระบบก่อนลบโพสต์');

    final post = await _posts.doc(postId).get();
    if (!post.exists || post.data()?['authorId'] != user.uid) {
      throw StateError('คุณไม่มีสิทธิ์ลบโพสต์นี้');
    }
    await post.reference.delete();
  }

  Future<void> toggleLike(String postId, bool liked) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('กรุณาเข้าสู่ระบบก่อนกดถูกใจ');
    final post = _posts.doc(postId);
    final like = post.collection('likes').doc(uid);
    final batch = _firestore.batch();
    batch.set(post, {
      'likesCount': FieldValue.increment(liked ? -1 : 1),
      'trendScore': FieldValue.increment(liked ? -1 : 1),
    }, SetOptions(merge: true));
    if (liked) {
      batch.delete(like);
    } else {
      batch.set(like, {'createdAt': FieldValue.serverTimestamp()});
    }
    await batch.commit();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchComments(String postId) =>
      _posts.doc(postId).collection('comments').orderBy('createdAt').snapshots();

  Future<void> addComment(String postId, String content) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('กรุณาเข้าสู่ระบบก่อนคอมเมนต์');
    final post = _posts.doc(postId);
    final batch = _firestore.batch();
    batch.set(post.collection('comments').doc(), {
      'authorId': user.uid,
      'alias': 'ผู้ใช้นิรนาม',
      'content': content.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.update(post, {
      'commentsCount': FieldValue.increment(1),
      'trendScore': FieldValue.increment(1),
    });
    await batch.commit();
  }
}