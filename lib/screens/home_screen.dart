  import 'package:flutter/material.dart';
  import 'package:intl/intl.dart';
  import 'package:presensi/models/absensi.dart';
  import 'package:presensi/models/user.dart';
  import 'package:presensi/services/absensi_service.dart';
  import 'package:presensi/screens/profile_screen.dart';
  import 'package:presensi/screens/absensi_detail_screen.dart';

  class HomeScreen extends StatefulWidget {
    final User user;
    const HomeScreen({super.key, required this.user});

    @override
    State<HomeScreen> createState() => _HomeScreenState();
  }

  class _HomeScreenState extends State<HomeScreen> {
    final AbsensiService _absensiService = AbsensiService();

    // Fungsi untuk menampilkan pop-up konfirmasi
    void _showConfirmationDialog(bool isMasuk) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(isMasuk ? 'Konfirmasi Absen Masuk' : 'Konfirmasi Absen Keluar'),
            content: Text(isMasuk
                ? 'Apakah Anda yakin ingin absen masuk sekarang?'
                : 'Apakah Anda yakin ingin absen keluar sekarang?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Batal'),
                onPressed: () {
                  Navigator.of(context).pop(); // Tutup pop-up
                },
              ),
              TextButton(
                child: const Text('Ya, Absen'),
                onPressed: () {
                  if (isMasuk) {
                    _recordAbsensiMasuk();
                  } else {
                    _recordAbsensiKeluar();
                  }
                  Navigator.of(context).pop(); // Tutup pop-up
                },
              ),
            ],
          );
        },
      );
    }

    void _recordAbsensiMasuk() {
        _absensiService.recordAbsensi(AbsensiMasuk(DateTime.now()));
        setState(() {}); // Perbarui UI
    }

    void _recordAbsensiKeluar() {
        _absensiService.recordAbsensi(AbsensiKeluar(DateTime.now()));
        setState(() {}); // Perbarui UI
    }

    // Cek apakah sudah absen masuk hari ini
    bool _hasAbsenMasukToday() {
      return _absensiService.getAbsensiList().any((absensi) =>
          absensi.status == 'Masuk' &&
          absensi.timestamp.day == DateTime.now().day &&
          absensi.timestamp.month == DateTime.now().month &&
          absensi.timestamp.year == DateTime.now().year);
    }

    // Cek apakah sudah absen keluar hari ini
    bool _hasAbsenKeluarToday() {
      return _absensiService.getAbsensiList().any((absensi) =>
          absensi.status == 'Keluar' &&
          absensi.timestamp.day == DateTime.now().day &&
          absensi.timestamp.month == DateTime.now().month &&
          absensi.timestamp.year == DateTime.now().year);
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Aplikasi Presensi',
            style: TextStyle(fontWeight: FontWeight.bold,
            color: Colors.white),
          ),
          backgroundColor: Colors.blueAccent,
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.person_2_outlined, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(user: widget.user),
                  ),
                );
              },
            ),

          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: constraints.maxWidth > 600 ? 600 : constraints.maxWidth,
                  child: _buildMainContent(),
                ),
              ),
            );
          },
        ),
      );
    }

    Widget _buildMainContent() {
      final absensiList = _absensiService.getAbsensiList().reversed.toList();
      
      // Mengelompokkan absensi berdasarkan hari
      final Map<String, List<Absensi>> groupedAbsensi = {};
      for (var absensi in absensiList) {
        final date = DateFormat('EEEE, dd MMMM yyyy').format(absensi.timestamp);
        if (groupedAbsensi.containsKey(date)) {
          groupedAbsensi[date]!.add(absensi);
        } else {
          groupedAbsensi[date] = [absensi];
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildWelcomeSection(),
          const SizedBox(height: 24),
          _buildAbsensiControls(),
          const SizedBox(height: 24),
          _buildAbsensiList(groupedAbsensi),
        ],
      );
    }
    
    Widget _buildWelcomeSection() {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Welcome',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Halo, ${widget.user.name}',
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                'Jabatan: ${widget.user.position}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                'Email: ${widget.user.email}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildAbsensiControls() {
      final bool hasMasuk = _hasAbsenMasukToday();
      final bool hasKeluar = _hasAbsenKeluarToday();
      
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: hasMasuk ? null : () => _showConfirmationDialog(true),
                  icon: const Icon(Icons.login),
                  label: const Text('Absen Masuk'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: hasMasuk ? Colors.grey : Colors.green),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: !hasMasuk || hasKeluar ? null : () => _showConfirmationDialog(false),
                  icon: const Icon(Icons.logout),
                  label: const Text('Absen Keluar'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: !hasMasuk || hasKeluar ? Colors.grey : Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildAbsensiList(Map<String, List<Absensi>> groupedAbsensi) {
      if (groupedAbsensi.isEmpty) {
        return const Center(child: Text('Belum ada data absensi.'));
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rekap Absensi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              itemCount: groupedAbsensi.keys.length,
              itemBuilder: (context, index) {
                final date = groupedAbsensi.keys.elementAt(index);
                final absensiList = groupedAbsensi[date]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, left: 16, bottom: 8),
                      child: Text(
                        date,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: absensiList.length,
                      itemBuilder: (context, innerIndex) {
                        final absensi = absensiList[innerIndex];
                        final formattedTime = DateFormat('HH:mm:ss').format(absensi.timestamp);
                        final isMasuk = absensi.status == 'Masuk';
                        
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isMasuk ? Colors.green.shade500 : Colors.red.shade500,
                              child: Icon(
                                isMasuk ? Icons.login : Icons.logout,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              isMasuk ? 'Absensi Masuk' : 'Absensi Keluar',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(formattedTime),
                            trailing: Chip(
                              label: Text(absensi.status),
                              backgroundColor: isMasuk ? Colors.green.shade100 : Colors.red.shade100,
                            ),
                            onTap: () { // Perubahan baru di sini
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AbsensiDetailScreen(absensi: absensi),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      );
    }
  }