import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ManageOrdersPage extends StatelessWidget {
  const ManageOrdersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kelola Pesanan', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue.shade700,
          iconTheme: const IconThemeData(color: Colors.white), 
          bottom: TabBar(
            labelColor: Colors.white, 
            unselectedLabelColor: Colors.white60, 
            indicatorColor: Colors.white, 
            indicatorWeight: 3, 
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold, 
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal, 
            ),
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Processing'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OrderList(status: 'pending'),
            _OrderList(status: 'processing'),
            _OrderList(status: 'completed'),
            _OrderList(status: 'cancelled'),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final String status;

  const _OrderList({required this.status});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
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
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Belum ada pesanan ${status.toLowerCase()}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index].data() as Map<String, dynamic>;
            final createdAt = (order['createdAt'] as Timestamp).toDate();
            final pickupDate = (order['pickupDate'] as Timestamp).toDate();

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ExpansionTile(
                title: Text('Order #${orders[index].id.substring(0, 8)}'),
                subtitle: Text(
                  DateFormat('dd MMM yyyy HH:mm').format(createdAt),
                  style: TextStyle(color: Colors.grey[600]),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Nama Pelanggan', order['userName']),
                        _buildDetailRow('Jenis Layanan', order['laundryType']),
                        _buildDetailRow('Berat', '${order['quantity']} kg'),
                        _buildDetailRow(
                          'Total', 
                          'Rp ${NumberFormat('#,###').format(order['totalPrice'])}',
                        ),
                        _buildDetailRow(
                          'Waktu Pengambilan',
                          DateFormat('dd MMM yyyy HH:mm').format(pickupDate),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (status == 'pending')
                              ElevatedButton(
                                onPressed: () => _updateOrderStatus(
                                  orders[index].id, 
                                  'processing',
                                ),
                                child: const Text('Proses Pesanan'),
                              ),
                            if (status == 'processing')
                              ElevatedButton(
                                onPressed: () => _updateOrderStatus(
                                  orders[index].id, 
                                  'completed',
                                ),
                                child: const Text('Selesai'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({'status': newStatus});
    } catch (e) {
      print('Error updating order status: $e');
    }
  }
}