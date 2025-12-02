import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// --- DATA MODEL ---

class NilaiSemester {
  final String mataKuliah;
  final int tugas;
  final int uts;
  final int uas;
  final String hadir;
  final int sks;
  final String grade;
  final double bobotAngka;

  // Wajib menggunakan 'const' untuk digunakan dalam 'const List'
  const NilaiSemester({ 
    required this.mataKuliah,
    required this.tugas,
    required this.uts,
    required this.uas,
    required this.hadir,
    required this.sks,
    required this.grade,
    required this.bobotAngka,
  });
}

// --- Halaman Utama ---

class IpkKumulatifPage extends StatelessWidget {
  // Data tiruan (mock data) sesuai mockup
  // Nama Mahasiswa dan NIM tetap di sini sebagai field, tetapi tidak ditampilkan di build method.
  final String namaMahasiswa = "Zulyarachma Utasaputri";
  final String nim = "STI202303699";

  // Wajib menggunakan 'const' pada List dan setiap item di dalamnya
  final List<NilaiSemester> nilaiData = const [
    // HANYA 10 MATA KULIAH YANG TERSISA
    const NilaiSemester(mataKuliah: "Algoritma dan Pemrograman", tugas: 90, uts: 80, uas: 98, hadir: "95%", sks: 4, grade: "A", bobotAngka: 4.0),
    const NilaiSemester(mataKuliah: "Struktur Data", tugas: 91, uts: 87, uas: 96, hadir: "97%", sks: 3, grade: "A", bobotAngka: 4.0),
    const NilaiSemester(mataKuliah: "Basis Data", tugas: 92, uts: 85, uas: 93, hadir: "94%", sks: 4, grade: "A", bobotAngka: 4.0),
    const NilaiSemester(mataKuliah: "Jaringan Komputer", tugas: 93, uts: 89, uas: 92, hadir: "80%", sks: 4, grade: "B", bobotAngka: 3.0),
    const NilaiSemester(mataKuliah: "Analisis Sistem", tugas: 94, uts: 83, uas: 91, hadir: "87%", sks: 4, grade: "A", bobotAngka: 4.0),
    const NilaiSemester(mataKuliah: "Perancangan Sistem Produksi", tugas: 95, uts: 80, uas: 89, hadir: "89%", sks: 3, grade: "B", bobotAngka: 3.0),
    const NilaiSemester(mataKuliah: "Akuntansi Dasar", tugas: 96, uts: 89, uas: 87, hadir: "94%", sks: 3, grade: "A", bobotAngka: 4.0),
    const NilaiSemester(mataKuliah: "Pengantar Manajemen", tugas: 97, uts: 88, uas: 90, hadir: "88%", sks: 3, grade: "A", bobotAngka: 4.0),
    const NilaiSemester(mataKuliah: "Pengantar Hukum Indonesia", tugas: 98, uts: 82, uas: 95, hadir: "80%", sks: 3, grade: "A", bobotAngka: 4.0),
    const NilaiSemester(mataKuliah: "Pengantar Agribisnis", tugas: 99, uts: 84, uas: 86, hadir: "99%", sks: 4, grade: "A", bobotAngka: 4.0),
    
    // 5 MATA KULIAH LAMA SUDAH DIHAPUS
  ];

  // Menggunakan Map<String, dynamic> untuk menghindari error tuple destructuring
  Map<String, dynamic> _calculateCumulativeGpa(List<NilaiSemester> courses) {
    double totalBobotNilai = 0.0;
    int totalSks = 0;

    for (var course in courses) {
      totalBobotNilai += course.bobotAngka * course.sks;
      totalSks += course.sks;
    }

    final ipk = totalSks > 0 ? totalBobotNilai / totalSks : 0.0;
    
    return {"totalSks": totalSks, "ipk": ipk};
  }

  const IpkKumulatifPage({super.key});

  @override
  Widget build(BuildContext context) {
    final gpaSummary = _calculateCumulativeGpa(nilaiData);
    final int totalSksKumulatif = gpaSummary["totalSks"] as int;
    final double ipkKumulatif = gpaSummary["ipk"] as double;

    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. AppBar
          SliverAppBar(
            backgroundColor: const Color(0xFF1C2A4D), // Warna biru tua
            foregroundColor: Colors.white,
            pinned: true,
            title: const Text(
              "Indeks Prestasi Kumulatif",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            centerTitle: true,
          ),

          SliverList(
            delegate: SliverChildListDelegate(
              [
                // 2. Info Mahasiswa (Dihapus)
                
                // 3. Tabel Nilai
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Tabel
                        _buildTableHeader(),
                        // Baris Data
                        ...nilaiData.map((nilai) => _buildTableRow(nilai)).toList(),
                      ],
                    ),
                  ),
                ),

                // Padding agar konten tidak menutupi footer saat scroll
                Container(height: screenHeight * 0.05),
              ],
            ),
          ),
        ],
      ),
      // 4. Footer IPK & SKS (Di luar CustomScrollView agar sticky di bawah)
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF1C2A4D), // Warna biru tua untuk footer
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Total SKS : ${totalSksKumulatif} SKS",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              "IPK : ${ipkKumulatif.toStringAsFixed(2)}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk Header Tabel
  Widget _buildTableHeader() {
    const List<String> headers = [
      "Mata Kuliah", "Tugas", "UTS", "UAS", "Hadir", "SKS", "Grade", "Bobot"
    ];
    return Container(
      decoration: const BoxDecoration(
        color: const Color(0xFF1C2A4D), // Warna header biru tua
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: headers.map((header) {
            return _buildHeaderCell(header);
          }).toList(),
        ),
      ),
    );
  }

  // Widget untuk Cell Header
  Widget _buildHeaderCell(String text) {
    double width = text == "Mata Kuliah" ? 180.0 : 60.0;
    if (text == "Hadir") width = 70.0;

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Widget untuk Baris Data Nilai
  Widget _buildTableRow(NilaiSemester nilai) {
    final List<String> data = [
      nilai.mataKuliah,
      nilai.tugas.toString(),
      nilai.uts.toString(),
      nilai.uas.toString(),
      nilai.hadir,
      nilai.sks.toString(),
      nilai.grade,
      nilai.bobotAngka.toStringAsFixed(0),
    ];

    return IntrinsicHeight(
      child: Row(
        children: data.asMap().entries.map((entry) {
          int index = entry.key;
          String value = entry.value;

          double width = 60.0;
          if (index == 0) {
            width = 180.0; // Kolom Mata Kuliah
          } else if (index == 4) {
            width = 70.0; // Kolom Hadir
          }

          Color backgroundColor = Colors.white;

          return Container(
            width: width,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            alignment: index == 0 ? Alignment.centerLeft : Alignment.center,
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(color: Colors.grey.shade300, width: 0.5),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: index == 0 ? 12 : 13,
                fontWeight: index == 0 ? FontWeight.w500 : FontWeight.normal,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
      ),
    );
  }
}