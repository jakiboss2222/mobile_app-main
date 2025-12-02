import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://36.88.99.179:8000/api/';

  // Login method
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await Dio().post(
        "${baseUrl}auth/login",
        data: {'email': email, 'password': password, 'role': 1},
      );
      return response.data;
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Register method
  static Future<Map<String, dynamic>> register(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await Dio().post("${baseUrl}auth/register", data: data);
      return response.data;
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Simpan Token
  static Future<void> saveToken(String token, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('auth_email', email);
  }

  // get Token (plain string) - gunakan ini untuk header Authorization
  static Future<String?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // logout method
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_email');
  }

  // Helper to build Authorization headers
  static Future<Map<String, String>> _authHeader() async {
    final token = await getSession();
    if (token == null) return {};
    return {'Authorization': 'Bearer $token'};
  }

  // KRS: buat-krs (POST)
  static Future<Map<String, dynamic>> buatKrs({
    required String idMahasiswa,
    required String semester,
  }) async {
    try {
      final headers = await _authHeader();
      final response = await Dio().post(
        "${baseUrl}krs/buat-krs",
        data: {
          'id_mahasiswa': idMahasiswa,
          'semester': semester,
        },
        options: Options(headers: headers),
      );
      return response.data ?? {'status': response.statusCode};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // KRS: daftar-krs (GET)
  static Future<Map<String, dynamic>> daftarKrs({required String idMahasiswa}) async {
    try {
      final headers = await _authHeader();
      final dio = Dio();
      final response = await dio.get(
        "${baseUrl}krs/daftar-krs",
        queryParameters: {'id_mahasiswa': idMahasiswa},
        options: Options(headers: headers),
      );
      return response.data ?? {'status': response.statusCode};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // KRS: detail-krs (GET)
  static Future<Map<String, dynamic>> detailKrs({required int idKrs}) async {
    try {
      final headers = await _authHeader();
      final response = await Dio().get(
        "${baseUrl}krs/detail-krs",
        queryParameters: {'id_krs': idKrs},
        options: Options(headers: headers),
      );
      return response.data ?? {'status': response.statusCode};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // KRS: tambah-course-krs (POST)
  static Future<Map<String, dynamic>> tambahCourseKrs({
    required int idKrs,
    required int idJadwal,
  }) async {
    try {
      final headers = await _authHeader();
      final response = await Dio().post(
        "${baseUrl}krs/tambah-course-krs",
        data: {'id_krs': idKrs, 'id_jadwal': idJadwal},
        options: Options(headers: headers),
      );
      return response.data ?? {'status': response.statusCode};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // KRS: hapus-course-krs (DELETE)
  static Future<Map<String, dynamic>> hapusCourseKrs({required int id}) async {
    try {
      final headers = await _authHeader();
      final response = await Dio().delete(
        "${baseUrl}krs/hapus-course-krs",
        queryParameters: {'id': id},
        options: Options(headers: headers),
      );
      return response.data ?? {'status': response.statusCode};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // JADWAL: daftar-jadwal (GET)
  static Future<Map<String, dynamic>> daftarJadwal() async {
    try {
      final headers = await _authHeader();
      final dio = Dio();
      final response = await dio.get(
        "${baseUrl}jadwal/daftar-jadwal",
        options: Options(headers: headers),
      );
      return response.data ?? {'status': response.statusCode};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // MAHASISWA: detail-mahasiswa (POST)
  static Future<Map<String, dynamic>> detailMahasiswa({required String email}) async {
    try {
      final headers = await _authHeader();
      final dio = Dio();
      final response = await dio.post(
        "${baseUrl}mahasiswa/detail-mahasiswa",
        data: {'email': email},
        options: Options(headers: headers),
      );
      return response.data ?? {'status': response.statusCode};
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}