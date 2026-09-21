import 'package:cloud_firestore/cloud_firestore.dart';

class DeadlineRecord {
	const DeadlineRecord({
		this.id,
		required this.title,
		required this.subject,
		required this.description,
		required this.deadline,
		required this.completed,
		required this.notificationId,
	});

	final String? id;
	final String title;
	final String subject;
	final String description;
	final DateTime deadline;
	final bool completed;
	final int notificationId;

	factory DeadlineRecord.fromDocument(DocumentSnapshot<Map<String, dynamic>> document) {
		final data = document.data() ?? <String, dynamic>{};
		final deadlineValue = data['deadline'];
		return DeadlineRecord(
			id: document.id,
			title: data['title'] as String? ?? '',
			subject: data['subject'] as String? ?? '',
			description: data['description'] as String? ?? '',
			deadline: deadlineValue is Timestamp ? deadlineValue.toDate() : DateTime.now(),
			completed: data['completed'] as bool? ?? false,
			notificationId: (data['notificationId'] as num?)?.toInt() ?? document.id.hashCode,
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'title': title,
			'subject': subject,
			'description': description,
			'deadline': Timestamp.fromDate(deadline),
			'completed': completed,
			'notificationId': notificationId,
			'updatedAt': FieldValue.serverTimestamp(),
		};
	}

	DeadlineRecord copyWith({
		String? id,
		String? title,
		String? subject,
		String? description,
		DateTime? deadline,
		bool? completed,
		int? notificationId,
	}) {
		return DeadlineRecord(
			id: id ?? this.id,
			title: title ?? this.title,
			subject: subject ?? this.subject,
			description: description ?? this.description,
			deadline: deadline ?? this.deadline,
			completed: completed ?? this.completed,
			notificationId: notificationId ?? this.notificationId,
		);
	}
}
