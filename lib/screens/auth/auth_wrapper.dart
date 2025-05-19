import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:washup/screens/admin/admin_dashboard_screen.dart';
import 'package:washup/screens/main_dashboard.dart';
import 'package:washup/screens/auth/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;
        if (user == null) {
          return const LoginPage();
        }

        // Check user role
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData) {
              return const LoginPage();
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>?;
            final userRole = userData?['role'] as String? ?? 'customer';

            // Route based on role
            if (userRole == 'admin') {
              return const AdminDashboard();
            }
            return const MainDashboard();
          },
        );
      },
    );
  }
}