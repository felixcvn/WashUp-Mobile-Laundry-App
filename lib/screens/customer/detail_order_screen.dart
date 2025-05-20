// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrderDetailPage extends StatefulWidget {
  final Map<String, dynamic> order;
  final String orderId;

  const OrderDetailPage({
    super.key,
    required this.order,
    required this.orderId,
  });

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  GoogleMapController? _mapController;
  LatLng? _driverLocation;
  final LatLng _laundryLocation = const LatLng(-8.173277, 113.699675);

  @override
  void initState() {
    super.initState();
    _listenToDriverLocation();
  }

  void _listenToDriverLocation() {
    FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data['driverLocation'] != null) {
          final GeoPoint location = data['driverLocation'];
          setState(() {
            _driverLocation = LatLng(location.latitude, location.longitude);
          });
          _updateCameraPosition();
        }
      }
    });
  }

  void _updateCameraPosition() {
    if (_mapController != null && _driverLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          _getBounds(_driverLocation!, _laundryLocation),
          100.0,
        ),
      );
    }
  }

  LatLngBounds _getBounds(LatLng driver, LatLng laundry) {
    final south = driver.latitude < laundry.latitude ? driver.latitude : laundry.latitude;
    final north = driver.latitude > laundry.latitude ? driver.latitude : laundry.latitude;
    final west = driver.longitude < laundry.longitude ? driver.longitude : laundry.longitude;
    final east = driver.longitude > laundry.longitude ? driver.longitude : laundry.longitude;

    return LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pickupDate = (widget.order['pickupDate'] as Timestamp).toDate();
    final createdAt = (widget.order['createdAt'] as Timestamp).toDate();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Map Section
            Container(
              height: MediaQuery.of(context).size.height * 0.6, // Mengubah height menjadi 60% dari tinggi layar,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _laundryLocation,
                        zoom: 15,
                      ),
                      onMapCreated: (controller) => _mapController = controller,
                      markers: {
                        if (_driverLocation != null)
                          Marker(
                            markerId: const MarkerId('driver'),
                            position: _driverLocation!,
                            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                            infoWindow: const InfoWindow(title: 'Driver'),
                          ),
                        Marker(
                          markerId: const MarkerId('laundry'),
                          position: _laundryLocation,
                          infoWindow: const InfoWindow(title: 'WashUp Laundry'),
                        ),
                      },
                    ),
                    if (_driverLocation != null)
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Card(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(Icons.local_shipping, color: Colors.blue.shade700),
                                const SizedBox(width: 12),
                                const Text(
                                  'Driver sedang menuju lokasi',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Order Details
            Container(
              constraints: const BoxConstraints(minHeight: 500),
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order ID Section
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.receipt_long, color: Colors.blue.shade700),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Order #${widget.orderId.substring(0, 8)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Status Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.pending_actions, color: Colors.grey.shade700),
                                const SizedBox(width: 8),
                                const Text(
                                  'Status Pesanan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow('Status', widget.order['status'] ?? 'pending',
                              isStatus: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Service Details Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.local_laundry_service, color: Colors.grey.shade700),
                                const SizedBox(width: 8),
                                const Text(
                                  'Detail Layanan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow('Jenis Layanan', widget.order['laundryType']),
                            _buildDetailRow('Berat', '${widget.order['quantity']} kg'),
                            const SizedBox(height: 12),
                            if (widget.order['isPremium'] == true)
                              _buildServiceBadge('Premium Service', Colors.amber),
                            if (widget.order['needExpress'] == true)
                              _buildServiceBadge('Express (3 Jam)', Colors.red),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Time Details Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.access_time, color: Colors.grey.shade700),
                                const SizedBox(width: 8),
                                const Text(
                                  'Waktu',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow('Waktu Pengambilan', 
                              DateFormat('dd MMM yyyy HH:mm').format(pickupDate)),
                            _buildDetailRow('Dibuat pada', 
                              DateFormat('dd MMM yyyy HH:mm').format(createdAt)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Price Details Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.payment, color: Colors.blue.shade700),
                                const SizedBox(width: 8),
                                const Text(
                                  'Rincian Biaya',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow('Total Harga', 
                              'Rp ${NumberFormat('#,###').format(widget.order['totalPrice'])}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Notes Section (if exists)
                      if (widget.order['notes']?.isNotEmpty ?? false)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.note, color: Colors.grey.shade700),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Catatan',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                widget.order['notes'],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          if (isStatus)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(value),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            )
          else
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildServiceBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}