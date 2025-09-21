import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String name;
  final String email;
  final String position;
  final String role; // Tambahkan field role

  User({
    required this.uid,
    required this.name,
    required this.email,
    required this.position,
    required this.role, // Pastikan role juga ada di konstruktor
  });

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      position: data['position'] ?? '',
      role: data['role'] ?? 'pegawai', // Default role jika tidak ada
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'position': position,
      'role': role,
    };
  }
}