import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import '../../core/app_state.dart';

class TelemedicineScreen extends StatefulWidget {
  const TelemedicineScreen({Key? key}) : super(key: key);

  @override
  State<TelemedicineScreen> createState() => _TelemedicineScreenState();
}

class _TelemedicineScreenState extends State<TelemedicineScreen> {
  final _jitsiMeetPlugin = JitsiMeet();
  bool _isCallActive = false;
  late String _doctorName;
  late String _userName;

  @override
  void initState() {
    super.initState();
    final doctor = AppState.selectedDoctor;
    _doctorName = doctor != null ? doctor['name'] : 'Dr. Sarah Jenkins';
    _userName = AppState.userName.isNotEmpty ? AppState.userName : 'Mother';
  }

  void _joinMeeting() async {
    setState(() => _isCallActive = true);
    
    var options = JitsiMeetConferenceOptions(
      room: 'MaatriCare-Consultation-${DateTime.now().millisecondsSinceEpoch}',
      serverURL: "https://meet.jit.si",
      configOverrides: {
        "startWithAudioMuted": false,
        "startWithVideoMuted": false,
        "subject": "Consultation: $_doctorName"
      },
      userInfo: JitsiMeetUserInfo(
          displayName: _userName,
          email: "$_userName@maatricare.app",
      ),
    );

    try {
      await _jitsiMeetPlugin.join(options);
      setState(() => _isCallActive = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join consultation: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isCallActive = false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5FA), // Soft lavender background
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2D3142), size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Telemedicine',
                style: TextStyle(
                  color: Color(0xFF4A148C),
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Virtual maternal healthcare consultation",
                style: TextStyle(
                  color: Color(0xFF8F9BB3),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUpcomingConsultationCard(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Video Consultation Features', Icons.featured_play_list_rounded, Colors.purple),
                  const SizedBox(height: 16),
                  _buildFeaturesSection(isDesktop),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Consultation History', Icons.history_rounded, Colors.blue),
                  const SizedBox(height: 16),
                  _buildConsultationHistory(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('AI Smart Assistant', Icons.auto_awesome, Colors.pink),
                  const SizedBox(height: 16),
                  _buildAIAssistantSection(),
                  const SizedBox(height: 32),
                  _buildEmergencyAlert(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3142),
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingConsultationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF9C27B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.videocam_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Upcoming Call',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Row(
                children: [
                  Icon(Icons.timer_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Starts in 15:00',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  color: Colors.white.withOpacity(0.9),
                ),
                child: const Icon(Icons.person, color: Color(0xFF6C63FF), size: 40),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _doctorName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Senior Gynecologist',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Today, 10:30 AM - 11:00 AM',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCallActive ? null : _joinMeeting,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF6C63FF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_isCallActive ? Icons.hourglass_empty : Icons.video_call, color: const Color(0xFF6C63FF)),
                    const SizedBox(width: 8),
                    Text(
                      _isCallActive ? 'Connecting...' : 'Join Call Now',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(bool isDesktop) {
    return GridView.count(
      crossAxisCount: isDesktop ? 2 : 1,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isDesktop ? 2.5 : 3.5,
      children: [
        _buildFeatureCard('HD Video Consultation', 'Crystal clear video for accurate visual checkups.', Icons.hd_rounded, const Color(0xFF00B4D8)),
        _buildFeatureCard('AI Voice Notes', 'Automated transcription and notes of your session.', Icons.graphic_eq_rounded, const Color(0xFF9D4EDD)),
        _buildFeatureCard('Live Prescription', 'Receive digital prescriptions instantly during the call.', Icons.medical_information_rounded, const Color(0xFF43AA8B)),
        _buildFeatureCard('Real-time Monitoring', 'Doctor can view your latest health vitals live.', Icons.monitor_heart_rounded, const Color(0xFFF94144)),
      ],
    );
  }

  Widget _buildFeatureCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8F9BB3),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationHistory() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHistoryItem(
            date: 'Oct 12, 2023',
            doctor: 'Dr. Sarah Jenkins',
            duration: '30 mins',
            summary: 'Routine 2nd trimester checkup. Everything looks normal.',
          ),
          const Divider(height: 32),
          _buildHistoryItem(
            date: 'Sep 15, 2023',
            doctor: 'Dr. Michael Chen',
            duration: '15 mins',
            summary: 'Discussed mild nausea symptoms and prescribed supplements.',
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem({required String date, required String doctor, required String duration, required String summary}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E5F5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.assignment_rounded, color: Color(0xFF8E24AA)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    doctor,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D3142)),
                  ),
                  Text(
                    date,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF8F9BB3), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Duration: $duration',
                style: const TextStyle(fontSize: 13, color: Color(0xFF8F9BB3)),
              ),
              const SizedBox(height: 8),
              Text(
                summary,
                style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_rounded, size: 16),
                label: const Text('Download Prescription'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6C63FF),
                  side: const BorderSide(color: Color(0xFF6C63FF)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAIAssistantSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE91E63).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.smart_toy_rounded, color: Color(0xFFE91E63)),
              SizedBox(width: 8),
              Text(
                'Insights from your last consultation',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE91E63),
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Based on your last session, it is recommended to increase your daily water intake to 2.5L and continue your prenatal vitamins.',
            style: TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          _buildAIActionRow('Suggested Action', 'Schedule ultrasound next week', Icons.calendar_today_rounded, Colors.orange),
          const SizedBox(height: 12),
          _buildAIActionRow('Medication Reminder', 'Folic Acid 400mcg daily', Icons.medication_rounded, Colors.teal),
        ],
      ),
    );
  }

  Widget _buildAIActionRow(String title, String desc, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Color(0xFF8F9BB3), fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(fontSize: 14, color: Color(0xFF2D3142), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyAlert() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFF5252).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5252).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFF5252).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emergency_rounded, color: Color(0xFFFF5252), size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'Emergency Telemedicine Alert',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD32F2F),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Connect instantly with an on-call emergency doctor. Use only for urgent maternal or fetal health concerns.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFB71C1C),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.video_call_rounded, color: Colors.white),
              label: const Text(
                'Connect Instantly',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5252),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: const Color(0xFFFF5252).withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
