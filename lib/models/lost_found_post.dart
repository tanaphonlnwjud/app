import 'package:cloud_firestore/cloud_firestore.dart';

enum LostFoundType { lost, found }

enum LostFoundStatus { searching, found }

class LostFoundPost {
	const LostFoundPost({
		required this.id,
		required this.authorId,
		required this.alias,
		required this.type,
		required this.title,
		required this.description,
		required this.date,
		required this.location,
		required this.status,
		required this.createdAt,
	});

	final String id;
	final String authorId;
	final String alias;
	final LostFoundType type;
	final String title;
	final String description;
	final DateTime date;
	final String location;
	final LostFoundStatus status;
	final DateTime createdAt;

	factory LostFoundPost.fromSnapshot(
		DocumentSnapshot<Map<String, dynamic>> snapshot,
	) {
		final data = snapshot.data() ?? <String, dynamic>{};
		return LostFoundPost(
			id: snapshot.id,
			authorId: data['authorId'] as String? ?? '',
			alias: data['alias'] as String? ?? 'ผู้ใช้นิรนาม',
			type: data['type'] == 'found' ? LostFoundType.found : LostFoundType.lost,
			title: data['title'] as String? ?? '',
			description: data['description'] as String? ?? '',
			date: _readDate(data['date']),
			location: data['location'] as String? ?? '',
			status: data['status'] == 'found'
					? LostFoundStatus.found
					: LostFoundStatus.searching,
			createdAt: _readDate(data['createdAt']),
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'authorId': authorId,
			'alias': alias,
			'type': type.name,
			'title': title,
			'description': description,
			'date': Timestamp.fromDate(date),
			'location': location,
			'status': status.name,
			'createdAt': Timestamp.fromDate(createdAt),
		};
	}

	static DateTime _readDate(dynamic value) {
		if (value is Timestamp) return value.toDate();
		if (value is DateTime) return value;
		return DateTime.now();
	}
}
