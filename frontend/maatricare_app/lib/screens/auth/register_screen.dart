import 'package:flutter/material.dart';
import 'package:maatricare_app/core/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final Color primaryPurple = const Color(0xFF8E24AA);
  final Color lightPurple = const Color(0xFFE1BEE7);
  final Color backgroundGradientStart = const Color(0xFFF3E5F5);
  final Color backgroundGradientEnd = const Color(0xFFFCE4EC);
  final Color textDark = const Color(0xFF4A148C);
  final Color textLight = const Color(0xFF7B1FA2);
  final Color inputFill = const Color(0xFFFAFAFA);

  String _selectedRole = 'Mother';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

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
                        Icon(Icons.person_add_alt_1, size: 48, color: primaryPurple),
                        const SizedBox(height: 16),
                        Text(
                          'Create Account',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textDark),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Join MaatriCare to manage your healthcare journey',
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
                        _buildTextField('Full Name', Icons.person_outline, false, false, false, _nameController),
                        const SizedBox(height: 16),
                        _buildTextField('Email Address', Icons.email_outlined, false, false, false, _emailController),
                        const SizedBox(height: 16),
                        _buildTextField('Phone Number', Icons.phone_outlined, false, false, false, _phoneController),
                        const SizedBox(height: 16),
                        _buildTextField('Password', Icons.lock_outline, true, _obscurePassword, false, _passwordController),
                        const SizedBox(height: 16),
                        _buildTextField('Confirm Password', Icons.lock_outline, true, _obscureConfirmPassword, true, _confirmPasswordController),
                        const SizedBox(height: 32),

                        // Register Button
                        _isLoading
                            ? const Center(child: CircularProgressIndicator(color: Color(0xFF8E24AA)))
                            : ElevatedButton(
                                onPressed: _handleRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryPurple,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                                child: const Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                        const SizedBox(height: 24),

                        // Sign in link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Already have an account?', style: TextStyle(color: textLight)),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Sign in', style: TextStyle(color: primaryPurple, fontWeight: FontWeight.bold)),
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

  Widget _buildTextField(String hint, IconData icon, bool isPassword, bool obscureState, bool isConfirm, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: isPassword && obscureState,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: textLight.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: lightPurple),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(obscureState ? Icons.visibility_off : Icons.visibility, color: lightPurple),
                onPressed: () {
                  setState(() {
                    if (isConfirm) {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    } else {
                      _obscurePassword = !_obscurePassword;
                    }
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

  void _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields.'), backgroundColor: Colors.red));
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid email format.'), backgroundColor: Colors.red));
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must be at least 6 characters.'), backgroundColor: Colors.red));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match.'), backgroundColor: Colors.red));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.register(name, email, phone, password, _selectedRole);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration Successful! Please login.'), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration failed. Email might already exist.'), backgroundColor: Colors.red));
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
