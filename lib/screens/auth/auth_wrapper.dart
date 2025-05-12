import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:washup/screens/auth/login_screen.dart';
import 'package:washup/screens/auth/verify_email_screen.dart';
// import 'package:washup/screens/dashboard_screen.dart';
import 'package:washup/screens/main_dashboard.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return LoginPage(); // Halaman dashboard jika sudah login
    } else if (!user.emailVerified) {
      return VerifyEmailPage(); // Halaman login jika belum login
    } else {
      return MainDashboard(); // Halaman login jika belum login
    }
  }
}