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
    // Detect screen size for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final horizontalPadding = isSmallScreen ? 8.0 : 16.0;

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
          padding: EdgeInsets.all(horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan Logo
              _buildHeader(isSmallScreen),
              SizedBox(height: isSmallScreen ? 12 : 20),
              
              // Title
              Center(
                child: Text(
                  "KARTU HASIL STUDI SEMESTER SATU",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),

              // Info Mahasiswa
              _buildInfoMahasiswa(isSmallScreen),
              SizedBox(height: isSmallScreen ? 12 : 16),

              // Tabel Nilai
              _buildTabelNilai(isSmallScreen),
              SizedBox(height: isSmallScreen ? 12 : 16),

              // Keterangan
              _buildKeterangan(),
              SizedBox(height: isSmallScreen ? 12 : 20),

              // Catatan Studi
              _buildCatatanStudi(),
              SizedBox(height: isSmallScreen ? 16 : 30),

              // Area Tanda Tangan
              _buildTandaTangan(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader([bool isSmallScreen = false]) {
    final logoSize = isSmallScreen ? 40.0 : 50.0;
    final fontSize1 = isSmallScreen ? 9.0 : 11.0;
    final fontSize2 = isSmallScreen ? 11.0 : 13.0;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        Container(
          width: logoSize,
          height: logoSize,
          padding: const EdgeInsets.all(4),
          child: Image.asset(
            'assets/images/logo_stmik.png',
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(width: isSmallScreen ? 8 : 12),
        // Institusi Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "SEKOLAH TINGGI MANAJEMEN INFORMATIKA DAN KOMPUTER",
                style: TextStyle(
                  fontSize: fontSize1,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "STMIK WIDYA UTAMA",
                style: TextStyle(
                  fontSize: fontSize2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoMahasiswa([bool isSmallScreen = false]) {
    // Get nama and nim from userData, fallback to semester data if not available
    final String nama = userData?["nama"] ?? semester.nama;
    final String nim = userData?["nim"] ?? semester.nim;
    
    return Column(
      children: [
        _buildInfoRow("Nama | NIM", ": $nama | $nim", isSmallScreen),
        _buildInfoRow("Kelas | Semester", ": ${semester.kelas} | Ganjil", isSmallScreen),
        _buildInfoRow("Status", ": ${semester.status}", isSmallScreen),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, [bool isSmallScreen = false]) {
    final fontSize = isSmallScreen ? 10.0 : 12.0;
    final labelWidth = isSmallScreen ? 100.0 : 120.0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: TextStyle(fontSize: fontSize),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabelNilai(bool isSmallScreen) {
    // Responsive column widths - made more compact for mobile
    final noWidth = isSmallScreen ? 25.0 : 40.0;
    final kodeMkWidth = isSmallScreen ? 65.0 : 90.0;
    final mataKuliahWidth = isSmallScreen ? 110.0 : 180.0;
    final sksWidth = isSmallScreen ? 30.0 : 50.0;
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Tabel
            _buildTableHeader(noWidth, kodeMkWidth, mataKuliahWidth, sksWidth, isSmallScreen),
            // Baris Data
            ...semester.mataKuliah.asMap().entries.map((entry) {
              int index = entry.key + 1;
              MataKuliahKHS mk = entry.value;
              return _buildTableRow(
                index.toString(),
                mk.kodeMk,
                mk.namaMataKuliah,
                mk.sks.toString(),
                noWidth,
                kodeMkWidth,
                mataKuliahWidth,
                sksWidth,
                isSmallScreen,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(double noWidth, double kodeMkWidth, double mataKuliahWidth, double sksWidth, bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Row(
        children: [
          _buildTableHeaderCell("NO", noWidth, isSmallScreen),
          _buildTableHeaderCell("Kode MK", kodeMkWidth, isSmallScreen),
          _buildTableHeaderCell("Mata\nKuliah", mataKuliahWidth, isSmallScreen),
          _buildTableHeaderCell("SKS", sksWidth, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildTableHeaderCell(String text, double width, [bool isSmallScreen = false]) {
    final fontSize = isSmallScreen ? 8.0 : 11.0;
    final horizontalPadding = isSmallScreen ? 0.5 : 4.0;
    final verticalPadding = isSmallScreen ? 4.0 : 8.0;
    
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding,
        horizontal: horizontalPadding,
      ),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.black, width: 1)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }

  Widget _buildTableRow(
    String no,
    String kodeMk,
    String mataKuliah,
    String sks,
    double noWidth,
    double kodeMkWidth,
    double mataKuliahWidth,
    double sksWidth,
    bool isSmallScreen,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 0.5),
      ),
      child: Row(
        children: [
          _buildTableDataCell(no, noWidth, TextAlign.center, isSmallScreen),
          _buildTableDataCell(kodeMk, kodeMkWidth, TextAlign.left, isSmallScreen),
          _buildTableDataCell(mataKuliah, mataKuliahWidth, TextAlign.left, isSmallScreen),
          _buildTableDataCell(sks, sksWidth, TextAlign.center, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildTableDataCell(String text, double width, TextAlign align, [bool isSmallScreen = false]) {
    final fontSize = isSmallScreen ? 7.0 : 10.0;
    final horizontalPadding = isSmallScreen ? 0.5 : 4.0;
    final verticalPadding = isSmallScreen ? 3.0 : 6.0;
    
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding,
        horizontal: horizontalPadding,
      ),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.black, width: 0.5)),
      ),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(fontSize: fontSize),
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
