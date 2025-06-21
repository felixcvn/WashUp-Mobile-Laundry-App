import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryScreen extends StatefulWidget {
  final String orderId;
  final Map<String, dynamic> orderData;

  const DeliveryScreen({
    super.key, 
    required this.orderId, 
    required this.orderData,
  });
  
  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  final cloudinary = CloudinaryPublic('washup', 'bukti_foto_washup', cache: false);
  File? _photo;
  bool _isLoading = false;

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 70,
    );
      
    if (photo != null) {
      setState(() {
        _photo = File(photo.path);
      });
    }
  }

  Future<void> _completeDelivery() async {
    if (_photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap ambil foto bukti pengiriman'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          _photo!.path,
          folder: 'delivery_photos',
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      final photoUrl = response.secureUrl;

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({
        'deliveryStatus': 'delivered',
        'deliveryPhoto': photoUrl,
        'deliveredAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengiriman berhasil diselesaikan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error completing delivery: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyelesaikan pengiriman: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderData = widget.orderData;
    final isPremium = orderData['isPremium'] ?? false;
    final isExpress = orderData['needExpress'] ?? false;
    final createdAt = orderData['createdAt'] as Timestamp?;
    final formattedDate = createdAt != null 
        ? DateFormat('dd MMM yyyy, HH:mm').format(createdAt.toDate())
        : 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengiriman', 
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Informasi Pelanggan',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(Icons.account_circle, 'Nama', orderData['userName'] ?? 'N/A'),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.location_on, 'Alamat', orderData['address'] ?? 'N/A'),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.phone, 'Telepon', orderData['phone'] ?? 'N/A'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_laundry_service, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Detail Laundry',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(Icons.access_time, 'Tanggal Order', formattedDate),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.shopping_bag, 
                      'Jenis Laundry', 
                      orderData['laundryType'] ?? 'N/A'
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.scale, 
                      'Berat/Kuantitas', 
                      '${orderData['quantity'] ?? 0} kg'
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.payment, 
                      'Total Harga', 
                      'Rp${NumberFormat('#,###').format(orderData['totalPrice'] ?? 0)}'
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildServiceBadge(
                          isPremium,
                          'Premium',
                          Colors.amber,
                          Icons.stars,
                        ),
                        const SizedBox(width: 8),
                        _buildServiceBadge(
                          isExpress,
                          'Express',
                          Colors.red,
                          Icons.flash_on,
                        ),
                      ],
                    ),
                    if (orderData['notes']?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Catatan:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(orderData['notes']),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.camera_alt, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Foto Bukti Pengiriman',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_photo != null)
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: FileImage(_photo!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[200],
                        ),
                        child: const Center(
                          child: Text('Belum ada foto'),
                        ),
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _takePhoto,
                      icon: const Icon(Icons.camera_alt, color: Colors.blue),
                      label: const Text('Ambil Foto Bukti', 
                        style: TextStyle(color: Colors.blue),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 45),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            SlideToCompleteButton(
              onSlideComplete: _isLoading ? null : _completeDelivery,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    if (label == 'Telepon') {
      return InkWell(
        onTap: () async {
          String phoneNumber = value.replaceAll(RegExp(r'[^\d+]'), '');
          if (!phoneNumber.startsWith('+')) {
            if (phoneNumber.startsWith('0')) {
              phoneNumber = '+62${phoneNumber.substring(1)}';
            } else {
              phoneNumber = '+62$phoneNumber';
            }
          }
          
          final Uri whatsappUrl = Uri.parse('https://wa.me/$phoneNumber');
          
          if (await canLaunchUrl(whatsappUrl)) {
            await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tidak dapat membuka WhatsApp'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              '$label: ',
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.blue[700],
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(width: 4),
                  FaIcon(
                    FontAwesomeIcons.whatsapp,
                    size: 20,
                    color: Colors.green[600],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceBadge(bool isActive, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? color : Colors.grey[300]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isActive ? color : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? color : Colors.grey,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class SlideToCompleteButton extends StatefulWidget {
  final VoidCallback? onSlideComplete;
  final bool isLoading;

  const SlideToCompleteButton({
    super.key,
    this.onSlideComplete,
    this.isLoading = false,
  });

  @override
  State<SlideToCompleteButton> createState() => _SlideToCompleteButtonState();
}

class _SlideToCompleteButtonState extends State<SlideToCompleteButton> {
  double _dragValue = 0.0;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.grey[200],
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              'Geser untuk menyelesaikan pengiriman',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: MediaQuery.of(context).size.width * _dragValue,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.green,
            ),
          ),
          GestureDetector(
            onHorizontalDragStart: (_) => setState(() => _isDragging = true),
            onHorizontalDragEnd: (_) {
              setState(() => _isDragging = false);
              if (_dragValue > 0.75 && widget.onSlideComplete != null) {
                widget.onSlideComplete!();
              }
              setState(() => _dragValue = 0.0);
            },
            onHorizontalDragUpdate: (details) {
              setState(() {
                _dragValue = (_dragValue + details.delta.dx / MediaQuery.of(context).size.width)
                    .clamp(0.0, 1.0);
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              height: 60,
              width: 60,
              margin: EdgeInsets.only(
                left: (MediaQuery.of(context).size.width - 92) * _dragValue,
              ),
              decoration: BoxDecoration(
                color: widget.isLoading ? Colors.grey : Colors.green,
                borderRadius: BorderRadius.circular(30),
              ),
              child: widget.isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 32,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}