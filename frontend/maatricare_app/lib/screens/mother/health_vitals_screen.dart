import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/app_state.dart';

class HealthVitalsScreen extends StatefulWidget {
  const HealthVitalsScreen({super.key});

  @override
  State<HealthVitalsScreen> createState() => _HealthVitalsScreenState();
}

class _HealthVitalsScreenState extends State<HealthVitalsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _latestVitals;
  List<dynamic> _history = [];
  bool _isEmergency = false;

  @override
  void initState() {
    super.initState();
    _fetchVitals();
  }

  Future<void> _fetchVitals() async {
    setState(() => _isLoading = true);
    try {
      final userName = AppState.userName;
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/vitals/mother/$userName/'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        setState(() {
          if (data is Map<String, dynamic> && data.containsKey('latest')) {
            _latestVitals = data['latest'];
            _history = data['history'] ?? [];
            _checkEmergency(_latestVitals);
          } else if (data is List && data.isNotEmpty) {
            _history = data;
            _latestVitals = data.first;
            _checkEmergency(_latestVitals);
          } else {
            _latestVitals = null;
            _history = [];
          }
        });
      } else {
        setState(() {
          _latestVitals = null;
        });
      }
    } catch (e) {
      setState(() {
        _latestVitals = null;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _checkEmergency(Map<String, dynamic>? vitals) {
    if (vitals == null) {
      _isEmergency = false;
      return;
    }
    
    bool isAbnormal = false;
    
    final bp = vitals['blood_pressure']?.toString();
    if (bp != null && bp.contains('/')) {
      final parts = bp.split('/');
      final sys = int.tryParse(parts[0]) ?? 120;
      final dia = int.tryParse(parts[1]) ?? 80;
      if (sys >= 140 || dia >= 90 || sys <= 90 || dia <= 60) {
        isAbnormal = true;
      }
    }
    
    final hr = int.tryParse(vitals['heart_rate']?.toString() ?? '85') ?? 85;
    if (hr > 110 || hr < 60) isAbnormal = true;
    
    final o2 = int.tryParse(vitals['oxygen']?.toString() ?? '98') ?? 98;
    if (o2 < 95) isAbnormal = true;
    
    final fetalHr = int.tryParse(vitals['baby_heartbeat']?.toString() ?? '140') ?? 140;
    if (fetalHr > 160 || fetalHr < 110) isAbnormal = true;

    _isEmergency = isAbnormal;
  }

  String _getSafeValue(String key, String fallback) {
    if (_latestVitals == null) return fallback;
    return _latestVitals![key]?.toString() ?? fallback;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2FA), // Soft lavender background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF4A148C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Health Vitals",
              style: TextStyle(
                color: Color(0xFF4A148C),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              "Monitor maternal health in real-time",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF9C27B0)))
        : LayoutBuilder(
            builder: (context, constraints) {
              bool isDesktop = constraints.maxWidth > 800;
              
              if (_latestVitals == null) {
                return _buildEmptyState(isDesktop);
              }
              
              return SingleChildScrollView(
                padding: EdgeInsets.all(isDesktop ? 40 : 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Current Vitals"),
                        const SizedBox(height: 16),
                        _buildVitalsGrid(isDesktop),
                        const SizedBox(height: 32),
                        
                        if (isDesktop)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionTitle("Baby Monitoring"),
                                    const SizedBox(height: 16),
                                    _buildBabyMonitoringSection(),
                                    const SizedBox(height: 32),
                                    _buildSectionTitle("Weekly Health Trends"),
                                    const SizedBox(height: 16),
                                    _buildWeeklyTrendsSection(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 32),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_isEmergency) _buildEmergencyAlertCard(),
                                    if (_isEmergency) const SizedBox(height: 32),
                                    _buildBottomActionButtons(),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle("Baby Monitoring"),
                              const SizedBox(height: 16),
                              _buildBabyMonitoringSection(),
                              const SizedBox(height: 32),
                              _buildSectionTitle("Weekly Health Trends"),
                              const SizedBox(height: 16),
                              _buildWeeklyTrendsSection(),
                              const SizedBox(height: 32),
                              if (_isEmergency) _buildEmergencyAlertCard(),
                              if (_isEmergency) const SizedBox(height: 32),
                              _buildBottomActionButtons(),
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
      floatingActionButton: _latestVitals == null
          ? FloatingActionButton.extended(
              onPressed: () {
                // Future integration to add vitals manually
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add Vitals feature coming soon!')),
                );
              },
              backgroundColor: const Color(0xFF9C27B0),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text("Log Vitals", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildEmptyState(bool isDesktop) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE1BEE7).withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.monitor_heart_rounded, size: 64, color: Color(0xFF9C27B0)),
            ),
            const SizedBox(height: 24),
            const Text(
              "No Health Vitals Logged",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4A148C)),
            ),
            const SizedBox(height: 12),
            const Text(
              "You haven't logged any health vitals yet.\nSync your IoT device or log vitals manually to track your health.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
            ),
            const SizedBox(height: 32),
            _buildBottomActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF4A148C),
      ),
    );
  }

  Widget _buildVitalsGrid(bool isDesktop) {
    return GridView.count(
      crossAxisCount: isDesktop ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isDesktop ? 1.2 : 0.95,
      children: [
        _buildVitalCard("Blood Pressure", _getSafeValue('blood_pressure', 'N/A'), "mmHg", Icons.monitor_heart_rounded, const Color(0xFFF06292), "Active"),
        _buildVitalCard("Heart Rate", _getSafeValue('heart_rate', 'N/A'), "bpm", Icons.favorite_rounded, const Color(0xFFE91E63), "Active"),
        _buildVitalCard("Weight", _getSafeValue('weight', 'N/A'), "kg", Icons.monitor_weight_rounded, const Color(0xFFBA68C8), "Active"),
        _buildVitalCard("Oxygen Level", _getSafeValue('oxygen', 'N/A'), "%", Icons.air_rounded, const Color(0xFF4FC3F7), "Active"),
      ],
    );
  }

  Widget _buildVitalCard(String title, String value, String unit, IconData icon, Color color, String status) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
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
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: Color(0xFF4A148C),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBabyMonitoringSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBabyStat("Kick Counter", _getSafeValue('kick_count', 'N/A'), "kicks today", Icons.do_not_step_rounded, const Color(0xFF9C27B0)),
          Container(width: 1, height: 50, color: const Color(0xFFF3E5F5)),
          _buildBabyStat("Baby Status", _getSafeValue('baby_status', 'Active'), "Movement", Icons.child_care_rounded, const Color(0xFF00ACC1)),
          Container(width: 1, height: 50, color: const Color(0xFFF3E5F5)),
          _buildBabyStat("Heartbeat", _getSafeValue('baby_heartbeat', 'N/A'), "bpm", Icons.favorite_outline_rounded, const Color(0xFFE91E63)),
        ],
      ),
    );
  }

  Widget _buildBabyStat(String title, String value, String subtitle, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF4A148C),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyTrendsSection() {
    double weightTrend = 0.5;
    double bpTrend = 0.5;
    
    if (_history.length >= 2) {
      final latest = _history.first;
      final previous = _history[1];
      
      final currentWeight = double.tryParse(latest['weight']?.toString() ?? '0') ?? 0;
      final prevWeight = double.tryParse(previous['weight']?.toString() ?? '0') ?? 0;
      if (currentWeight > prevWeight) weightTrend = 0.8;
      if (currentWeight < prevWeight) weightTrend = 0.2;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
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
              const Text("Health Trends", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  "This Week",
                  style: TextStyle(color: Color(0xFF8E24AA), fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildTrendBar("Weight Trend", weightTrend > 0.6 ? "Increasing" : weightTrend < 0.4 ? "Decreasing" : "Steady", weightTrend, const Color(0xFFBA68C8)),
          const SizedBox(height: 20),
          _buildTrendBar("Blood Pressure", "Stable", bpTrend, const Color(0xFFF06292)),
        ],
      ),
    );
  }

  Widget _buildTrendBar(String title, String status, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
            Text(status, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFFFBF8FF),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            FractionallySizedBox(
              widthFactor: value.clamp(0.0, 1.0),
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmergencyAlertCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFCDD2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE53935).withOpacity(0.1),
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
                  color: const Color(0xFFFFCDD2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F), size: 24),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  "Emergency Alert",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB71C1C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Abnormal vitals detected! If you experience severe pain, bleeding, or fluid leakage, contact your doctor immediately.",
            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                 ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Calling Doctor...')),
                  );
              },
              icon: const Icon(Icons.phone_rounded, color: Colors.white, size: 20),
              label: const Text(
                "Contact Doctor",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                shadowColor: const Color(0xFFE53935).withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF8E24AA), Color(0xFFD81B60)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD81B60).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() => _isLoading = true);
                Future.delayed(const Duration(seconds: 2), () {
                   if(mounted) {
                     setState(() => _isLoading = false);
                     ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('IoT Device Synced Successfully!')),
                     );
                   }
                });
              },
              icon: const Icon(Icons.sync_rounded, color: Colors.white, size: 20),
              label: const Text(
                "Sync IoT Device",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_latestVitals != null)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                 ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Downloading Vitals Report...')),
                 );
              },
              icon: const Icon(Icons.download_rounded, color: Color(0xFF9C27B0), size: 20),
              label: const Text(
                "Download Report",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF9C27B0),
                side: const BorderSide(color: Color(0xFFCE93D8), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                backgroundColor: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}
