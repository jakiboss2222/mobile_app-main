import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../api/api_service.dart';
import './detail_absensi_page.dart';
import './webcam_helper_mobile.dart';

class AbsenPage extends StatefulWidget {
  final int idKrsDetail;
  final String namaMatkul;

  const AbsenPage({
    super.key,
    required this.idKrsDetail,
    required this.namaMatkul,
  });

  @override
  State<AbsenPage> createState() => _AbsenPageState();
}

class _AbsenPageState extends State<AbsenPage> {
  // List State
  List<dynamic> statusAbsen = [];
  bool isLoading = true;

  // Submission State
  bool isSubmittingView = false;
  int? selectedPertemuan;
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
    loadStatusAbsen();
  }

  @override
  void dispose() {
    cam.dispose();
    super.dispose();
  }

  Future<void> loadStatusAbsen() async {
    setState(() => isLoading = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception("Token tidak ditemukan");
      }

      Dio dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      List<dynamic> tempStatus = [];
      for (int i = 1; i <= 16; i++) {
        try {
          final response = await dio.get(
            '${ApiService.baseUrl}absensi/detail',
            queryParameters: {
              'id_krs_detail': widget.idKrsDetail,
              'pertemuan': i,
            },
          );
          if (response.statusCode == 200 && response.data['data'] != null) {
            tempStatus.add(response.data['data']);
          } else {
            tempStatus.add(null);
          }
        } catch (e) {
          tempStatus.add(null);
        }
      }

      if (mounted) {
        setState(() {
          statusAbsen = tempStatus;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat status absensi: $e')),
        );
      }
    }
  }

  // ================= SUBMISSION LOGIC =================

  Future<void> _startSubmission(int pertemuan) async {
    setState(() {
      selectedPertemuan = pertemuan;
      isSubmittingView = true;
      imageBytes = null;
      position = null;
      isCameraReady = false;
      isLoadingLocation = true;
      locationStatus = "Mengambil lokasi...";
    });

    await _initializeCamera();
    await _checkAndRequestLocation();
  }

  Future<void> _initializeCamera() async {
    try {
      await cam.initialize();
      if (mounted) setState(() => isCameraReady = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Gagal akses kamera: $e")));
      }
    }
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

  Future<void> _switchCamera() async {
    try {
      setState(() => isCameraReady = false);
      await cam.switchCamera();
      setState(() => isCameraReady = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengganti kamera: $e")),
      );
      setState(() => isCameraReady = true);
    }
  }

  Future<void> _checkAndRequestLocation() async {
    setState(() {
      isLoadingLocation = true;
      locationStatus = "Memeriksa layanan GPS...";
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        isLoadingLocation = false;
        locationStatus = "GPS tidak aktif";
      });
      _showEnableGPSDialog();
      return;
    }

    setState(() => locationStatus = "Memeriksa izin lokasi...");

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      setState(() => locationStatus = "Meminta izin lokasi...");
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

    await _getHighAccuracyLocation();
  }

  Future<void> _getHighAccuracyLocation() async {
    setState(() => locationStatus = "Mendapatkan lokasi presisi...");

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (mounted) {
        setState(() {
          position = pos;
          isLoadingLocation = false;
          locationStatus = "Lokasi ditemukan";
        });
      }
    } catch (e) {
      if (mounted) {
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
  }

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
              setState(() => isSubmittingView = false);
            },
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _checkAndRequestLocation();
            },
            child: const Text("Coba Lagi"),
          ),
        ],
      ),
    );
  }

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
              setState(() => isSubmittingView = false);
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
              setState(() => isSubmittingView = false);
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
        "pertemuan": selectedPertemuan,
        "latitude": position!.latitude,
        "longitude": position!.longitude,
        "foto": MultipartFile.fromBytes(
          imageBytes!,
          filename: "absen_${DateTime.now().millisecondsSinceEpoch}.png",
        ),
      });

      final res =
          await dio.post("${ApiService.baseUrl}absensi/submit", data: form);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.data["message"] ?? "Absen berhasil"),
            backgroundColor: Colors.green,
          ),
        );
        // Return to list and reload
        setState(() {
          isSubmittingView = false;
          isSubmitting = false;
        });
        loadStatusAbsen();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal submit absen: $e"),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If in submission view, show the submission UI
    if (isSubmittingView) {
      return _buildSubmissionView();
    }

    // Otherwise show the list of meetings
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.namaMatkul),
        backgroundColor: const Color(0xFF1C2A4D),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 16,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                int pertemuan = index + 1;
                var status = statusAbsen.length > index ? statusAbsen[index] : null;
                bool isAbsen = status != null;

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF1C2A4D),
                      child: Text(
                        "$pertemuan",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      "Pertemuan $pertemuan",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      isAbsen
                          ? "Hadir: ${status['waktu_absen'] ?? '-'}"
                          : "Belum Absen",
                      style: TextStyle(
                        color: isAbsen ? Colors.green : Colors.red,
                      ),
                    ),
                    trailing: isAbsen
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailAbsensiPage(
                                    idKrsDetail: widget.idKrsDetail,
                                    pertemuan: pertemuan,
                                    namaMatkul: widget.namaMatkul,
                                  ),
                                ),
                              );
                            },
                            child: const Text("Lihat"),
                          )
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _startSubmission(pertemuan),
                            child: const Text("Absen"),
                          ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSubmissionView() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2A4D),
        elevation: 0,
        title: const Text(
          "Presensi",
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            setState(() => isSubmittingView = false);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // MAP ATAS
            SizedBox(
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
                      : Stack(
                          children: [
                            FlutterMap(
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
                                    "${widget.namaMatkul} - Pertemuan $selectedPertemuan",
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

                            // Koordinat
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(8),
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
            ),

            // CAMERA & SUBMIT
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

                  // Mobile Camera Preview
                  if (isCameraReady && cam.controller != null)
                    Stack(
                      children: [
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CameraPreview(cam.controller!),
                          ),
                        ),

                        // Switch Camera Button
                        if (cam.hasMultipleCameras)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Material(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(30),
                              child: InkWell(
                                onTap: _switchCamera,
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  child: const Icon(
                                    Icons.flip_camera_ios,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  else
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
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
