import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
	const UserProfile({
		required this.firstName,
		required this.lastName,
		required this.nickname,
		required this.birthDate,
		required this.email,
		required this.phone,
	});

	final String firstName;
	final String lastName;
	final String nickname;
	final DateTime birthDate;
	final String email;
	final String phone;

	Map<String, dynamic> toMap() {
		return {
			'firstName': firstName,
			'lastName': lastName,
			'nickname': nickname,
			'birthDate': Timestamp.fromDate(birthDate),
			'email': email,
			'phone': phone,
			'createdAt': FieldValue.serverTimestamp(),
		};
	}
}
