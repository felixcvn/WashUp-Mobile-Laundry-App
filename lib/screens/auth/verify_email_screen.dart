// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:washup/screens/main_dashboard.dart';
import 'dart:async';
import 'package:lottie/lottie.dart'; // Tambahkan package Lottie untuk animasi

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> with SingleTickerProviderStateMixin {
  bool isVerified = false;
  bool isLoading = false;
  Timer? _timer;
  Timer? _countdownTimer;
  int _countdown = 30;
  late AnimationController _animationController;
  bool _canResendEmail = true;

  @override
  void initState() {
    super.initState();
    // Mulai timer untuk memeriksa verifikasi email
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => checkEmailVerified());
    
    // Controller untuk animasi
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified) {
        // Periksa bahwa widget masih terpasang sebelum memanggil setState
        if (!mounted) return;
        
        setState(() {
          isVerified = true;
        });
        _timer?.cancel();
        
        // Tambahkan delay sebelum navigasi untuk menampilkan animasi sukses
        await Future.delayed(const Duration(seconds: 2));
        
        // Periksa lagi bahwa widget masih terpasang sebelum melakukan navigasi
        if (!mounted) return;
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainDashboard()),
        );
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _resendEmailVerification() async {
    if (!_canResendEmail) return;
    
    setState(() {
      isLoading = true;
    });
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();

      // Periksa bahwa widget masih terpasang
      if (!mounted) return;

      setState(() {
        _canResendEmail = false;
        _countdown = 30;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Email verifikasi berhasil dikirim!'),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      // Batalkan timer countdown sebelumnya jika ada
      _countdownTimer?.cancel();
      
      // Timer untuk countdown
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        // Periksa bahwa widget masih terpasang sebelum setState
        if (!mounted) {
          timer.cancel();
          return;
        }
        
        if (_countdown > 0) {
          setState(() {
            _countdown--;
          });
        } else {
          setState(() {
            _canResendEmail = true;
          });
          timer.cancel();
        }
      });
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Terjadi kesalahan saat mengirim email';
      
      if (e.code == 'too-many-requests') {
        errorMessage = 'Terlalu banyak permintaan. Coba lagi nanti.';
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      
      // Periksa bahwa widget masih terpasang
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      // Periksa bahwa widget masih terpasang
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _manualCheckVerification() {
    setState(() {
      isLoading = true;
    });
    
    checkEmailVerified().then((_) {
      // Periksa bahwa widget masih terpasang
      if (!mounted) return;
      
      if (!isVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Email belum diverifikasi. Silakan periksa inbox Anda.'),
            backgroundColor: Colors.orange[700],
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final emailMasked = user?.email != null 
        ? maskEmail(user!.email!) 
        : "tidak tersedia";
    
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text('Verifikasi Email'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animasi email
                  Container(
                    height: 180,
                    width: 180,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Lottie.asset(
                      'assets/animations/email_verification.json', 
                      // Tambahkan file animasi email verification dari Lottie
                    ),
                  ),
                  
                  // Judul
                  Text(
                    'Verifikasi Email Anda',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Penjelasan
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Info email
                        Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Email telah dikirim ke:',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          emailMasked,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Instruksi
                        const Text(
                          'Kami telah mengirimkan email verifikasi ke alamat email Anda. Silakan buka email tersebut dan klik tautan verifikasi untuk melanjutkan.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tidak menerima email? Periksa folder spam atau klik tombol kirim ulang di bawah.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Tombol kirim ulang
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _canResendEmail ? _resendEmailVerification : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: _canResendEmail 
                          ? const Icon(Icons.send) 
                          : Text('$_countdown'),
                      label: Text(_canResendEmail 
                          ? 'Kirim Ulang Email Verifikasi' 
                          : 'Kirim Ulang Dalam $_countdown detik'),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tombol cek verifikasi
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : _manualCheckVerification,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: isLoading 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,),
                      label: const Text(
                        'Saya Sudah Verifikasi',
                        style: TextStyle(color: Colors.white), // Tambahkan style untuk mengubah warna teks menjadi putih
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Tombol bantuan
                  TextButton.icon(
                    onPressed: () {
                      // Implementasi bantuan - bisa tampilkan dialog atau navigasi ke halaman bantuan
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Bantuan Verifikasi'),
                          content: const SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('• Periksa folder SPAM atau Junk di email Anda'),
                                SizedBox(height: 8),
                                Text('• Pastikan alamat email yang Anda masukkan benar'),
                                SizedBox(height: 8),
                                Text('• Jika masih mengalami masalah, coba kirim ulang email verifikasi'),
                                SizedBox(height: 8),
                                Text('• Tunggu beberapa menit setelah melakukan verifikasi'),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Tutup'),
                            )
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.help_outline),
                    label: const Text('Butuh Bantuan?'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Fungsi untuk menyembunyikan sebagian email
  String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    
    String name = parts[0];
    String domain = parts[1];
    
    if (name.length <= 2) {
      return '$name@$domain';
    }
    
    String maskedName = name.substring(0, 2) + '*' * (name.length - 2);
    return '$maskedName@$domain';
  }
}