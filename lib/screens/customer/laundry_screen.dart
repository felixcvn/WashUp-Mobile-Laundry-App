// ignore_for_file: unused_field, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:washup/screens/customer/HistoryOrder_screen.dart';
import 'package:geolocator/geolocator.dart';


class LaundryPage extends StatefulWidget {
  const LaundryPage({super.key});

  @override
  State<LaundryPage> createState() => _LaundryPageState();
}

class _LaundryPageState extends State<LaundryPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _couponController = TextEditingController();
  
  
  // Data fields
  String _serviceType = 'Cuci Aja';
  int _quantity = 1;
  String _notes = '';
  DateTime _pickupDate = DateTime.now().add(const Duration(hours: 3));
  TimeOfDay _pickupTime = TimeOfDay.now();
  bool _isPremiumService = false;
  bool _needExpress = false;
  int _totalPrice = 0;
  String _couponCode = '';
  double _discountPercentage = 0;
  bool _isCouponValid = false;
  
  // Service prices
  final Map<String, int> _prices = {
    'Cuci Aja': 4000,
    'Cuci Setrika': 8000,
    'Deep Cleaning': 15000,
  };

  final Map<String, double> _validCoupons = {
  'KUCEK99': 0.10, // 10% discount
  'NOVEMBERSIH99': 0.20, // 20% discount
  'SUPERCLEAN99': 0.30, // 30% discount
};
  
  // Animation controller
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _calculatePrice();
  }
  
  @override
  void dispose() {
    _couponController.dispose(); 
    _animationController.dispose();
    super.dispose();
  }
  
  void _calculatePrice() {
    int basePrice = _prices[_serviceType]! * _quantity;
    int additional = 0;
    
    if (_isPremiumService) {
      additional += 5000;
    }
    
    if (_needExpress) {
      additional += (basePrice * 0.5).round(); // 50% tambahan untuk express
    }

    int subtotal = basePrice + additional;

    if (_isCouponValid) {
      int discount = (subtotal * _discountPercentage).round();
      subtotal -= discount;
    }
    
    setState(() {
      _totalPrice = subtotal;
    });
  }

  void _validateCoupon(String code) {
    setState(() {
      if (_validCoupons.containsKey(code.toUpperCase())) {
        _couponCode = code.toUpperCase();
        _discountPercentage = _validCoupons[code.toUpperCase()]!;
        _isCouponValid = true;
        _calculatePrice(); // Recalculate price with discount
      } else {
        _couponCode = code;
        _discountPercentage = 0;
        _isCouponValid = false;
        _calculatePrice();
      }
    });
  }

  void _submitOrder() async {
    if (_formKey.currentState!.validate()) {
      try {
        final uid = FirebaseAuth.instance.currentUser!.uid;

        // ✅ Ambil lokasi pengguna
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        // Default lokasi jika tidak ada izin
        GeoPoint userLocation = const GeoPoint(0, 0);

        if (permission == LocationPermission.always || permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          final position = await Geolocator.getCurrentPosition(
            // ignore: deprecated_member_use
            desiredAccuracy: LocationAccuracy.high,
          );
          userLocation = GeoPoint(position.latitude, position.longitude);
        }

        // ✅ Simpan data ke Firestore dengan lokasi
        await FirebaseFirestore.instance.collection('orders').add({
          'userId': uid,
          'laundryType': _serviceType,
          'quantity': _quantity,
          'notes': _notes,
          'pickupDate': Timestamp.fromDate(
            DateTime(
              _pickupDate.year,
              _pickupDate.month,
              _pickupDate.day,
              _pickupTime.hour,
              _pickupTime.minute,
            ),
          ),
          'isPremium': _isPremiumService,
          'needExpress': _needExpress,
          'totalPrice': _totalPrice,
          'createdAt': Timestamp.now(),
          'userLocation': userLocation,
          'status': 'pending', // Status awal
          'userName': FirebaseAuth.instance.currentUser?.displayName ?? 'User',
        });

        // Animasi & snackbar sukses
        _animationController.forward().then((_) {
          _animationController.reverse();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Pesanan berhasil ditambahkan!'),
            backgroundColor: Colors.green.shade700,
          ),
        );

        // Reset form
        setState(() {
          _quantity = 1;
          _notes = '';
          _isPremiumService = false;
          _needExpress = false;
          _pickupDate = DateTime.now().add(const Duration(hours: 3));
          _pickupTime = TimeOfDay.now();
          _couponController.clear();
          _serviceType = 'Cuci Aja';
          _isCouponValid = false;
          _calculatePrice();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambahkan pesanan: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }


  void _viewOrders() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OrderHistoryPage(), 
      ),
    );
  }
  
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _pickupDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 14)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade700,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _pickupDate = picked;
      });
    }
  }
  
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _pickupTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade700,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _pickupTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 
        const Text('Tambah Pesanan Cucian'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.blue.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: _viewOrders,
            tooltip: 'Riwayat Pesanan',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade700, const Color.fromARGB(255, 146, 228, 255)],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar Ilustrasi dengan animasi
                Center(
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 1.0, end: 1.1).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.elasticInOut,
                      ),
                    ),
                    child: Lottie.asset(
                      'assets/animations/laundry.json',
                      height: 200,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Card untuk form
                Card(
                  elevation: 8,
                  shadowColor: Colors.blue.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          const Text(
                            'Tambah Pesanan Cucian',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pilih jenis layanan dan isi detail pesanan Anda',
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                          ),
                          const Divider(height: 32),
                          
                          // Dropdown
                          const Text(
                            'Jenis Cucian',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _serviceType,
                            isExpanded: true,
                            icon: const Icon(Icons.local_laundry_service),
                            items: const [
                              DropdownMenuItem(value: 'Cuci Aja', child: Text('Cuci Aja (Reguler)')),
                              DropdownMenuItem(value: 'Cuci Setrika', child: Text('Cuci Setrika (Lengkap)')),
                              DropdownMenuItem(value: 'Deep Cleaning', child: Text('Deep Cleaning (Premium)')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _serviceType = value!;
                                _calculatePrice();
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.blue.shade50,
                              hintText: 'Pilih jenis cucian',
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Weight input with slider
                          Row(
                            children: [
                              const Text(
                                'Jumlah (kg)',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade700,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '$_quantity kg',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Slider(
                            min: 1,
                            max: 10,
                            divisions: 9,
                            value: _quantity.toDouble(),
                            activeColor: Colors.blue.shade700,
                            inactiveColor: Colors.blue.shade100,
                            label: '$_quantity kg',
                            onChanged: (value) {
                              setState(() {
                                _quantity = value.toInt();
                                _calculatePrice();
                              });
                            },
                          ),
                          
                          // Pickup date and time
                          const SizedBox(height: 16),
                          const Text(
                            'Waktu Pengambilan',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: _selectDate,
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Colors.blue.shade50,
                                      prefixIcon: const Icon(Icons.calendar_today),
                                      hintText: 'Tanggal',
                                    ),
                                    child: Text(
                                      DateFormat('dd MMM yyyy').format(_pickupDate),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: _selectTime,
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Colors.blue.shade50,
                                      prefixIcon: const Icon(Icons.access_time),
                                      hintText: 'Waktu',
                                    ),
                                    child: Text(
                                      _pickupTime.format(context),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          // Additional services
                          const SizedBox(height: 16),
                          const Text(
                            'Layanan Tambahan',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          SwitchListTile(
                            title: const Text('Layanan Premium'),
                            subtitle: const Text('Deterjen premium & pewangi ekstra'),
                            value: _isPremiumService,
                            activeColor: Colors.blue.shade700,
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            onChanged: (bool value) {
                              setState(() {
                                _isPremiumService = value;
                                _calculatePrice();
                              });
                            },
                          ),
                          SwitchListTile(
                            title: const Text('Express (3 Jam)'),
                            subtitle: const Text('Layanan cepat dengan tambahan biaya 50%'),
                            value: _needExpress,
                            activeColor: Colors.blue.shade700,
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            onChanged: (bool value) {
                              setState(() {
                                _needExpress = value;
                                _calculatePrice();
                              });
                            },
                          ),
                          
                          // Notes
                          const SizedBox(height: 16),
                          const Text(
                            'Catatan Tambahan',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            maxLines: 3,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.blue.shade50,
                              hintText: 'Misal: Pakaian putih dipisah, dll',
                            ),
                            onChanged: (value) {
                              setState(() {
                                _notes = value;
                              });
                            },
                          ),

                          const SizedBox(height: 16),

                          const Text(
                            'Kupon Diskon',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                          controller: _couponController, // Tambahkan ini
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.blue.shade50,
                            hintText: 'Masukkan kode kupon',
                            prefixIcon: const Icon(Icons.discount),
                            suffixIcon: _isCouponValid 
                              ? Icon(Icons.check_circle, color: Colors.green.shade700)
                              : (_couponCode.isNotEmpty 
                                  ? Icon(Icons.error, color: Colors.red.shade700)
                                  : null),
                          ),
                          onChanged: _validateCoupon,
                          textCapitalization: TextCapitalization.characters,
                        ),
                          if (_isCouponValid) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Hemat ${(_discountPercentage * 100).toInt()}% dengan kupon $_couponCode',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          
                          // Price summary
                          const SizedBox(height: 24),
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
                                const Text(
                                  'Rincian Biaya',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('$_serviceType ($_quantity kg)'),
                                    Text('Rp ${NumberFormat('#,###').format(_prices[_serviceType]! * _quantity)}'),
                                  ],
                                ),
                                if (_isPremiumService) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Layanan Premium'),
                                      Text('Rp ${NumberFormat('#,###').format(5000)}'),
                                    ],
                                  ),
                                ],
                                if (_needExpress) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Biaya Express (50%)'),
                                      Text('Rp ${NumberFormat('#,###').format((_prices[_serviceType]! * _quantity * 0.5).round())}'),
                                    ],
                                  ),
                                ],
                                if (_isCouponValid) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Diskon $_couponCode (${(_discountPercentage * 100).toInt()}%)',
                                        style: TextStyle(color: Colors.green.shade700),
                                      ),
                                      Text(
                                        '- Rp ${NumberFormat('#,###').format(((_prices[_serviceType]! * _quantity + (_isPremiumService ? 5000 : 0) + (_needExpress ? (_prices[_serviceType]! * _quantity * 0.5).round() : 0)) * _discountPercentage).round())}',
                                        style: TextStyle(color: Colors.green.shade700),
                                      ),
                                    ],
                                  ),
                                ],
                                const Divider(height: 16),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Rp ${NumberFormat('#,###').format(_totalPrice)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          // Submit button
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _submitOrder,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                              ),
                              child: const Text(
                                'Tambah Pesanan',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed: _viewOrders,
                              icon: const Icon(Icons.list_alt, color: Colors.blue),
                              label: const Text(
                                'Lihat Daftar Pesanan',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, 
                                color: Colors.blue),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.blue.shade700),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
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
      ),
    );
  }
}