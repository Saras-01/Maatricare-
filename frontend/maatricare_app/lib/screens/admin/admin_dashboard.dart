import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:maatricare_app/screens/auth/login_screen.dart';
import '../../core/app_state.dart';
import '../../core/api_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // Premium Admin Color Palette
  final Color primaryIndigo = const Color(0xFF5D5FEF); 
  final Color softLavender = const Color(0xFFE0E0FF);
  final Color backgroundLight = const Color(0xFFF3F4F9);
  final Color cardWhite = Colors.white;
  final Color textDark = const Color(0xFF1B254B);
  final Color textLight = const Color(0xFFA3AED0);
  
  // Status Colors
  final Color emergencyRed = const Color(0xFFEE5D50);
  final Color warningOrange = const Color(0xFFFF9F43);
  final Color successGreen = const Color(0xFF05CD99);
  final Color infoBlue = const Color(0xFF39B8FF);

  bool _isLoading = true;
  String _adminName = '';
  
  Map<String, dynamic> _dashboardData = {
    'total_mothers': 0,
    'total_doctors': 0,
    'high_risk_cases': 0,
    'active_pregnancies': 0,
    'deliveries_completed': 0,
    'pending_deliveries': 0,
    'emergencies': [],
    'pending_requests': [],
    'reports': [],
    'system_stats': {
      'active_users': 0,
      'iot_devices': 0,
      'live_logs': '0/s',
      'telemedicine': 0
    },
    'analytics': []
  };

  @override
  void initState() {
    super.initState();
    _adminName = AppState.userName.isNotEmpty ? AppState.userName : 'Admin';
    _loadData();
  }

  Future<void> _loadData() async {
    await _fetchDashboardData();
    await _fetchPendingRequests();
  }

  Future<void> _fetchPendingRequests() async {
    try {
      final response = await http.get(Uri.parse('${ApiService.baseUrl}/doctors/requests/'));
      print(response.body);
      debugPrint("FETCH REQUESTS RESPONSE: ${response.body}");
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        if (mounted) {
          setState(() {
            _dashboardData['pending_requests'] = data;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching requests: $e');
    }
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('${ApiService.baseUrl}/doctors/admin-dashboard/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _dashboardData = data;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryIndigo))
          : LayoutBuilder(
              builder: (context, constraints) {
                bool isDesktop = constraints.maxWidth > 1100;
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
                            const SizedBox(height: 32),
                            _buildAnalyticsOverviewCards(isDesktop),
                            const SizedBox(height: 32),
                            if (isDesktop)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      children: [
                                        _buildHospitalManagementSection(),
                                        const SizedBox(height: 32),
                                        _buildPendingDoctorRequests(),
                                        const SizedBox(height: 32),
                                        _buildDeliveryManagementSection(),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 32),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: [
                                        _buildLiveEmergencyAlerts(),
                                        const SizedBox(height: 32),
                                        _buildQuickActionsGrid(),
                                        const SizedBox(height: 32),
                                        _buildAIAnalyticsSection(),
                                        const SizedBox(height: 32),
                                        _buildSystemMonitoringSection(),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            else
                              Column(
                                children: [
                                  _buildLiveEmergencyAlerts(),
                                  const SizedBox(height: 32),
                                  _buildQuickActionsGrid(),
                                  const SizedBox(height: 32),
                                  _buildHospitalManagementSection(),
                                  const SizedBox(height: 32),
                                  _buildAIAnalyticsSection(),
                                  const SizedBox(height: 32),
                                  _buildSystemMonitoringSection(),
                                  const SizedBox(height: 32),
                                  _buildPendingDoctorRequests(),
                                  const SizedBox(height: 32),
                                  _buildDeliveryManagementSection(),
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
    List emergencies = _dashboardData['emergencies'] ?? [];
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
              gradient: LinearGradient(
                colors: [primaryIndigo, const Color(0xFF868CFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: primaryIndigo.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Text(
            'Hospital Admin',
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
                  blurRadius: 10,
                  offset: const Offset(0, 2),
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
                      hintText: 'Search patients, doctors, or settings...',
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
              if (emergencies.isNotEmpty)
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
                Text('Admin $_adminName', style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Chief Administrator', style: TextStyle(color: textLight, fontSize: 12)),
              ],
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryIndigo, width: 2),
              ),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: softLavender,
                child: Icon(Icons.admin_panel_settings, color: primaryIndigo),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, $_adminName 👋',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Here is the overall status of the maternal healthcare system today.',
          style: TextStyle(
            fontSize: 16,
            color: textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsOverviewCards(bool isDesktop) {
    final List emergencies = _dashboardData['emergencies'] ?? [];
    
    final List<Map<String, dynamic>> stats = [
      {'title': 'Total Mothers', 'value': '${_dashboardData['total_mothers']}', 'icon': Icons.pregnant_woman, 'color': primaryIndigo, 'trend': 'Active System'},
      {'title': 'Total Doctors', 'value': '${_dashboardData['total_doctors']}', 'icon': Icons.medical_services, 'color': infoBlue, 'trend': 'Registered Staff'},
      {'title': 'High Risk Cases', 'value': '${_dashboardData['high_risk_cases']}', 'icon': Icons.warning_amber_rounded, 'color': warningOrange, 'trend': 'Requires Monitoring'},
      {'title': 'Active Pregnancies', 'value': '${_dashboardData['active_pregnancies']}', 'icon': Icons.favorite, 'color': const Color(0xFFEE4266), 'trend': 'Ongoing Care'},
      {'title': 'Deliveries Completed', 'value': '${_dashboardData['deliveries_completed']}', 'icon': Icons.child_care, 'color': successGreen, 'trend': 'Successful Outcomes'},
      {'title': 'Emergency Alerts', 'value': '${emergencies.length}', 'icon': Icons.emergency, 'color': emergencyRed, 'trend': emergencies.isNotEmpty ? 'Action Required' : 'All Clear'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 6 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isDesktop ? 1.0 : 1.2,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              Icon(Icons.more_horiz, color: textLight),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat['value'] as String,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textDark),
              ),
              Text(
                stat['title'] as String,
                style: TextStyle(fontSize: 14, color: textLight, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                stat['trend'] as String,
                style: TextStyle(fontSize: 11, color: statColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalManagementSection() {
    final modules = [
      {'title': 'Doctor Management', 'icon': Icons.group_add, 'color': primaryIndigo, 'desc': 'Manage staff, schedules'},
      {'title': 'Mother Records', 'icon': Icons.folder_shared, 'color': infoBlue, 'desc': 'View all patient data'},
      {'title': 'Appt. Management', 'icon': Icons.calendar_month, 'color': successGreen, 'desc': 'Review hospital schedule'},
      {'title': 'Emergency Monitoring', 'icon': Icons.monitor_heart, 'color': emergencyRed, 'desc': 'NICU and ward live stats'},
      {'title': 'AI Analytics', 'icon': Icons.auto_awesome, 'color': warningOrange, 'desc': 'Global risk predictions'},
      {'title': 'Delivery Management', 'icon': Icons.bedroom_baby, 'color': const Color(0xFFB554FF), 'desc': 'Post-childbirth workflows'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Hospital Management'),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.8,
          ),
          itemCount: modules.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: _cardDecoration(),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (modules[index]['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(modules[index]['icon'] as IconData, color: modules[index]['color'] as Color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          modules[index]['title'] as String,
                          style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          modules[index]['desc'] as String,
                          style: TextStyle(color: textLight, fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLiveEmergencyAlerts() {
    List emergencies = _dashboardData['emergencies'] ?? [];
    if (emergencies.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: emergencyRed,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: emergencyRed.withOpacity(0.3),
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
                child: const Icon(Icons.notifications_active, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Text('Live Emergency Alerts', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          ...emergencies.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildEmergencyAlertCard(
              e['name'] ?? 'Unknown Patient', 
              e['type'] ?? 'Emergency', 
              e['location'] ?? 'Hospital', 
              e['doctor'] ?? 'Assigned Doctor'
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildEmergencyAlertCard(String name, String type, String location, String doctor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: emergencyRed.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text('Urgent', style: TextStyle(color: emergencyRed, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(type, style: TextStyle(color: emergencyRed, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, color: textLight, size: 14),
              const SizedBox(width: 4),
              Text(location, style: TextStyle(color: textLight, fontSize: 12)),
              const SizedBox(width: 16),
              Icon(Icons.medical_services, color: textLight, size: 14),
              const SizedBox(width: 4),
              Text(doctor, style: TextStyle(color: textLight, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.call, size: 16, color: Colors.white),
                  label: const Text('Contact Dr.', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryIndigo,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textDark,
                    side: BorderSide(color: textLight.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('View Logs'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    final actions = [
      {'icon': Icons.person_add, 'label': 'Add Doctor', 'color': primaryIndigo},
      {'icon': Icons.pregnant_woman, 'label': 'Add Mother', 'color': infoBlue},
      {'icon': Icons.auto_awesome, 'label': 'AI Insights', 'color': warningOrange},
      {'icon': Icons.emergency, 'label': 'Emerg. Control', 'color': emergencyRed},
      {'icon': Icons.child_care, 'label': 'Deliveries', 'color': successGreen},
      {'icon': Icons.analytics, 'label': 'Reports', 'color': const Color(0xFFB554FF)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Quick Actions'),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: _cardDecoration(),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (actions[index]['color'] as Color).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(actions[index]['icon'] as IconData, color: actions[index]['color'] as Color, size: 24),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        actions[index]['label'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: textDark, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAIAnalyticsSection() {
    List analytics = _dashboardData['analytics'] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('AI Global Analytics', icon: Icons.auto_awesome, iconColor: warningOrange),
        const SizedBox(height: 16),
        Container(
          decoration: _cardDecoration(),
          padding: const EdgeInsets.all(24),
          child: analytics.isEmpty 
            ? Center(child: Text("No AI Analytics generated yet.", style: TextStyle(color: textLight)))
            : Column(
                children: analytics.map((a) {
                  return Column(
                    children: [
                      _buildAIStatRow(
                        a['title'] ?? 'Analytics', 
                        a['desc'] ?? 'Data insight', 
                        Icons.analytics, 
                        a['trend'] == 'up' ? warningOrange : successGreen
                      ),
                      if (a != analytics.last) const Divider(height: 32),
                    ],
                  );
                }).toList(),
              ),
        ),
      ],
    );
  }

  Widget _buildAIStatRow(String title, String desc, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Text(desc, style: TextStyle(color: textLight, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSystemMonitoringSection() {
    Map<String, dynamic> sys = _dashboardData['system_stats'] ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('System Monitoring'),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildSystemMetricCard('Active Users', '${sys['active_users'] ?? 0}', Icons.people, primaryIndigo),
            _buildSystemMetricCard('IoT Devices', '${sys['iot_devices'] ?? 0}', Icons.router, infoBlue),
            _buildSystemMetricCard('Real-time Logs', '${sys['live_logs'] ?? '0/s'}', Icons.speed, warningOrange),
            _buildSystemMetricCard('Telemedicine', '${sys['telemedicine'] ?? 0} Live', Icons.video_call, successGreen),
          ],
        ),
      ],
    );
  }

  Widget _buildSystemMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: TextStyle(color: textLight, fontSize: 12, fontWeight: FontWeight.w600))),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 20)),
        ],
      ),
    );
  }

  Widget _buildDeliveryManagementSection() {
    int pendingDeliveries = _dashboardData['pending_deliveries'] ?? 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Delivery Management Workflows', icon: Icons.child_friendly, iconColor: primaryIndigo),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: primaryIndigo.withOpacity(0.2), width: 2),
            boxShadow: [
              BoxShadow(
                color: primaryIndigo.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pending Deliveries', style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 8),
                    Text('$pendingDeliveries deliveries require confirmation to activate the Baby Dashboard.', style: TextStyle(color: textLight, fontSize: 14)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                label: const Text('Manage', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryIndigo,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPendingDoctorRequests() {
    List requests = _dashboardData['pending_requests'] ?? [];
    
    // Filter only pending requests
    requests = requests.where((r) => r['status'] == 'pending').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Pending Doctor Requests'),
        const SizedBox(height: 16),
        Container(
          decoration: _cardDecoration(),
          child: requests.isEmpty 
            ? Padding(
                padding: const EdgeInsets.all(32),
                child: Center(child: Text("No pending doctor assignments.", style: TextStyle(color: textLight))),
              )
            : Column(
                children: requests.map((r) {
                  return Column(
                    children: [
                      _buildApprovalRow(
                        r['id'],
                        r['mother_name'] ?? 'Mother', 
                        r['doctor_name'] ?? 'Doctor', 
                        r['status'] ?? 'pending',
                        r['pregnancy_week'] ?? r['created_at'] ?? 'Date'
                      ),
                      if (r != requests.last) const Divider(height: 1),
                    ],
                  );
                }).toList(),
              ),
        ),
      ],
    );
  }

  Widget _buildApprovalRow(int id, String motherName, String doctorName, String status, String date) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: backgroundLight, borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.assignment_ind, color: primaryIndigo),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(motherName, style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('Requested: Dr. $doctorName', style: TextStyle(color: textLight, fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(date, style: TextStyle(color: textLight, fontSize: 12)),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _handleApproval(id, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: successGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(80, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('Approve', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => _handleApproval(id, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: emergencyRed,
                      side: BorderSide(color: emergencyRed.withOpacity(0.5)),
                      minimumSize: const Size(80, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('Reject', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleApproval(int requestId, bool approve) async {
    try {
      final endpoint = approve ? 'approve-request' : 'reject-request';
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/doctors/$endpoint/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'request_id': requestId}),
      );
      if (response.statusCode == 200) {
        _loadData(); // Load data sequentially to prevent state overwrites
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(approve ? 'Request Approved' : 'Request Rejected')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Widget _buildSectionHeader(String title, {String? actionText, IconData? icon, Color? iconColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor ?? textDark, size: 24),
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
            child: Text(actionText, style: TextStyle(color: primaryIndigo, fontWeight: FontWeight.bold)),
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
          color: primaryIndigo.withOpacity(0.04),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}
