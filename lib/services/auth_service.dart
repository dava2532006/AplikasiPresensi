import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:presensi/models/user.dart' as app_user;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fungsi untuk mendaftarkan user baru
  Future<String?> signUp(String name, String email, String password, String position, String role) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? firebaseUser = result.user;

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
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
    return null;
  }

  // Fungsi untuk login
  Future<app_user.User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? firebaseUser = result.user;

      if (firebaseUser != null) {
        // Memuat ulang status verifikasi email terbaru
        await firebaseUser.reload();
        
        if (!firebaseUser.emailVerified) {
          // Jika email belum diverifikasi, logout dan lempar exception
          await _auth.signOut();
          throw Exception('Mohon verifikasi email Anda terlebih dahulu.');
        }

        DocumentSnapshot doc = await _db.collection('users').doc(firebaseUser.uid).get();
        if (doc.exists) {
          return app_user.User.fromMap(doc.data() as Map<String, dynamic>);
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      // Menangani error dari Firebase Auth
      print(e);
      return null;
    } on Exception catch (e) {
      // Melempar kembali exception dari verifikasi email
      print(e);
      return null;
    }
  }
}