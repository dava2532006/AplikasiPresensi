import 'package:flutter/material.dart';
import 'package:presensi/screens/splash_screen.dart'; // Tambahkan baris ini

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Presensi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // Ubah dari LoginScreen menjadi SplashScreen
    );
  }
}