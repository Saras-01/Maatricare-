import 'package:flutter/material.dart';
import 'package:maatricare_app/screens/auth/register_screen.dart';
import 'package:maatricare_app/screens/auth/forgot_password_screen.dart';
import 'package:maatricare_app/screens/mother/mother_dashboard.dart';
import 'package:maatricare_app/screens/doctor/doctor_dashboard.dart';
import 'package:maatricare_app/screens/admin/admin_dashboard.dart';
import 'package:maatricare_app/screens/mother/pregnancy_setup_screen.dart';
import 'package:maatricare_app/core/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maatricare_app/core/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Color primaryPurple = const Color(0xFF8E24AA);
  final Color lightPurple = const Color(0xFFE1BEE7);
  final Color backgroundGradientStart = const Color(0xFFF3E5F5);
  final Color backgroundGradientEnd = const Color(0xFFFCE4EC);
  final Color textDark = const Color(0xFF4A148C);
  final Color textLight = const Color(0xFF7B1FA2);
  final Color inputFill = const Color(0xFFFAFAFA);

  String _selectedRole = 'Mother';
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [backgroundGradientStart, backgroundGradientEnd],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    width: constraints.maxWidth > 500 ? 500 : double.infinity,
                    padding: const EdgeInsets.all(32.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: primaryPurple.withOpacity(0.08),
                          blurRadius: 32,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(Icons.favorite, size: 48, color: primaryPurple),
                        const SizedBox(height: 16),
                        Text(
                          'Welcome Back',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textDark),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to continue to MaatriCare',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: textLight),
                        ),
                        const SizedBox(height: 32),
                        
                        // Role Selection
                        Text('Select Role', style: TextStyle(fontWeight: FontWeight.bold, color: textDark)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildRoleChip('Mother', Icons.pregnant_woman)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildRoleChip('Doctor', Icons.medical_services_outlined)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildRoleChip('Admin', Icons.admin_panel_settings_outlined)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Inputs
                        _buildTextField('Email Address', Icons.email_outlined, false, controller: _emailController),
                        const SizedBox(height: 16),
                        _buildTextField('Password', Icons.lock_outline, true, controller: _passwordController),
                        const SizedBox(height: 16),

                        // Remember Me & Forgot Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (val) {
                                    setState(() => _rememberMe = val!);
                                  },
                                  activeColor: primaryPurple,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                ),
                                Text('Remember me', style: TextStyle(color: textLight, fontSize: 13)),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
                              },
                              child: Text('Forgot Password?', style: TextStyle(color: primaryPurple, fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Login Button
                        _isLoading
                            ? const Center(child: CircularProgressIndicator(color: Color(0xFF8E24AA)))
                            : ElevatedButton(
                                onPressed: _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryPurple,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                                child: const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                        const SizedBox(height: 24),

                        // Sign up link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Don\'t have an account?', style: TextStyle(color: textLight)),
                            TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                              },
                              child: Text('Sign up', style: TextStyle(color: primaryPurple, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleChip(String role, IconData icon) {
    bool isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? primaryPurple : lightPurple),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : primaryPurple, size: 20),
            const SizedBox(height: 4),
            Text(
              role,
              style: TextStyle(
                color: isSelected ? Colors.white : primaryPurple,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, IconData icon, bool isPassword, {TextEditingController? controller}) {
    return TextField(
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: textLight.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: lightPurple),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: lightPurple),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryPurple),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.login(email, password);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Successful!'), backgroundColor: Colors.green),
        );

        AppState.userName = response['email'] ?? email;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userName', AppState.userName);
        await prefs.setString('userRole', _selectedRole);

        Widget targetScreen;
        if (_selectedRole == 'Admin') {
          targetScreen = const AdminDashboard();
        } else if (_selectedRole == 'Doctor') {
          targetScreen = const DoctorDashboard();
        } else {
          final lmpDate = prefs.getString('lmp_date');
          if (lmpDate == null || lmpDate.isEmpty) {
            targetScreen = const PregnancySetupScreen();
          } else {
            targetScreen = const MotherDashboardScreen();
          }
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => targetScreen),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Failed: Invalid credentials or API error.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
