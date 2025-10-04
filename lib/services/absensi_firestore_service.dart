import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class AbsensiFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get uid => firebase_auth.FirebaseAuth.instance.currentUser?.uid;

  Future<String> recordAbsensi(String status) async {
    if (uid == null) return "Gagal: Pengguna tidak ditemukan.";

    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    // Cek apakah sudah ada absensi dengan status yang sama hari ini
    QuerySnapshot snapshot = await _firestore
        .collection('absensi')
        .where('uid', isEqualTo: uid)
        .where('status', isEqualTo: status)
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThanOrEqualTo: endOfDay)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return "Anda sudah absen $status hari ini.";
    }

    // Jika belum ada, tambahkan data absensi baru
    await _firestore.collection('absensi').add({
      'uid': uid,
      'status': status,
      'timestamp': Timestamp.now(),
    });

    return "Absensi $status berhasil dicatat!";
  }

  Stream<QuerySnapshot> getAbsensiHistory() {
    if (uid == null) {
      return const Stream.empty();
    }
    return _firestore
        .collection('absensi')
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}