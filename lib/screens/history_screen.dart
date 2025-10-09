import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:presensi/services/absensi_firestore_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final AbsensiFirestoreService _absensiService = AbsensiFirestoreService();
  late Stream<QuerySnapshot> _absensiStream;

  @override
  void initState() {
    super.initState();
    _absensiStream = _absensiService.getAbsensiHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Semua Riwayat Absensi'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[800]),
        titleTextStyle: TextStyle(
            color: Colors.grey[800], fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _absensiStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan memuat riwayat.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada riwayat absensi.'));
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

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: groupedData.length,
            itemBuilder: (context, index) {
              final dateKey = groupedData.keys.elementAt(index);
              final entries = groupedData[dateKey]!;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
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
                        // Ambil data lokasi_status, beri nilai default jika tidak ada
                        final lokasiStatus = entry['lokasi_status'] ?? 'Tidak Diketahui';
                        final isInside = lokasiStatus == 'Di Dalam Area';

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(
                                status == 'Masuk' ? Icons.arrow_forward : Icons.arrow_back,
                                color: status == 'Masuk' ? Colors.green : Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text('$status: $time', style: const TextStyle(fontSize: 16)),
                              const Spacer(),
                              Text(
                                lokasiStatus,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isInside ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
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
    );
  }
}