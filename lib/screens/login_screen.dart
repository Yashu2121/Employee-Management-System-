import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dashboard_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _login(String username, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await ApiService.login(username, password);
      final token = data['access_token'];
      final userData = data['user'];

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardShell(token: token, user: userData),
          ),
        );
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

  void _autofill(String username, String password) {
    _usernameController.text = username;
    _passwordController.text = password;
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFDFBF7),
              Color(0xFFF5F6F8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Beautiful Professional Brand Login Card
                  Container(
                    width: isMobile ? double.infinity : 420,
                    constraints: const BoxConstraints(maxWidth: 420),
                    padding: const EdgeInsets.all(32.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2C3E50).withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFEE8E30).withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Touchmatik Brand Header
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'touchmatik',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFFEE8E30),
                                  letterSpacing: -1,
                                  shadows: [
                                    Shadow(
                                      color: const Color(0xFF2C3E50).withOpacity(0.1),
                                      offset: const Offset(1, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Smart Automation Solutions',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF7F8C8D),
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 36),
                        const Text(
                          'EMPLOYEE PORTAL LOGIN',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Username Field
                        TextField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person_outline, color: Color(0xFF7F8C8D)),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF7F8C8D)),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Error Message
                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(color: Color(0xFFE74C3C), fontSize: 13, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        // Login Button
                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () => _login(_usernameController.text, _passwordController.text),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            backgroundColor: const Color(0xFFEE8E30),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'SIGN IN',
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Floating Test Accounts Panel
                  Container(
                    width: isMobile ? double.infinity : 420,
                    constraints: const BoxConstraints(maxWidth: 420),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2C3E50).withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '💡 Demo Test Accounts:',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEE8E30), fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildAutofillChip('Employee', 'employee', 'employee123'),
                            _buildAutofillChip('Team Leader', 'leader', 'leader123'),
                            _buildAutofillChip('HR Manager', 'hr', 'hr123'),
                            _buildAutofillChip('Director', 'director', 'director123'),
                          ],
                        ),
                      ],
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

  Widget _buildAutofillChip(String label, String u, String p) {
    return ActionChip(
      label: Text(label),
      backgroundColor: const Color(0xFFF5F6F8),
      labelStyle: const TextStyle(fontSize: 11, color: Color(0xFF2C3E50), fontWeight: FontWeight.w600),
      side: const BorderSide(color: Color(0xFFE0E0E0)),
      onPressed: () => _autofill(u, p),
    );
  }
}
