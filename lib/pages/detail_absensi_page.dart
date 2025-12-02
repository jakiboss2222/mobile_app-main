// Conditional export untuk detail absensi page
// Web menggunakan Google Maps IFrame, Mobile menggunakan FlutterMap

export 'detail_absensi_page_web.dart' if (dart.library.io) 'detail_absensi_page_mobile.dart';
