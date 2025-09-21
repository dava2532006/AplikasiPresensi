import 'package:flutter/material.dart';
import 'package:presensi/screens/add_employee_screen.dart';
import 'package:presensi/screens/home_screen.dart';
import 'package:presensi/screens/login_screen.dart';
import 'package:presensi/screens/splash_screen.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();  
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
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