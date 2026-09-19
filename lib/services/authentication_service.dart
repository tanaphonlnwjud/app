import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String userName = '';

  Future<bool> login(String username, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: username,
        password: password,
      );
      userName = username;
      return userCredential.user != null;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String nickname,
    required String phoneNumber,
    required DateTime birthDate,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = userCredential.user;
    if (user == null) return false;

    await _firestore.collection('users').doc(user.uid).set({
      'email': email.trim(),
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'nickname': nickname.trim(),
      'phoneNumber': phoneNumber.trim(),
      'birthDate': Timestamp.fromDate(birthDate),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return true;
  }

  Future<void> logout() async {
    await _auth.signOut();
    userName = '';
  }

  bool isAuthenticated() {
    return _auth.currentUser != null;
  }

  Future<String> getCurrentUserFullName() async {
    final user = _auth.currentUser;
    if (user == null) return '';

    final snapshot = await _firestore.collection('users').doc(user.uid).get();
    final data = snapshot.data();
    if (data == null) return user.displayName ?? '';

    final firstName = (data['firstName'] as String? ?? '').trim();
    final lastName = (data['lastName'] as String? ?? '').trim();
    return '$firstName $lastName'.trim();
  }
}
