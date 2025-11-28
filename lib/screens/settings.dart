import 'package:cyklze/screens/faq_page.dart';
import 'package:cyklze/screens/webpageview.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  final String termsUrl = 'https://www.cyklze.com/Terms_of_Service.html';
  final String privacyUrl = 'https://www.cyklze.com/Privacy_policy.html';

  void _onTileTapped(BuildContext context, String label) async {
    if (label == 'Terms of Service') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const WebViewPage(
            url: 'https://www.cyklze.com/Terms_of_Service.html',
            bartitle: "Terms of Service",
          ),
        ),
      );
    } else if (label == 'Privacy Policy') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const WebViewPage(
            url: 'https://www.cyklze.com/Privacy_policy.html',
            bartitle: "Privacy Policy",
          ),
        ),
      );
    } else if (label == 'FAQs') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FAQPage()),
      );
    }
  }

  void _launchURL(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      final success = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to launch URL')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch URL')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1D4D61), Color(0xFF163B4B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text("Settings",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSettingsTile(context,
              icon: Icons.description_outlined, label: 'Terms of Service'),
          const SizedBox(height: 12),
          _buildSettingsTile(context,
              icon: Icons.privacy_tip_outlined, label: 'Privacy Policy'),
          const SizedBox(height: 12),
          _buildSettingsTile(context, icon: Icons.help_outline, label: 'FAQs'),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context,
      {required IconData icon, required String label}) {
    return InkWell(
      onTap: () => _onTileTapped(context, label),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: const Color(0xFF1D4D61)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}