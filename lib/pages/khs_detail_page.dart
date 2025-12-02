import 'package:flutter/material.dart';
import 'package:siakad/models/khs_model.dart';

class KhsDetailPage extends StatelessWidget {
  final SemesterKHS semester;
  final Map<String, dynamic>? userData;

  const KhsDetailPage({
    super.key,
    required this.semester,
    this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B5998),
        foregroundColor: Colors.white,
        title: const Text(
          "Kartu Hasil Studi",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan Logo
              _buildHeader(),
              const SizedBox(height: 20),
              
              // Title
              const Center(
                child: Text(
                  "KARTU HASIL STUDI SEMESTER SATU",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Info Mahasiswa
              _buildInfoMahasiswa(),
              const SizedBox(height: 16),

              // Tabel Nilai
              _buildTabelNilai(),
              const SizedBox(height: 16),

              // Keterangan
              _buildKeterangan(),
              const SizedBox(height: 20),

              // Catatan Studi
              _buildCatatanStudi(),
              const SizedBox(height: 30),

              // Area Tanda Tangan
              _buildTandaTangan(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        Container(
          width: 50,
          height: 50,
          padding: const EdgeInsets.all(4),
          child: Image.asset(
            'assets/images/logo_stmik.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 12),
        // Institusi Info
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "SEKOLAH TINGGI MANAJEMEN INFORMATIKA DAN KOMPUTER",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2),
              Text(
                "STMIK WIDYA UTAMA",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoMahasiswa() {
    // Get nama and nim from userData, fallback to semester data if not available
    final String nama = userData?["nama"] ?? semester.nama;
    final String nim = userData?["nim"] ?? semester.nim;
    
    return Column(
      children: [
        _buildInfoRow("Nama | NIM", ": $nama | $nim"),
        _buildInfoRow("Kelas | Semester", ": ${semester.kelas} | Ganjil"),
        _buildInfoRow("Status", ": ${semester.status}"),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabelNilai() {
    return Column(
      children: [
        // Header Tabel
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: Row(
            children: [
              _buildTableHeaderCell("NO", 40),
              _buildTableHeaderCell("Kode MK", 80),
              _buildTableHeaderCell("Mata\nKuliah", 150),
              _buildTableHeaderCell("SKS", 50),
              _buildTableHeaderCell("Nilai", 50),
              _buildTableHeaderCell("Bobot", 50),
            ],
          ),
        ),
        // Baris Data
        ...semester.mataKuliah.asMap().entries.map((entry) {
          int index = entry.key + 1;
          MataKuliahKHS mk = entry.value;
          return _buildTableRow(
            index.toString(),
            mk.kodeMk,
            mk.namaMataKuliah,
            mk.sks.toString(),
            mk.nilai,
            mk.bobot.toString(),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTableHeaderCell(String text, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.black, width: 1)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildTableRow(
    String no,
    String kodeMk,
    String mataKuliah,
    String sks,
    String nilai,
    String bobot,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 0.5),
      ),
      child: Row(
        children: [
          _buildTableDataCell(no, 40, TextAlign.center),
          _buildTableDataCell(kodeMk, 80, TextAlign.left),
          _buildTableDataCell(mataKuliah, 150, TextAlign.left),
          _buildTableDataCell(sks, 50, TextAlign.center),
          _buildTableDataCell(nilai, 50, TextAlign.center),
          _buildTableDataCell(bobot, 50, TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildTableDataCell(String text, double width, TextAlign align) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.black, width: 0.5)),
      ),
      child: Text(
        text,
        textAlign: align,
        style: const TextStyle(fontSize: 10),
      ),
    );
  }

  Widget _buildKeterangan() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Keterangan",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        SizedBox(height: 4),
        Text(
          "MK = Mata Kuliah yang ditempuh",
          style: TextStyle(fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildCatatanStudi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Catatan Studi",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          "SKS Semester / IPS = 0sks",
          style: const TextStyle(fontSize: 11),
        ),
        Text(
          "SKS Akumulatif / IPK = 27sks / 3....",
          style: const TextStyle(fontSize: 11),
        ),
        const Text(
          "Tugas Akhir = Belum",
          style: TextStyle(fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildTandaTangan() {
    return Column(
      children: [
        // Icon catatan dosen
        Row(
          children: [
            const Icon(Icons.note_alt, size: 18),
            const SizedBox(width: 8),
            const Text(
              "Catatan Dosen Pembimbing Akademik",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Area tanda tangan
        Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1),
          ),
        ),
        const SizedBox(height: 12),
        
        // Tempat dan nama
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Purwokerto, ______________",
                  style: TextStyle(fontSize: 11),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Dosen Pembimbing Akademik",
                  style: TextStyle(fontSize: 11),
                ),
                const SizedBox(height: 50),
                Text(
                  semester.dosenPembimbingAkademik,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
