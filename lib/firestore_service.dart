// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:washup/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get users => _firestore.collection('users');

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Create or update user in Firestore
  Future<void> saveUserData({
    required String uid,
    required String email,
    required String name,
    String? profileImageUrl,
  }) async {
    try {
      await users.doc(uid).set({
        'uid': uid,
        'email': email,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
        'profileImageUrl': profileImageUrl,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving user data: $e');
      rethrow;
    }
  }

  // Get user data
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await users.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Check if user exists
  Future<bool> userExists(String uid) async {
    try {
      DocumentSnapshot doc = await users.doc(uid).get();
      return doc.exists;
    } catch (e) {
      print('Error checking if user exists: $e');
      return false;
    }
  }

  // Update user name
  Future<void> updateUserName(String uid, String name) async {
    try {
      await users.doc(uid).update({'name': name});
    } catch (e) {
      print('Error updating user name: $e');
      rethrow;
    }
  }

  // Update user profile image
  Future<void> updateProfileImage(String uid, String imageUrl) async {
    try {
      await users.doc(uid).update({'profileImageUrl': imageUrl});
    } catch (e) {
      print('Error updating profile image: $e');
      rethrow;
    }
  }

  // Delete user data (useful for account deletion)
  Future<void> deleteUserData(String uid) async {
    try {
      await users.doc(uid).delete();
    } catch (e) {
      print('Error deleting user data: $e');
      rethrow;
    }
  }
}