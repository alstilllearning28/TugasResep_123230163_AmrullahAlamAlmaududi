import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/meal.dart';
import 'services/auth_service.dart';
import 'services/favorite_service.dart';
import 'pages/auth_page.dart';
import 'pages/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Hive
  await Hive.initFlutter();
  Hive.registerAdapter(MealAdapter());
  await FavoriteService.init();

  // Cek sesi login
  final authService = AuthService();
  final isLoggedIn = await authService.isLoggedIn();

  runApp(ResepKuApp(isLoggedIn: isLoggedIn));
}

class ResepKuApp extends StatelessWidget {
  final bool isLoggedIn;

  const ResepKuApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResepKu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4E342E), // Coklat Gelap
          primary: const Color(0xFF4E342E),
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F8F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4E342E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: isLoggedIn ? const MainPage() : const AuthPage(),
    );
  }
}