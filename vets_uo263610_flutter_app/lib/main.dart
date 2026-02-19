import 'package:flutter/material.dart';
import 'package:vets_uo263610_flutter_app/pages/login_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Aplicación para la gestión de veterinarias",
      home: LoginPage(),
    );
  }
}
