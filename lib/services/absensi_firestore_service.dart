import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart'; // Impor geolocator

class AbsensiFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get uid => firebase_auth.FirebaseAuth.instance.currentUser?.uid;

  // --- LOKASI KANTOR DAN RADIUS ---
  // GANTI DENGAN KOORDINAT LOKASI ANDA
  final double _targetLatitude = -7.6363;   // Contoh: Latitude Madiun
  final double _targetLongitude = 111.5225; // Contoh: Longitude Madiun
  final double _allowedRadiusInMeters = 100; // Radius toleransi dalam meter

  Future<String> recordAbsensi(String status) async {
    if (uid == null) return "Gagal: Pengguna tidak ditemukan.";

    // --- 1. PENGECEKAN LOKASI ---
    try {
      final position = await _determinePosition();
      final distance = Geolocator.distanceBetween(
        _targetLatitude,
        _targetLongitude,
        position.latitude,
        position.longitude,
      );

      if (distance > _allowedRadiusInMeters) {
        return "Gagal: Anda berada di luar area yang diizinkan untuk absen. Jarak Anda ${distance.round()} meter dari lokasi.";
      }
    } catch (e) {
      return "Gagal: ${e.toString()}";
    }

    // --- 2. PENGECEKAN DUPLIKAT ABSENSI ---
    try {
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

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

      // --- 3. TAMBAHKAN DATA ABSENSI BARU ---
      await _firestore.collection('absensi').add({
        'uid': uid,
        'status': status,
        'timestamp': Timestamp.now(),
      });

      return "Absensi $status berhasil dicatat!";

    } catch (e) {
      debugPrint("TERJADI GALAT FIRESTORE: $e");
      return "Terjadi galat saat mengakses database. Periksa Debug Console.";
    }
  }

  // --- Fungsi Helper untuk Mendapatkan Lokasi ---
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Layanan lokasi dinonaktifkan.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Izin lokasi ditolak.');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Izin lokasi ditolak secara permanen, kami tidak dapat meminta izin.');
    } 

    return await Geolocator.getCurrentPosition();
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