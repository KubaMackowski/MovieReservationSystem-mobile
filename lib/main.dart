import 'package:flutter/cupertino.dart'; // Zmiana importu!
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'Merito Cinema',
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.activeBlue,
        // Tutaj ustawiasz fonty i kolory specyficzne dla iOS
      ),
      home: HomeScreen(),
    );
  }
}