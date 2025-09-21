import 'package:presensi/models/absensi.dart';
import 'package:presensi/data.dart';

class AbsensiService {

  List<Absensi> getAbsensiList() {
    return dummyAbsensi;
  }

 
  // Menerima objek Absensi yang bisa berupa AbsensiMasuk atau AbsensiKeluar
  void recordAbsensi(Absensi newAbsensi) {
    dummyAbsensi.add(newAbsensi);
  }
}