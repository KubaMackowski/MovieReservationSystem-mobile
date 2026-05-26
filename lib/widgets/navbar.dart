import 'package:flutter/material.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  final bool isLoggedIn;
  final VoidCallback? onLoginPressed;
  final VoidCallback? onProfilePressed;

  const Navbar({
    super.key,
    this.isLoggedIn = false,
    this.onLoginPressed,
    this.onProfilePressed,
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
            icon: const Icon(Icons.person, color: textColor),
            onPressed: onProfilePressed,
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onLoginPressed,
              child: const Text('Zaloguj się', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }

  // Wymagane przez PreferredSizeWidget – standardowa wysokość paska
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}