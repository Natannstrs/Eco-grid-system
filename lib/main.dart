// lib/main.dart
// Entry point aplikasi EcoGrid — Renewable Energy Dashboard
// NIM: 202431091 | Gesture: Tap, Long Press, Drag/Pan

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Kunci orientasi ke potrait saja (dashboard mobile)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Status bar transparan agar tema gelap konsisten
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const EcoGridApp());
}

/// Root widget aplikasi EcoGrid
class EcoGridApp extends StatelessWidget {
  const EcoGridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoGrid — Renewable Energy Dashboard',
      debugShowCheckedModeBanner: false,
      // Tema gelap bernuansa hijau hutan
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A1A0A),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF4CAF50),
          secondary: const Color(0xFF69F0AE),
          surface: const Color(0xFF0F1E0F),
        ),
        fontFamily: 'Roboto',
        cardColor: const Color(0xFF1A2E1A),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}
