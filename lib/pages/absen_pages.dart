import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../api/api_service.dart';
import './absen_submit_page.dart';
import './detail_absensi_page.dart';
import './kehadiran_detail_page.dart';

class AbsenPages extends StatefulWidget {
  const AbsenPages({super.key});

  @override
  State<AbsenPages> createState() => _AbsenPagesState();
}

class _AbsenPagesState extends State<AbsenPages> {
  TextEditingController searchController = TextEditingController();

  List<dynamic> allSchedules = []; // Semua jadwal dari API
  List<dynamic> myKrsCourses = []; // Matkul yang diambil mahasiswa
  List<dynamic> displayedCourses = []; // Matkul yang ditampilkan (filtered)
  
  // KRS Selection
  List<dynamic> availableKrs = [];
  int? selectedKrsId;
  String selectedKrsLabel = "Pilih Semester";
  
  bool isLoading = true;
  Map<String, dynamic>? user;
  int? currentIdKrs;
  String selectedDay = "Senin";

  final List<String> days = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];


  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _setInitialDay();
    _loadInitialData();
  }

  void _setInitialDay() {
    var now = DateTime.now();
    var dayName = DateFormat('EEEE', 'id_ID').format(now);
    // Map English names just in case locale isn't perfect or to be safe
    final dayMap = {
      'Monday': 'Senin',
      'Tuesday': 'Selasa',
      'Wednesday': 'Rabu',
      'Thursday': 'Kamis',
      'Friday': 'Jumat',
      'Saturday': 'Sabtu',
      'Sunday': 'Minggu',
    };
    // If it's already Indonesian (Senin, etc) from DateFormat('id_ID'), great. 
    // If it returns English, map it.
    // Note: DateFormat('EEEE', 'id_ID') usually returns Senin, Selasa etc.
    // But let's check if it matches one of our days.
    
    // Simple normalization
    if (days.contains(dayName)) {
      selectedDay = dayName;
    } else if (dayMap.containsKey(dayName)) {
      selectedDay = dayMap[dayName]!;
    }
    // else default is Senin
  }

  Future<void> _loadInitialData() async {
    setState(() => isLoading = true);
    await _getMahasiswaData();
    if (user != null) {
      // Load KRS list first to get selectedKrsId
      await _getAvailableKrs();
      
      // Then load schedules and KRS details
      await Future.wait([
        _getAllSchedules(),
        _getKrsData(),
      ]);
      _filterCourses();
    }
    setState(() => isLoading = false);
  }

  Future<void> _getAvailableKrs() async {
    try {
      if (user == null || user!['nim'] == null) {
        debugPrint('User data not loaded yet');
        return;
      }

      final response = await ApiService.daftarKrs(idMahasiswa: user!['nim'].toString());
      
      if (response['data'] != null) {
        final krsList = response['data'] as List;
        
        debugPrint('KRS loaded: ${krsList.length} items');
        
        setState(() {
          availableKrs = krsList;
          // Auto-select the first (latest) KRS if available and not already selected
          if (krsList.isNotEmpty && selectedKrsId == null) {
            selectedKrsId = krsList[0]['id'];
            selectedKrsLabel = "${krsList[0]['tahun_ajaran']} - Semester ${krsList[0]['semester']}";
          }
        });
      } else {
        debugPrint('KRS response error: ${response['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      debugPrint('Error loading KRS list: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat daftar semester: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _getAllSchedules() async {
    try {
      final res = await ApiService.daftarJadwal();
      if (res['jadwals'] != null) {
        setState(() {
          allSchedules = res['jadwals'];
        });
      }
    } catch (e) {
      debugPrint("Error loading schedules: $e");
    }
  }

  Future<void> _getKrsData() async {
    if (selectedKrsId == null) {
      setState(() => myKrsCourses = []);
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      Dio dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      // Get Detail KRS using ApiService
      final response = await ApiService.detailKrs(idKrs: selectedKrsId!);
      List<dynamic> tempMatkul = response['data'] ?? [];

      // Tidak perlu cek status karena user akan akses via History page
      // untuk melihat status masing-masing pertemuan

      setState(() {
        myKrsCourses = tempMatkul;
      });
    } catch (e) {
      debugPrint("Error loading KRS details: $e");
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
    final hasil = displayedCourses.where((item) {
      final nama = item["nama_matakuliah"].toString().toLowerCase();
      final input = query.toLowerCase();
      return nama.contains(input);
    }).toList();

    setState(() {
      displayedCourses = hasil;
    });
  }

  void _filterCourses() {
    // Filter jadwal berdasarkan hari yang dipilih
    final filtered = allSchedules.where((item) {
      final itemDay = item['nama_hari']?.toString() ?? '';
      return itemDay.toLowerCase() == selectedDay.toLowerCase();
    }).toList();

    // Map status KRS ke jadwal yang ditampilkan
    final mappedCourses = filtered.map((schedule) {
      // Cari apakah matkul ini ada di KRS user
      // Kita cocokkan berdasarkan nama_matakuliah dan hari/jam jika perlu
      // Atau idealnya ID jadwal jika ada relasinya.
      // Asumsi: Kita cocokkan nama matakuliah
      final krsMatch = myKrsCourses.firstWhere(
        (krs) => krs['nama_matakuliah'] == schedule['nama_matakuliah'],
        orElse: () => null,
      );

      if (krsMatch != null) {
        return {
          ...schedule,
          'is_taken': true,
          'id_krs_detail': krsMatch['id'], // ID untuk absen
          'sudah_absen': krsMatch['sudah_absen'],
          'zoom_link': krsMatch['zoom_link'], // Ambil zoom link dari KRS jika ada
        };
      } else {
        return {
          ...schedule,
          'is_taken': false,
        };
      }
    }).toList();

    setState(() {
      displayedCourses = mappedCourses;
    });
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

              // KRS/Semester Selector
              GestureDetector(
                onTap: () {
                  debugPrint('KRS selector tapped. Available KRS: ${availableKrs.length}');
                  
                  if (availableKrs.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tidak ada data semester. Silakan coba reload halaman.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }
                  
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: const Color(0xff1C2A4D),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Pilih Semester',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ...availableKrs.map((krs) => ListTile(
                            title: Text(
                              "${krs['tahun_ajaran']} - Semester ${krs['semester']}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: selectedKrsId == krs['id']
                                ? const Icon(Icons.check, color: Colors.green)
                                : null,
                            onTap: () async {
                              setState(() {
                                selectedKrsId = krs['id'];
                                selectedKrsLabel = "${krs['tahun_ajaran']} - Semester ${krs['semester']}";
                              });
                              Navigator.pop(context);
                              await _getKrsData();
                              _filterCourses();
                            },
                          )),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: availableKrs.isEmpty 
                          ? Colors.orange.withOpacity(0.5)
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.school, color: Colors.white),
                      Expanded(
                        child: Text(
                          availableKrs.isEmpty ? 'Loading...' : selectedKrsLabel,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        availableKrs.isEmpty ? Icons.warning : Icons.arrow_drop_down,
                        color: availableKrs.isEmpty ? Colors.orange : Colors.white,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Day Selection
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Hari",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    DropdownButton<String>(
                      value: selectedDay,
                      dropdownColor: const Color(0xff1C2A4D),
                      isExpanded: true,
                      underline: Container(),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      items: days.map((String day) {
                        return DropdownMenuItem<String>(
                          value: day,
                          child: Text(day),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedDay = newValue;
                            _filterCourses();
                          });
                        }
                      },
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
                    : displayedCourses.isEmpty
                        ? const Center(
                            child: Text(
                              "Belum ada matakuliah",
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: displayedCourses.length,
                            itemBuilder: (context, index) {
                              final item = displayedCourses[index];
                              
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
                                            color: item['is_taken'] == true
                                                ? (item['sudah_absen'] == true
                                                    ? Colors.green.withOpacity(0.1)
                                                    : Colors.red.withOpacity(0.1))
                                                : Colors.grey.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: item['is_taken'] == true
                                                  ? (item['sudah_absen'] == true
                                                      ? Colors.green
                                                      : Colors.red)
                                                  : Colors.grey,
                                            ),
                                          ),
                                          child: Text(
                                            item['is_taken'] == true
                                                ? (item['sudah_absen'] == true
                                                    ? "Sudah Absen"
                                                    : "Belum Absen")
                                                : "Belum Diambil",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: item['is_taken'] == true
                                                  ? (item['sudah_absen'] == true
                                                      ? Colors.green
                                                      : Colors.red)
                                                  : Colors.grey,
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
                                          // Camera Button (Zoom) - Only if zoom link exists
                                          if (item['zoom_link'] != null && item['zoom_link'].toString().isNotEmpty)
                                            _buildActionButton(
                                              icon: Icons.video_camera_front,
                                              color: const Color(0xff5A6C7D),
                                              onTap: () => _openZoom(item['zoom_link']),
                                            ),
                                          if (item['zoom_link'] != null && item['zoom_link'].toString().isNotEmpty)
                                            const SizedBox(width: 10),

                                          // History Button (Riwayat) - Main action for attendance
                                          _buildActionButton(
                                            icon: Icons.history,
                                            color: const Color(0xffE67E22), // Orange
                                            onTap: () {
                                              if (item['is_taken'] != true || item['id_krs_detail'] == null) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Pilih semester yang sesuai terlebih dahulu'),
                                                    backgroundColor: Colors.orange,
                                                  ),
                                                );
                                                return;
                                              }
                                              
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => KehadiranDetailPage(
                                                    idKrsDetail: item['id_krs_detail'],
                                                    namaMatkul: item['nama_matakuliah'],
                                                    dosenName: item['nama_dosen'],
                                                  ),
                                                ),
                                              );
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
