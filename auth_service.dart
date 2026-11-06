import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // REGISTRASI MENTEE
  Future<UserModel> registerMentee({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Membuat akun di Firebase Authentication
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;

      // Membuat data profil pengguna
      final user = UserModel(
        uid: uid,
        name: name.trim(),
        email: email.trim(),
        role: 'mentee',
        verificationStatus: 'verified',
        createdAt: DateTime.now(),
      );

      // Menyimpan profil ke Firestore
      await _db.collection('users').doc(uid).set(user.toMap());

      return user;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // LOGIN
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // MENGAMBIL USER YANG SEDANG LOGIN
  User? get currentUser => _auth.currentUser;

  // MENGAMBIL DATA PROFIL DARI FIRESTORE
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }
}
