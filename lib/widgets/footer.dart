import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    const textColor = Colors.white;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // Nawigacja do polityki
              },
              child: Text(
                'Polityka Prywatności',
                style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 12),
              ),
            ),
            TextButton(
              onPressed: () {
                // Nawigacja do regulaminu
              },
              child: Text(
                'Regulamin',
                style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '© 2026 CINESOFT ENTERTAINMENT',
          style: TextStyle(
            color: textColor.withOpacity(0.3),
            fontSize: 10,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }
}