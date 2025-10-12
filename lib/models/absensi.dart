import 'package:cloud_firestore/cloud_firestore.dart';

class Absensi {
  final String userId;
  final String status; // 'Masuk' atau 'Keluar'
  final DateTime timestamp;

  Absensi({
    required this.userId,
    required this.status,
    required this.timestamp,

  });

  // Fungsi untuk mengubah objek menjadi Map agar bisa disimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': userId, // Sesuaikan nama field dengan di service
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
      // 'latitude': latitude,
      // 'longitude': longitude,
    };
  }
}