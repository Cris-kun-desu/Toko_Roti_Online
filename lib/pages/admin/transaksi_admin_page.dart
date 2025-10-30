import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class TransaksiAdminPage extends StatefulWidget {
  const TransaksiAdminPage({Key? key}) : super(key: key);

  @override
  State<TransaksiAdminPage> createState() => _TransaksiAdminPageState();
}

class _TransaksiAdminPageState extends State<TransaksiAdminPage> {
  List<Map<String, dynamic>> _transaksiList = [];

  @override
  void initState() {
    super.initState();
    _loadTransaksi();
  }

  Future<void> openGoogleMapsDirections(
      double destinationLat,
      double destinationLng,
      ) async {
    final String googleMapUrl =
        "https://www.google.com/maps/search/?api=1&query=${destinationLat},${destinationLng}";
    final Uri encodedURl = Uri.parse(googleMapUrl);
    // cek apakah google udh diinstall dan bisa dibuka
    if (await canLaunchUrl(encodedURl)) {
      launchUrl(encodedURl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open Google Maps';
    }
  }

  Future<void> _loadTransaksi() async {
    DatabaseHelper db = DatabaseHelper();
    List<Map<String, dynamic>> transaksi = await db.getAllTransaksi();
    setState(() {
      _transaksiList = transaksi;
    });
  }

  Future<void> _updateStatus(int id, String status) async {
    DatabaseHelper db = DatabaseHelper();
    await db.updateStatusTransaksi(id, status);
    _loadTransaksi();
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
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (t['latitude'] != null && t['longitude'] != null)
                  GestureDetector(
                    onLongPress: () {
                      openGoogleMapsDirections(
                        double.parse(t['latitude'].toString()),
                        double.parse(t['longitude'].toString()),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  color: Colors.red, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Lokasi Pengiriman',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${t['latitude']}, ${t['longitude']}',
                            style: TextStyle(fontSize: 12),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Tekan tahan untuk buka Google Maps',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Text('Lokasi: Tidak tersedia'),

                const SizedBox(height: 8),
                Text(
                  'Pembeli: ${t['nama_pembeli']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Roti: ${t['nama_roti']}'),
                Text('Jumlah: ${t['jumlah']}'),
                Text('Total: Rp ${t['total_harga'].toStringAsFixed(0)}'),
                Text('Status: ${t['status']}'),

                const SizedBox(height: 8),
                Row(
                  children: [
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: t['status'] == 'pending'
                          ? () => _updateStatus(t['id'], 'kirim')
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text('Kirim'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}