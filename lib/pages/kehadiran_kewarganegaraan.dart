import 'package:flutter/material.dart';

class KehadiranKewarganegaraanPage extends StatefulWidget {
  @override
  State<KehadiranKewarganegaraanPage> createState() =>
      _KehadiranKewarganegaraanPageState();
}

class _KehadiranKewarganegaraanPageState
    extends State<KehadiranKewarganegaraanPage> {
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff14213D),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // FIX — TOMBOL BACK SUDAH BERFUNGSI
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context); // ← ini bikin berfungsi
                        },
                        child: Icon(Icons.arrow_back, size: 26),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "#1 Kewarganegaraan",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Lutvi Riyandari, S.Pd., M.Si",
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            // LIST KEHADIRAN
            Expanded(
              child: ListView.builder(
                itemCount: data.length,
                padding: EdgeInsets.symmetric(horizontal: 20),
                itemBuilder: (context, index) {
                  final item = data[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        // TANGGAL
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Center(
                              child: Text(
                                item["tanggal"]!,
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 10),

                        // STATUS (read-only)
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
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
