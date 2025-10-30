import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../database/database_helper.dart';

class DaftarRotiPage extends StatefulWidget {
  final int userId;

  const DaftarRotiPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<DaftarRotiPage> createState() => _DaftarRotiPageState();
}

class _DaftarRotiPageState extends State<DaftarRotiPage> {
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

  Future<Position?> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      return null;
    }
  }

  Future<void> _beliRoti(Map<String, dynamic> roti) async {
    final jumlahController = TextEditingController();
    Position? position;
    bool isLoadingLocation = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Beli ${roti['nama']}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Harga: Rp ${roti['harga'].toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: jumlahController,
                    decoration: const InputDecoration(
                      labelText: 'Jumlah',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.shopping_cart),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red, size: 20),
                      const SizedBox(width: 5),
                      const Text(
                        'Lokasi Pengiriman',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (position == null && !isLoadingLocation)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.orange.shade700, size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Belum ada lokasi',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (isLoadingLocation)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Mengambil lokasi...', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  if (position != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: Colors.green.shade700, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Lokasi berhasil diambil',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Lat: ${position!.latitude.toStringAsFixed(6)}',
                            style: const TextStyle(fontSize: 11),
                          ),
                          Text(
                            'Long: ${position!.longitude.toStringAsFixed(6)}',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isLoadingLocation
                          ? null
                          : () async {
                        setState(() {
                          isLoadingLocation = true;
                        });

                        Position? loc = await _getCurrentLocation();

                        setState(() {
                          position = loc;
                          isLoadingLocation = false;
                        });

                        if (loc == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Gagal mengambil lokasi. Pastikan GPS aktif.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      icon: Icon(position != null ? Icons.refresh : Icons.my_location),
                      label: Text(position != null ? 'Ambil Ulang Lokasi' : 'Ambil Lokasi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: position != null ? Colors.orange : Colors.blue,
                      ),
                    ),
                  ),
                  if (position == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        '* Lokasi diperlukan untuk pengiriman',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (jumlahController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Jumlah tidak boleh kosong')),
                    );
                    return;
                  }

                  if (position == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Silakan ambil lokasi terlebih dahulu'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  int jumlah = int.parse(jumlahController.text);
                  double totalHarga = roti['harga'] * jumlah;

                  DatabaseHelper db = DatabaseHelper();
                  await db.insertTransaksi({
                    'id_pembeli': widget.userId,
                    'id_roti': roti['id'],
                    'jumlah': jumlah,
                    'total_harga': totalHarga,
                    'latitude': position!.latitude,
                    'longitude': position!.longitude,
                    'status': 'pending',
                    'tanggal': DateTime.now().toIso8601String(),
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pesanan berhasil dibuat'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('Pesan Sekarang'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _rotiList.isEmpty
        ? const Center(child: Text('Belum ada roti tersedia'))
        : GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _rotiList.length,
      itemBuilder: (context, index) {
        final roti = _rotiList[index];
        return Card(
          child: InkWell(
            onTap: () => _beliRoti(roti),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bakery_dining, size: 60, color: Colors.orange),
                  const SizedBox(height: 10),
                  Text(
                    roti['nama'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Rp ${roti['harga'].toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _beliRoti(roti),
                    child: const Text('Beli'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
