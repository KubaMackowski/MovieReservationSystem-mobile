import 'package:flutter/material.dart';
import '../screens/login_screen.dart'; // Import ekranu logowania
// import '../screens/profile_screen.dart'; // Odkomentuj/dodaj, gdy stworzysz ekran profilu

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  final bool isLoggedIn;
  final VoidCallback? onLogoutPressed;

  const Navbar({
    super.key,
    this.isLoggedIn = false,
    this.onLogoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Colors.deepPurpleAccent;
    const textColor = Colors.white;

    return AppBar(
      backgroundColor: const Color(0xFF1E1E2C),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          const Icon(Icons.movie_creation_rounded, color: primaryColor, size: 28),
          const SizedBox(width: 8),
          const Text(
            'CineSoft',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: textColor),
          ),
        ],
      ),
      actions: [
        if (isLoggedIn)
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent), // Zmieniona ikona na wyloguj
            onPressed: onLogoutPressed, // Wywołujemy przekazaną akcję
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                // NAWIGACJA DO EKRANU LOGOWANIA
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Zaloguj się', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}