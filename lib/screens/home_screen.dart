import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:presensi/models/user.dart';
import 'package:presensi/screens/history_screen.dart';
import 'package:presensi/screens/profile_screen.dart';
import 'package:presensi/services/absensi_firestore_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AbsensiFirestoreService _absensiService = AbsensiFirestoreService();
  late Stream<QuerySnapshot> _absensiStream;
  bool _isAbsenLoading = false;
  String _currentAddress = "Mencari lokasi...";

  @override
  void initState() {
    super.initState();
    _absensiStream = _absensiService.getAbsensiHistory();
    _updateLocationInfo();
  }

  Future<String> _getAddressFromCoordinates(Position position) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}');
    try {
      final response = await http.get(url, headers: {'User-Agent': 'com.example.presensi'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['display_name'] ?? 'Alamat tidak ditemukan';
        // Memotong alamat jika terlalu panjang
        return address.length > 50 ? '${address.substring(0, 50)}...' : address;
      }
      return 'Gagal mengambil alamat (Server)';
    } catch (e) {
      return 'Gagal mengambil alamat (Network)';
    }
  }

  void _updateLocationInfo() async {
    try {
      Position position = await _absensiService.determinePosition();
      String address = await _getAddressFromCoordinates(position);
      if (mounted) setState(() => _currentAddress = address);
    } catch (e) {
      if (mounted) setState(() => _currentAddress = "Gagal mendapatkan lokasi.");
    }
  }

  void _handleAbsen(String status) async {
    setState(() => _isAbsenLoading = true);
    String result = await _absensiService.recordAbsensi(status);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
      _updateLocationInfo();
    }
    setState(() => _isAbsenLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildWelcomeCard(),
            const SizedBox(height: 24),
            _buildAttendanceButtons(),
            const SizedBox(height: 24),
            _buildHistoryHeader(),
            const SizedBox(height: 10),
            _buildHistoryList(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           _showAbsenDialog();
        },
        backgroundColor: Colors.blue,
        elevation: 4.0,
        shape: const CircleBorder(),
        child: const Icon(Icons.fingerprint, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // --- WIDGET-WIDGET YANG DIPERBARUI ---

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white,
          child: Icon(Icons.person, size: 40, color: Colors.blue),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _currentAddress,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    var hour = DateTime.now().hour;
    String greeting;
    if (hour < 11) {
      greeting = 'Selamat Pagi';
    } else if (hour < 15) {
      greeting = 'Selamat Siang';
    } else if (hour < 19) {
      greeting = 'Selamat Sore';
    } else {
      greeting = 'Selamat Malam';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.user.position.isNotEmpty ? widget.user.position : 'Pegawai',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '$greeting, selamat dan semangat bekerja!',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
   void _showAbsenDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Absensi'),
          content: const Text('Pilih tipe absensi Anda:'),
          actions: <Widget>[
            TextButton(
              child: const Text('Masuk'),
              onPressed: () {
                Navigator.of(context).pop();
                _handleAbsen('Masuk');
              },
            ),
            TextButton(
              child: const Text('Keluar'),
              onPressed: () {
                Navigator.of(context).pop();
                _handleAbsen('Keluar');
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAttendanceButtons() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              label: 'Masuk',
              onTap: () => _handleAbsen('Masuk'),
              color: Colors.blue,
              icon: Icons.login,
            ),
            const VerticalDivider(width: 1, thickness: 1, indent: 10, endIndent: 10),
            _buildActionButton(
              label: 'Keluar',
              onTap: () => _handleAbsen('Keluar'),
              color: Colors.red,
              icon: Icons.logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required String label, required VoidCallback onTap, required Color color, required IconData icon}) {
    return Expanded(
      child: InkWell(
        onTap: _isAbsenLoading ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '5 Hari Terakhir',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen())),
          child: const Text('Lihat Semua'),
        ),
      ],
    );
  }

  Widget _buildHistoryList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _absensiStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Card(child: Padding(padding: EdgeInsets.all(32.0), child: Center(child: Text('Belum ada riwayat absensi.'))));
        }

        final allDocs = snapshot.data!.docs;
        final groupedData = <String, List<Map<String, dynamic>>>{};

        for (var doc in allDocs) {
          final data = doc.data() as Map<String, dynamic>;
          final dateKey = DateFormat('yyyy-MM-dd').format((data['timestamp'] as Timestamp).toDate());
          if (!groupedData.containsKey(dateKey)) {
            groupedData[dateKey] = [];
          }
          groupedData[dateKey]!.add(data);
        }

        final sortedDates = groupedData.keys.toList()..sort((a, b) => b.compareTo(a));
        final limitedDates = sortedDates.take(5);

        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: limitedDates.map((dateKey) {
            final entries = groupedData[dateKey]!;
            final formattedDate = DateFormat('EEE, d MMM yyyy').format(DateTime.parse(dateKey));
            
            return Card(
              elevation: 1,
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(formattedDate, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Divider(),
                    ...entries.map((entry) {
                      final status = entry['status'] as String;
                      final time = DateFormat('HH:mm:ss').format((entry['timestamp'] as Timestamp).toDate());
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(status),
                            Text(time),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
  return BottomAppBar(
    shape: const CircularNotchedRectangle(),
    notchMargin: 8.0,
    elevation: 8.0, // Memberi sedikit bayangan agar lebih terlihat
    child: SizedBox( // Menggunakan SizedBox untuk memastikan tinggi yang konsisten
      height: 60.0, // Tinggi standar untuk bottom nav bar
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavBarItem(icon: Icons.home, label: 'Home', isSelected: true, onTap: () {}),
          const SizedBox(width: 40), // Spacer untuk Floating Action Button
          _buildNavBarItem(icon: Icons.person_outline, label: 'Profile', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(user: widget.user)))),
        ],
      ),
    ),
  );
}

Widget _buildNavBarItem({required IconData icon, required String label, bool isSelected = false, required VoidCallback onTap}) {
  final color = isSelected ? Colors.blue : Colors.grey;
  return Expanded( // Menggunakan Expanded agar item memiliki lebar yang sama
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24), // Agar efek klik melingkar
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Pusatkan konten secara vertikal
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 2), // Mengurangi jarak antara ikon dan teks
          Text(label, style: TextStyle(color: color, fontSize: 12)), // Ukuran font sedikit dikecilkan
        ],
      ),
    ),
  );
}
}