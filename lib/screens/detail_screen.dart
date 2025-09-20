
// import 'package:flutter/material.dart';
// import 'package:presensi/services/absensi_service.dart';
// import 'package:intl/intl.dart';

// class DetailScreen extends StatelessWidget {
//   const DetailScreen({super.key});

//   @override 
//   Widget build(BuildContext context) {
//     final absensiList = AbsensiService().getAbsensiList();
//     return Scaffold(
//       appBar: AppBar(title: const Text('Rekap Absensi')),
//       body: ListView.builder(
//         itemCount: absensiList.length,
//         itemBuilder: (context, index) {
//           final absensi = absensiList[index];
//           final formattedTime = DateFormat('dd MMM yyyy, HH:mm:ss').format(absensi.timestamp);

//           // Implementasi Polymorphism
//           // Widget akan menyesuaikan berdasarkan tipe objek (AbsensiMasuk atau AbsensiKeluar)
//           Color tileColor = absensi.status == 'Masuk' ? Colors.green.shade100 : Colors.red.shade100;
//           IconData icon = absensi.status == 'Masuk' ? Icons.login : Icons.logout;

//           return Card(
//             color: tileColor,
//             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: ListTile(
//               leading: Icon(icon),
//               title: Text('Absensi ${absensi.status}'),
//               subtitle: Text(formattedTime),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }