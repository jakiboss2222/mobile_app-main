import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../api/api_service.dart';

class DaftarMatakuliahPage extends StatefulWidget {
  const DaftarMatakuliahPage({super.key});

  @override
  State<DaftarMatakuliahPage> createState() => _DaftarMatakuliahPageState();
}

class _DaftarMatakuliahPageState extends State<DaftarMatakuliahPage> {
  List<dynamic> daftarMatakuliah = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchMatakuliah();
  }

  Future<void> fetchMatakuliah() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      Dio dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await dio.get(
        '${ApiService.baseUrl}matakuliah/daftar-matakuliah',
      );

      if (response.statusCode == 200 && response.data["status"] == 200) {
        setState(() {
          daftarMatakuliah = response.data["data"];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response.data["msg"] ?? 'Gagal memuat data';
          isLoading = false;
        });
      }
    } on DioException catch (e) {
      setState(() {
        errorMessage =
            e.response?.data["message"] ?? 'Terjadi kesalahan koneksi';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Mata Kuliah'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
              child: Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: daftarMatakuliah.length,
              itemBuilder: (context, index) {
                final mk = daftarMatakuliah[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        mk['jumlah_sks'].toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      mk['nama_matakuliah'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text('Kode: ${mk['kode']}'),
                        Text('Semester: ${mk['semester']}'),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Anda memilih ${mk['nama_matakuliah']}',
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
