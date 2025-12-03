import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import '../api/api_service.dart';
import '../widgets/bottom_nav.dart';

import './detail_berita_pages.dart';
import './matakuliah_page.dart';
import './profile_pages.dart';
import './input_krs_page.dart';
import './jadwal_pages.dart';
import './kehadiran_pages.dart';
import './ipk_kumulatif_page.dart'; // Impor IpkKumulatifPage
import './khs_list_page.dart'; // Impor KhsListPage
import './ktm_page.dart'; // Impor KtmPage
import './absen_pages.dart'; // Impor AbsenPages

class DashboardPages extends StatefulWidget {
  const DashboardPages({super.key});

  @override
  State<DashboardPages> createState() => _DashboardPagesState();
}

class _DashboardPagesState extends State<DashboardPages> {
  Map<String, dynamic>? user;
  List<dynamic> beritaAkademik = [];

  // MENU
  final List<Map<String, dynamic>> menuItems = [
    {"icon": Icons.person_outline, "label": "Biodata"},
    {"icon": Icons.calendar_month_outlined, "label": "Jadwal"},
    {"icon": Icons.how_to_reg_outlined, "label": "Kehadiran"},
    {"icon": Icons.fact_check_outlined, "label": "Nilai"},
    {"icon": Icons.menu_book_outlined, "label": "KRS"},
    {"icon": Icons.assignment_outlined, "label": "KHS"},
    {"icon": Icons.badge_outlined, "label": "KTM"},
    {"icon": Icons.camera_alt_outlined, "label": "Absen"},
  ];

  @override
  void initState() {
    super.initState();
    _getMahasiswaData();
    _getBeritaAkademik();
  }

  // ================= GET MAHASISWA ===================
  Future<void> _getMahasiswaData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      final email = prefs.getString("auth_email");

      Dio dio = Dio()
        ..options.headers['Authorization'] = 'Bearer $token'
        ..options.headers['Content-type'] = 'application/json';

      final response = await dio.post(
        "${ApiService.baseUrl}mahasiswa/detail-mahasiswa",
        data: {"email": email},
      );

      setState(() => user = response.data["data"]);
    } catch (e) {
      debugPrint("Error getMahasiswa: $e");
    }
  }

  // ================= GET BERITA ===================
  Future<void> _getBeritaAkademik() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");

      Dio dio = Dio()
        ..options.headers['Authorization'] = 'Bearer $token'
        ..options.headers['Content-type'] = 'application/json';

      final response = await dio.get("${ApiService.baseUrl}info/berita");

      setState(() => beritaAkademik = response.data["data"] ?? []);
    } catch (e) {
      debugPrint("Error getBerita: $e");
    }
  }

  // ================= NAVIGASI MENU ===================
  void _onMenuTap(String label) {
    switch (label) {
      case "Biodata":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePages()),
        );
        break;

      case "Jadwal":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => JadwalPages()),
        );
        break;

      case "Kehadiran":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => KehadiranPages()),
        );
        break;

      case "Nilai": // Navigasi ke halaman IPK
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const IpkKumulatifPage()), // Menggunakan 'const'
        );
        break;

      case "KRS":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const InputKrsPage()),
        );
        break;

      case "KHS":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const KhsListPage()),
        );
        break;

      case "KTM":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const KtmPage()),
        );
        break;

      case "Absen":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AbsenPages()),
        );
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Menu "$label" belum tersedia')),
        );
    }
  }

  // ================= UI / HALAMAN ===================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNav(),
      backgroundColor: Colors.grey.shade200,
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // ================= HEADER =================
                  Stack(
                    children: [
                      Container(
                        height: 260,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/images/SWU_2.jpg"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        height: 260,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black54,
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 95,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            "Selamat Datang",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.95),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 45,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 22, vertical: 12),
                            decoration: BoxDecoration(
                              color:const Color(0xFF1C2A4D),
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 6,
                                  color: Colors.black.withOpacity(0.15),
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.person,
                                    color: Colors.white, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  user?["nama"] ?? "-",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ================= MENU =================
                  Transform.translate(
                    offset: const Offset(0, -20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 25),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.05),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "BERANDA",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 18),
                          GridView.count(
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.3,
                            children: menuItems.map((item) {
                              return GestureDetector(
                                onTap: () => _onMenuTap(item["label"]),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.black87,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Icon(
                                        item["icon"],
                                        size: 24,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Flexible(
                                      child: Text(
                                        item["label"],
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ================= BERITA =================
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Berita Akademik",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1C2A4D),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  beritaAkademik.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Belum ada berita akademik"),
                        )
                      : ListView.builder(
                          itemCount: beritaAkademik.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            final berita = beritaAkademik[index];
                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.article_outlined,
                                  color: const Color(0xFF1C2A4D),
                                ),
                                title: Text(
                                  berita["judul"] ?? "-",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle:
                                    Text("Tanggal: ${berita["createdAt"] ?? ""}"),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          DetailBeritaPages(berita: berita),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}