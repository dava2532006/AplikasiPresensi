import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:presensi/models/user.dart';
import 'package:presensi/screens/add_employee_screen.dart';
import 'package:presensi/screens/history_screen.dart';
import 'package:presensi/screens/profile_screen.dart';
import 'package:presensi/services/absensi_firestore_service.dart';
import 'package:presensi/services/auth_service.dart'; // <-- Import AuthService
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- PERUBAHAN 1: Buat state untuk user ---
  late User currentUser;
  final AbsensiFirestoreService _absensiService = AbsensiFirestoreService();
  late Stream<QuerySnapshot> _absensiStream;
  bool _isAbsenLoading = false;
  String _currentAddress = "Mencari lokasi...";

  @override
  void initState() {
    super.initState();
    // Inisialisasi currentUser dari widget
    currentUser = widget.user;
    _absensiStream = _absensiService.getAbsensiHistory();
    _updateLocationInfo();
  }

  // --- PERUBAHAN 2: Fungsi untuk refresh data user ---
  void _refreshUserData() async {
    final updatedUser = await AuthService.instance.getUserData(currentUser.uid);
    if (updatedUser != null && mounted) {
      setState(() {
        currentUser = updatedUser;
      });
    }
  }

  Future<String> _getAddressFromCoordinates(Position position) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}');
    try {
      final response = await http.get(url, headers: {'User-Agent': 'com.example.presensi'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['display_name'] ?? 'Alamat tidak ditemukan';
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

  void _showAbsenDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          children: [
            const SizedBox(height: 20),
            _buildHeader(),
            const SizedBox(height: 24),
            _buildWelcomeCard(),
            const SizedBox(height: 16),
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
        onPressed: _showAbsenDialog,
        backgroundColor: Colors.blue,
        elevation: 4.0,
        shape: const CircleBorder(),
        child: const Icon(Icons.fingerprint, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // --- PERUBAHAN 3: Update _buildHeader untuk menampilkan gambar ---
  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.blue.shade100,
          backgroundImage: currentUser.photoURL != null && currentUser.photoURL!.isNotEmpty
              ? NetworkImage("${currentUser.photoURL!}?t=${DateTime.now().millisecondsSinceEpoch}")
              : null,
          child: (currentUser.photoURL == null || currentUser.photoURL!.isEmpty)
              ? Icon(Icons.person, size: 30, color: Colors.blue.shade800)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentUser.name, // Gunakan currentUser
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _currentAddress,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            currentUser.position.isNotEmpty ? currentUser.position : 'Pegawai', // Gunakan currentUser
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Selamat Malam, selamat dan semangat bekerja!',
            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceButtons() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(label: 'Masuk', onTap: () => _handleAbsen('Masuk'), color: Colors.blue, icon: Icons.arrow_forward),
            const VerticalDivider(width: 1, thickness: 1, indent: 16, endIndent: 16),
            _buildActionButton(label: 'Keluar', onTap: () => _handleAbsen('Keluar'), color: Colors.red, icon: Icons.arrow_back),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required String label, required VoidCallback onTap, required Color color, required IconData icon}) {
    return Expanded(
      child: InkWell(
        onTap: _isAbsenLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
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
        const Text('5 Hari Terakhir', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF).withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text('Belum ada riwayat absensi.')),
          );
        }

        final allDocs = snapshot.data!.docs;
        final groupedData = <String, List<Map<String, dynamic>>>{};
        for (var doc in allDocs) {
          final data = doc.data() as Map<String, dynamic>;
          final dateKey = DateFormat('yyyy-MM-dd').format((data['timestamp'] as Timestamp).toDate());
          if (!groupedData.containsKey(dateKey)) groupedData[dateKey] = [];
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
            
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: entries.map((entry) {
                      final status = entry['status'] as String;
                      final time = DateFormat('HH:mm').format((entry['timestamp'] as Timestamp).toDate());
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Text('$status: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(time),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  Text(formattedDate, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // --- PERUBAHAN 4: Update _buildBottomNavBar untuk menunggu hasil dari ProfileScreen ---
  Widget _buildBottomNavBar() {
    return BottomAppBar(
      color: const Color(0xFFF3E8FF).withOpacity(0.5),
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      elevation: 0,
      child: SizedBox(
        height: 60.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavBarItem(icon: Icons.home, label: 'Home', isSelected: true, onTap: () {}),
            const SizedBox(width: 40),
            if (currentUser.role == 'admin') // Gunakan currentUser
              _buildNavBarItem(
                icon: Icons.person_add,
                label: 'Tambah',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEmployeeScreen())),
              )
            else
              _buildNavBarItem(
                icon: Icons.person,
                label: 'Profil',
                onTap: () async {
                  // Tunggu hasil dari ProfileScreen
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen(user: currentUser)),
                  );
                  // Setelah kembali, refresh data pengguna
                  _refreshUserData();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem({required IconData icon, required String label, bool isSelected = false, required VoidCallback onTap}) {
    final color = isSelected ? Colors.blue : Colors.grey[700];
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}