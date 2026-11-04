import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'navigation.dart';

// Import halaman
import 'pages/register_page.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/scholarship_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const BeaskitApp());
}

class BeaskitApp extends StatelessWidget {
  const BeaskitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beaskit',
      debugShowCheckedModeBanner: false,

      // Tema aplikasi
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),

      // Halaman pertama yang dibuka
      initialRoute: AppRoutes.login,

      // Daftar navigasi halaman
      routes: {
        AppRoutes.register: (context) => const RegisterPage(),
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.dashboard: (context) => const DashboardPage(),
        AppRoutes.scholarship: (context) => const ScholarshipPage(),
      },
    );
  }
}
