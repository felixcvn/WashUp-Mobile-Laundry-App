import 'package:flutter/material.dart';
import 'package:washup/screens/customer/dashboard_screen.dart';
import 'package:washup/screens/customer/laundry_screen.dart';
import 'package:washup/screens/profile/profile_screen.dart';
import 'package:washup/screens/setting_screen.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;

  // Daftar halaman yang akan ditampilkan di setiap tab
  final List<Widget> _pages = [
    DashboardPage(),
    LaundryPage(),
    ProfilePage(),
    SettingsPage(),
    // const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue, // Warna biru di bagian atas
            Colors.white, // Warna putih di bagian bawah
          ],
        ),
      ),

      child: Scaffold(
        backgroundColor: Colors.white,
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.blue.shade500, // latar biru konsisten
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_rounded),
              label: 'Cucian',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Pengaturan',
            ),
          ],
        ),
      )
    );  
  }
}
