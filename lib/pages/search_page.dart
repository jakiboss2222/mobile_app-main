import 'package:flutter/material.dart';
import 'input_krs_page.dart';
import 'matakuliah_page.dart';
import 'profile_pages.dart';
import 'ipk_kumulatif_page.dart';
import 'jadwal_pages.dart';
import 'kehadiran_pages.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchC = TextEditingController();

  // Menu yang tersedia
  final List<Map<String, dynamic>> menuList = [
    {
      "title": "Input KRS",
      "page": const InputKrsPage(),
      "icon": Icons.edit_document,
    },
    {
      "title": "Daftar Mata Kuliah",
      "page": const DaftarMatakuliahPage(),
      "icon": Icons.book,
    },
    {
      "title": "Profil Mahasiswa",
      "page": const ProfilePages(),
      "icon": Icons.person,
    },
  
  {
      "title": "Indeks Prestasi Kumulatif",
      "page": const IpkKumulatifPage(),
      "icon": Icons.bookmark,
    },
     {
      "title": "Jadwal Kuliah",
      "page": const JadwalPages(),
      "icon": Icons.book,
    },
    {
      "title": "Kehadiran Kuliah",
      "page": const KehadiranPages(),
      "icon": Icons.check_circle,
    },


  ];
  List<Map<String, dynamic>> filtered = [];

  @override
  void initState() {
    super.initState();
    filtered = menuList;
  }

  void searchMenu(String query) {
    setState(() {
      filtered = menuList.where((item) {
        final title = item["title"].toString().toLowerCase();
        return title.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2A4D),
        title: const Text(
          "Pencarian Menu",
          style: TextStyle(
            color: Colors.white,        // Judul jadi putih
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,          // Icon back juga putih
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Input pencarian
            TextField(
              controller: searchC,
              onChanged: searchMenu,
              decoration: InputDecoration(
                hintText: "Cari menu seperti KRS, Profil, Mata Kuliah...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Hasil Pencarian
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text("Menu tidak ditemukan"),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];

                        return Card(
                          elevation: 3,
                          child: ListTile(
                            leading: Icon(
                              item["icon"],
                              color: const Color(0xFF1C2A4D),
                              size: 28,
                            ),
                            title: Text(
                              item["title"],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => item["page"],
                                ),
                              );
                            },
                          ),
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