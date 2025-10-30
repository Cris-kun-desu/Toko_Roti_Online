import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class ManageRotiPage extends StatefulWidget {
  const ManageRotiPage({Key? key}) : super(key: key);

  @override
  State<ManageRotiPage> createState() => _ManageRotiPageState();
}

class _ManageRotiPageState extends State<ManageRotiPage> {
  List<Map<String, dynamic>> _rotiList = [];

  @override
  void initState() {
    super.initState();
    _loadRoti();
  }

  Future<void> _loadRoti() async {
    DatabaseHelper db = DatabaseHelper();
    List<Map<String, dynamic>> roti = await db.getRotiList();
    setState(() {
      _rotiList = roti;
    });
  }

  Future<void> _showAddEditDialog({Map<String, dynamic>? roti}) async {
    final namaController = TextEditingController(text: roti?['nama'] ?? '');
    final hargaController = TextEditingController(
      text: roti?['harga']?.toString() ?? '',
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(roti == null ? 'Tambah Roti' : 'Edit Roti'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: 'Nama Roti'),
            ),
            TextField(
              controller: hargaController,
              decoration: const InputDecoration(labelText: 'Harga'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              if (namaController.text.isEmpty || hargaController.text.isEmpty) {
                return;
              }

              DatabaseHelper db = DatabaseHelper();
              Map<String, dynamic> data = {
                'nama': namaController.text,
                'harga': double.parse(hargaController.text),
              };

              if (roti == null) {
                await db.insertRoti(data);
              } else {
                await db.updateRoti(roti['id'], data);
              }

              Navigator.pop(context);
              _loadRoti();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // Method konfirmasi hapus roti
  Future<void> _confirmDeleteRoti(int id, String namaRoti) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Roti'),
        content: Text('Apakah Anda yakin ingin menghapus "$namaRoti"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await _deleteRoti(id);
    }
  }

  Future<void> _deleteRoti(int id) async {
    try {
      DatabaseHelper db = DatabaseHelper();
      await db.deleteRoti(id);

      // Tampilkan snackbar sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Roti berhasil dihapus'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      _loadRoti();
    } catch (e) {
      // Tampilkan snackbar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus roti: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _rotiList.isEmpty
          ? const Center(child: Text('Belum ada data roti'))
          : ListView.builder(
        itemCount: _rotiList.length,
        itemBuilder: (context, index) {
          final roti = _rotiList[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.bakery_dining, color: Colors.orange),
              title: Text(roti['nama']),
              subtitle: Text('Rp ${roti['harga'].toStringAsFixed(0)}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showAddEditDialog(roti: roti),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDeleteRoti(roti['id'], roti['nama']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}