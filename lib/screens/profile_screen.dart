// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:washup/screens/auth/login_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String _userName = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final User? user = _auth.currentUser;
      
      if (user != null) {
        // Mencoba mendapatkan data user dari Firestore
        final docSnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
            
        if (docSnapshot.exists) {
          setState(() {
            _userName = docSnapshot.data()?['name'] ?? 'Pelanggan';
          });
        } else {
          // Jika data tidak ada di Firestore, gunakan displayName dari Firebase Auth
          setState(() {
            _userName = user.displayName ?? 'Pelanggan';
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      if (mounted) {
        // Cara yang lebih aman untuk navigasi ke halaman login
        // Gunakan pushReplacement daripada pushNamedAndRemoveUntil
        // Ini akan mengganti halaman saat ini dengan halaman login
        // tanpa harus mencari route spesifik dalam tabel routes
        
        // Jika menggunakan MaterialApp.router atau Navigator 2.0
        // Akan lebih baik menggunakan GoRouter atau cara navigasi lain yang tersedia
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
        );
        
        // Sebagai alternatif, jika route '/login' memang tidak terdaftar di routes table,
        // Gunakan pop untuk kembali ke halaman sebelumnya yang mungkin halaman welcome/login
        // Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during logout: $e')),
        );
      }
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text('LOGOUT'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF1E63B8),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Profile Image
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF1E63B8),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.blue[100],
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: Color(0xFF1E63B8),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // User Name
                    Text(
                      _userName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E63B8),
                      ),
                    ),
                    
                    const SizedBox(height: 2),
                    
                    // User Role
                    Text(
                      'Customer',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Profile Options
                    _buildProfileOption(
                      icon: Icons.edit,
                      title: 'Edit Profile',
                      onTap: () {
                        Navigator.pushNamed(context, '/edit-profile');
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildProfileOption(
                      icon: Icons.notifications,
                      title: 'Notification',
                      onTap: () {
                        Navigator.pushNamed(context, '/notifications');
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildProfileOption(
                      icon: Icons.lock,
                      title: 'Change Password',
                      onTap: () {
                        Navigator.pushNamed(context, '/change-password');
                      },
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _showLogoutConfirmation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E63B8),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.logout),
                            SizedBox(width: 8),
                            Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Color(0xFF1E63B8),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E63B8),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Color(0xFF1E63B8),
        ),
        onTap: onTap,
      ),
    );
  }
}