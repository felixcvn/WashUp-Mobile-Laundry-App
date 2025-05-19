import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:washup/firebase_options.dart';
import 'package:washup/screens/profile/change_password_screen.dart';
import 'package:washup/screens/profile/edit_profile_screen.dart';
import 'package:washup/screens/profile/notif_screen.dart';
import 'package:washup/screens/setting_screen.dart';
import 'package:washup/screens/splash_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        '/edit-profile': (context) => const EditProfilePage(),
        '/change-password': (context) => const ChangePasswordPage(),
        '/notifications': (context) => const NotificationsPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}
