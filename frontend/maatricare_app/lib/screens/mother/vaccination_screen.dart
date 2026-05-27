import 'package:flutter/material.dart';

class VaccinationScreen extends StatefulWidget {
  const VaccinationScreen({Key? key}) : super(key: key);

  @override
  State<VaccinationScreen> createState() => _VaccinationScreenState();
}

class _VaccinationScreenState extends State<VaccinationScreen> {
  bool _smsReminder = true;
  bool _pushReminder = true;

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
                'Vaccination Tracker',
                style: TextStyle(
                  color: Color(0xFF4A148C),
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Track maternal and baby immunizations",
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
                  _buildHeroVaccinationCard(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Maternal Vaccination', Icons.pregnant_woman_rounded, Colors.purple),
                  const SizedBox(height: 16),
                  _buildMaternalTimeline(isDesktop),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Baby Vaccination Schedule', Icons.child_care_rounded, Colors.blue),
                  const SizedBox(height: 16),
                  _buildBabyVaccinationSection(isDesktop),
                  const SizedBox(height: 32),
                  _buildSectionTitle('AI Immunization Insights', Icons.auto_awesome, Colors.pink),
                  const SizedBox(height: 16),
                  _buildAIInsightsCard(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Records & Settings', Icons.settings_rounded, Colors.teal),
                  const SizedBox(height: 16),
                  _buildDownloadRecordCard(),
                  const SizedBox(height: 16),
                  _buildReminderSettings(),
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

  Widget _buildHeroVaccinationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8E24AA), Color(0xFFE91E63)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withOpacity(0.4),
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
                    Icon(Icons.vaccines_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Upcoming Vaccine',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    color: Color(0xFFE91E63),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Tetanus Toxoid (TT-2)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.calendar_today_rounded, color: Colors.white70, size: 18),
              SizedBox(width: 8),
              Text(
                'Due: Oct 25, 2023',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Overall Immunization Status',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  Text(
                    '60%',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: 0.6,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
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

  Widget _buildMaternalTimeline(bool isDesktop) {
    return Column(
      children: [
        _buildTimelineItem('Tetanus (TT-1)', 'Completed', 'Sep 10, 2023', true, Colors.green),
        const SizedBox(height: 12),
        _buildTimelineItem('Tetanus (TT-2)', 'Upcoming', 'Oct 25, 2023', false, Colors.orange),
        const SizedBox(height: 12),
        _buildTimelineItem('Flu Vaccine', 'Recommended', 'Nov 05, 2023', false, Colors.blue),
        const SizedBox(height: 12),
        _buildTimelineItem('COVID Booster', 'Optional', 'Dec 01, 2023', false, Colors.purple),
      ],
    );
  }

  Widget _buildTimelineItem(String name, String status, String date, bool completed, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: completed ? Border.all(color: Colors.green.withOpacity(0.3), width: 1.5) : null,
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
              color: completed ? Colors.green.withOpacity(0.1) : const Color(0xFFF3E5F5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              completed ? Icons.check_circle_rounded : Icons.vaccines_rounded,
              color: completed ? Colors.green : const Color(0xFF8E24AA),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D3142)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Due: $date',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF8F9BB3)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBabyVaccinationSection(bool isDesktop) {
    return GridView.count(
      crossAxisCount: isDesktop ? 2 : 1,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isDesktop ? 2.5 : 3.5,
      children: [
        _buildBabyVaccineCard('BCG', 'At Birth', 'Pending', Colors.red),
        _buildBabyVaccineCard('Hepatitis B', 'At Birth', 'Pending', Colors.orange),
        _buildBabyVaccineCard('Polio (OPV)', '6 Weeks', 'Upcoming', Colors.blue),
        _buildBabyVaccineCard('DPT (Diphtheria)', '6 Weeks', 'Upcoming', Colors.purple),
      ],
    );
  }

  Widget _buildBabyVaccineCard(String name, String schedule, String status, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
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
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.child_friendly_rounded, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2D3142)),
                ),
                const SizedBox(height: 4),
                Text(
                  schedule,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF8F9BB3)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: const TextStyle(color: Color(0xFF4B5563), fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsightsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF9C27B0).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9C27B0).withOpacity(0.05),
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
              Icon(Icons.psychology_rounded, color: Color(0xFF9C27B0)),
              SizedBox(width: 8),
              Text(
                'Smart Recommendations',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF9C27B0), fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Based on your pregnancy stage, completing the TT-2 vaccine is critical to prevent neonatal tetanus. Flu vaccination is highly recommended during this season to boost immunity.',
            style: TextStyle(color: Color(0xFF4B5563), fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),
          _buildInsightRow('Risk Alert', 'Flu season is approaching', Icons.warning_rounded, Colors.orange),
          const SizedBox(height: 8),
          _buildInsightRow('Reminder', 'Drink plenty of water post-vaccination', Icons.water_drop_rounded, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildInsightRow(String title, String desc, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          '$title: ',
          style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13),
        ),
        Expanded(
          child: Text(
            desc,
            style: const TextStyle(color: Color(0xFF4B5563), fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadRecordCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFD32F2F), size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vaccination Record (PDF)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D3142)),
                ),
                SizedBox(height: 4),
                Text(
                  'Official immunization certificate',
                  style: TextStyle(fontSize: 13, color: Color(0xFF8F9BB3)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.download_rounded, color: Color(0xFF4A148C)),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF3E5F5),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reminder Settings',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D3142)),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            value: _smsReminder,
            onChanged: (val) {
              setState(() {
                _smsReminder = val;
              });
            },
            title: const Text('SMS Reminders', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            subtitle: const Text('Get notified via text message', style: TextStyle(fontSize: 12, color: Colors.grey)),
            activeColor: const Color(0xFF6C63FF),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            value: _pushReminder,
            onChanged: (val) {
              setState(() {
                _pushReminder = val;
              });
            },
            title: const Text('Push Notifications', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            subtitle: const Text('App alerts for upcoming vaccines', style: TextStyle(fontSize: 12, color: Colors.grey)),
            activeColor: const Color(0xFF6C63FF),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
