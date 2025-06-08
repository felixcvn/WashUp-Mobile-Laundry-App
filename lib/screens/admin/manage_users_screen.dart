import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class ManageUsersPage extends StatelessWidget {
  const ManageUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pengguna', 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          )
        ),
        backgroundColor: Colors.blue.shade700,
        iconTheme: const IconThemeData(color: Colors.white), 
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.person_add, color: Colors.white),
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'admin',
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Tambah Admin'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'courier',
                child: Row(
                  children: [
                    Icon(Icons.delivery_dining, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Tambah Kurir'),
                  ],
                ),
              ),
            ],
            onSelected: (String value) {
              if (value == 'admin') {
                _showAddUserDialog(context, 'admin');
              } else {
                _showAddUserDialog(context, 'courier');
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada pengguna',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              String formattedDate = 'Baru ditambahkan';
              final createdAt = userData['createdAt'];
              if (createdAt != null && createdAt is Timestamp) {
                formattedDate = DateFormat('dd MMM yyyy').format(createdAt.toDate());
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      userData['name'][0].toUpperCase(),
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(userData['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userData['email']),
                      Text('Telepon: ${userData['phone']}'),
                      Text(
                        'Bergabung: $formattedDate', // Use the formatted string directly
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      // Add email verification status
                      Text(
                        userData['emailVerified'] == true 
                            ? 'Email Terverifikasi' 
                            : 'Email Belum Terverifikasi',
                        style: TextStyle(
                          color: userData['emailVerified'] == true 
                              ? Colors.green 
                              : Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8, 
                          vertical: 4
                        ),
                        decoration: BoxDecoration(
                          color: userData['role'] == 'admin' 
                              ? Colors.blue.shade100 
                              : const Color.fromARGB(70, 92, 92, 92),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          userData['role'] ?? 'customer',
                          style: TextStyle(
                            color: userData['role'] == 'admin' 
                                ? Colors.blue.shade700 
                                : Colors.grey[700],
                          ),
                        ),
                      ),
                      if (userData['role'] != 'admin')
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red.shade300),
                          onPressed: () => _showDeleteConfirmation(
                            context, 
                            users[index].id, 
                            userData
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context, 
    String userId, 
    Map<String, dynamic> userData
  ) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengguna'),
        content: Text('Anda yakin ingin menghapus ${userData['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .delete();
                
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pengguna berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(
              'Hapus',
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddUserDialog(BuildContext context, String role) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final phoneController = TextEditingController();

    return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Tambah ${role == 'admin' ? 'Admin' : 'Kurir'} Baru'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama wajib diisi';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email wajib diisi';
                  }
                  if (!value.contains('@')) {
                    return 'Email tidak valid';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor telepon wajib diisi';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              try {
                // Create user in Authentication
                final userCredential = await FirebaseAuth.instance
                    .createUserWithEmailAndPassword(
                  email: emailController.text.trim(),
                  password: passwordController.text,
                );

                // Add user data to Firestore
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userCredential.user!.uid)
                    .set({
                  'name': nameController.text,
                  'email': emailController.text.trim(),
                  'phone': phoneController.text,
                  'role': role,
                  'createdAt': FieldValue.serverTimestamp(),
                  'emailVerified': true, // Set to true by default
                });

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${role == 'admin' ? 'Admin' : 'Kurir'} baru berhasil ditambahkan',
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
          },
          child: const Text('Tambah'),
        ),
      ],
    ),
  );
  }
}