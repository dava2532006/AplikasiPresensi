import 'package:presensi/models/absensi.dart';
import 'package:presensi/models/user.dart';

final List<Absensi> dummyAbsensi = [
  AbsensiMasuk(DateTime(2025, 11, 25, 8, 30)),

  
  AbsensiKeluar(DateTime(2025, 11, 25, 17, 0)),
  AbsensiMasuk(DateTime(2025, 11, 26, 8, 45)),
  AbsensiKeluar(DateTime(2025, 11, 26, 16, 55)),
];

// Perbarui data user dengan jabatan dan email
final List<User> dummyUsers = [
  User('user1', 'pass1', 'Budi Santoso', 'Manager', 'budi.s@example.com'),
  User('user2', 'pass2', 'Siti Aminah', 'Staff', 'siti.a@example.com'),
];