// ignore_for_file: use_super_parameters, avoid_print

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:washup/screens/courier/delivery_screen.dart';

class CourierDashboard extends StatelessWidget {
  const CourierDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard Kurir', 
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )
          ),
          backgroundColor: Colors.blue.shade700,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
            tabs: [
              Tab(text: 'Pesanan Baru'),
              Tab(text: 'Riwayat'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white60),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _NewDeliveriesTab(),
            _DeliveryHistoryTab(),
          ],
        ),
      ),
    );
  }
}

class _DeliveryHistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
        .collection('orders')
        .where('status', isEqualTo: 'completed')
        .where('deliveryStatus', isEqualTo: 'delivered')
        .orderBy('createdAt', descending: true)
        .orderBy(FieldPath.documentId, descending: true) // Tambahkan ini
        .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!.docs;

        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Belum ada riwayat pengiriman',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: orders.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final order = orders[index].data() as Map<String, dynamic>;
            final createdAt = (order['createdAt'] as Timestamp?)?.toDate();
            
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: const Icon(Icons.check, color: Colors.green),
                ),
                title: Text('Order #${orders[index].id}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pelanggan: ${order['userName'] ?? 'Tidak ada nama'}'),
                    Text('Alamat: ${order['address'] ?? 'Tidak ada alamat'}'),
                    if (createdAt != null)
                      Text(
                        'Dikirim pada: ${_formatDate(createdAt)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    Text(
                      'Total: Rp${NumberFormat('#,###').format(order['totalPrice'] ?? 0)}', // Ubah dari totalAmount ke 
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}

class _NewDeliveriesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
        .collection('orders')
        .where('status', isEqualTo: 'completed')
        .where('deliveryStatus', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .orderBy(FieldPath.documentId, descending: true) // Tambahkan ini
        .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!.docs;

        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Tidak ada pesanan baru',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: orders.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final order = orders[index].data() as Map<String, dynamic>;
            final createdAt = (order['createdAt'] as Timestamp?)?.toDate();
            
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text('Order #${orders[index].id}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pelanggan: ${order['userName'] ?? 'Tidak ada nama'}'),
                    Text('Alamat: ${order['userAddress'] ?? 'Tidak ada alamat'}'),
                    if (createdAt != null)
                      Text(
                        'Dipesan pada: ${_formatDate(createdAt)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    Text(
                      'Total: Rp${order['totalPrice']?.toString() ?? '0'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () => _startDelivery(context, orders[index].id, order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Antar'),
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  void _startDelivery(BuildContext context, String orderId, Map<String, dynamic> order) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DeliveryScreen(orderId: orderId, orderData: order),
      ),
    );
  }
}