import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;
  String currentLanguage = 'Indonesia';

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
          title: const Text(
            'Pengaturan Aplikasi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              const SizedBox(height: 10),
              _buildCard(
                child: SwitchListTile(
                  secondary: Icon(Icons.dark_mode, color: Colors.blue.shade700),
                  title: const Text(
                    'Mode Gelap',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  value: isDarkMode,
                  onChanged: (val) {
                    setState(() {
                      isDarkMode = val;
                    });
                  },
                ),
              ),
              const SizedBox(height: 10),
              _buildCard(
                child: ListTile(
                  leading: Icon(Icons.language, color: Colors.blue.shade700),
                  title: const Text(
                    'Bahasa',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    currentLanguage,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  onTap: () => _showLanguageDialog(),
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Informasi'),
              const SizedBox(height: 10),
              _buildCard(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.description, color: Colors.blue.shade700),
                      title: const Text(
                        'Syarat & Ketentuan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () => _showTermsDialog(),
                    ),
                    const Divider(),
                    ListTile(
                      leading: Icon(Icons.privacy_tip, color: Colors.blue.shade700),
                      title: const Text(
                        'Kebijakan Privasi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () => _showPrivacyDialog(),
                    ),
                    const Divider(),
                    ListTile(
                      leading: Icon(Icons.help_outline, color: Colors.blue.shade700),
                      title: const Text(
                        'Bantuan & Dukungan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () => _showSupportDialog(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildCard(
                child: ListTile(
                  leading: Icon(Icons.info, color: Colors.blue.shade700),
                  title: const Text(
                    'Versi Aplikasi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'v1.0.0',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Pilih Bahasa'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              setState(() {
                currentLanguage = 'Indonesia';
              });
              Navigator.pop(context);
            },
            child: const Text('Indonesia'),
          ),
          SimpleDialogOption(
            onPressed: () {
              setState(() {
                currentLanguage = 'English';
              });
              Navigator.pop(context);
            },
            child: const Text('English'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Bantuan & Dukungan'),
        content: const Text('Hubungi kami:\nWhatsApp: 08xxxxxxxx\nEmail: support@washup.com'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Syarat & Ketentuan'),
        content: const SingleChildScrollView(
          child: Text('Isi S&K akan ditampilkan di sini.\n(Tambahkan sesuai kebutuhan aplikasi.)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Kebijakan Privasi'),
        content: const SingleChildScrollView(
          child: Text('Isi kebijakan privasi ditampilkan di sini.'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        ],
      ),
    );
  }
}
