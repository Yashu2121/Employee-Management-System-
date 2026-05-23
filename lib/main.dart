import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Touchmatik Employee Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFFEE8E30),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF2C3E50),
          elevation: 1,
          iconTheme: IconThemeData(color: Color(0xFF2C3E50)),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEE8E30),
          brightness: Brightness.light,
          primary: const Color(0xFFEE8E30),
          secondary: const Color(0xFFE27C2A),
          surface: Colors.white,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
          titleLarge: TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
          bodyLarge: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: Color(0xFF34495E)),
          bodyMedium: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: Color(0xFF7F8C8D)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEE8E30), width: 1.5),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
