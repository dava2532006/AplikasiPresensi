import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:presensi/models/user.dart';
import 'package:presensi/services/absensi_firestore_service.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AbsensiFirestoreService _absensiService = AbsensiFirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Profil Pengguna
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      child: Icon(Icons.person, size: 40),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.name,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.user.position,
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bagian Tombol Presensi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await _absensiService.recordAbsensi('Masuk');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Absensi Masuk berhasil dicatat!')),
                    );
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Masuk'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await _absensiService.recordAbsensi('Keluar');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Absensi Keluar berhasil dicatat!')),
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Keluar'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Bagian Riwayat Absensi
            const Text(
              'Riwayat Absensi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: _absensiService.getAbsensiHistory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Terjadi kesalahan saat memuat data.'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Belum ada riwayat absensi.'));
                }

                // Mengelompokkan data berdasarkan tanggal
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

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: groupedData.length,
                  itemBuilder: (context, index) {
                    final dateKey = groupedData.keys.elementAt(index);
                    final entries = groupedData[dateKey]!;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dateKey,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const Divider(),
                            ...entries.map((entry) {
                              final status = entry['status'] as String;
                              final timestamp = (entry['timestamp'] as Timestamp).toDate();
                              final time = DateFormat('HH:mm').format(timestamp);
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('$status: $time'),
                                    Icon(
                                      status == 'Masuk' ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                                      color: status == 'Masuk' ? Colors.green : Colors.red,
                                      size: 16,
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
            ),
          ],
        ),
      ),
    );
  }
}