import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:presensi/models/user.dart' as app_user;
import 'package:supabase_flutter/supabase_flutter.dart';


class AuthService {
  // --- Singleton Pattern ---
  // Membuat constructor private untuk mencegah pembuatan instance baru dari luar
  AuthService._privateConstructor();
  // Membuat satu-satunya instance dari service ini yang akan digunakan di seluruh aplikasi
  static final AuthService instance = AuthService._privateConstructor();

  // Inisialisasi service Firebase & Firestore
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Mendaftarkan pengguna baru dengan Firebase Auth dan menyimpan datanya di Firestore.
  Future<String?> signUp(String name, String email, String password, String position, String role) async {
    try {
      firebase_auth.UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      firebase_auth.User? firebaseUser = result.user;

      if (firebaseUser != null) {
        // Mengirim email verifikasi ke pengguna baru
        await firebaseUser.sendEmailVerification();
        
        // Menyimpan detail pengguna ke koleksi 'users' di Firestore
        await _db.collection('users').doc(firebaseUser.uid).set({
          'uid': firebaseUser.uid,
          'name': name,
          'email': email,
          'position': position,
          'role': role,
          'photoURL': 'https://cdn-icons-png.flaticon.com/512/149/149071.png', 
        });
        return null; // Mengembalikan null jika berhasil
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      return e.message; // Mengembalikan pesan error jika gagal
    }
    return "Terjadi kesalahan yang tidak diketahui.";
  }

  /// Melakukan login pengguna dengan email dan password.
  Future<firebase_auth.UserCredential?> signIn(String email, String password) async {
    try {
      firebase_auth.UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on firebase_auth.FirebaseAuthException {
      rethrow; // Melemparkan kembali error untuk ditangani di UI
    }
  }

  /// Mengambil data pengguna dari Firestore berdasarkan UID.
  // Future<app_user.User?> getUserData(String uid) async {
  //   DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
  //   if (doc.exists) {
  //     return app_user.User.fromMap(doc.data() as Map<String, dynamic>);
  //   }
  //   return null;
  // }

  /// Mengirim ulang email verifikasi.
  Future<void> resendEmailVerification(firebase_auth.User user) async {
    await user.sendEmailVerification();
  }

  /// Mengirim email untuk reset password.
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  /// Memperbarui data nama pengguna di Firestore.
  Future<void> updateUserData(String uid, String name) async {
    await _db.collection('users').doc(uid).update({
      'name': name,
    });
  }

  /// Mengganti password pengguna dengan verifikasi password lama.
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return 'Pengguna tidak ditemukan. Silakan login kembali.';
      }

      final cred = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      // Lakukan re-autentikasi sebelum mengganti password
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);

      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return 'Kata sandi saat ini salah.';
      }
      return e.message;
    } catch (e) {
      return 'Terjadi kesalahan tidak terduga.';
    }
  }
  
  /// Melakukan logout pengguna.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Mengunggah gambar profil ke Supabase Storage.
  Future<String?> uploadProfilePicture(XFile image, String uid) async {
    final supabase = Supabase.instance.client;
    try {
      final fileName = '$uid.${image.name.split('.').last}';
      const bucket = 'profile-pictures';

      if (kIsWeb) {
        // --- LOGIKA UNTUK WEB ---
        // Baca file gambar sebagai bytes dari memory.
        final imageBytes = await image.readAsBytes();
        // Gunakan 'uploadBinary' untuk mengunggah dari memory.
        await supabase.storage.from(bucket).uploadBinary(
              fileName,
              imageBytes,
              fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
            );
      } else {
        // --- LOGIKA UNTUK MOBILE ---
        // Buat objek File dari path gambar.
        final imageFile = File(image.path);
        // Gunakan 'upload' biasa.
        await supabase.storage.from(bucket).upload(
              fileName,
              imageFile,
              fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
            );
      }

      // Kode ini sama untuk web dan mobile: mendapatkan URL publik.
      final String publicUrl = supabase.storage.from(bucket).getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      print('Error uploading image to Supabase: $e');
      return null;
    }
  }

  /// Memperbarui field 'photoURL' di dokumen pengguna pada Firestore.
  Future<void> updateUserPhotoURL(String uid, String photoURL) async {
    await _db.collection('users').doc(uid).update({
      'photoURL': photoURL,
    });
  }

  /// Mengambil data pengguna dari Firestore.
  Future<app_user.User?> getUserData(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return app_user.User.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updatePassword(firebase_auth.User user, String newPassword) async {
    await user.updatePassword(newPassword);
  }

 
}