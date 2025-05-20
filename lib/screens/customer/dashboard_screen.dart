// ignore_for_file: unused_element, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:washup/screens/auth/login_screen.dart';
import 'package:washup/screens/profile/notif_screen.dart';
import 'package:washup/screens/profile/profile_screen.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue, // Warna biru di bagian atas
              Color.fromARGB(255, 146, 228, 255), // Warna putih di bagian bawah
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Selamat Pagi,',
                            style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 255, 255, 255))),
                        Text(
                          user?.displayName ?? 'Felix',
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 0, 0, 0)),
                          // style: const TextStyle(
                          //     fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_none_rounded),
                          onPressed: () {
                            // Aksi ketika ikon notifikasi ditekan
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const NotificationsPage()),
                            );
                          },
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ProfilePage()), // Ganti dengan halaman profil Anda
                            );
                          },
                          child: CircleAvatar(
                            radius: 20, // Ukuran avatar
                            backgroundColor: Colors.blue.shade100, // Warna latar belakang avatar
                            child: const Icon(
                              Icons.person, // Gunakan ikon person
                              color: Colors.blue, // Warna ikon
                              size: 24, // Ukuran ikon
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),

                const SizedBox(height: 20),

                // Laundry Status
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FADF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.check_circle, color: Color(0xFF12B76A)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Laundry kamu udah selesai!\nLagi otw dianter nih 🚴‍♀️',
                          style: TextStyle(color: Color(0xFF027A48)),
                        ),
                      ),
                      Icon(Icons.close, color: Color(0xFF027A48)),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Promo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Promo',
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Lihat Semua',
                        style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
                  ],
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      promoCard('Bikin sepatu kinclong!\nPake kode ini :', 'KUCEKSHOE21'),
                      const SizedBox(width: 10),
                      promoCard('Diskon khusus setrika\npake kode ini :', 'KUCSET10'),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Text('Layanan kami',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                const SizedBox(height: 12),

                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: const [
                      ServiceTile(icon: Icons.local_laundry_service, title: "Cuci Aja", subtitle: "Cuci bersih wangi,\ntapi ga disetrika"),
                      ServiceTile(icon: Icons.iron, title: "Cuci Setrika", subtitle: "Cuci bersih wangi,\ndan di setrika", discount: '10% OFF'),
                      ServiceTile(icon: Icons.checkroom, title: "Dry Cleaning", subtitle: "Jas, Gaun, dan\nsemacamnya bersih!"),
                      // ServiceTile(icon: Icons.carpet, title: "Karpet", subtitle: "Biar nyaman lesehan\nsantai-santai"),
                      ServiceTile(icon: Icons.bed, title: "Kasur", subtitle: "Tidur jadi nyaman,\nbebas gatel dan bau"),
                      ServiceTile(icon: Icons.cleaning_services, title: "Sepatu & Tas", subtitle: "Biar tambah kece dan\nbersih"),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget promoCard(String text, String code) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: const AssetImage('assets/promo_bg.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.2), // Mengatur opacity menjadi 50%
            BlendMode.dstATop, // Mode blending
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text,
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ]),
            child: Text(code,
                style: const TextStyle(
                    color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class ServiceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? discount;

  const ServiceTile(
      {super.key,
      required this.icon,
      required this.title,
      required this.subtitle,
      this.discount});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ]),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 10),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 42, color: Colors.blueAccent),
                const SizedBox(height: 8),
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                Text(subtitle,
                    style: const TextStyle(color: Colors.black54, fontSize: 12)),
              ],
            ),
            if (discount != null)
              Positioned(
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(discount!,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                ),
              )
          ],
        ),
      ),
    );
  }
}
