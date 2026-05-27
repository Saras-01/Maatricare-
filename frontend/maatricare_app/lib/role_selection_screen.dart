import 'package:flutter/material.dart';
import 'package:maatricare_app/screens/mother/mother_dashboard.dart';
import 'package:maatricare_app/screens/admin/admin_dashboard.dart';
import 'package:maatricare_app/screens/doctor/doctor_dashboard.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // A modern purple and pink gradient theme background
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF3E5F5), // Very light purple
              Color(0xFFFCE4EC), // Light pink
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 64, // Subtracting padding
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Section
                      const Icon(
                        Icons.favorite,
                        size: 64,
                        color: Color(0xFF9C27B0), // Purple
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome to MaatriCare',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4A148C), // Dark Purple
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select your role to continue',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF7B1FA2), // Medium Purple
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Role Cards
                      _RoleCard(
                        title: 'Mother',
                        subtitle: 'Access maternal healthcare, track pregnancy & baby development',
                        icon: Icons.pregnant_woman,
                        onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const MotherDashboardScreen(),
    ),
  );
},
                      ),
                      const SizedBox(height: 16),
                      _RoleCard(
                        title: 'Doctor',
                        subtitle: 'Manage appointments, patient records & consultations',
                        icon: Icons.medical_services_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DoctorDashboard(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _RoleCard(
                        title: 'Admin',
                        subtitle: 'Manage hospital staff, system settings & analytics',
                        icon: Icons.admin_panel_settings_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminDashboard(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9C27B0).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                // Icon Container with Gradient
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFAB47BC), // Light Purple
                        Color(0xFFEC407A), // Pink
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEC407A).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                // Text Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A148C), // Dark Purple
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Forward Arrow
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFFCE93D8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
