import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Asumsi path ini valid di proyek Anda
import '../api/api_service.dart'; 
import './krs_detail_page.dart'; // Asumsi path ini valid di proyek Anda

class InputKrsPage extends StatefulWidget {
  const InputKrsPage({super.key});

  @override
  State<InputKrsPage> createState() => _InputKrsPageState();
}

class _InputKrsPageState extends State<InputKrsPage> {
  // Warna utama yang digunakan di mockup (Deep Navy/Ungu Tua)
  final Color _primaryColor = const Color(0xff1e3557); 
  final Color _backgroundColor = const Color(0xfff5f7fb);

  Map<String, dynamic>? user;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController semesterController = TextEditingController();

  bool isLoading = false;
  bool isFetchingKrs = false;

  List<dynamic> daftarKrs = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }
  
  // Pastikan untuk memanggil dispose pada controller
  @override
  void dispose() {
    semesterController.dispose();
    super.dispose();
  }

  // ==============================
  // LOGIKA API
  // ==============================
  Future<void> _loadInitialData() async {
    if (mounted) setState(() => isFetchingKrs = true);
    await _getMahasiswaData();
    if (user != null) await _getDaftarKrs();
    if (mounted) setState(() => isFetchingKrs = false);
  }

  Future<void> _getMahasiswaData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final email = prefs.getString('auth_email');

      Dio dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await dio.post(
        "${ApiService.baseUrl}mahasiswa/detail-mahasiswa",
        data: {"email": email},
      );

      if (mounted) {
        setState(() {
          user = response.data['data'];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal memuat data mahasiswa"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitKrs() async {
    if (!_formKey.currentState!.validate()) return;

    if (mounted) setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      Dio dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await dio.post(
        "${ApiService.baseUrl}krs/buat-krs",
        data: {'nim': user?['nim'], 'semester': semesterController.text},
      );

      final msg = response.data['message'] ?? "KRS berhasil disimpan";

      if (response.statusCode == 201 || response.statusCode == 202) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: Colors.green),
          );

          semesterController.clear();
          _formKey.currentState!.reset();
          await _getDaftarKrs();
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.response?.data['message'] ?? "Gagal menyimpan data"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _getDaftarKrs() async {
    if (user == null) return;
    if (mounted) setState(() => isFetchingKrs = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      Dio dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await dio.get(
        "${ApiService.baseUrl}krs/daftar-krs?id_mahasiswa=${user!['nim']}",
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            daftarKrs = response.data['data'] ?? [];
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal memuat daftar KRS"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isFetchingKrs = false);
    }
  }

  // Fungsi untuk menghitung tahun ajaran berdasarkan semester
  // Semester 1 = 2023, Semester 2 = 2024, Semester 3 = 2024, dst
  String getTahunAjaran(int semester) {
    // Base year untuk semester 1
    int baseYear = 2023;
    
    // Hitung tahun berdasarkan semester
    // Semester 1,2 -> 2023/2024
    // Semester 3,4 -> 2024/2025
    // Semester 5,6 -> 2025/2026
    // dst
    
    int groupIndex = (semester - 1) ~/ 2; // 0 for sem 1-2, 1 for sem 3-4, dst
    int yearStart = baseYear + groupIndex;
    int yearEnd = yearStart + 1;
    
    return "$yearStart/$yearEnd";
  }

  // ==============================
  // UI - App Bar dan Struktur Halaman
  // ==============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          elevation: 0,
          backgroundColor: _primaryColor,
          centerTitle: true, 
          title: const Text(
            "Kartu Rancangan Studi", // Judul sesuai mockup pertama
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          // Menonaktifkan tombol default
          automaticallyImplyLeading: false, 
          // Menambahkan Leading kustom
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: isFetchingKrs
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : RefreshIndicator(
              onRefresh: _loadInitialData,
              color: _primaryColor,
              child: _buildContent(),
            ),
    );
  }

  // ==============================
  // UI - Content Halaman
  // ==============================
  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FORM CARD
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // INPUT FIELD
                  TextFormField(
                    controller: semesterController,
                    style: const TextStyle(fontSize: 16),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Semester",
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black26),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black26),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: _primaryColor, width: 1.5),
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Semester wajib diisi" : null,
                  ),

                  const SizedBox(height: 14),

                  // BUTTON SIMPAN (Diubah kembali menggunakan ElevatedButton.icon)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon( 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        // Membuat tampilan tombol lebih padat
                        padding: EdgeInsets.zero, 
                        elevation: 0, 
                      ),
                      onPressed: isLoading ? null : _submitKrs,
                      icon: isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          // Ikon panah ke bawah/download (Icons.file_download atau Icons.save_alt)
                          : const Icon(Icons.file_download, color: Colors.white), 
                      label: Text(
                        isLoading ? "Menyimpan..." : "Simpan KRS",
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 26),

          // Judul Riwayat KRS
          Text(
            "Riwayat KRS", // Judul sesuai mockup pertama
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 10),

          // Daftar Riwayat KRS
          if (daftarKrs.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                "Belum ada KRS yang tersimpan.",
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: daftarKrs.length,
              itemBuilder: (context, index) {
                final krs = daftarKrs[index];
                final int semester = int.tryParse(krs['semester'].toString()) ?? 1;
                final String tahunAjaran = getTahunAjaran(semester);
                
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => KrsDetailPage(
                          idKrs: krs['id'],
                          semester: krs['semester'].toString(),
                          tahunAjaran: tahunAjaran,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.menu_book,
                              color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Semester $semester",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "Tahun ajaran: $tahunAjaran",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 18),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}