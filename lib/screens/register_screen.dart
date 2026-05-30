import 'package:flutter/material.dart';
import '../data/api_client.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _apiClient = ApiClient();

  bool _isLoading = false;
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  String? _errorMessage;

  // Kolory aplikacji (zgodne z LoginScreen)
  final Color _bgColor = const Color(0xFF1E1E2C);
  final Color _cardColor = const Color(0xFF2A2A3D);
  final Color _inputColor = const Color(0xFF151520);
  final Color _primaryColor = Colors.deepPurpleAccent;
  final Color _textColor = Colors.white;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await _apiClient.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Konto zostało utworzone! Możesz się zalogować.'),
            backgroundColor: Colors.green,
          ),
        );
        // Wracamy do ekranu logowania
        Navigator.pop(context);
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
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: _textColor),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // KARTA REJESTRACJI (Neumorphic Outset)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, offset: Offset(4, 4), blurRadius: 8),
                    BoxShadow(color: Colors.white10, offset: Offset(-2, -2), blurRadius: 6),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // NAGŁÓWEK
                      Text(
                        'Stwórz konto',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Dołącz do nas już dziś',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: _textColor.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // POLE IMIĘ
                      _buildLabel('Imię'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _firstNameController,
                        hintText: 'Jan',
                        icon: Icons.badge_outlined,
                        textInputAction: TextInputAction.next,
                        validator: (value) => value == null || value.trim().isEmpty ? 'Wpisz imię' : null,
                      ),
                      const SizedBox(height: 16),

                      // POLE NAZWISKO
                      _buildLabel('Nazwisko'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _lastNameController,
                        hintText: 'Kowalski',
                        icon: Icons.badge_outlined,
                        textInputAction: TextInputAction.next,
                        validator: (value) => value == null || value.trim().isEmpty ? 'Wpisz nazwisko' : null,
                      ),
                      const SizedBox(height: 16),

                      // POLE EMAIL
                      _buildLabel('Email'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _emailController,
                        hintText: 'john@example.com',
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Wpisz adres email';
                          if (!value.contains('@')) return 'Wpisz poprawny adres email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // POLE HASŁO
                      _buildLabel('Hasło'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _passwordController,
                        hintText: '••••••••',
                        icon: Icons.lock_outline,
                        obscureText: _isPasswordObscured,
                        textInputAction: TextInputAction.next,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: _textColor.withOpacity(0.5),
                          ),
                          onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Wpisz hasło';
                          if (value.length < 6) return 'Hasło musi mieć min. 6 znaków';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // POLE POWTÓRZ HASŁO
                      _buildLabel('Powtórz hasło'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        hintText: '••••••••',
                        icon: Icons.lock_reset_outlined,
                        obscureText: _isConfirmPasswordObscured,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleRegister(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: _textColor.withOpacity(0.5),
                          ),
                          onPressed: () => setState(() => _isConfirmPasswordObscured = !_isConfirmPasswordObscured),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Powtórz hasło';
                          if (value != _passwordController.text) return 'Hasła nie są identyczne';
                          return null;
                        },
                      ),

                      // BŁĄD Z API
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade400),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // PRZYCISK ZAREJESTRUJ
                      SizedBox(
                        height: 56,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: _primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isLoading ? null : _handleRegister,
                          child: _isLoading
                              ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                          )
                              : Text(
                            'Zarejestruj się',
                            style: TextStyle(
                              color: _bgColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // LINK DO LOGOWANIA
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Masz już konto? ',
                    style: TextStyle(color: _textColor.withOpacity(0.6)),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Wraca do ekranu logowania
                    },
                    child: Text(
                      'Zaloguj się',
                      style: TextStyle(
                        color: _primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- POMOCNICZE WIDGETY DLA FORMULARZA ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: _textColor.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    Function(String)? onFieldSubmitted,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      style: TextStyle(color: _textColor, fontSize: 16),
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: _textColor.withOpacity(0.3)),
        filled: true,
        fillColor: _inputColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        prefixIcon: Icon(icon, color: _textColor.withOpacity(0.5)),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor.withOpacity(0.5), width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400, width: 2),
        ),
      ),
    );
  }
}