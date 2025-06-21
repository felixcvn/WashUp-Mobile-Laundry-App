import 'package:firebase_messaging/firebase_messaging.dart';
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
  
  @override
  void initState() {
    super.initState();
    _setupNotificationHandlers();
  }

  // Daftar halaman yang akan ditampilkan di setiap tab
  final List<Widget> _pages = [
    DashboardPage(),
    LaundryPage(),
    ProfilePage(),
    SettingsPage(),
    // const SettingsPage(),
  ];

  void _setupNotificationHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleMessage);

    // Handle when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    // Check if app was opened from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleMessage(message);
      }
    });
  }

  void _handleMessage(RemoteMessage message) {
    final route = message.data['route'];
    final orderId = message.data['orderId'];

    if (route != null) {
      switch (route) {
        case '/admin/orders':
          Navigator.pushNamed(
            context, 
            '/admin/orders',
            arguments: orderId,
          );
          break;
        case '/courier/deliveries':
          Navigator.pushNamed(
            context, 
            '/courier/deliveries',
            arguments: orderId,
          );
          break;
        case '/orders':
          Navigator.pushNamed(
            context, 
            '/orders',
            arguments: orderId,
          );
          break;
      }
    }
  }

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
        bottomNavigationBar: SizedBox(
          height: 60, // Adjust this value to change the height
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.white,
            selectedItemColor: const Color.fromARGB(255, 61, 144, 215),
            unselectedItemColor: const Color.fromARGB(255, 197, 197, 197),
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 11,
            ),
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
    )
  );
  }
}
