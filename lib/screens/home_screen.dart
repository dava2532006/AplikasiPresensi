import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:presensi/models/user.dart';
import 'package:presensi/services/absensi_firestore_service.dart';
import 'package:presensi/screens/add_employee_screen.dart';
import 'package:presensi/screens/history_screen.dart';
import 'package:presensi/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AbsensiFirestoreService _absensiService = AbsensiFirestoreService();
  late Stream<QuerySnapshot> _absensiStream;

  @override
  void initState() {
    super.initState();
    _absensiStream = _absensiService.getAbsensiHistory();
  }

  void _handleAbsen(String status) async {
    String result = await _absensiService.recordAbsensi(status);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: widget.user.role == 'admin'
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddEmployeeScreen()),
                );
              },
              shape: const CircleBorder(),
              child: const Icon(Icons.person_add),
            )
          : null,
      
      // BottomAppBar yang sudah disesuaikan
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // Tombol Beranda
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: IconButton(
                tooltip: 'Beranda',
                icon: const Icon(Icons.home, color: Colors.blue, size: 30),
                onPressed: () {
                  // Tidak melakukan apa-apa karena sudah di halaman beranda
                },
              ),
            ),
            // Tombol Profil
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: IconButton(
                tooltip: 'Profil',
                icon: Icon(Icons.person, color: Colors.grey[700], size: 30),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen(user: widget.user)),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: 4,
                        shadowColor: Colors.grey.withOpacity(0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: _buildGreeting(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 4,
                        shadowColor: Colors.grey.withOpacity(0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildAttendanceButtons(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Riwayat Absensi',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const HistoryScreen()),
                                );
                              },
                              child: const Text(
                                'Lihat Semua',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildHistorySection(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ... (Sisa kode widget _buildGreeting, _buildAttendanceButtons, _buildHistorySection tidak berubah)
  Widget _buildGreeting() {
    var hour = DateTime.now().hour;
    String greeting;
    if (hour < 11) {
      greeting = 'Selamat Pagi,';
    } else if (hour < 15) {
      greeting = 'Selamat Siang,';
    } else if (hour < 19) {
      greeting = 'Selamat Sore,';
    } else {
      greeting = 'Selamat Malam,';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(greeting, style: TextStyle(fontSize: 22, color: Colors.grey[700])),
        Text(widget.user.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Selamat dan semangat bekerja!', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildAttendanceButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _handleAbsen('Masuk'),
            icon: const Icon(Icons.login, color: Colors.white),
            label: const Text('Masuk', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _handleAbsen('Keluar'),
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Keluar', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildHistorySection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _absensiStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Terjadi kesalahan memuat riwayat.'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: Text('Belum ada riwayat absensi.')),
            ),
          );
        }

        final groupedData = <String, List<Map<String, dynamic>>>{};
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final date = (data['timestamp'] as Timestamp).toDate();
          final dateKey = DateFormat('EEEE, d MMM yyyy').format(date);
          if (!groupedData.containsKey(dateKey)) {
            groupedData[dateKey] = [];
          }
          groupedData[dateKey]!.add(data);
        }
        
        const int itemCountLimit = 3;
        final int itemCount = groupedData.length > itemCountLimit ? itemCountLimit : groupedData.length;

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: itemCount,
          itemBuilder: (context, index) {
            final dateKey = groupedData.keys.elementAt(index);
            final entries = groupedData[dateKey]!;

            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dateKey, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Divider(),
                    ...entries.map((entry) {
                      final status = entry['status'] as String;
                      final time = DateFormat('HH:mm').format((entry['timestamp'] as Timestamp).toDate());
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('$status: $time', style: const TextStyle(fontSize: 16)),
                            Icon(
                              status == 'Masuk' ? Icons.arrow_forward : Icons.arrow_back,
                              color: status == 'Masuk' ? Colors.green : Colors.red,
                              size: 20,
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}