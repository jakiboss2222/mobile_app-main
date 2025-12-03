import 'package:flutter/material.dart';
import '../api/api_service.dart';
import 'absen_submit_page.dart';
import 'detail_absensi_page.dart';

class KehadiranDetailPage extends StatefulWidget {
  final int idKrsDetail;
  final String namaMatkul;
  final String? dosenName;

  const KehadiranDetailPage({
    super.key,
    required this.idKrsDetail,
    required this.namaMatkul,
    this.dosenName,
  });

  @override
  State<KehadiranDetailPage> createState() => _KehadiranDetailPageState();
}

class _KehadiranDetailPageState extends State<KehadiranDetailPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> meetings = [];

  @override
  void initState() {
    super.initState();
    _loadMeetingData();
  }

  Future<void> _loadMeetingData() async {
    setState(() => isLoading = true);
    
    List<Map<String, dynamic>> tempMeetings = [];
    
    // Kita cek status untuk pertemuan 1 sampai 16
    // Menggunakan Future.wait agar parallel dan lebih cepat
    List<Future<Map<String, dynamic>>> futures = [];
    
    for (int i = 1; i <= 16; i++) {
      futures.add(ApiService.cekStatusAbsensi(
        idKrsDetail: widget.idKrsDetail,
        pertemuan: i,
      ));
    }

    try {
      final results = await Future.wait(futures);
      
      for (int i = 0; i < 16; i++) {
        final result = results[i];
        bool isAttended = false;
        
        // Cek apakah ada data absensi
        if (result['data'] != null) {
          isAttended = true;
        }
        
        tempMeetings.add({
          "pertemuan": i + 1,
          "status": isAttended ? "Hadir" : "Belum Absen",
          "data": result['data'], // Simpan data detail jika ada
        });
      }
      
      if (mounted) {
        setState(() {
          meetings = tempMeetings;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading meetings: $e");
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat data: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff14213D),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.arrow_back, size: 26),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.namaMatkul,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (widget.dosenName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.dosenName!,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),

            // LIST PERTEMUAN
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : ListView.builder(
                      itemCount: meetings.length,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemBuilder: (context, index) {
                        final item = meetings[index];
                        final bool isAttended = item["status"] == "Hadir";

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () {
                              if (isAttended) {
                                // Lihat Detail
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailAbsensiPage(
                                      idKrsDetail: widget.idKrsDetail,
                                      pertemuan: item["pertemuan"],
                                      namaMatkul: widget.namaMatkul,
                                    ),
                                  ),
                                );
                              } else {
                                // Submit Absen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AbsenSubmitPage(
                                      idKrsDetail: widget.idKrsDetail,
                                      pertemuan: item["pertemuan"],
                                      namaMatkul: widget.namaMatkul,
                                    ),
                                  ),
                                ).then((_) => _loadMeetingData()); // Reload after return
                              }
                            },
                            child: Row(
                              children: [
                                // NOMOR PERTEMUAN
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Pertemuan ${item["pertemuan"]}",
                                        style: const TextStyle(
                                            fontSize: 14, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                // STATUS
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(
                                        color: isAttended ? Colors.green : Colors.grey,
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            isAttended ? Icons.check_circle : Icons.circle_outlined,
                                            size: 16,
                                            color: isAttended ? Colors.green : Colors.grey,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            item["status"],
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: isAttended
                                                  ? Colors.green
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
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
    );
  }
}
