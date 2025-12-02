import 'package:flutter/material.dart';

// Import semua halaman
import 'kehadiran_kewarganegaraan.dart';
import 'kehadiran_pancasila.dart';
import 'kehadiran_etika_profesi.dart';

class KehadiranPages extends StatefulWidget {
  const KehadiranPages({super.key});

  @override
  State<KehadiranPages> createState() => _KehadiranPagesState();
}

class _KehadiranPagesState extends State<KehadiranPages> {
  TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> kehadiran = [
    {"kode": "#144", "nama": "Kewarganegaraan"},
    {"kode": "#75", "nama": "Pancasila"},
    {"kode": "#100", "nama": "Etika Profesi Dan Bimbingan Karir"},
  ];

  List<Map<String, dynamic>> filteredKehadiran = [];

  @override
  void initState() {
    super.initState();
    filteredKehadiran = kehadiran;
  }

  void filterSearch(String query) {
    final hasil = kehadiran.where((item) {
      final nama = item["nama"].toString().toLowerCase();
      final kode = item["kode"].toString().toLowerCase();
      final input = query.toLowerCase();
      return nama.contains(input) || kode.contains(input);
    }).toList();

    setState(() {
      filteredKehadiran = hasil;
    });
  }

  void navigateToPage(String namaMatkul) {
    if (namaMatkul == "Kewarganegaraan") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => KehadiranKewarganegaraanPage()),
      );
    } else if (namaMatkul == "Pancasila") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => KehadiranPancasilaPage()),
      );
    } else if (namaMatkul == "Etika Profesi Dan Bimbingan Karir") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => KehadiranEtikaProfesiPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 101, 114, 114),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              ),

              const SizedBox(height: 10),

              const Center(
                child: Text(
                  "KEHADIRAN MATA KULIAH",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // SEARCH
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: filterSearch,
                        decoration: const InputDecoration(
                          hintText: "Cari kode / mata kuliah",
                          border: InputBorder.none,
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: filteredKehadiran.isEmpty
                    ? const Center(
                        child: Text(
                          "Tidak ada hasil",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredKehadiran.length,
                        itemBuilder: (context, index) {
                          final item = filteredKehadiran[index];

                          return GestureDetector(
                            onTap: () => navigateToPage(item["nama"]),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xff284169),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.book,
                                      color: Colors.white, size: 22),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item["kode"],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          item["nama"],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
