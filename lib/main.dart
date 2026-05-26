import 'package:flutter/material.dart';
import 'package:movie_reservation_system_mobile/screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Reservation System',
      theme: ThemeData(useMaterial3: true),
      home: const HomeScreen(), // Uruchamiamy aplikację na ekranie logowania
    );
  }
}