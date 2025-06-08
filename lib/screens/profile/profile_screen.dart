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
  final ScrollController _scrollController = ScrollController();
  Color _appBarColor = Colors.blue;
  Color _textColor = Colors.white;
  double _elevation = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String _userName = '';
  String? _profileImageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _scrollController.addListener(_onScroll);
  }

    @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 20) {
      if (_appBarColor != Colors.white) {
        setState(() {
          _appBarColor = Colors.white;
          _textColor = Colors.blue;
          _elevation = 4;
        });
      }
    } else {
      if (_appBarColor != Colors.blue) {
        setState(() {
          _appBarColor = Colors.blue;
          _textColor = Colors.white;
          _elevation = 0;
        });
      }
    }
  }

  Future<void> _loadUserData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    
    try {
      final User? user = _auth.currentUser;
      
      if (user != null) {
        final docSnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
            
        if (docSnapshot.exists) {
          if (mounted) {
            setState(() {
              _userName = docSnapshot.data()?['name'] ?? 'Pelanggan';
              _profileImageUrl = docSnapshot.data()?['profileImageUrl'];
              debugPrint('Profile URL: $_profileImageUrl'); // Debug print
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _userName = user.displayName ?? 'Pelanggan';
              _profileImageUrl = user.photoURL;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
        );
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _appBarColor,
        elevation: _elevation,
        toolbarHeight: 60,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(18),
          ),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            color: _textColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    _buildProfileImage(),
                    const SizedBox(height: 24),
                    Text(
                      _userName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue, // Changed to blue
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Customer',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Updated Profile Options with light blue background
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

  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF1E63B8),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: _profileImageUrl != null
                  ? Image.network(
                      _profileImageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('Error loading image: $error');
                        return const Icon(
                          Icons.person,
                          size: 60,
                          color: Color(0xFF1E63B8),
                        );
                      },
                    )
                  : CircleAvatar(
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
        ],
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
        color: Colors.blue.shade50, // Changed to light blue
        borderRadius: BorderRadius.circular(12),
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
          decoration: BoxDecoration(
            color: Colors.blue.shade100, // Lighter blue for icon background
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.blue, // Blue icon
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.blue.shade700, // Darker blue for text
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.blue.shade700,
        ),
        onTap: onTap,
      ),
    );
  }
}