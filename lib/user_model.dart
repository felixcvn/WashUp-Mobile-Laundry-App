import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  customer,
  admin,
  courier
}

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final DateTime createdAt;
  final String? profileImageUrl;
  final UserRole role;
  final bool emailVerified;
  final String? address;
  final bool? isAvailable; // For couriers to set their availability

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.createdAt,
    required this.role,
    this.profileImageUrl,
    this.emailVerified = false,
    this.address,
    this.isAvailable,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'createdAt': createdAt,
      'profileImageUrl': profileImageUrl,
      'role': role.toString().split('.').last,
      'emailVerified': emailVerified,
      'address': address,
      'isAvailable': isAvailable,
    };
  }

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      profileImageUrl: data['profileImageUrl'],
      role: _stringToUserRole(data['role'] ?? 'customer'),
      emailVerified: data['emailVerified'] ?? false,
      address: data['address'],
      isAvailable: data['isAvailable'],
    );
  }

  static UserRole _stringToUserRole(String role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'courier':
        return UserRole.courier;
      default:
        return UserRole.customer;
    }
  }

  // Helper method to check user role
  bool get isAdmin => role == UserRole.admin;
  bool get isCourier => role == UserRole.courier;
  bool get isCustomer => role == UserRole.customer;

  // Create a copy of UserModel with modified fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phone,
    DateTime? createdAt,
    String? profileImageUrl,
    UserRole? role,
    bool? emailVerified,
    String? address,
    bool? isAvailable,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      emailVerified: emailVerified ?? this.emailVerified,
      address: address ?? this.address,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}