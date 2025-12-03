import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';

class JadwalPages extends StatefulWidget {
  const JadwalPages({super.key});

  @override
  State<JadwalPages> createState() => _JadwalPagesState();
}

class _JadwalPagesState extends State<JadwalPages> {
  TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> jadwal = [];
  List<Map<String, dynamic>> filteredJadwal = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJadwal();
  }

  // Load jadwal - using dummy data
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
          jadwal = data.map((item) => item as Map<String, dynamic>).toList();
        // Sort jadwal by day, with today's schedule first
        jadwal = _sortJadwalByDay(jadwal);
        filteredJadwal = jadwal;
        isLoading = false;
      });
       } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error loading jadwal: $e");
      setState(() => isLoading = false);
    }
  }

  // Sort jadwal by day of week, with today's schedule appearing first
  List<Map<String, dynamic>> _sortJadwalByDay(List<Map<String, dynamic>> jadwalList) {
    if (jadwalList.isEmpty) return jadwalList;

    // Map hari ke index (Monday = 1, Sunday = 7)
    final Map<String, int> dayToIndex = {
      'senin': 1,
      'selasa': 2,
      'rabu': 3,
      'kamis': 4,
      'jumat': 5,
      'sabtu': 6,
      'minggu': 7,
    };

    // Get current day of week (1 = Monday, 7 = Sunday)
    final now = DateTime.now();
    final currentDayIndex = now.weekday;

    // Sort jadwal
    jadwalList.sort((a, b) {
      final String dayA = (a['nama_hari'] ?? '').toString().toLowerCase();
      final String dayB = (b['nama_hari'] ?? '').toString().toLowerCase();
      
      final int indexA = dayToIndex[dayA] ?? 8;
      final int indexB = dayToIndex[dayB] ?? 8;
      
      // Calculate distance from current day
      // Today's schedule gets priority (distance = 0)
      // Tomorrow gets distance = 1, etc.
      int distanceA = (indexA - currentDayIndex) % 7;
      int distanceB = (indexB - currentDayIndex) % 7;
      
      // If distance is negative, add 7 to make it positive
      if (distanceA < 0) distanceA += 7;
      if (distanceB < 0) distanceB += 7;
      
      // Compare distances
      final dayComparison = distanceA.compareTo(distanceB);
      
      // If same day, sort by time
      if (dayComparison == 0) {
        final String timeA = a['jam_mulai'] ?? '';
        final String timeB = b['jam_mulai'] ?? '';
        return timeA.compareTo(timeB);
      }
      
      return dayComparison;
    });

    return jadwalList;
  }

  void filterSearch(String query) {
    final hasil = jadwal.where((item) {
      final nama = item["nama_matakuliah"].toString().toLowerCase();
      final kode = item["kode"].toString().toLowerCase();
      final dosen = item["dosen"].toString().toLowerCase();
      final input = query.toLowerCase();
      return nama.contains(input) || kode.contains(input) || dosen.contains(input);
    }).toList();

    setState(() {
      filteredJadwal = hasil;
    });
  }

  // Check if schedule is for today
  bool _isToday(Map<String, dynamic> jadwalItem) {
    final Map<String, int> dayToIndex = {
      'senin': 1,
      'selasa': 2,
      'rabu': 3,
      'kamis': 4,
      'jumat': 5,
      'sabtu': 6,
      'minggu': 7,
    };
    
    final String day = (jadwalItem['nama_hari'] ?? '').toString().toLowerCase();
    final int dayIndex = dayToIndex[day] ?? 0;
    final int currentDayIndex = DateTime.now().weekday;
    
    return dayIndex == currentDayIndex;
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
                  "JADWAL KULIAH",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
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
                          hintText: "Cari Kode / Mata Kuliah / Dosen",
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
                    : filteredJadwal.isEmpty
                        ? const Center(
                            child: Text(
                              "Tidak ada jadwal",
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: filteredJadwal.length,
                            itemBuilder: (context, index) {
                              final item = filteredJadwal[index];
                              final bool isToday = _isToday(item);
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isToday 
                                      ? const Color(0xff2d5aa0) // Brighter blue for today
                                      : const Color(0xff284169),
                                  borderRadius: BorderRadius.circular(20),
                                  border: isToday
                                      ? Border.all(
                                          color: const Color(0xFF4FC3F7), // Cyan accent border
                                          width: 2,
                                        )
                                      : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 6,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Kode & SKS & Badge Hari Ini
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Text(
                                                item["kode"] ?? "-",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              if (isToday) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    gradient: const LinearGradient(
                                                      colors: [
                                                        Color(0xFF4FC3F7),
                                                        Color(0xFF29B6F6),
                                                      ],
                                                    ),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: const Text(
                                                    "Hari Ini",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8, 
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            "${item["jumlah_sks"]} SKS",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Nama Matkul
                                    Text(
                                      item["nama_matakuliah"] ?? "-",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Dosen
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.person_outline,
                                          color: Colors.white70,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            item["dosen"] ?? "-",
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.9),
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),

                                    // Hari & Jam
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today_outlined,
                                          color: Colors.white70,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "${item["nama_hari"]} | ${item["jam_mulai"]} - ${item["jam_selesai"]}",
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.9),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),

                                    // Ruangan
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.meeting_room_outlined,
                                          color: Colors.white70,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          item["nama_ruang"] ?? "-",
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.9),
                                            fontSize: 13,
                                          ),
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
}