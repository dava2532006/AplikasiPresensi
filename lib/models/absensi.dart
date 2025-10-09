import 'package:cloud_firestore/cloud_firestore.dart';

class Absensi {
  final String userId;
  final String status; // 'Masuk' atau 'Keluar'
  final DateTime timestamp;
  // Anda bisa tambahkan field lokasi jika sudah diimplementasikan
  // final double latitude;
  // final double longitude;

  Absensi({
    required this.userId,
    required this.status,
    required this.timestamp,
    // required this.latitude,
    // required this.longitude,
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