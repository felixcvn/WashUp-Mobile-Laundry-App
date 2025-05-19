import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Laporan'),
          backgroundColor: Colors.blue.shade700,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pendapatan'),
              Tab(text: 'Statistik'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _RevenueReport(),
            _StatisticsReport(),
          ],
        ),
      ),
    );
  }
}

class _RevenueReport extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: 'completed')
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
        final totalRevenue = orders.fold<int>(
          0,
          (sum, order) => sum + (order.data() as Map<String, dynamic>)['totalPrice'] as int,
        );

        // Group orders by month
        final monthlyRevenue = <String, int>{};
        for (var order in orders) {
          final data = order.data() as Map<String, dynamic>;
          final date = (data['createdAt'] as Timestamp).toDate();
          final monthKey = DateFormat('MMM yyyy').format(date);
          monthlyRevenue[monthKey] = (monthlyRevenue[monthKey] ?? 0) + data['totalPrice'] as int;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Pendapatan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rp ${NumberFormat('#,###').format(totalRevenue)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Dari ${orders.length} pesanan selesai',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Pendapatan Bulanan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceBetween,
                    maxY: monthlyRevenue.values.reduce((a, b) => a > b ? a : b).toDouble(),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              monthlyRevenue.keys.elementAt(value.toInt()),
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: monthlyRevenue.entries
                        .toList()
                        .asMap()
                        .entries
                        .map((entry) {
                          return BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value.value.toDouble(),
                                color: Colors.blue.shade700,
                                width: 16,
                              ),
                            ],
                          );
                        })
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatisticsReport extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!.docs;
        
        // Calculate statistics
        int totalOrders = orders.length;
        int completedOrders = orders.where((order) => 
          (order.data() as Map<String, dynamic>)['status'] == 'completed'
        ).length;
        double totalWeight = orders.fold(0.0, (sum, order) =>
          sum + ((order.data() as Map<String, dynamic>)['quantity'] as num));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatCard(
                'Total Pesanan',
                totalOrders.toString(),
                Icons.shopping_bag,
              ),
              _buildStatCard(
                'Pesanan Selesai',
                completedOrders.toString(),
                Icons.check_circle,
              ),
              _buildStatCard(
                'Total Berat Laundry',
                '${totalWeight.toStringAsFixed(1)} kg',
                Icons.scale,
              ),
              const SizedBox(height: 24),
              const Text(
                'Status Pesanan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: _generatePieChartSections(orders),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.blue.shade700),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _generatePieChartSections(List<QueryDocumentSnapshot> orders) {
    final Map<String, int> statusCounts = {
      'pending': 0,
      'processing': 0,
      'completed': 0,
      'cancelled': 0,
    };

    for (var order in orders) {
      final status = (order.data() as Map<String, dynamic>)['status'] as String;
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
    }

    final colors = {
      'pending': Colors.orange,
      'processing': Colors.blue,
      'completed': Colors.green,
      'cancelled': Colors.red,
    };

    return statusCounts.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${entry.value}\n${entry.key}',
        color: colors[entry.key],
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}