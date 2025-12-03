import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';
import 'kehadiran_detail_page.dart';

class KehadiranPages extends StatefulWidget {
  const KehadiranPages({super.key});

  @override
  State<KehadiranPages> createState() => _KehadiranPagesState();
}

class _KehadiranPagesState extends State<KehadiranPages> {
  TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> kehadiran = [];
  List<Map<String, dynamic>> filteredKehadiran = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJadwal();
  }

  // Load jadwal from API
  Future<void> _loadJadwal() async {
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      Dio dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await dio.get("${ApiService.baseUrl}jadwal/daftar-jadwal");
      
      if (response.data != null && response.data['jadwals'] != null) {
        List<dynamic> data = response.data['jadwals'];
        
        setState(() {
          kehadiran = data.map((item) => item as Map<String, dynamic>).toList();
          filteredKehadiran = kehadiran;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error loading jadwal: $e");
      setState(() => isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal memuat data mata kuliah"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void filterSearch(String query) {
    final hasil = kehadiran.where((item) {
      final nama = item["nama_matakuliah"].toString().toLowerCase();
      final kode = item["kode"].toString().toLowerCase();
      final input = query.toLowerCase();
      return nama.contains(input) || kode.contains(input);
    }).toList();

    setState(() {
      filteredKehadiran = hasil;
    });
  }

  void navigateToDetail(Map<String, dynamic> course) {
    // Karena halaman ini hanya menampilkan jadwal umum tanpa relasi KRS,
    // kita tidak bisa langsung ke detail attendance.
    // User harus melalui halaman Absen yang sudah terintegrasi dengan KRS.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Silakan akses fitur Absensi melalui menu Absen untuk melihat riwayat kehadiran ${course['nama_matakuliah']}',
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 101, 114, 114),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              ),

              const SizedBox(height: 10),

              const Center(
                child: Text(
                  "KEHADIRAN MATA KULIAH",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // SEARCH
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: filterSearch,
                        decoration: const InputDecoration(
                          hintText: "Cari kode / mata kuliah",
                          border: InputBorder.none,
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : filteredKehadiran.isEmpty
                        ? const Center(
                            child: Text(
                              "Tidak ada hasil",
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredKehadiran.length,
                            itemBuilder: (context, index) {
                              final item = filteredKehadiran[index];

                              return GestureDetector(
                                onTap: () => navigateToDetail(item),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff284169),
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.25),
                                        blurRadius: 6,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.book,
                                          color: Colors.white, size: 22),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item["kode"] ?? "-",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              item["nama_matakuliah"] ?? "-",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
