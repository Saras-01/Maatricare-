import 'package:flutter/material.dart';
import 'doctor_selection_screen.dart';
import 'appointment_screen.dart';
import 'chat_screen.dart';
import 'health_vitals_screen.dart';
import 'medical_reports_screen.dart';
import 'medicine_screen.dart';
import 'kick_counter_screen.dart';
import 'sos_screen.dart';
import 'baby_development_screen.dart';
import 'telemedicine_screen.dart';
import 'vaccination_screen.dart';
import 'package:maatricare_app/core/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maatricare_app/screens/auth/login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/api_service.dart';

class MotherDashboardScreen extends StatefulWidget {
  const MotherDashboardScreen({super.key});

  @override
  State<MotherDashboardScreen> createState() => _MotherDashboardScreenState();
}

class _MotherDashboardScreenState extends State<MotherDashboardScreen> {
  int _currentWeek = 0;
  int _currentTrimester = 1;
  int _weeksRemaining = 40;
  double _progressPercentage = 0.0;

  String _assignmentStatus = 'unassigned';

  @override
  void initState() {
    super.initState();
    _loadPregnancyData();
    _fetchAssignmentStatus();
  }

  Future<void> _fetchAssignmentStatus() async {
    try {
      final response = await http.get(Uri.parse('${ApiService.baseUrl}/doctors/assigned-doctor/?mother_name=${AppState.userName}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _assignmentStatus = data['status'] ?? 'unassigned';
          });
        }
      }
    } catch (e) {
      debugPrint('Failed to fetch assignment status: $e');
    }
  }

  Future<void> _loadPregnancyData() async {
    final prefs = await SharedPreferences.getInstance();
    final lmpStr = prefs.getString('lmp_date');
    
    if (lmpStr != null && lmpStr.isNotEmpty) {
      final lmpDate = DateTime.parse(lmpStr);
      final difference = DateTime.now().difference(lmpDate).inDays;
      
      int week = 0;
      if (difference > 0) {
        week = (difference / 7).floor();
      }
      
      int trimester = 1;
      if (week >= 14 && week < 28) {
        trimester = 2;
      } else if (week >= 28) {
        trimester = 3;
      }
      
      int remaining = 40 - week;
      if (remaining < 0) remaining = 0;
      
      double progress = (week / 40);
      if (progress > 1.0) progress = 1.0;
      else if (progress < 0.0) progress = 0.0;

      if (mounted) {
        setState(() {
          _currentWeek = week;
          _currentTrimester = trimester;
          _weeksRemaining = remaining;
          _progressPercentage = progress;
        });
      }
    }
  }

  String get _trimesterText {
    if (_currentTrimester == 1) return "First Trimester";
    if (_currentTrimester == 2) return "Second Trimester";
    return "Third Trimester";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2FA), // Soft lavender background
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isDesktop = constraints.maxWidth > 900;
            return SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 40.0 : 20.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopHeader(context, isDesktop),
                      const SizedBox(height: 32),
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 7,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildPregnancySummary(isDesktop),
                                  const SizedBox(height: 24),
                                  _buildPregnancyProgress(),
                                  const SizedBox(height: 24),
                                  _buildSectionTitle('Health Overview'),
                                  const SizedBox(height: 16),
                                  _buildHealthOverview(isDesktop),
                                ],
                              ),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDoctorSection(context),
                                  const SizedBox(height: 24),
                                  _buildSectionTitle('Quick Actions'),
                                  const SizedBox(height: 16),
                                  _buildQuickActions(context, isDesktop),
                                  const SizedBox(height: 24),
                                  _buildDigitalBirthCertificate(),
                                ],
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPregnancySummary(isDesktop),
                            const SizedBox(height: 24),
                            _buildPregnancyProgress(),
                            const SizedBox(height: 24),
                            _buildDoctorSection(context),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Health Overview'),
                            const SizedBox(height: 16),
                            _buildHealthOverview(isDesktop),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Quick Actions'),
                            const SizedBox(height: 16),
                            _buildQuickActions(context, isDesktop),
                            const SizedBox(height: 24),
                            _buildDigitalBirthCertificate(),
                          ],
                        ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context, bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFCE93D8), width: 2),
              ),
              child: const Icon(Icons.pregnant_woman_rounded, color: Color(0xFF8E24AA), size: 32),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Mother's Dashboard",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Welcome, ${AppState.userName}",
                  style: TextStyle(
                    fontSize: isDesktop ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4A148C),
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SOSScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.sos_rounded, color: Colors.white, size: 20),
              label: const Text("SOS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                elevation: 4,
                shadowColor: Colors.redAccent.withOpacity(0.5),
              ),
            ),
            if (isDesktop) const SizedBox(width: 16) else const SizedBox(width: 8),
            _buildIconAction(Icons.notifications_none_rounded, onPressed: () {}),
            const SizedBox(width: 8),
            _buildIconAction(Icons.logout_rounded, onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildIconAction(IconData icon, {VoidCallback? onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF6A1B9A)),
        onPressed: onPressed ?? () {},
        splashRadius: 24,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF4A148C),
      ),
    );
  }

  Widget _buildPregnancySummary(bool isDesktop) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(isDesktop ? 24 : 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8E24AA), Color(0xFFD81B60)], // Purple gradient background
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD81B60).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(height: 12),
                const Text("Current Week", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text("Week $_currentWeek", style: TextStyle(color: Colors.white, fontSize: isDesktop ? 26 : 20, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 4),
                const Text("of 40 weeks", style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryWhiteCard(
            "Trimester",
            "$_currentTrimester",
            _trimesterText,
            Icons.pregnant_woman_rounded,
            const Color(0xFFAB47BC),
            isDesktop,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryWhiteCard(
            "Weeks Remaining",
            "$_weeksRemaining",
            "Expected date",
            Icons.hourglass_bottom_rounded,
            const Color(0xFFEC407A),
            isDesktop,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryWhiteCard(String title, String value, String subtitle, IconData icon, Color iconColor, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 12),
          FittedBox(fit: BoxFit.scaleDown, child: Text(title, style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w500))),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: const Color(0xFF4A148C), fontSize: isDesktop ? 26 : 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          FittedBox(fit: BoxFit.scaleDown, child: Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 11))),
        ],
      ),
    );
  }

  Widget _buildPregnancyProgress() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Pregnancy Progress",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A148C)),
              ),
              Text(
                "${(_progressPercentage * 100).toStringAsFixed(0)}%",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFD81B60)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5F5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: _progressPercentage > 0 ? _progressPercentage : 0.01,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFBA68C8), Color(0xFFF06292)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF06292).withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFE082), width: 1),
            ),
            child: Row(
              children: [
                const Text("🍈", style: TextStyle(fontSize: 28)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Baby Size Update",
                        style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Your baby is about the size of a honeydew melon",
                        style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorSection(BuildContext context) {
    if (_assignmentStatus == 'approved') {
      final doctorMap = AppState.selectedDoctor;
      if (doctorMap != null) {
        return _buildYourDoctorCard(context, doctorMap);
      }
    } else if (_assignmentStatus == 'pending') {
      return _buildPendingAdminAlert(context);
    }
    return _buildDoctorSelectionAlert(context);
  }

  Widget _buildPendingAdminAlert(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF64B5F6), width: 1.5), // Blue outlined card
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64B5F6).withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFBBDEFB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.hourglass_top_rounded, color: Color(0xFF1976D2), size: 28),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  "Pending Admin Approval",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Your doctor request has been successfully sent. Waiting for hospital administration to approve the assignment.",
            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildYourDoctorCard(BuildContext context, Map<String, dynamic> doctor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3E5F5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Assigned Doctor",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A148C)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text("Approved", style: TextStyle(color: Color(0xFF2E7D32), fontSize: 12, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5F5),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFCE93D8), width: 1.5),
                ),
                child: const Icon(Icons.person, color: Color(0xFF8E24AA), size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor['name'] ?? 'Unknown',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4A148C)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor['specialty'] ?? '',
                      style: const TextStyle(color: Color(0xFFE91E63), fontSize: 13, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            doctor['hospital'] ?? '',
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E63),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE91E63).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 20),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorSelectionAlert(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDE7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFD54F), width: 1.5), // Yellow outlined card
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD54F).withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFECB3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFF57F17), size: 28), // Warning icon
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  "Select Your Doctor",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE65100),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Please select a gynecologist to guide you through your pregnancy journey.",
            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DoctorSelectionScreen(),
                  ),
                );
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA000),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text(
                "Select Doctor Now",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthOverview(bool isDesktop) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildHealthCard("Latest Vitals", "BP: 120/80\nWeight: 68kg\nHeart Rate: 85 bpm", Icons.monitor_heart_rounded, const Color(0xFF4FC3F7))),
          const SizedBox(width: 16),
          Expanded(child: _buildHealthCard("Next Appointment", "Oct 15, 10:00 AM\nDr. Sarah Smith\nCheckup", Icons.calendar_month_rounded, const Color(0xFF9575CD))),
          const SizedBox(width: 16),
          Expanded(child: _buildHealthCard("Medical Reports", "5 Total Reports\n1 Pending Review\nUltrasound Ready", Icons.folder_shared_rounded, const Color(0xFF4DB6AC))),
        ],
      );
    } else {
      return Column(
        children: [
          _buildHealthCard("Latest Vitals", "BP: 120/80\nWeight: 68kg\nHeart Rate: 85 bpm", Icons.monitor_heart_rounded, const Color(0xFF4FC3F7)),
          const SizedBox(height: 16),
          _buildHealthCard("Next Appointment", "Oct 15, 10:00 AM\nDr. Sarah Smith\nCheckup", Icons.calendar_month_rounded, const Color(0xFF9575CD)),
          const SizedBox(height: 16),
          _buildHealthCard("Medical Reports", "5 Total Reports\n1 Pending Review\nUltrasound Ready", Icons.folder_shared_rounded, const Color(0xFF4DB6AC)),
        ],
      );
    }
  }

  Widget _buildHealthCard(String title, String details, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, // 3 white cards
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A148C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            details,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDesktop) {
    return GridView.count(
      crossAxisCount: isDesktop ? 3 : 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.9,
      children: [
        _buildActionItem(
          "Appointments",
            Icons.edit_calendar_rounded,
            const Color(0xFF9C27B0),
            context,
        ),
        _buildActionItem("Health Vitals", Icons.favorite_border_rounded, const Color(0xFFE91E63), context),
        _buildActionItem("Medical Reports", Icons.receipt_long_rounded, const Color(0xFF00ACC1), context),
        _buildActionItem("Chat with Doctor", Icons.chat_bubble_outline_rounded, const Color(0xFF43A047), context),
        _buildActionItem("Medicines", Icons.medication_rounded, const Color(0xFFF4511E), context),
        _buildActionItem("Kick Counter", Icons.do_not_step_rounded, const Color(0xFF3949AB), context),
        _buildActionItem("Baby Development", Icons.child_care_rounded, const Color(0xFFFF6F91), context),
        _buildActionItem("Telemedicine", Icons.video_camera_front_rounded, const Color(0xFF6C63FF), context),
        _buildActionItem("Vaccination Tracker", Icons.vaccines_rounded, const Color(0xFF8E24AA), context),
      ],
    );
  }

  Widget _buildActionItem(
  String title,
  IconData icon,
  Color color,
  BuildContext context,
) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (title == "Appointments") {
              if (_assignmentStatus != 'approved') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Wait for doctor approval to book appointments.')),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppointmentScreen(),
                ),
              );
            } else if (title == "Chat with Doctor") {
              if (_assignmentStatus != 'approved') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Wait for doctor approval to chat.')),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    peerName: AppState.selectedDoctor?['doctor_name'] ?? 'Unknown Doctor',
                    peerEmail: AppState.selectedDoctor?['doctor_email'] ?? 'doctor@example.com',
                  ),
                ),
              );
            } else if (title == "Health Vitals") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HealthVitalsScreen(),
                ),
              );
            } else if (title == "Medical Reports") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MedicalReportsScreen(),
                ),
              );
            } else if (title == "Medicines") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MedicineScreen(),
                ),
              );
            } else if (title == "Kick Counter") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const KickCounterScreen(),
                ),
              );
            } else if (title == "Baby Development") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BabyDevelopmentScreen(),
                ),
              );
            } else if (title == "Telemedicine") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TelemedicineScreen(),
                ),
              );
            } else if (title == "Vaccination Tracker") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VaccinationScreen(),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDigitalBirthCertificate() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFCE93D8), width: 1.5), // Purple border card
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCE93D8).withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.verified_rounded, color: Color(0xFF8E24AA), size: 28),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  "Digital Birth Certificate - Preview",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A148C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Prepare for your baby's arrival. Preview and complete the preliminary details for the digital birth certificate issuance process.",
            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF8E24AA), Color(0xFFD81B60)], // Purple gradient button
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
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  "Preview Birth Certificate (Demo)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
