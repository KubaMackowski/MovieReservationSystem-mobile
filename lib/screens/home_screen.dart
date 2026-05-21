import 'package:flutter/cupertino.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Strona Główna'),
        // Ikony z pakietu cupertino_icons
        trailing: Icon(CupertinoIcons.settings),
      ),
      child: SafeArea( // SafeArea chroni przed wejściem na notch/wyspę
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Witaj w aplikacji Cupertino!'),
              const SizedBox(height: 20),
              CupertinoButton.filled(
                onPressed: () {
                  // Logika po kliknięciu
                },
                child: const Text('Kliknij mnie'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}