import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';

class KrsDetailPage extends StatefulWidget {
  final int idKrs;
  final String semester;
  final String tahunAjaran;

  const KrsDetailPage({
    super.key,
    required this.idKrs,
    required this.semester,
    required this.tahunAjaran,
  });

  @override
  State<KrsDetailPage> createState() => _KrsDetailPageState();
}

class _KrsDetailPageState extends State<KrsDetailPage> {
  List<dynamic> daftarMatkul = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getDetailKrs();
  }



  Future<void> _hapusMatakuliah(int idKrsDetail) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    Dio dio = Dio();
    dio.options.headers['Authorization'] = 'Bearer $token';

    try {
      final res = await dio.delete(
        "${ApiService.baseUrl}krs/hapus-course-krs?id=$idKrsDetail",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.data['message'] ?? "Matakuliah dihapus"),
          backgroundColor: Colors.green,
        ),
      );

      _getDetailKrs();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal menghapus matakuliah"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _getDetailKrs() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    Dio dio = Dio();
    dio.options.headers['Authorization'] = 'Bearer $token';

    final url = "${ApiService.baseUrl}krs/detail-krs?id_krs=${widget.idKrs}";

    try {
      final res = await dio.get(url);

      List<dynamic> tempMatkul = res.data['data'] ?? [];

      setState(() {
        daftarMatkul = tempMatkul;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal memuat detail KRS"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => isLoading = false);
    }
  }



  void _tambahMatkulModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return TambahMatkulSheet(
          idKrs: widget.idKrs,
          onSuccess: () => _getDetailKrs(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1A3A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Detail KRS Semester ${widget.semester}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _tambahMatkulModal,
        backgroundColor: const Color(0xFF0D1A3A),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Container(
        color: Colors.grey.shade400,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : daftarMatkul.isEmpty
                ? const Center(
                    child: Text(
                      "Belum ada matakuliah\nyang dipilih.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: daftarMatkul.length,
                    itemBuilder: (context, index) {
                      final mk = daftarMatkul[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    mk['nama_matakuliah'] ?? '-',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "SKS ${mk['jumlah_sks']} | ${mk['nama_hari']} ${mk['jam_mulai']} - ${mk['jam_selesai']}",
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 12),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // TOMBOL HAPUS
                                SizedBox(
                                  width: 42,
                                  height: 42,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 24,
                                    ),
                                    onPressed: () =>
                                        _hapusMatakuliah(mk['id']),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

/* ======================================================
   BOTTOM SHEET — TAMBAH MATKUL (UI DISAMAKAN DENGAN LIST)
   Logic tetap sama: loadMatkul(), tambahMatkul()
====================================================== */
class TambahMatkulSheet extends StatefulWidget {
  final int idKrs;
  final VoidCallback onSuccess;

  const TambahMatkulSheet({
    super.key,
    required this.idKrs,
    required this.onSuccess,
  });

  @override
  State<TambahMatkulSheet> createState() => _TambahMatkulSheetState();
}

class _TambahMatkulSheetState extends State<TambahMatkulSheet> {
  List<dynamic> daftarMatkulTersedia = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMatkul();
  }

  Future<void> loadMatkul() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    Dio dio = Dio();
    dio.options.headers['Authorization'] = 'Bearer $token';

    try {
      final res = await dio.get("${ApiService.baseUrl}jadwal/daftar-jadwal");

      setState(() {
        daftarMatkulTersedia = res.data['jadwals'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal memuat matakuliah")),
      );
      setState(() => isLoading = false);
    }
  }

  Future<void> tambahMatkul(int idJadwal) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    Dio dio = Dio();
    dio.options.headers['Authorization'] = 'Bearer $token';

    try {
      final res = await dio.post(
        "${ApiService.baseUrl}krs/tambah-course-krs",
        data: {"id_krs": widget.idKrs, "id_jadwal": idJadwal},
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.data['message'] ?? "Berhasil menambahkan")),
      );

      widget.onSuccess();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal menambahkan matakuliah"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // DraggableScrollableSheet supaya modal bisa di-drag dan menyesuaikan tinggi
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFBF0F5), // warna soft seperti mockup
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // drag handle
                    Container(
                      width: 60,
                      height: 6,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: daftarMatkulTersedia.length,
                        itemBuilder: (context, index) {
                          final mk = daftarMatkulTersedia[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // teks title & subtitle
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          mk['nama_matakuliah'] ?? '-',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          "SKS: ${mk['jumlah_sks']} | ${mk['nama_hari']}, ${mk['jam_mulai']} - ${mk['jam_selesai']}",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.black87.withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // tombol Tambah bergaya pill (sama ukuran & gaya di setiap baris)
                                  const SizedBox(width: 12),
                                  ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(minWidth: 86),
                                    child: ElevatedButton(
                                      onPressed: () => tambahMatkul(mk['id']),
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          side: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                      ),
                                      child: Text(
                                        "Tambah",
                                        style: TextStyle(
                                          color: Colors.deepPurple.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}