// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:siakad/pages/login_pages.dart';
import 'package:siakad/api/api_service.dart';

void main() {
  ui_web.platformViewRegistry.registerViewFactory('webcam-view', (int viewId) {
    final div = html.DivElement()
      ..id = "camera-container"
      ..style.width = "100%"
      ..style.height = "100%"
      ..style.backgroundColor = "black";

    return div;
  });
  // REGISTER HTML VIEW UNTUK MAP
  ui_web.platformViewRegistry.registerViewFactory('maps-view', (int viewId) {
    final iframe = html.IFrameElement()
      ..id = "map-frame"
      ..style.border = "0"
      ..style.width = "100%"
      ..style.height = "100%"
      ..src = ""; // akan diisi dari detail_absensi_page.dart

    return iframe;
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIAKAD',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // Biar tampilan web seperti HP (center 480px)
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(color: Colors.white, child: child),
          ),
        );
      },
      home: FutureBuilder(
        future: ApiService.getSession(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LoginPages();
          } else {
            return const LoginPages(); // nanti ke dashboard setelah login
          }
        },
      ),
    );
  }
}