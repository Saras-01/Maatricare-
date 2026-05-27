import 'package:flutter/material.dart';

class DeliveryManagementScreen extends StatefulWidget {
  const DeliveryManagementScreen({super.key});

  @override
  State<DeliveryManagementScreen> createState() => _DeliveryManagementScreenState();
}

class _DeliveryManagementScreenState extends State<DeliveryManagementScreen> {
  // Premium Admin Color Palette
  final Color primaryLavender = const Color(0xFF6A5ACD); // Slate Blue/Lavender
  final Color softLavender = const Color(0xFFE6E6FA);
  final Color backgroundLight = const Color(0xFFF8F9FE);
  final Color cardWhite = Colors.white;
  final Color textDark = const Color(0xFF2D3142);
  final Color textLight = const Color(0xFF9094A6);

  // Status Colors
  final Color highRiskColor = const Color(0xFFFF6B6B);
  final Color moderateRiskColor = const Color(0xFFFFA06B);
  final Color lowRiskColor = const Color(0xFF4ECDC4);

  // State
  bool _deliveryCompleted = false;
  String _selectedGender = 'Male';
  bool _isModeSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isDesktop = constraints.maxWidth > 900;
            return CustomScrollView(
              slivers: [
                _buildAppBar(isDesktop),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAnalyticsOverview(isDesktop),
                        const SizedBox(height: 32),
                        if (isDesktop)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildMotherRecordsTable(),
                                    const SizedBox(height: 32),
                                    _buildAIInsights(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 32),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    _buildModeSwitchingSection(),
                                    const SizedBox(height: 24),
                                    _buildDeliveryConfirmationCard(),
                                    const SizedBox(height: 24),
                                    _buildBabyRegistration(),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildModeSwitchingSection(),
                              const SizedBox(height: 24),
                              _buildDeliveryConfirmationCard(),
                              const SizedBox(height: 24),
                              _buildBabyRegistration(),
                              const SizedBox(height: 32),
                              _buildMotherRecordsTable(),
                              const SizedBox(height: 32),
                              _buildAIInsights(),
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
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryLavender.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.admin_panel_settings, color: primaryLavender),
          ),
          const SizedBox(width: 16),
          Text(
            'Delivery Management',
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
            width: 300,
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: cardWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: textLight.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: textLight),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search records...',
                      hintStyle: TextStyle(color: textLight),
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
              Icon(Icons.notifications_outlined, color: textDark, size: 28),
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 16),
        CircleAvatar(
          radius: 20,
          backgroundColor: primaryLavender.withOpacity(0.2),
          child: Text('AD', style: TextStyle(color: primaryLavender, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 24),
      ],
    );
  }

  Widget _buildAnalyticsOverview(bool isDesktop) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Active Pregnancies', '2,451', Icons.pregnant_woman, primaryLavender)),
        if (isDesktop) const SizedBox(width: 24) else const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Deliveries Completed', '842', Icons.child_care, lowRiskColor)),
        if (isDesktop) const SizedBox(width: 24) else const SizedBox(width: 12),
        Expanded(child: _buildStatCard('High-Risk Mothers', '124', Icons.warning_amber_rounded, highRiskColor)),
        if (isDesktop) const SizedBox(width: 24) else const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Babies Monitored', '835', Icons.monitor_heart, moderateRiskColor)),
      ],
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Icon(Icons.arrow_upward, color: lowRiskColor, size: 16),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            count,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotherRecordsTable() {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mother Records',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filter'),
                  style: TextButton.styleFrom(foregroundColor: primaryLavender),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: textLight,
                fontSize: 12,
              ),
              columns: const [
                DataColumn(label: Text('MOTHER NAME')),
                DataColumn(label: Text('PREGNANCY WEEK')),
                DataColumn(label: Text('DOCTOR ASSIGNED')),
                DataColumn(label: Text('DELIVERY STATUS')),
                DataColumn(label: Text('RISK LEVEL')),
                DataColumn(label: Text('LAST APPOINTMENT')),
              ],
              rows: [
                _buildDataRow('Emily Chen', 'Week 39', 'Dr. Sarah J.', 'Pending', 'Low', 'Oct 12, 2023'),
                _buildDataRow('Sarah Miller', 'Week 40', 'Dr. Marcus', 'In Progress', 'Moderate', 'Today'),
                _buildDataRow('Jessica Wong', 'Week 38', 'Dr. Sarah J.', 'Pending', 'High', 'Oct 10, 2023'),
                _buildDataRow('Amanda Smith', 'Delivered', 'Dr. Marcus', 'Completed', 'Low', 'Oct 05, 2023'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(String name, String week, String doctor, String status, String risk, String date) {
    Color riskColor = risk == 'High' ? highRiskColor : (risk == 'Moderate' ? moderateRiskColor : lowRiskColor);
    Color statusColor = status == 'Completed' ? lowRiskColor : (status == 'In Progress' ? moderateRiskColor : textLight);

    return DataRow(
      cells: [
        DataCell(Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: textDark))),
        DataCell(Text(week, style: TextStyle(color: textDark))),
        DataCell(Text(doctor, style: TextStyle(color: textLight))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: riskColor, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(risk, style: TextStyle(color: textDark)),
            ],
          ),
        ),
        DataCell(Text(date, style: TextStyle(color: textLight))),
      ],
    );
  }

  Widget _buildModeSwitchingSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryLavender.withOpacity(0.05), primaryLavender.withOpacity(0.15)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryLavender.withOpacity(0.3), width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.published_with_changes, color: primaryLavender),
              const SizedBox(width: 8),
              Text(
                'Application Mode Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryLavender,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildModeIcon('Mother Dashboard', Icons.pregnant_woman, !_isModeSwitched),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Divider(color: primaryLavender.withOpacity(0.3), thickness: 2),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _isModeSwitched ? lowRiskColor : primaryLavender,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),
              _buildModeIcon('Baby Monitoring', Icons.child_care, _isModeSwitched),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeIcon(String label, IconData icon, bool isActive) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isActive ? primaryLavender : cardWhite,
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [BoxShadow(color: primaryLavender.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]
                : [],
            border: isActive ? null : Border.all(color: textLight.withOpacity(0.2)),
          ),
          child: Icon(icon, color: isActive ? Colors.white : textLight, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? textDark : textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryConfirmationCard() {
    return Container(
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryLavender.withOpacity(0.1),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(color: primaryLavender.withOpacity(0.2), width: 2),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: highRiskColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.emergency, color: highRiskColor),
              ),
              const SizedBox(width: 12),
              Text(
                'Delivery Confirmation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Delivery Completed', style: TextStyle(color: textDark, fontWeight: FontWeight.bold)),
              Switch(
                value: _deliveryCompleted,
                onChanged: (val) {
                  setState(() {
                    _deliveryCompleted = val;
                  });
                },
                activeColor: primaryLavender,
              ),
            ],
          ),
          const Divider(height: 32),
          _buildTextField('Baby Birth Date', 'e.g. Oct 16, 2023', Icons.calendar_today),
          const SizedBox(height: 16),
          _buildTextField('Baby Weight (kg)', 'e.g. 3.2', Icons.monitor_weight_outlined),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Baby Gender', style: TextStyle(fontSize: 12, color: textLight, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildGenderChip('Male'),
                  const SizedBox(width: 8),
                  _buildGenderChip('Female'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _deliveryCompleted
                  ? () {
                      // Trigger mode switch logic
                      setState(() {
                        _isModeSwitched = true;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Delivery confirmed! Mode switched to Baby Monitoring.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryLavender,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text(
                'Confirm Delivery & Switch Mode',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderChip(String gender) {
    bool isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryLavender : backgroundLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? primaryLavender : textLight.withOpacity(0.2)),
        ),
        child: Text(
          gender,
          style: TextStyle(
            color: isSelected ? Colors.white : textLight,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildBabyRegistration() {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Baby Registration',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField('Baby Name', 'Enter baby name', Icons.child_care),
          const SizedBox(height: 16),
          _buildTextField('Assign Pediatrician', 'Select doctor', Icons.medical_services_outlined),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: lowRiskColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: lowRiskColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.vaccines, color: lowRiskColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vaccination Tracking', style: TextStyle(fontWeight: FontWeight.bold, color: textDark)),
                      Text('Will be initialized automatically upon confirmation.', style: TextStyle(fontSize: 12, color: textLight)),
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

  Widget _buildTextField(String label, String hint, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: textLight, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: textLight.withOpacity(0.5)),
            prefixIcon: Icon(icon, color: primaryLavender),
            filled: true,
            fillColor: backgroundLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryLavender),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAIInsights() {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.amber.shade600),
              const SizedBox(width: 8),
              Text(
                'AI Delivery Insights',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInsightItem(
            Icons.warning_rounded,
            'High-Risk Alert: Jessica Wong',
            'Gestational diabetes detected. Ensure NICU team is on standby for delivery.',
            highRiskColor,
          ),
          const Divider(height: 32),
          _buildInsightItem(
            Icons.analytics,
            'Delivery Analytics',
            '30% increase in expected deliveries for the upcoming week based on EDD predictions.',
            primaryLavender,
          ),
          const Divider(height: 32),
          _buildInsightItem(
            Icons.medical_information,
            'Emergency Recommendations',
            'Ensure O-negative blood stock is replenished for 2 upcoming high-risk cesareans.',
            moderateRiskColor,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(IconData icon, String title, String desc, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textDark, fontSize: 16)),
              const SizedBox(height: 4),
              Text(desc, style: TextStyle(color: textLight, height: 1.4)),
            ],
          ),
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
          color: textLight.withOpacity(0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}
