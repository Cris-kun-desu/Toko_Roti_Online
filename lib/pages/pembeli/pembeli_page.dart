import 'package:flutter/material.dart';
import 'daftar_roti_page.dart';
import 'transaksi_pembeli_page.dart';
import '../login_page.dart';

class PembeliPage extends StatefulWidget {
  final int userId;
  final String namaPembeli;

  const PembeliPage({
    Key? key,
    required this.userId,
    required this.namaPembeli,
  }) : super(key: key);

  @override
  State<PembeliPage> createState() => _PembeliPageState();
}

class _PembeliPageState extends State<PembeliPage> {
  int _selectedIndex = 0;

  Future<void> _confirmLogout() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (result == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      DaftarRotiPage(userId: widget.userId),
      TransaksiPembeliPage(userId: widget.userId),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Halo, ${widget.namaPembeli}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Daftar Roti',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Transaksi',
          ),
        ],
      ),
    );
  }
}