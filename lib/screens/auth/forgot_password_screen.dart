// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart'; // Import Lottie for animations

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  bool isLoading = false;
  late AnimationController _animationController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    
    // Controller for animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    // Validate form first
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      isLoading = true;
    });
    
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Link reset password berhasil dikirim!'),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      // Add slight delay before navigation
      await Future.delayed(const Duration(milliseconds: 1500));
      
      if (mounted) {
        Navigator.pop(context); // kembali ke halaman login
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Gagal mengirim email reset password';
      
      if (e.code == 'user-not-found') {
        errorMessage = 'Email tidak terdaftar dalam sistem';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Format email tidak valid';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'Terlalu banyak permintaan. Coba lagi nanti.';
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      
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
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Lupa Password'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue, // Ubah warna background menjadi biru
        titleTextStyle: const TextStyle( // Ubah warna tulisan menjadi putih
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animation
                    Container(
                      height: 200,
                      width: 200,
                      margin: const EdgeInsets.only(bottom: 40),
                      child: Lottie.asset(
                        'assets/animations/forgot_password.json', 
                      ),
                    ),
                    
                    // Title
                    Text(
                      'Reset Password',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Explanation
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
                      child: const Column(
                        children: [
                          Text(
                            'Masukkan alamat email yang terdaftar pada akun Anda. Kami akan mengirimkan link untuk reset password Anda.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Pastikan untuk memeriksa folder spam jika email tidak ditemukan di inbox Anda.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Email input field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Masukkan email Anda',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Theme.of(context).primaryColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        // Basic email validation
                        final bool emailValid = RegExp(
                          r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
                        ).hasMatch(value);
                        
                        if (!emailValid) {
                          return 'Masukkan format email yang valid';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Reset button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : _resetPassword,
                        style: ElevatedButton.styleFrom(
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
                            : const Icon(Icons.send),
                        label: const Text('Kirim Link Reset'),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Help button
                    TextButton.icon(
                      onPressed: () {
                        // Show help dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Bantuan Reset Password'),
                            content: const SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('• Pastikan Anda memasukkan email yang benar dan terdaftar'),
                                  SizedBox(height: 8),
                                  Text('• Periksa folder SPAM atau Junk di email Anda'),
                                  SizedBox(height: 8),
                                  Text('• Link reset password hanya berlaku selama 15 menit'),
                                  SizedBox(height: 8),
                                  Text('• Jika masih mengalami masalah, hubungi customer support'),
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
      ),
    );
  }
}