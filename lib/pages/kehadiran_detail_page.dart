import 'package:flutter/material.dart';

class KehadiranDetailPage extends StatefulWidget {
  final Map<String, dynamic> courseData;

  const KehadiranDetailPage({super.key, required this.courseData});

  @override
  State<KehadiranDetailPage> createState() => _KehadiranDetailPageState();
}

class _KehadiranDetailPageState extends State<KehadiranDetailPage> {
  List<Map<String, String>> data = [
    {"tanggal": "01/09/2025", "status": "Hadir"},
    {"tanggal": "08/09/2025", "status": "Hadir"},
    {"tanggal": "15/09/2025", "status": "Izin"},
    {"tanggal": "22/09/2025", "status": "Hadir"},
    {"tanggal": "29/09/2025", "status": "Hadir"},
    {"tanggal": "06/10/2025", "status": "Hadir"},
    {"tanggal": "13/10/2025", "status": "Hadir"},
    {"tanggal": "27/10/2025", "status": "Hadir"},
    {"tanggal": "03/11/2025", "status": "Hadir"},
    {"tanggal": "10/11/2025", "status": "Alfa"},
    {"tanggal": "17/11/2025", "status": "Hadir"},
    {"tanggal": "24/11/2025", "status": "Hadir"},
    {"tanggal": "01/12/2025", "status": "Hadir"},
    {"tanggal": "08/12/2025", "status": "Hadir"},
  ];

  void pilihStatus(int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Pilih Kehadiran",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              _opsiStatus(index, "Hadir", Colors.green),
              _opsiStatus(index, "Izin", Colors.orange),
              _opsiStatus(index, "Alfa", Colors.red),
            ],
          ),
        );
      },
    );
  }

  Widget _opsiStatus(int index, String status, Color color) {
    return ListTile(
      title: Text(status, style: TextStyle(color: color, fontSize: 16)),
      onTap: () {
        setState(() {
          data[index]["status"] = status;
        });
        Navigator.pop(context);
      },
    );
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
                          "${widget.courseData['kode']} ${widget.courseData['nama_matakuliah']}",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.courseData['dosen'] ?? "-",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            // LIST KEHADIRAN
            Expanded(
              child: ListView.builder(
                itemCount: data.length,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemBuilder: (context, index) {
                  final item = data[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        // TANGGAL
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
                                item["tanggal"]!,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // STATUS (click to change)
                        Expanded(
                          child: InkWell(
                            onTap: () => pilihStatus(index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Center(
                                child: Text(
                                  item["status"]!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: item["status"] == "Hadir"
                                        ? Colors.green
                                        : item["status"] == "Izin"
                                            ? Colors.orange
                                            : Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ),
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
    );
  }
}
