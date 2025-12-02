import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

// Map import
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import './webcam_helper.dart';
import '../api/api_service.dart';

class AbsenSubmitPage extends StatefulWidget {
  final int idKrsDetail;
  final int pertemuan;
  final String namaMatkul;

  const AbsenSubmitPage({
    super.key,
    required this.idKrsDetail,
    required this.pertemuan,
    required this.namaMatkul,
  });

  @override
  State<AbsenSubmitPage> createState() => _AbsenSubmitPageState();
}

class _AbsenSubmitPageState extends State<AbsenSubmitPage> {
  final WebCamera cam = WebCamera();

  Uint8List? imageBytes;
  Position? position;

  bool isCameraReady = false;
  bool isSubmitting = false;
  bool isLoadingLocation = true;
  String locationStatus = "Mengambil lokasi...";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCameraAfterRender();
    });

    _checkAndRequestLocation();
  }

  Future<void> _initializeCameraAfterRender() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      await cam.initialize();
      setState(() => isCameraReady = true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gagal akses kamera: $e")));
    }
  }

  @override
  void dispose() {
    cam.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    try {
      final data = await cam.capture();
      setState(() => imageBytes = data);
    } catch (_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Gagal mengambil foto")));
    }
  }

  // ✅ BEST PRACTICE: Cek dan minta izin lokasi dengan feedback yang jelas
  Future<void> _checkAndRequestLocation() async {
    setState(() {
      isLoadingLocation = true;
      locationStatus = "Memeriksa layanan GPS...";
    });

    // 1. Cek apakah layanan lokasi aktif
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        isLoadingLocation = false;
        locationStatus = "GPS tidak aktif";
      });
      
      // Tampilkan dialog untuk meminta pengguna mengaktifkan GPS
      _showEnableGPSDialog();
      return;
    }

    setState(() => locationStatus = "Memeriksa izin lokasi...");

    // 2. Cek status izin
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      setState(() => locationStatus = "Meminta izin lokasi...");
      
      // Minta izin
      permission = await Geolocator.requestPermission();
      
      if (permission == LocationPermission.denied) {
        setState(() {
          isLoadingLocation = false;
          locationStatus = "Izin lokasi ditolak";
        });
        
        _showPermissionDeniedDialog();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        isLoadingLocation = false;
        locationStatus = "Izin lokasi ditolak permanen";
      });
      
      _showPermissionDeniedForeverDialog();
      return;
    }

    // 3. Izin diberikan, ambil lokasi dengan presisi tinggi
    await _getHighAccuracyLocation();
  }

  // ✅ BEST PRACTICE: Gunakan akurasi tinggi untuk presisi lokasi
  Future<void> _getHighAccuracyLocation() async {
    setState(() => locationStatus = "Mendapatkan lokasi presisi...");

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high, // ✅ Presisi tinggi
        timeLimit: const Duration(seconds: 10), // Timeout 10 detik
      );
      
      setState(() {
        position = pos;
        isLoadingLocation = false;
        locationStatus = "Lokasi ditemukan";
      });
    } catch (e) {
      setState(() {
        isLoadingLocation = false;
        locationStatus = "Gagal mendapatkan lokasi";
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal mendapatkan lokasi: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Dialog untuk meminta pengguna mengaktifkan GPS
  void _showEnableGPSDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("GPS Tidak Aktif"),
        content: const Text(
          "Aplikasi memerlukan GPS untuk mencatat lokasi absensi Anda. Silakan aktifkan GPS di pengaturan perangkat.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Kembali ke halaman sebelumnya
            },
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Coba lagi
              await _checkAndRequestLocation();
            },
            child: const Text("Coba Lagi"),
          ),
        ],
      ),
    );
  }

  // Dialog saat izin ditolak
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Izin Lokasi Diperlukan"),
        content: const Text(
          "Aplikasi memerlukan izin lokasi untuk mencatat kehadiran Anda. Tanpa izin ini, Anda tidak dapat melakukan absensi.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _checkAndRequestLocation();
            },
            child: const Text("Berikan Izin"),
          ),
        ],
      ),
    );
  }

  // Dialog saat izin ditolak permanen
  void _showPermissionDeniedForeverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Izin Lokasi Ditolak Permanen"),
        content: const Text(
          "Anda telah menolak izin lokasi secara permanen. Silakan buka Pengaturan aplikasi dan berikan izin lokasi secara manual.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Geolocator.openAppSettings();
            },
            child: const Text("Buka Pengaturan"),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAbsen() async {
    if (imageBytes == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Foto belum diambil")));
      return;
    }
    if (position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lokasi belum tersedia. Pastikan GPS aktif."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      Dio dio = Dio();

      final form = FormData.fromMap({
        "id_krs_detail": widget.idKrsDetail,
        "pertemuan": widget.pertemuan,
        "latitude": position!.latitude,
        "longitude": position!.longitude,
        "foto": MultipartFile.fromBytes(
          imageBytes!,
          filename: "absen_${DateTime.now().millisecondsSinceEpoch}.png",
        ),
      });

      final res =
          await dio.post("${ApiService.baseUrl}absensi/submit", data: form);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.data["message"] ?? "Absen berhasil"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal submit absen: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2A4D),
        elevation: 0,
        title: const Text(
          "Presensi",
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // ======================= MAP ATAS =======================
            Stack(
              children: [
                Container(
                  height: 330,
                  child: isLoadingLocation
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(
                                locationStatus,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : position == null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.location_off,
                                    size: 60,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    locationStatus,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    onPressed: _checkAndRequestLocation,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text("Coba Lagi"),
                                  ),
                                ],
                              ),
                            )
                          : FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(
                                    position!.latitude, position!.longitude),
                                initialZoom: 17,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(position!.latitude,
                                          position!.longitude),
                                      width: 50,
                                      height: 50,
                                      child: const Icon(Icons.location_on,
                                          color: Colors.red, size: 40),
                                    )
                                  ],
                                ),
                              ],
                            ),
                ),

                // Nama mata kuliah
                Positioned(
                  top: 18,
                  left: 25,
                  right: 25,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.namaMatkul,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                // Koordinat lokasi
                if (position != null)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.my_location,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            "${position!.latitude.toStringAsFixed(6)}, ${position!.longitude.toStringAsFixed(6)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // ======================= CAMERA & SUBMIT =======================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const Text("Foto Presensi",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),

                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const HtmlElementView(viewType: 'webcam-view'),
                  ),

                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: isCameraReady ? _capturePhoto : null,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Ambil Foto"),
                  ),

                  if (imageBytes != null) ...[
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.memory(
                        imageBytes!,
                        width: 180,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],

                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D3E67),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: isSubmitting ? null : _submitAbsen,
                      child: isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Hadir",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
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
}
