// Lokasi file: lib/services/absensi_firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class AbsensiFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get uid => firebase_auth.FirebaseAuth.instance.currentUser?.uid;

  // GANTI DENGAN KOORDINAT LOKASI ANDA
  final double _targetLatitude = -7.6363;
  final double _targetLongitude = 111.5225;
  final double _allowedRadiusInMeters = 100;

  Future<String> recordAbsensi(String status) async {
    if (uid == null) return "Gagal: Pengguna tidak ditemukan.";

    try {
      // --- 1. DAPATKAN LOKASI & TENTUKAN STATUS LOKASI ---
      // Memanggil fungsi publik 'determinePosition'
      final position = await determinePosition();
      final distance = Geolocator.distanceBetween(
        _targetLatitude,
        _targetLongitude,
        position.latitude,
        position.longitude,
      );

      // Tentukan status lokasi berdasarkan jarak
      String lokasiStatus;
      if (distance > _allowedRadiusInMeters) {
        lokasiStatus = "Di Luar Area";
      } else {
        lokasiStatus = "Di Dalam Area";
      }

      // --- 2. PENGECEKAN DUPLIKAT ABSENSI ---
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

      // --- 3. TAMBAHKAN DATA ABSENSI BARU DENGAN STATUS LOKASI ---
      await _firestore.collection('absensi').add({
        'uid': uid,
        'status': status,
        'timestamp': Timestamp.now(),
        'latitude': position.latitude,
        'longitude': position.longitude,
        'lokasi_status': lokasiStatus,
      });

      return "Absensi $status berhasil dicatat dari $lokasiStatus.";

    } catch (e) {
      debugPrint("TERJADI GALAT: $e");
      return "Gagal mencatat absensi: ${e.toString()}";
    }
  }

  // --- Fungsi Helper untuk Mendapatkan Lokasi (sekarang menjadi publik) ---
  Future<Position> determinePosition() async {
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