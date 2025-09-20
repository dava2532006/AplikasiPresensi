import 'package:presensi/models/absensi.dart';
import 'package:presensi/data.dart';

class AbsensiService {
  // Method untuk mendapatkan semua data absensi
  List<Absensi> getAbsensiList() {
    return dummyAbsensi;
  }

  // Method untuk merekam absensi (Polymorphism)
  // Menerima objek Absensi yang bisa berupa AbsensiMasuk atau AbsensiKeluar
  void recordAbsensi(Absensi newAbsensi) {
    dummyAbsensi.add(newAbsensi);
  }
}