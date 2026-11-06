import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/bookmark_service.dart';

class ScholarshipPage extends StatefulWidget {
  const ScholarshipPage({super.key});

  @override
  State<ScholarshipPage> createState() => _ScholarshipPageState();
}

class _ScholarshipPageState extends State<ScholarshipPage> {
  final TextEditingController searchController = TextEditingController();

  final BookmarkService bookmarkService = BookmarkService();

  String searchQuery = '';

  final CollectionReference scholarships = FirebaseFirestore.instance
      .collection('scholarships');

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Menambah atau menghapus bookmark
  Future<void> handleBookmark(String scholarshipId) async {
    try {
      await bookmarkService.toggleBookmark(scholarshipId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bookmark berhasil diperbarui.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui bookmark: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Beasiswa'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // KOLOM PENCARIAN
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama beasiswa atau penyelenggara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase().trim();
                });
              },
            ),

            const SizedBox(height: 20),

            // DAFTAR BEASISWA
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: scholarships
                    .where('status', isEqualTo: 'active')
                    .snapshots(),

                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Gagal mengambil data: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final documents = snapshot.data?.docs ?? [];

                  final filteredDocuments = documents.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    final title = (data['title'] ?? '')
                        .toString()
                        .toLowerCase();

                    final provider = (data['provider'] ?? '')
                        .toString()
                        .toLowerCase();

                    return title.contains(searchQuery) ||
                        provider.contains(searchQuery);
                  }).toList();

                  if (filteredDocuments.isEmpty) {
                    return const Center(
                      child: Text('Beasiswa tidak ditemukan.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredDocuments.length,

                    itemBuilder: (context, index) {
                      final document = filteredDocuments[index];

                      final scholarshipId = document.id;

                      final data = document.data() as Map<String, dynamic>;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 15),
                        elevation: 3,

                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),

                          leading: const CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.school, color: Colors.white),
                          ),

                          title: Text(
                            data['title'] ?? 'Tanpa Judul',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Penyelenggara: ${data['provider'] ?? '-'}',
                                ),
                                Text(
                                  'Jenjang: ${data['education_level'] ?? '-'}',
                                ),
                                Text('Kategori: ${data['category'] ?? '-'}'),
                                Text('Deadline: ${data['deadline'] ?? '-'}'),
                              ],
                            ),
                          ),

                          // IKON BOOKMARK
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              StreamBuilder<bool>(
                                stream: bookmarkService.watchBookmark(
                                  scholarshipId,
                                ),

                                builder: (context, bookmarkSnapshot) {
                                  final isBookmarked =
                                      bookmarkSnapshot.data ?? false;

                                  return IconButton(
                                    tooltip: isBookmarked
                                        ? 'Hapus bookmark'
                                        : 'Simpan bookmark',

                                    icon: Icon(
                                      isBookmarked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isBookmarked
                                          ? Colors.red
                                          : Colors.grey,
                                    ),

                                    onPressed: () {
                                      handleBookmark(scholarshipId);
                                    },
                                  );
                                },
                              ),

                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),

                          // DETAIL BEASISWA
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    data['title'] ?? 'Detail Beasiswa',
                                  ),

                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Penyelenggara: ${data['provider'] ?? '-'}',
                                        ),

                                        const SizedBox(height: 12),

                                        const Text(
                                          'Deskripsi:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        Text(data['description'] ?? '-'),

                                        const SizedBox(height: 12),

                                        const Text(
                                          'Persyaratan:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        Text(data['requirements'] ?? '-'),

                                        const SizedBox(height: 12),

                                        Text(
                                          'Deadline: ${data['deadline'] ?? '-'}',
                                        ),
                                      ],
                                    ),
                                  ),

                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Tutup'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
