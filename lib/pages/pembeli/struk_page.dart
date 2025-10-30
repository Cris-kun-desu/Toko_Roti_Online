import 'package:flutter/material.dart';

class StrukPage extends StatelessWidget {
  final Map<String, dynamic> transaksi;

  const StrukPage({Key? key, required this.transaksi}) : super(key: key);

  // helper method untuk handle null values
  String _getStringValue(dynamic value) {
    if (value == null) return '-';
    return value.toString();
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '-';
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  double _getHarga() {
    if (transaksi['harga'] != null) {
      return double.parse(transaksi['harga'].toString());
    }
    if (transaksi['total_harga'] != null && transaksi['jumlah'] != null) {
      return transaksi['total_harga'] / transaksi['jumlah'];
    }
    return 0.0;
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Struk Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // header toko
            const Center(
              child: Column(
                children: [
                  Text(
                    'TOKO ROTI ONLINE',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Struk Pembelian',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),

            // detail transaksi
            _buildDetailItem('No. Transaksi', '#${_getStringValue(transaksi['id'])}'),
            _buildDetailItem('Tanggal', _formatDate(transaksi['tanggal'])),
            _buildDetailItem('Status', _getStringValue(transaksi['status']).toUpperCase()),
            const SizedBox(height: 10),
            const Divider(),

            // item yang dibeli
            _buildDetailItem('Produk', _getStringValue(transaksi['nama_roti'])),
            _buildDetailItem('Jumlah', '${_getStringValue(transaksi['jumlah'])} pcs'),
            _buildDetailItem('Harga Satuan', 'Rp ${_getHarga().toStringAsFixed(0)}'),
            const SizedBox(height: 10),
            const Divider(),

            // total
            _buildDetailItem(
              'TOTAL BAYAR',
              'Rp ${_getStringValue(transaksi['total_harga'])}',
              isBold: true,
              isTotal: true,
            ),

            // lokasi jika ada
            if (transaksi['latitude'] != null && transaksi['longitude'] != null) ...[
              const SizedBox(height: 10),
              const Divider(),
              _buildDetailItem('Lokasi Kirim', '${transaksi['latitude']}, ${transaksi['longitude']}'),
            ],

            const SizedBox(height: 30),
            const Text(
              'Terima kasih atas pembeliannya!',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {bool isBold = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 14,
              color: isTotal ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}