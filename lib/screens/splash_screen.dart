import 'package:flutter/material.dart';
import 'package:presensi/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Panggil fungsi navigasi setelah durasi tertentu
    _navigateToLogin();
  }

  // Fungsi untuk navigasi setelah delay
  _navigateToLogin() async {
    // Menunggu selama 3 detik sebelum berpindah halaman
    await Future.delayed(const Duration(seconds: 3), () {});
    
    // Memastikan widget masih terpasang sebelum navigasi
    if (mounted) {
      // Navigasi ke halaman login dan hapus riwayat navigasi sebelumnya
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Aplikasi
            Image(
              image: AssetImage('assets/images/logo.png'),
              width: 200,
              height: 200,
            ),
            SizedBox(height: 20),
            Text(
              'Aplikasi Presensi',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Dibuat oleh: Dhava Gilang Ramadhan',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}