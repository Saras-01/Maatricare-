import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../auth/login_screen.dart';
import '../../core/app_state.dart';
import '../../core/api_service.dart';
import '../mother/chat_screen.dart';
import '../mother/telemedicine_screen.dart';
import '../mother/ai_risk_screen.dart';
import '../mother/medical_reports_screen.dart';
import '../mother/sos_screen.dart';
class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  // Premium Doctor Palette
  final Color primaryLavender = const Color(0xFF7C83FD); 
  final Color softLavender = const Color(0xFFE2E2FF);
  final Color backgroundLight = const Color(0xFFF4F7FE);
  final Color cardWhite = Colors.white;
  final Color textDark = const Color(0xFF2B3674);
  final Color textLight = const Color(0xFFA3AED0);
  
  // Status Colors
  final Color emergencyRed = const Color(0xFFFF5B5B);
  final Color warningOrange = const Color(0xFFFF9F43);
  final Color successGreen = const Color(0xFF00D084);

  bool _isLoading = true;
  String _doctorName = '';
  List<dynamic> _patients = [];
  List<dynamic> _requests = [];
  List<dynamic> _appointments = [];
  List<dynamic> _reports = [];
  List<dynamic> _emergencies = [];

  @override
  void initState() {
    super.initState();
    _doctorName = AppState.userName.isNotEmpty ? AppState.userName : 'Doctor';
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    try {
      debugPrint('Fetching for doctor_name/email: $_doctorName');
      final response = await http.get(Uri.parse('${ApiService.baseUrl}/doctors/patients/?doctor_name=$_doctorName'));
      
      debugPrint('API response body: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _patients = data['patients'] ?? [];
            _requests = data['requests'] ?? [];
            _appointments = data['appointments'] ?? [];
            _reports = data['reports'] ?? [];
            _emergencies = data['emergencies'] ?? [];
            _isLoading = false;
          });
          debugPrint('Assigned patient count: ${_patients.length}');
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _calculatePregnancyWeek(String? lmpDateStr) {
    if (lmpDateStr == null || lmpDateStr.isEmpty) return 'Week N/A';
    try {
      final lmp = DateTime.parse(lmpDateStr);
      final weeks = (DateTime.now().difference(lmp).inDays / 7).floor();
      return 'Week ${weeks.clamp(0, 42)}';
    } catch (e) {
      return 'Week N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryLavender))
          : LayoutBuilder(
              builder: (context, constraints) {
                bool isDesktop = constraints.maxWidth > 1000;
                return CustomScrollView(
                  slivers: [
                    _buildAppBar(isDesktop),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32.0 : 20.0, vertical: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildWelcomeSection(),
                            const SizedBox(height: 24),
                            _buildOverviewCards(isDesktop),
                            const SizedBox(height: 32),
                            if (isDesktop)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      children: [
                                        _buildQuickActionsGrid(isDesktop),
                                        const SizedBox(height: 32),
                                        _buildPendingRequests(),
                                        const SizedBox(height: 32),
                                        _buildPatientMonitoring(),
                                        const SizedBox(height: 32),
                                        _buildMedicalReports(),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 32),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: [
                                        _buildEmergencySection(),
                                        const SizedBox(height: 32),
                                        _buildAppointments(),
                                        const SizedBox(height: 32),
                                        _buildAIRiskAlerts(),
                                        const SizedBox(height: 32),
                                        _buildLiveMonitoring(),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            else
                              Column(
                                children: [
                                  _buildEmergencySection(),
                                  const SizedBox(height: 32),
                                  _buildQuickActionsGrid(isDesktop),
                                  const SizedBox(height: 32),
                                  _buildPendingRequests(),
                                  const SizedBox(height: 32),
                                  _buildPatientMonitoring(),
                                  const SizedBox(height: 32),
                                  _buildAppointments(),
                                  const SizedBox(height: 32),
                                  _buildMedicalReports(),
                                  const SizedBox(height: 32),
                                  _buildAIRiskAlerts(),
                                  const SizedBox(height: 32),
                                  _buildLiveMonitoring(),
                                ],
                              ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
      ),
    );
  }

  SliverAppBar _buildAppBar(bool isDesktop) {
    return SliverAppBar(
      backgroundColor: backgroundLight,
      elevation: 0,
      pinned: true,
      toolbarHeight: 80,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryLavender,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: primaryLavender.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Text(
            'MaatriCare',
            style: TextStyle(
              color: textDark,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: [
        if (isDesktop)
          Container(
            width: 350,
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: cardWhite,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: textLight.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: textLight),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search patients, ID, or alerts...',
                      hintStyle: TextStyle(color: textLight, fontSize: 14),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        IconButton(
          icon: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: cardWhite, shape: BoxShape.circle),
                child: Icon(Icons.notifications_none_rounded, color: textDark, size: 24),
              ),
              if (_emergencies.isNotEmpty || _requests.isNotEmpty)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: emergencyRed,
                      shape: BoxShape.circle,
                      border: Border.all(color: backgroundLight, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 16),
        Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Dr. $_doctorName', style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Lead Obstetrician', style: TextStyle(color: textLight, fontSize: 12)),
              ],
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryLavender, width: 2),
              ),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: softLavender,
                child: Icon(Icons.person, color: primaryLavender),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: cardWhite, shape: BoxShape.circle),
            child: Icon(Icons.logout_rounded, color: emergencyRed, size: 24),
          ),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            }
          },
        ),
        const SizedBox(width: 24),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    int highRiskCount = _patients.where((p) => p['risk_level'] == 'High').length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good Morning, Dr. $_doctorName! 👋',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          highRiskCount > 0 
            ? 'You have $highRiskCount high-risk patients requiring immediate attention today.'
            : 'All your assigned patients are currently stable.',
          style: TextStyle(
            fontSize: 16,
            color: textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCards(bool isDesktop) {
    int highRiskCount = _patients.where((p) => p['risk_level'] == 'High').length;

    final List<Map<String, dynamic>> stats = [
      {'title': 'Total Patients', 'value': '${_patients.length}', 'icon': Icons.groups_rounded, 'color': primaryLavender, 'trend': 'Active'},
      {'title': 'High Risk', 'value': '$highRiskCount', 'icon': Icons.warning_rounded, 'color': warningOrange, 'trend': 'Monitor'},
      {'title': 'Appointments', 'value': '${_appointments.length}', 'icon': Icons.calendar_today_rounded, 'color': successGreen, 'trend': 'Today'},
      {'title': 'Emergencies', 'value': '${_emergencies.length}', 'icon': Icons.emergency_rounded, 'color': emergencyRed, 'trend': 'Action Req'},
    ];

    return isDesktop
        ? Row(
            children: stats.map((stat) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 20), child: _buildStatCard(stat)))).toList(),
          )
        : GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: stats.length,
            itemBuilder: (context, index) => _buildStatCard(stats[index]),
          );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
    Color statColor = stat['color'] as Color;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(stat['icon'] as IconData, color: statColor, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  stat['trend'] as String,
                  style: TextStyle(color: statColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            stat['value'] as String,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textDark),
          ),
          Text(
            stat['title'] as String,
            style: TextStyle(fontSize: 14, color: textLight, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencySection() {
    if (_emergencies.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [emergencyRed, const Color(0xFFD63031)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: emergencyRed.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Text('Active Emergencies', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          ..._emergencies.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildEmergencyCard(
              e['mother_name'] ?? 'Unknown Patient', 
              e['issue'] ?? 'Immediate Attention Required',
              _calculatePregnancyWeek(e['lmp_date'])
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildEmergencyCard(String name, String details, String week) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: emergencyRed.withOpacity(0.1), child: Icon(Icons.person, color: emergencyRed)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(week, style: TextStyle(color: emergencyRed, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(details, style: TextStyle(color: textLight, fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.call, color: emergencyRed),
            style: IconButton.styleFrom(backgroundColor: emergencyRed.withOpacity(0.1)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(bool isDesktop) {
    final actions = [
      {'icon': Icons.chat_bubble_rounded, 'label': 'Chat', 'color': primaryLavender},
      {'icon': Icons.video_call_rounded, 'label': 'Video Consult', 'color': successGreen},
      {'icon': Icons.auto_awesome_rounded, 'label': 'AI Insights', 'color': warningOrange},
      {'icon': Icons.description_rounded, 'label': 'Reports', 'color': const Color(0xFF00B8D9)},
      {'icon': Icons.emergency_share_rounded, 'label': 'Emergency', 'color': emergencyRed},
      {'icon': Icons.medication_rounded, 'label': 'Prescriptions', 'color': const Color(0xFF6554C0)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Quick Actions'),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 6 : 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            return _buildActionCard(
              context,
              actions[index]['icon'] as IconData,
              actions[index]['label'] as String,
              actions[index]['color'] as Color,
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, IconData icon, String label, Color color) {
    return Container(
      decoration: _cardDecoration(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            debugPrint("Navigating to $label");
            if (label == 'Chat') {
              final firstPatient = _patients.isNotEmpty ? _patients.first : null;
              final peerName = firstPatient != null ? firstPatient['mother_name'] : 'Unknown Patient';
              final peerEmail = firstPatient != null ? (firstPatient['mother_email'] ?? 'patient@example.com') : 'patient@example.com';
              Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(
                peerName: peerName,
                peerEmail: peerEmail,
              )));
            } else if (label == 'Video Consult') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => TelemedicineScreen()));
            } else if (label == 'AI Insights') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AIRiskScreen()));
            } else if (label == 'Reports') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => MedicalReportsScreen()));
            } else if (label == 'Emergency') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => SOSScreen()));
            } else if (label == 'Prescriptions') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => PrescriptionScreen()));
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(color: textDark, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingRequests() {
    if (_requests.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Pending Patient Requests', icon: Icons.person_add_alt_1_rounded, iconColor: primaryLavender),
        const SizedBox(height: 16),
        Container(
          decoration: _cardDecoration(),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _requests.length,
            separatorBuilder: (context, index) => Divider(color: backgroundLight, thickness: 2, height: 1),
            itemBuilder: (context, index) {
              final req = _requests[index];
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: warningOrange.withOpacity(0.1),
                      child: Icon(Icons.person, color: warningOrange),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(req['mother_name'] ?? 'New Mother', style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(_calculatePregnancyWeek(req['lmp_date']), style: TextStyle(color: textLight, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Request Accepted!'))
                         );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: successGreen, foregroundColor: Colors.white, elevation: 0),
                      child: const Text('Accept'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(foregroundColor: emergencyRed),
                      child: const Text('Reject'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPatientMonitoring() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Active Patients', actionText: _patients.length > 5 ? 'View All' : null),
        const SizedBox(height: 16),
        Container(
          decoration: _cardDecoration(),
          child: _patients.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.groups_rounded, size: 48, color: textLight.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text("No Active Patients", style: TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("You do not have any assigned patients yet.", style: TextStyle(color: textLight)),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _patients.length > 5 ? 5 : _patients.length,
                separatorBuilder: (context, index) => Divider(color: backgroundLight, thickness: 2, height: 1),
                itemBuilder: (context, index) {
                  final patient = _patients[index];
                  return _buildPatientRow(
                    name: patient['name'] ?? patient['mother_name'] ?? 'Mother',
                    week: _calculatePregnancyWeek(patient['lmp_date']),
                    risk: patient['risk_level'] ?? 'Low',
                    vitals: patient['latest_vitals'] ?? 'No vitals logged yet',
                    aiStatus: patient['ai_status'] ?? 'Healthy Progress',
                  );
                },
              ),
        ),
      ],
    );
  }

  Widget _buildPatientRow({required String name, required String week, required String risk, required String vitals, required String aiStatus}) {
    Color riskColor = risk == 'High' ? emergencyRed : (risk == 'Moderate' ? warningOrange : successGreen);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: primaryLavender.withOpacity(0.1),
            child: Text(name.isNotEmpty ? name.substring(0, 1) : 'P', style: TextStyle(color: primaryLavender, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: riskColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text(risk, style: TextStyle(color: riskColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(week, style: TextStyle(color: textLight, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.monitor_heart_outlined, color: textLight, size: 14),
                    const SizedBox(width: 4),
                    Expanded(child: Text(vitals, style: TextStyle(color: textDark, fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: warningOrange, size: 14),
                    const SizedBox(width: 4),
                    Expanded(child: Text('AI: $aiStatus', style: TextStyle(color: warningOrange, fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              debugPrint("Navigating to Quick View");
              Navigator.push(context, MaterialPageRoute(builder: (_) => PatientDetailsScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryLavender.withOpacity(0.1),
              foregroundColor: primaryLavender,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text('Quick View', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Appointments Today'),
        const SizedBox(height: 16),
        Container(
          decoration: _cardDecoration(),
          padding: const EdgeInsets.all(20),
          child: _appointments.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text("No appointments today.", style: TextStyle(color: textLight))),
              )
            : Column(
                children: _appointments.map((app) {
                  return Column(
                    children: [
                      _buildAppointmentCard(
                        app['time'] ?? 'N/A', 
                        app['patient_name'] ?? 'Patient', 
                        app['type'] ?? 'Consultation', 
                        app['is_video'] ?? false
                      ),
                      if (app != _appointments.last) const Divider(height: 24),
                    ],
                  );
                }).toList(),
              ),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(String time, String patient, String type, bool isVideo) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: backgroundLight, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Text(time.contains(' ') ? time.split(' ')[0] : time, style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 16)),
              Text(time.contains(' ') ? time.split(' ')[1] : '', style: TextStyle(color: textLight, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(patient, style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 16)),
              Row(
                children: [
                  Icon(isVideo ? Icons.video_call : Icons.person, color: isVideo ? successGreen : primaryLavender, size: 14),
                  const SizedBox(width: 4),
                  Text(type, style: TextStyle(color: textLight, fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.check_circle, color: successGreen),
              onPressed: () {},
              tooltip: 'Approve',
            ),
            IconButton(
              icon: Icon(Icons.calendar_month, color: warningOrange),
              onPressed: () {},
              tooltip: 'Reschedule',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMedicalReports() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Pending Medical Reports'),
        const SizedBox(height: 16),
        Container(
          decoration: _cardDecoration(),
          child: _reports.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(32),
                child: Center(child: Text("No pending medical reports to review.", style: TextStyle(color: textLight))),
              )
            : Column(
                children: _reports.map((report) {
                  return Column(
                    children: [
                      _buildReportRow(
                        report['type'] ?? 'Medical Report',
                        report['patient_name'] ?? 'Patient',
                        report['ai_insight'] ?? 'AI: Pending Evaluation',
                        isWarning: report['status'] == 'Requires Attention'
                      ),
                      if (report != _reports.last) const Divider(height: 1),
                    ],
                  );
                }).toList(),
              ),
        ),
      ],
    );
  }

  Widget _buildReportRow(String testName, String patient, String aiSummary, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: backgroundLight, borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.description, color: primaryLavender),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(testName, style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('Patient: $patient', style: TextStyle(color: textLight, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: isWarning ? warningOrange : successGreen, size: 14),
                    const SizedBox(width: 4),
                    Expanded(child: Text(aiSummary, style: TextStyle(color: isWarning ? warningOrange : successGreen, fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  debugPrint("Navigating to Review Report");
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ReportReviewScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryLavender,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  minimumSize: const Size(100, 36),
                ),
                child: const Text('Review', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: textDark,
                  side: BorderSide(color: textLight.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  minimumSize: const Size(100, 36),
                ),
                child: const Text('Add Note'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAIRiskAlerts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('AI Risk Alerts', icon: Icons.auto_awesome, iconColor: warningOrange),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: warningOrange.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(color: warningOrange.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 8)),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildAlertRow('AI Monitoring Active', 'All patient vitals are being monitored in real-time. No severe anomalies detected currently.', Icons.health_and_safety),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlertRow(String title, String desc, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: warningOrange.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: warningOrange, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Text(desc, style: TextStyle(color: textLight, fontSize: 13, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLiveMonitoring() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Live NICU/Ward Monitoring'),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildLiveMetricCard('Heart Rate', 'Stable', '', Icons.favorite, successGreen, false),
            _buildLiveMetricCard('Blood Press.', 'Normal', '', Icons.speed, primaryLavender, false),
            _buildLiveMetricCard('Oxygen', '98', '%', Icons.air, const Color(0xFF00B8D9), false),
            _buildLiveMetricCard('Movement', 'Active', 'status', Icons.child_friendly, successGreen, false),
          ],
        ),
      ],
    );
  }

  Widget _buildLiveMetricCard(String title, String value, String unit, IconData icon, Color color, bool isAlert) {
    return Container(
      decoration: BoxDecoration(
        color: isAlert ? color.withOpacity(0.1) : cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isAlert ? color : Colors.transparent),
        boxShadow: [
          BoxShadow(color: textLight.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              if (isAlert) Icon(Icons.warning, color: color, size: 16),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(value, style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(width: 4),
                  Text(unit, style: TextStyle(color: textLight, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 4),
              Text(title, style: TextStyle(color: textLight, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? actionText, IconData? icon, Color? iconColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor ?? textDark),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textDark),
            ),
          ],
        ),
        if (actionText != null)
          TextButton(
            onPressed: () {},
            child: Text(actionText, style: TextStyle(color: primaryLavender, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: cardWhite,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: primaryLavender.withOpacity(0.04),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}

class PrescriptionScreen extends StatelessWidget {
  const PrescriptionScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Prescriptions')), body: const Center(child: Text('Prescriptions coming soon')));
}

class PatientDetailsScreen extends StatelessWidget {
  const PatientDetailsScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Patient Details')), body: const Center(child: Text('Patient Details coming soon')));
}

class ReportReviewScreen extends StatelessWidget {
  const ReportReviewScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Report Review')), body: const Center(child: Text('Report Review coming soon')));
}
