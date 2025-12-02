// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../api/api_service.dart';

class DetailAbsensiPage extends StatefulWidget {
  final int idKrsDetail;
  final int pertemuan;
  final String namaMatkul;

  const DetailAbsensiPage({
    super.key,
    required this.idKrsDetail,
    required this.pertemuan,
    required this.namaMatkul,
  });

  @override
  State<DetailAbsensiPage> createState() => _DetailAbsensiPageState();
}

class _DetailAbsensiPageState extends State<DetailAbsensiPage> {
  bool isLoading = true;
  Map<String, dynamic>? data;
  String? mapViewType;

  @override
  void initState() {
    super.initState();
    loadDetail();
  }

  Future<void> loadDetail() async {
    try {
      Dio dio = Dio();

      final url =
          "${ApiService.baseUrl}absensi/detail?id_krs_detail=${widget.idKrsDetail}&pertemuan=${widget.pertemuan}";

      final res = await dio.get(url);

      data = res.data["data"];

      if (data != null) {
        final lat = data!['latitude'];
        final lng = data!['longitude'];

        // unique id setiap map
        mapViewType = "maps-view-${DateTime.now().millisecondsSinceEpoch}";

        // register iframe MAP langsung DI SINI
        ui_web.platformViewRegistry.registerViewFactory(mapViewType!, (
          int viewId,
        ) {
          final iframe = html.IFrameElement()
            ..src = "https://www.google.com/maps?q=$lat,$lng&z=16&output=embed"
            ..style.border = "0"
            ..style.width = "100%"
            ..style.height = "100%";

          return iframe;
        });
      }

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal mengambil data")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Detail Absensi - ${widget.namaMatkul} (P.${widget.pertemuan})",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        backgroundColor: const Color(0xFF0D1A3A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : data == null
          ? const Center(
              child: Text("Belum ada absensi", style: TextStyle(fontSize: 16)),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FOTO DENGAN LOADING INDICATOR
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        "${data!['foto']}",
                        height: 240,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 240,
                            color: Colors.grey.shade300,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 240,
                            color: Colors.grey.shade300,
                            child: const Center(
                              child: Icon(Icons.error, size: 50, color: Colors.red),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),
                    
                    // INFO DETAIL
                    _buildInfoRow("Pertemuan", "${data!['pertemuan']}"),
                    const SizedBox(height: 8),
                    _buildInfoRow("Latitude", "${data!['latitude']}"),
                    const SizedBox(height: 8),
                    _buildInfoRow("Longitude", "${data!['longitude']}"),
                    const SizedBox(height: 8),
                    _buildInfoRow("Waktu", "${data!['created_at'] ?? '-'}"),

                    const SizedBox(height: 24),
                    const Text(
                      "Lokasi pada Peta:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    // PETA DENGAN CONTAINER FIXED HEIGHT
                    if (mapViewType != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 300,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: HtmlElementView(viewType: mapViewType!),
                        ),
                      ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            "$label :",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ],
    );
  }
}
