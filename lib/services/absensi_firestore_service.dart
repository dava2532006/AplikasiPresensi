import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class AbsensiFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mendapatkan UID pengguna yang sedang login
  String? get uid => firebase_auth.FirebaseAuth.instance.currentUser?.uid;

  // Fungsi untuk mencatat absensi masuk atau keluar
  Future<void> recordAbsensi(String status) async {
    if (uid == null) return;

    await _firestore.collection('absensi').add({
      'userId': uid,
      'status': status, // 'Masuk' atau 'Keluar'
      'timestamp': Timestamp.now(),
    });
  }

  // Fungsi untuk mendapatkan riwayat absensi pengguna
  Stream<QuerySnapshot> getAbsensiHistory() {
    if (uid == null) {
      return const Stream.empty();
    }
    return _firestore
        .collection('absensi')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}