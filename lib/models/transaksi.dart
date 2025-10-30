class Transaksi {
  final int? id;
  final int idPembeli;
  final int idRoti;
  final int jumlah;
  final double totalHarga;
  final double? latitude;
  final double? longitude;
  final String status;
  final String tanggal;

  Transaksi({
    this.id,
    required this.idPembeli,
    required this.idRoti,
    required this.jumlah,
    required this.totalHarga,
    this.latitude,
    this.longitude,
    required this.status,
    required this.tanggal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_pembeli': idPembeli,
      'id_roti': idRoti,
      'jumlah': jumlah,
      'total_harga': totalHarga,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'tanggal': tanggal,
    };
  }

  factory Transaksi.fromMap(Map<String, dynamic> map) {
    return Transaksi(
      id: map['id'],
      idPembeli: map['id_pembeli'],
      idRoti: map['id_roti'],
      jumlah: map['jumlah'],
      totalHarga: map['total_harga'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      status: map['status'],
      tanggal: map['tanggal'],
    );
  }
}