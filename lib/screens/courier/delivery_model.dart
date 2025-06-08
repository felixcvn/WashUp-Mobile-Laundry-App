import 'package:cloud_firestore/cloud_firestore.dart';

class Delivery {
  final String id;
  final String orderId;
  final String userId;
  final String? courierId;
  final String status;
  final String? deliveryPhoto;
  final DateTime? deliveredAt;
  final String userName;
  final GeoPoint userLocation;
  final String laundryType;
  final int quantity;
  final String? notes;
  final DateTime pickupDate;
  final bool isPremium;
  final bool needExpress;
  final double totalPrice;
  final DateTime createdAt;

  Delivery({
    required this.id,
    required this.orderId,
    required this.userId,
    this.courierId,
    required this.status,
    this.deliveryPhoto,
    this.deliveredAt,
    required this.userName,
    required this.userLocation,
    required this.laundryType,
    required this.quantity,
    this.notes,
    required this.pickupDate,
    required this.isPremium,
    required this.needExpress,
    required this.totalPrice,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'userId': userId,
      'courierId': courierId,
      'status': status,
      'deliveryPhoto': deliveryPhoto,
      'deliveredAt': deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
      'userName': userName,
      'userLocation': userLocation,
      'laundryType': laundryType,
      'quantity': quantity,
      'notes': notes,
      'pickupDate': Timestamp.fromDate(pickupDate),
      'isPremium': isPremium,
      'needExpress': needExpress,
      'totalPrice': totalPrice,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Delivery.fromMap(Map<String, dynamic> map) {
    return Delivery(
      id: map['id'],
      orderId: map['orderId'],
      userId: map['userId'],
      courierId: map['courierId'],
      status: map['status'],
      deliveryPhoto: map['deliveryPhoto'],
      deliveredAt: map['deliveredAt']?.toDate(),
      userName: map['userName'] ?? 'User',
      userLocation: map['userLocation'] as GeoPoint,
      laundryType: map['laundryType'],
      quantity: map['quantity'],
      notes: map['notes'],
      pickupDate: (map['pickupDate'] as Timestamp).toDate(),
      isPremium: map['isPremium'] ?? false,
      needExpress: map['needExpress'] ?? false,
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}