import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:washup/screens/admin/manage_orders_screen.dart';
import 'package:washup/screens/auth/login_screen.dart';
import 'package:washup/screens/courier/delivery_screen.dart';
import 'package:washup/services/firebase_options.dart';
import 'package:washup/screens/profile/change_password_screen.dart';
import 'package:washup/screens/profile/edit_profile_screen.dart';
import 'package:washup/screens/profile/notif_screen.dart';
import 'package:washup/screens/setting_screen.dart';
import 'package:washup/screens/splash_screen.dart';
import 'package:washup/services/notification_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final notificationService = NotificationService();
  await notificationService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/edit-profile': (context) => const EditProfilePage(),
        '/change-password': (context) => const ChangePasswordPage(),
        '/notifications': (context) => const NotificationsPage(),
        '/settings': (context) => const SettingsPage(),
        '/admin/orders': (context) => const ManageOrdersPage(),
        '/courier/deliveries': (context) => const DeliveryScreen(orderId: '', orderData: {},),
        '/orders': (context) => const ManageOrdersPage(),
      },
    );
  }
}
