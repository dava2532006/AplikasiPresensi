import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // <-- Tambahkan alias
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:presensi/models/user.dart' as app_user; // <-- Tambahkan alias

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Metode untuk login
  Future<app_user.User?> signIn(String email, String password) async {
    try {
      firebase_auth.UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Ambil UID dari user Firebase
      String uid = userCredential.user!.uid;

      // Ambil data dari Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        // Kembalikan instance dari 'app_user.User'
        return app_user.User.fromMap(userDoc.data() as Map<String, dynamic>);
      }
      return null;
    } on firebase_auth.FirebaseAuthException {
      return null;
    }
  }
}