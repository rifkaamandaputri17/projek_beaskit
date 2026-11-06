import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_page.dart';
import 'scholarship_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Future<Map<String, dynamic>?> getUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return null;

    final document = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    return document.data();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        title: const Text(
          'Beaskit',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,

        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),

      body: user == null
          ? const Center(child: Text('Silakan login terlebih dahulu.'))
          : FutureBuilder<Map<String, dynamic>?>(
              future: getUserData(),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final userData = snapshot.data;

                final name = userData?['name'] ?? 'Mentee';

                final email = userData?['email'] ?? user.email ?? '-';

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      // BAGIAN SAPAAN
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),

                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(18),
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            const Text(
                              'Selamat Datang di Beaskit!',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              name.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              email.toString(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 18),

                            const Text(
                              'Temukan peluang beasiswa dan '
                              'wujudkan pendidikan impianmu.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // RINGKASAN BEASISWA
                      const Text(
                        'Ringkasan Beasiswa',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('scholarships')
                            .where('status', isEqualTo: 'active')
                            .snapshots(),

                        builder: (context, snapshot) {
                          String total = '0';

                          if (snapshot.hasData) {
                            total = snapshot.data!.docs.length.toString();
                          }

                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),

                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),

                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Color(0xFFE3F2FD),
                                  child: Icon(
                                    Icons.school,
                                    color: Colors.blue,
                                    size: 28,
                                  ),
                                ),

                                const SizedBox(width: 16),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      const Text(
                                        'Beasiswa Tersedia',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),

                                      const SizedBox(height: 5),

                                      Text(
                                        total,
                                        style: const TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 25),

                      // MENU UTAMA
                      const Text(
                        'Menu Utama',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // CARI BEASISWA
                      menuCard(
                        context: context,
                        icon: Icons.search,
                        title: 'Cari Beasiswa',
                        description: 'Temukan informasi beasiswa terbaru.',
                        color: Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ScholarshipPage(),
                            ),
                          );
                        },
                      ),

                      // BOOKMARK
                      menuCard(
                        context: context,
                        icon: Icons.bookmark,
                        title: 'Bookmark Beasiswa',
                        description: 'Lihat beasiswa yang kamu simpan.',
                        color: Colors.orange,
                        onTap: () {
                          showComingSoon(context);
                        },
                      ),

                      // TRACKER
                      menuCard(
                        context: context,
                        icon: Icons.checklist,
                        title: 'Tracker Beasiswa',
                        description: 'Pantau proses dan persyaratan beasiswa.',
                        color: Colors.green,
                        onTap: () {
                          showComingSoon(context);
                        },
                      ),

                      // MENTOR
                      menuCard(
                        context: context,
                        icon: Icons.people,
                        title: 'Cari Mentor',
                        description: 'Temukan mentor untuk membimbingmu.',
                        color: Colors.purple,
                        onTap: () {
                          showComingSoon(context);
                        },
                      ),

                      const SizedBox(height: 25),

                      // INFORMASI
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),

                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(15),
                        ),

                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Icon(Icons.info_outline, color: Colors.blue),

                            SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                'Beaskit membantu kamu menemukan '
                                'informasi beasiswa dan mendapatkan '
                                'bimbingan untuk mempersiapkan '
                                'pendaftaran.',
                                style: TextStyle(fontSize: 13, height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // KOMPONEN MENU
  Widget menuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),

      child: ListTile(
        contentPadding: const EdgeInsets.all(14),

        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color),
        ),

        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(description),
        ),

        trailing: const Icon(Icons.arrow_forward_ios, size: 16),

        onTap: onTap,
      ),
    );
  }

  // MENU YANG BELUM DIKEMBANGKAN
  void showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur ini akan segera dikembangkan.')),
    );
  }
}
