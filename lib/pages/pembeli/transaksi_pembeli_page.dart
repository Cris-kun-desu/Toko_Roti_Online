import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import 'struk_page.dart';

class TransaksiPembeliPage extends StatefulWidget {
  final int userId;

  const TransaksiPembeliPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<TransaksiPembeliPage> createState() => _TransaksiPembeliPageState();
}

class _TransaksiPembeliPageState extends State<TransaksiPembeliPage> {
  List<Map<String, dynamic>> _transaksiList = [];

  @override
  void initState() {
    super.initState();
    _loadTransaksi();
  }

  Future<void> _loadTransaksi() async {
    DatabaseHelper db = DatabaseHelper();
    List<Map<String, dynamic>> transaksi = await db.getTransaksiByPembeli(widget.userId);
    setState(() {
      _transaksiList = transaksi;
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.blue;
      case 'kirim':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _transaksiList.isEmpty
        ? const Center(child: Text('Belum ada transaksi'))
        : ListView.builder(
      itemCount: _transaksiList.length,
      itemBuilder: (context, index) {
        final t = _transaksiList[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            leading: Icon(
              Icons.receipt,
              color: _getStatusColor(t['status']),
            ),
            title: Text(t['nama_roti']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jumlah: ${t['jumlah']}'),
                Text('Total: Rp ${t['total_harga'].toStringAsFixed(0)}'),
                Text('Status: ${t['status'].toUpperCase()}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.receipt_long),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StrukPage(transaksi: t),
                  ),
                );
              },
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}