import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presensi/models/absensi.dart';

class AbsensiDetailScreen extends StatelessWidget {
  final Absensi absensi;

  const AbsensiDetailScreen({super.key, required this.absensi});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, dd MMMM yyyy').format(absensi.timestamp);
    final formattedTime = DateFormat('HH:mm:ss').format(absensi.timestamp);
    final isMasuk = absensi.status == 'Masuk';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Absensi'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: isMasuk ? Colors.green : Colors.red,
                    child: Icon(
                      isMasuk ? Icons.login : Icons.logout,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Absensi ${absensi.status}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isMasuk ? Colors.green : Colors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildDetailRow(
                  icon: Icons.calendar_today,
                  label: 'Tanggal ',
                  value: formattedDate,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  icon: Icons.access_time,
                  label: 'Waktu',
                  value: formattedTime,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  icon: Icons.check_circle,
                  label: 'Status',
                  value: 'Berhasil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ],
    );
  }
}