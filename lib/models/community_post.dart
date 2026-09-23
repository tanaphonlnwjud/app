import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.authorId,
    required this.alias,
    required this.content,
    required this.createdAt,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
  });

  final String id;
  final String authorId;
  final String alias;
  final String content;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;

  factory CommunityPost.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? <String, dynamic>{};
    final timestamp = data['createdAt'];
    return CommunityPost(
      id: snapshot.id,
      authorId: data['authorId'] as String? ?? '',
      alias: data['alias'] as String? ?? 'ผู้ใช้นิรนาม',
      content: data['content'] as String? ?? '',
      createdAt: timestamp is Timestamp ? timestamp.toDate() : DateTime.now(),
      likesCount: (data['likesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (data['commentsCount'] as num?)?.toInt() ?? 0,
      sharesCount: (data['sharesCount'] as num?)?.toInt() ?? 0,
    );
  }
}