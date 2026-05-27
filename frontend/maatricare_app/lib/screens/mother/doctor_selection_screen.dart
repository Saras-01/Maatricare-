import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_state.dart';
import '../../core/api_service.dart';

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String hospital;
  final String availableDays;
  final int experienceYears;
  final double rating;
  final String patients;
  final String successRate;
  final String responseTime;
  final String image;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.hospital,
    required this.availableDays,
    required this.experienceYears,
    required this.rating,
    required this.patients,
    required this.successRate,
    required this.responseTime,
    required this.image,
  });
}

class DoctorSelectionScreen extends StatefulWidget {
  DoctorSelectionScreen({super.key});

  @override
  State<DoctorSelectionScreen> createState() => _DoctorSelectionScreenState();
}

class _DoctorSelectionScreenState extends State<DoctorSelectionScreen> {
  String? _selectedDoctorId;
  late Future<List<Doctor>> _doctorsFuture;

  @override
  void initState() {
    super.initState();
    _doctorsFuture = ApiService.fetchDoctors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2FA), // Soft lavender page background
      appBar: AppBar(
        title: const Text(
          'Select Your Doctor',
          style: TextStyle(
            color: Color(0xFF4A148C),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF4A148C)),
      ),
      body: FutureBuilder<List<Doctor>>(
        future: _doctorsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF4A148C)));
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load doctors: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No doctors available at the moment.'));
          }

          final doctors = snapshot.data!;
          final selectedDoctor = doctors.where((d) => d.id == _selectedDoctorId).firstOrNull;

          return Stack(
            children: [
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    bool isDesktop = constraints.maxWidth > 800;
                    
                    return SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: 24,
                        right: 24,
                        top: 16,
                        bottom: _selectedDoctorId != null ? 120 : 24,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: isDesktop
                              ? GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 24,
                                    mainAxisSpacing: 24,
                                    mainAxisExtent: 260,
                                  ),
                                  itemCount: doctors.length,
                                  itemBuilder: (context, index) {
                                    return _buildDoctorCard(doctors[index]);
                                  },
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: doctors.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 20),
                                  itemBuilder: (context, index) {
                                    return _buildDoctorCard(doctors[index]);
                                  },
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (selectedDoctor != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildStickyConfirmationBar(selectedDoctor),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDoctorCard(Doctor doctor) {
    bool isSelected = _selectedDoctorId == doctor.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDoctorId = doctor.id;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white, // White premium doctor cards
          borderRadius: BorderRadius.circular(24), // Rounded corners (24px)
          border: Border.all(
            color: isSelected ? const Color(0xFFE91E63) : Colors.transparent, // Bright pink border when selected
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04), // Smooth shadows
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E5F5),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFCE93D8), width: 1.5),
                        image: doctor.image.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(doctor.image.startsWith('http') ? doctor.image : '${ApiService.baseUrl}${doctor.image}'),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: doctor.image.isEmpty ? const Icon(Icons.person, color: Color(0xFF8E24AA), size: 36) : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  doctor.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4A148C),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    doctor.rating.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            doctor.specialty,
                            style: const TextStyle(
                              color: Color(0xFFE91E63),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  doctor.hospital,
                                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.calendar_month_rounded, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  doctor.availableDays,
                                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.work_rounded, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                '${doctor.experienceYears} Years Experience',
                                style: const TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBF8FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF3E5F5), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildAnalyticItem('Patients', '${doctor.patients}+'),
                      Container(height: 30, width: 1, color: const Color(0xFFE1BEE7)),
                      _buildAnalyticItem('Success Rate', doctor.successRate),
                      Container(height: 30, width: 1, color: const Color(0xFFE1BEE7)),
                      _buildAnalyticItem('Response', doctor.responseTime),
                    ],
                  ),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE91E63), // Pink circular checkmark
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF4A148C),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStickyConfirmationBar(Doctor doctor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E5F5),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFCE93D8), width: 1.5),
                    image: doctor.image.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(doctor.image.startsWith('http') ? doctor.image : '${ApiService.baseUrl}${doctor.image}'),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: doctor.image.isEmpty ? const Icon(Icons.person, color: Color(0xFF8E24AA), size: 28) : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected Doctor',
                        style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctor.name,
                        style: const TextStyle(
                          color: Color(0xFF4A148C),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8E24AA), Color(0xFFD81B60)], // Purple gradient
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD81B60).withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      AppState.selectedDoctor = {
                        'id': doctor.id,
                        'name': doctor.name,
                        'specialty': doctor.specialty,
                        'rating': doctor.rating,
                        'hospital': doctor.hospital,
                        'availableDays': doctor.availableDays,
                        'experienceYears': doctor.experienceYears,
                        'patients': doctor.patients,
                        'successRate': doctor.successRate,
                        'responseTime': doctor.responseTime,
                      };
                      
                      // Notify Backend
                      try {
                        final prefs = await SharedPreferences.getInstance();
                        String? savedLmp = prefs.getString('lmp_date');
                        
                        await http.post(
                          Uri.parse('${ApiService.baseUrl}/doctors/request/'),
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode({
                            'mother_name': AppState.userName,
                            'mother_email': '${AppState.userName.replaceAll(' ', '').toLowerCase()}@example.com',
                            'doctor_name': doctor.name,
                            'doctor_email': 'contact@${doctor.name.replaceAll(' ', '').replaceAll('.', '').toLowerCase()}.com',
                            'pregnancy_week': 12, // Example week
                            'status': 'pending'
                          }),
                        );
                      } catch (e) {
                         debugPrint('Failed to assign doctor in backend: $e');
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Request sent to hospital admin for approval',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: const Color(0xFF43A047),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Confirm Selection',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
