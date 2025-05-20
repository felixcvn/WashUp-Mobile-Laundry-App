import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:washup/screens/admin/manage_orders_screen.dart';
import 'package:washup/screens/admin/manage_reports_screen.dart';
import 'package:washup/screens/admin/manage_services_screen.dart';
import 'package:washup/screens/admin/manage_users_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,)
          ),
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: () async {
              try {
                await _auth.signOut();
                if (context.mounted) {
                  // Navigate to login/auth screen and remove all previous routes
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login', // Sesuaikan dengan route name halaman login Anda
                    (route) => false,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error signing out: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(24),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildMenuCard(
            icon: Icons.shopping_bag,
            title: 'Kelola Pesanan',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageOrdersPage()),
            ),
          ),
          _buildMenuCard(
            icon: Icons.people,
            title: 'Kelola Pengguna',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageUsersPage()),
            ),
          ),
          _buildMenuCard(
            icon: Icons.local_laundry_service,
            title: 'Kelola Layanan',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageServicesPage()),
            ),
          ),
          _buildMenuCard(
            icon: Icons.analytics,
            title: 'Laporan',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReportsPage()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: Colors.blue.shade700,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}