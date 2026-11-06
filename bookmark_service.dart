import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookmarkService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mengambil UID pengguna yang sedang login
  String get _userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    return user.uid;
  }

  // Mengakses subcollection bookmarks milik pengguna
  CollectionReference<Map<String, dynamic>> get _bookmarkCollection {
    return _db.collection('users').doc(_userId).collection('bookmarks');
  }

  // Menambahkan beasiswa ke bookmark
  Future<void> addBookmark(String scholarshipId) async {
    if (scholarshipId.trim().isEmpty) {
      throw ArgumentError('ID beasiswa tidak boleh kosong.');
    }

    await _bookmarkCollection.doc(scholarshipId).set({
      'scholarship_id': scholarshipId,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // Menghapus beasiswa dari bookmark
  Future<void> removeBookmark(String scholarshipId) async {
    await _bookmarkCollection.doc(scholarshipId).delete();
  }

  // Memeriksa apakah beasiswa sudah disimpan
  Future<bool> isBookmarked(String scholarshipId) async {
    final document = await _bookmarkCollection.doc(scholarshipId).get();

    return document.exists;
  }

  // Memantau status bookmark secara real-time
  Stream<bool> watchBookmark(String scholarshipId) {
    return _bookmarkCollection
        .doc(scholarshipId)
        .snapshots()
        .map((document) => document.exists);
  }

  // Mengambil daftar bookmark secara real-time
  Stream<QuerySnapshot<Map<String, dynamic>>> getBookmarks() {
    return _bookmarkCollection
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  // Menambahkan atau menghapus bookmark
  Future<void> toggleBookmark(String scholarshipId) async {
    final document = await _bookmarkCollection.doc(scholarshipId).get();

    if (document.exists) {
      await removeBookmark(scholarshipId);
    } else {
      await addBookmark(scholarshipId);
    }
  }
}
