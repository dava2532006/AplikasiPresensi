import 'package:flutter/material.dart';
import 'package:presensi/services/auth_service.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  // Fungsi untuk menampilkan dialog konfirmasi
  void _showConfirmationDialog() {
    // Mengambil data dari input fields
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    // Validasi input sederhana
    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan Email tidak boleh kosong!')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Penambahan Pegawai'),
          content: Text('Anda yakin ingin menambahkan "$name" sebagai pegawai baru?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
            ),
            ElevatedButton(
              child: const Text('Ya, Tambahkan'),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                _performAddEmployee();      // Lanjutkan proses penambahan
              },
            ),
          ],
        );
      },
    );
  }

  // Fungsi inti untuk menambahkan pegawai setelah dikonfirmasi
  void _performAddEmployee() async {
    setState(() {
      _isLoading = true;
    });

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final position = _positionController.text.trim();
    
    // Kata sandi default
    const String defaultPassword = "password";

    // Memanggil fungsi signUp dengan role 'pegawai'
    String? result = await _authService.signUp(name, email, defaultPassword, position, 'pegawai');

    if (mounted) {
      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pegawai berhasil ditambahkan! Email verifikasi telah dikirim.')),
        );
        Navigator.pop(context); // Kembali ke halaman beranda
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan pegawai: $result')),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Pegawai'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _positionController,
              decoration: const InputDecoration(
                labelText: 'Jabatan',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                // Mengganti onPressed untuk memanggil dialog
                onPressed: _isLoading ? null : _showConfirmationDialog,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Tambah Pegawai'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}