import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:presensi/models/user.dart' as app_user;

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fungsi untuk mendaftarkan user baru
  Future<String?> signUp(String name, String email, String password, String position, String role) async {
    try {
      firebase_auth.UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      firebase_auth.User? firebaseUser = result.user;

      if (firebaseUser != null) {
        // Mengirim email verifikasi
        await firebaseUser.sendEmailVerification();
        
        await _db.collection('users').doc(firebaseUser.uid).set({
          'uid': firebaseUser.uid,
          'name': name,
          'email': email,
          'position': position,
          'role': role, // Menyimpan role pengguna baru
        });
        return null; // Berhasil
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      return e.message;
    }
    return null;
  }

  // Fungsi untuk login. Sekarang mengembalikan UserCredential.
  Future<firebase_auth.UserCredential?> signIn(String email, String password) async {
    try {
      firebase_auth.UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Melemparkan kembali exception Firebase Auth agar dapat ditangani di UI
      throw e;
    }
  }

  // Fungsi untuk mendapatkan data user dari Firestore
  Future<app_user.User?> getUserData(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return app_user.User.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Fungsi untuk mengirim ulang email verifikasi
  Future<void> resendEmailVerification(firebase_auth.User user) async {
    try {
      await user.sendEmailVerification();
    } on firebase_auth.FirebaseAuthException catch (e) {
      rethrow; // Melemparkan kembali exception untuk ditangani di UI
    }
  }

  // Fungsi untuk memperbarui kata sandi
  Future<void> updatePassword(firebase_auth.User user, String newPassword) async {
    await user.updatePassword(newPassword);
  }
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Berhasil
    } on firebase_auth.FirebaseAuthException catch (e) {
      return e.message; // Mengembalikan pesan error jika gagal
    }
  }
  // Fungsi untuk memperbarui data user (hanya nama untuk saat ini)
   Future<void> updateUserData(String uid, String name) async {
    await _db.collection('users').doc(uid).update({
      'name': name,
    });
  }

  // Fungsi untuk mengganti password dengan verifikasi password lama
   Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return 'Pengguna tidak ditemukan. Silakan login kembali.';
      }

      // Buat kredensial dengan password saat ini
      final cred = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      // Lakukan re-autentikasi pengguna
      await user.reauthenticateWithCredential(cred);

      // Jika berhasil, perbarui password
      await user.updatePassword(newPassword);

      return null; 
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Tangani error spesifik seperti password salah
      if (e.code == 'wrong-password') {
        return 'Kata sandi saat ini salah.';
      }
      return e.message; // Kembalikan pesan error lainnya
    } catch (e) {
      return 'Terjadi kesalahan tidak terduga.';
    }
  }
  // Fungsi untuk logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
