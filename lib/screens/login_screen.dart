import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/api_client.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Klucz formularza do walidacji danych
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiClient = ApiClient();
  final _storage = const FlutterSecureStorage();

  bool _isLoading = false;
  bool _isPasswordObscured = true; // Do pokazywania/ukrywania hasła
  String? _errorMessage;

  // Bardzo ważne: Zwalnianie zasobów, gdy ekran zostaje zniszczony
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Sprawdź, czy formularz jest poprawnie wypełniony
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiClient.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      String token = '';

      // Sprawdzamy, w jakim formacie przyszła odpowiedź z backendu C#
      if (response.data is String) {
        // Opcja 1: Serwer zwrócił sam czysty tekst (token)
        token = response.data;
      } else if (response.data is Map<String, dynamic>) {
        // Opcja 2: Serwer poprawnie zwrócił obiekt JSON
        token = response.data['token'] ?? '';
      } else {
        throw Exception('Nieznany format odpowiedzi z serwera');
      }

      if (token.isEmpty) {
        throw Exception('Serwer nie zwrócił tokena logowania');
      }

      await _storage.write(key: 'jwt_token', value: token);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Zalogowano pomyślnie!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey, // Podpięcie klucza formularza
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Miejsce na Twoje logo (możesz tu użyć np. SvgPicture.asset)
                  const Icon(
                    Icons.movie_creation_rounded,
                    size: 80,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Witaj ponownie',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Zaloguj się, aby zarezerwować bilet',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  // Wyświetlanie błędu z API
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Pole Email z walidacją
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Wpisz adres email';
                      }
                      if (!value.contains('@')) {
                        return 'Wpisz poprawny adres email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Pole Hasło z walidacją i ukrywaniem tekstu
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _isPasswordObscured,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleLogin(), // Loguje po wciśnięciu 'Enter' na klawiaturze
                    decoration: InputDecoration(
                      labelText: 'Hasło',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordObscured
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordObscured = !_isPasswordObscured;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wpisz hasło';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Przycisk logowania
                  SizedBox(
                    height: 50,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : FilledButton( // Nowoczesny przycisk z Material 3
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _handleLogin,
                      child: const Text(
                        'Zaloguj się',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}