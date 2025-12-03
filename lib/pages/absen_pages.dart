import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../api/api_service.dart';
import './absen_submit_page.dart';
import './detail_absensi_page.dart';

class AbsenPages extends StatefulWidget {
  const AbsenPages({super.key});

  @override
  State<AbsenPages> createState() => _AbsenPagesState();
}

class _AbsenPagesState extends State<AbsenPages> {
  TextEditingController searchController = TextEditingController();

  List<dynamic> daftarMatkul = [];
  List<dynamic> filteredMatkul = [];
  bool isLoading = true;
  Map<String, dynamic>? user;
  int? currentIdKrs;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => isLoading = true);
    await _getMahasiswaData();
    if (user != null) {
      await _getLatestKrsAndDetail();
    } else {
      setState(() => isLoading = false);
    }
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
      debugPrint("Error loading student data: $e");
    }
  }

  Future<void> _getLatestKrsAndDetail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      Dio dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      // 1. Get List KRS
      final responseKrs = await dio.get(
        "${ApiService.baseUrl}krs/daftar-krs?id_mahasiswa=${user!['nim']}",
      );

      List<dynamic> listKrs = responseKrs.data['data'] ?? [];
      
      if (listKrs.isNotEmpty) {
        final latestKrs = listKrs.last;
        currentIdKrs = latestKrs['id'];

        // 2. Get Detail KRS
        await _getDetailKrs(currentIdKrs!);
      } else {
        setState(() {
          daftarMatkul = [];
          filteredMatkul = [];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading KRS: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _getDetailKrs(int idKrs) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    Dio dio = Dio();
    dio.options.headers['Authorization'] = 'Bearer $token';

    final url = "${ApiService.baseUrl}krs/detail-krs?id_krs=$idKrs";

    try {
      final res = await dio.get(url);

      List<dynamic> tempMatkul = res.data['data'] ?? [];
      
      // Cek status absensi untuk setiap matkul
      for (var mk in tempMatkul) {
        mk['sudah_absen'] = await _cekStatusAbsensi(mk['id'], dio);
      }
      
      if (mounted) {
        setState(() {
          daftarMatkul = tempMatkul;
          filteredMatkul = tempMatkul;
          isLoading = false;
        });
        _filterByDate();
      }
    } catch (e) {
      debugPrint("Error loading detail KRS: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal memuat detail KRS"),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => isLoading = false);
      }
    }
  }

  // Method untuk cek apakah sudah absen
  Future<bool> _cekStatusAbsensi(int idKrsDetail, Dio dio) async {
    try {
      final url = "${ApiService.baseUrl}absensi/detail?id_krs_detail=$idKrsDetail&pertemuan=1";
      final res = await dio.get(url);
      
      // Jika ada data absensi, berarti sudah absen
      return res.data['data'] != null;
    } catch (e) {
      // Jika error (404 atau lainnya), berarti belum absen
      return false;
    }
  }

  Future<void> _openZoom(String? url) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Link Zoom tidak tersedia"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final Uri uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal membuka Zoom"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void filterSearch(String query) {
    final hasil = daftarMatkul.where((item) {
      final nama = item["nama_matakuliah"].toString().toLowerCase();
      final input = query.toLowerCase();
      return nama.contains(input);
    }).toList();

    setState(() {
      filteredMatkul = hasil;
    });
  }

  void _filterByDate() {
    final dayName = DateFormat('EEEE', 'id_ID').format(selectedDate);
    final dayMap = {
      'Monday': 'Senin',
      'Tuesday': 'Selasa',
      'Wednesday': 'Rabu',
      'Thursday': 'Kamis',
      'Friday': 'Jumat',
      'Saturday': 'Sabtu',
      'Sunday': 'Minggu',
    };
    final indonesianDay = dayMap[dayName] ?? dayName;

    final filtered = daftarMatkul.where((item) {
      final itemDay = item['nama_hari']?.toString() ?? '';
      return itemDay.toLowerCase() == indonesianDay.toLowerCase();
    }).toList();

    setState(() {
      filteredMatkul = filtered;
    });
  }

  void _changeDate(int days) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: days));
      _filterByDate();
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _filterByDate();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff14213D),
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
                  "ABSENSI KULIAH",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Date Switcher
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                      onPressed: () => _changeDate(-1),
                    ),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Column(
                        children: [
                          Text(
                            DateFormat('EEEE', 'id_ID').format(selectedDate),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            DateFormat('dd MMMM yyyy', 'id_ID').format(selectedDate),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.white),
                      onPressed: () => _changeDate(1),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

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
                          hintText: "Cari Mata Kuliah",
                          border: InputBorder.none,
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Loading or List
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : filteredMatkul.isEmpty
                        ? const Center(
                            child: Text(
                              "Belum ada matakuliah",
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: filteredMatkul.length,
                            itemBuilder: (context, index) {
                              final item = filteredMatkul[index];
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    )
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Top row: Nama Matkul
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item["nama_matakuliah"] ?? "-",
                                            style: const TextStyle(
                                              color: Color(0xff14213D),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        // VALIDASI STATUS ABSEN
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: item['sudah_absen'] == true
                                                ? Colors.green.withOpacity(0.1)
                                                : Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: item['sudah_absen'] == true
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                          child: Text(
                                            item['sudah_absen'] == true
                                                ? "Sudah Absen"
                                                : "Belum Absen",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: item['sudah_absen'] == true
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // SKS & Schedule Info
                                    Text(
                                      "SKS ${item["jumlah_sks"]} | ${item["nama_hari"]} ${item["jam_mulai"]} - ${item["jam_selesai"]}",
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 12,
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    // Action Buttons
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // Camera Button (Zoom)
                                        _buildActionButton(
                                          icon: Icons.video_camera_front,
                                          color: const Color(0xff5A6C7D),
                                          onTap: () => _openZoom(item['zoom_link']),
                                        ),
                                        const SizedBox(width: 10),

                                        // Absen Button
                                        if (item['sudah_absen'] == true)
                                          _buildActionButton(
                                            icon: Icons.assignment_turned_in,
                                            color: const Color(0xff4A90E2),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      DetailAbsensiPage(
                                                    idKrsDetail: item['id'],
                                                    pertemuan: 1,
                                                    namaMatkul: item['nama_matakuliah'],
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        else
                                          _buildActionButton(
                                            icon: Icons.check_circle,
                                            color: Colors.green,
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      AbsenSubmitPage(
                                                    idKrsDetail: item['id'],
                                                    pertemuan: 1,
                                                    namaMatkul: item['nama_matakuliah'],
                                                  ),
                                                ),
                                              ).then((_) {
                                                if (currentIdKrs != null) {
                                                  _getDetailKrs(currentIdKrs!);
                                                }
                                              });
                                            },
                                          ),
                                      ],
                                    ),
                                  ],
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

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}
