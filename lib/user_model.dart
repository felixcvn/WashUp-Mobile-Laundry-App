import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final DateTime createdAt;
  final String? profileImageUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.createdAt,
    this.profileImageUrl,
  });

  // Convert to a map for storing in Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'createdAt': createdAt,
      'profileImageUrl': profileImageUrl,
    };
  }

  // Create a UserModel from a Firestore document
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      profileImageUrl: data['profileImageUrl'],
    );
  }
}