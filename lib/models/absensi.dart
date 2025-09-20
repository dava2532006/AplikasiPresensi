abstract class Absensi {
  final DateTime _timestamp;
  final String _status;

  Absensi(this._timestamp, this._status);

  DateTime get timestamp => _timestamp;
  String get status => _status;
}

// Kelas anak untuk Absensi Masuk
class AbsensiMasuk extends Absensi {
  AbsensiMasuk(DateTime timestamp) : super(timestamp, 'Masuk');
}

// Kelas anak untuk Absensi Keluar
class AbsensiKeluar extends Absensi {
  AbsensiKeluar(DateTime timestamp) : super(timestamp, 'Keluar');
}