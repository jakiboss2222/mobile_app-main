import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';


class KtmPage extends StatefulWidget {
  const KtmPage({super.key});

  @override
  State<KtmPage> createState() => _KtmPageState();
}

class _KtmPageState extends State<KtmPage> {
  Map<String, dynamic>? mahasiswaData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMahasiswaData();
  }

  Future<void> _fetchMahasiswaData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('auth_email');

      if (email == null) {
        setState(() {
          errorMessage = 'Email tidak ditemukan';
          isLoading = false;
        });
        return;
      }

      final response = await ApiService.detailMahasiswa(email: email);

      if (response.containsKey('error')) {
        setState(() {
          errorMessage = response['error'];
          isLoading = false;
        });
        return;
      }

      setState(() {
        mahasiswaData = response['data'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Gagal memuat data: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B5998),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Lihat Kartu Tanda Mahasiswa",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat Data',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchMahasiswaData,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (mahasiswaData == null) {
      return const Center(
        child: Text('Data tidak tersedia'),
      );
    }

    return _buildKTMCard();
  }

  Widget _buildKTMCard() {
    final nama = mahasiswaData?['nama'] ?? 'N/A';
    final nim = mahasiswaData?['nim'] ?? 'N/A';
    final tempatLahir = mahasiswaData?['tempat_lahir'] ?? 'N/A';
    final tanggalLahir = mahasiswaData?['tanggal_lahir'] ?? 'N/A';
    final jurusan = mahasiswaData?['jurusan'] ?? 'N/A';
    final fotoUrl = mahasiswaData?['foto'];

    // Get screen width to adjust layout for mobile
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    // Responsive sizes
    final headerHeight = isSmallScreen ? 70.0 : 80.0;
    final logoSize = isSmallScreen ? 48.0 : 56.0;
    final photoWidth = isSmallScreen ? 90.0 : 120.0;
    final photoHeight = isSmallScreen ? 110.0 : 150.0;
    final barcodeHeight = isSmallScreen ? 40.0 : 50.0;
    final barcodeWidth = isSmallScreen ? 140.0 : 180.0;

    return Container(
      constraints: BoxConstraints(
        maxWidth: 600,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with gradient
            Container(
              height: headerHeight,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF5C6BC0), // Indigo
                    Color(0xFF4DD0E1), // Cyan
                  ],
                ),
              ),
              child: Row(
                children: [
                  // Logo
                  Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 8.0 : 12.0),
                    child: Container(
                      width: logoSize,
                      height: logoSize,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo_stmik.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  // Text
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: isSmallScreen ? 8.0 : 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Kartu Tanda Mahasiswa",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 11 : 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "STMIK Widya Utama Purwokerto",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 10 : 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Jl. Sunan Kalijaga, Dusun III, Berkoh, Kec. Purwokerto Sel., Kabupaten Banyumas, Jawa Tengah 53146",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: isSmallScreen ? 7 : 9,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Body with info and photo
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 12.0 : 20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side - Info and Barcode
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Info fields
                        _buildInfoRow("Nama", nama, isSmallScreen),
                        SizedBox(height: isSmallScreen ? 6 : 8),
                        _buildInfoRow("NIM", nim, isSmallScreen),
                        SizedBox(height: isSmallScreen ? 6 : 8),
                        _buildInfoRow(
                          "Tempat. Tanggal Lahir",
                          "$tempatLahir, $tanggalLahir",
                          isSmallScreen,
                        ),
                        SizedBox(height: isSmallScreen ? 6 : 8),
                        _buildInfoRow("Jurusan", jurusan, isSmallScreen),
                        
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        
                        // Barcode
                        Container(
                          height: barcodeHeight,
                          width: barcodeWidth,
                          child: BarcodeWidget(
                            barcode: Barcode.code128(),
                            data: nim,
                            drawText: false,
                            color: Colors.black,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(width: isSmallScreen ? 8 : 16),
                  
                  // Right side - Photo
                  Container(
                    width: photoWidth,
                    height: photoHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: (fotoUrl != null && fotoUrl.toString().isNotEmpty)
                          ? Image.network(
                              fotoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/profile_photo.jpg',
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          : Image.asset(
                              'assets/images/profile_photo.jpg',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, [bool isSmallScreen = false]) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: isSmallScreen ? 110 : 140,
          child: Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 9 : 11,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          ": ",
          style: TextStyle(
            fontSize: isSmallScreen ? 9 : 11,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isSmallScreen ? 9 : 11,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
