import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;
  String _profileImageUrl = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final User? user = _auth.currentUser;
      
      if (user != null) {
        // Load email from Firebase Auth
        _emailController.text = user.email ?? '';
        
        // Load other user data from Firestore
        final docSnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
            
        if (docSnapshot.exists) {
          final userData = docSnapshot.data()!;
          setState(() {
            _nameController.text = userData['name'] ?? '';
            _phoneController.text = userData['phone'] ?? '';
            _addressController.text = userData['address'] ?? '';
            _profileImageUrl = userData['profileImage'] ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile data: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final User? user = _auth.currentUser;
      
      if (user != null) {
        // Update display name in Firebase Auth
        await user.updateDisplayName(_nameController.text);
        
        // Update user data in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'profileImage': _profileImageUrl,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue,
            Colors.white,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Edit Profile',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Profile Image Section
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF1E63B8),
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 58,
                                  backgroundColor: Colors.blue[100],
                                  backgroundImage: _profileImageUrl.isNotEmpty
                                      ? NetworkImage(_profileImageUrl) as ImageProvider
                                      : null,
                                  child: _profileImageUrl.isEmpty
                                      ? const Icon(
                                          Icons.person,
                                          size: 70,
                                          color: Color(0xFF1E63B8),
                                        )
                                      : null,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF1E63B8),
                                    border: Border.all(
                                      width: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.camera_alt,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      // Implement image picking functionality
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Image upload not implemented yet'),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Form Fields
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name Field
                              _buildFormField(
                                label: 'Full Name',
                                controller: _nameController,
                                icon: Icons.person,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Email Field (Read-only)
                              _buildFormField(
                                label: 'Email',
                                controller: _emailController,
                                icon: Icons.email,
                                readOnly: true,
                                helperText: 'Email cannot be changed',
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Phone Field
                              _buildFormField(
                                label: 'Phone Number',
                                controller: _phoneController,
                                icon: Icons.phone,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    // Simple validation for phone
                                    if (value.length < 10) {
                                      return 'Please enter a valid phone number';
                                    }
                                  }
                                  return null;
                                },
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Address Field
                              _buildTextAreaField(
                                label: 'Address',
                                controller: _addressController,
                                icon: Icons.home,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E63B8),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              disabledBackgroundColor: Colors.blue.shade300,
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    String? helperText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
        helperText: helperText,
        helperStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF1E63B8),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1E63B8), width: 2),
        ),
        filled: true,
        fillColor: readOnly ? Colors.grey[100] : Colors.white,
      ),
      readOnly: readOnly,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: readOnly ? Colors.grey[700] : Colors.black,
      ),
    );
  }

  Widget _buildTextAreaField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF1E63B8),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1E63B8), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        alignLabelWithHint: true,
      ),
      maxLines: 3,
      keyboardType: TextInputType.multiline,
    );
  }
}