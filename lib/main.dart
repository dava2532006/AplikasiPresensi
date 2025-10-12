import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:presensi/screens/splash_screen.dart';
import 'firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase (tetap ada jika masih dipakai)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://tjshitvsjldmavhlsebr.supabase.co', // <-- Ganti dengan URL Proyek Supabase
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRqc2hpdHZzamxkbWF2aGxzZWJyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAwNzg0NTQsImV4cCI6MjA3NTY1NDQ1NH0.ryn63LqLjrSxsMDlHYzFHJyBoFulE0ldkz96d3D4h5o', // <-- Ganti dengan Anon Key
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Presensi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}

// Helper untuk mengakses Supabase client secara global
