// Main untuk MOBILE (tanpa dart:html registration)
import 'package:flutter/material.dart';
import 'package:siakad/pages/login_pages.dart';
import 'package:siakad/api/api_service.dart';

void main() {
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
