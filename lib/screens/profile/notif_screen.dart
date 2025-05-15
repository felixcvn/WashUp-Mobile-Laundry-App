import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> notifications = [
      {
        'title': 'Pesanan Berhasil',
        'subtitle': 'Pesanan laundry kamu sudah dikonfirmasi!',
        'time': '2 jam lalu',
        'icon': 'check_circle'
      },
      {
        'title': 'Pengingat Pembayaran',
        'subtitle': 'Jangan lupa bayar sebelum pesanan diproses.',
        'time': '5 jam lalu',
        'icon': 'payment'
      },
      {
        'title': 'Diskon Spesial!',
        'subtitle': 'Dapatkan potongan 20% untuk layanan express.',
        'time': 'Kemarin',
        'icon': 'local_offer'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi', style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 255, 255, 255),
        )),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              leading: Icon(
                _getIconData(notif['icon']),
                color: Colors.blueAccent,
                size: 30,
              ),
              title: Text(
                notif['title'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(notif['subtitle'] ?? ''),
              trailing: Text(
                notif['time'] ?? '',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          );
        },
      ),
      backgroundColor: const Color(0xFFF2F2F2),
    );
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'check_circle':
        return Icons.check_circle;
      case 'payment':
        return Icons.payment;
      case 'local_offer':
        return Icons.local_offer;
      default:
        return Icons.notifications;
    }
  }
}
