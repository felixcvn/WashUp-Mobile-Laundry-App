import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagement {
  static Future<void> createAdminUser({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    // Verify current user is admin
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('No user logged in');

    final adminDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (adminDoc.data()?['role'] != 'admin') {
      throw Exception('Unauthorized: Only admins can create admin users');
    }

    try {
      // Create new admin user
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Set role as admin
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'uid': userCredential.user!.uid,
        'name': name,
        'phone': phone,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'admin',
      });

      // Send email verification
      await userCredential.user!.sendEmailVerification();
    } catch (e) {
      rethrow;
    }
  }
}