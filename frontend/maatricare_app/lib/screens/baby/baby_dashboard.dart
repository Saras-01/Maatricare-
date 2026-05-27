import 'package:flutter/material.dart';

class BabyDashboard extends StatefulWidget {
  const BabyDashboard({super.key});

  @override
  State<BabyDashboard> createState() => _BabyDashboardState();
}

class _BabyDashboardState extends State<BabyDashboard> {
  // Premium Color Palette
  final Color babyBlue = const Color(0xFFB5EAEA);
  final Color lavender = const Color(0xFFE2D5F8);
  final Color softPink = const Color(0xFFFFDFD3);
  final Color textDark = const Color(0xFF2D3142);
  final Color textLight = const Color(0xFF9094A6);
  final Color cardWhite = Colors.white;
  final Color backgroundLight = const Color(0xFFF8F9FE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isDesktop = constraints.maxWidth > 800;
            return CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: isDesktop ? 1000 : 600),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeroCard(),
                            const SizedBox(height: 32),
                            _buildQuickActionsGrid(isDesktop),
                            const SizedBox(height: 32),
                            _buildSectionTitle('Growth Monitoring'),
                            const SizedBox(height: 16),
                            _buildGrowthMonitoring(),
                            const SizedBox(height: 32),
                            _buildSectionTitle('Feeding Schedule'),
                            const SizedBox(height: 16),
                            _buildFeedingSchedule(),
                            const SizedBox(height: 32),
                            _buildSectionTitle('Sleep Tracking'),
                            const SizedBox(height: 16),
                            _buildSleepTracking(),
                            const SizedBox(height: 32),
                            _buildSectionTitle('AI Baby Insights', icon: Icons.auto_awesome, iconColor: Colors.amber),
                            const SizedBox(height: 16),
                            _buildAIInsights(),
                            const SizedBox(height: 32),
                            _buildSectionTitle('Assigned Pediatrician'),
                            const SizedBox(height: 16),
                            _buildPediatricianSection(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
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

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: backgroundLight,
      elevation: 0,
      pinned: true,
      expandedHeight: 80.0,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: lavender,
                child: const Text('👶', style: TextStyle(fontSize: 30)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Baby Leo',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      '3 Months, 2 Weeks',
                      style: TextStyle(
                        fontSize: 14,
                        color: textLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: cardWhite,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: textLight.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Stack(
                    children: [
                      Icon(Icons.notifications_none_rounded, color: textDark, size: 28),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [lavender, babyBlue],
        ),
        boxShadow: [
          BoxShadow(
            color: lavender.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeroStat(Icons.scale_rounded, 'Weight', '6.2 kg'),
              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.5)),
              _buildHeroStat(Icons.height_rounded, 'Height', '61 cm'),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSmallHeroStat(Icons.bedtime_rounded, 'Sleep', '14h 30m'),
                _buildSmallHeroStat(Icons.restaurant_menu_rounded, 'Feeding', 'Every 3h'),
                _buildSmallHeroStat(Icons.vaccines_rounded, 'Vaccine', 'Up to date'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: textDark.withOpacity(0.8), size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: textDark.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallHeroStat(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: textDark.withOpacity(0.7), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: textDark,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: textDark.withOpacity(0.6),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid(bool isDesktop) {
    final actions = [
      {'icon': Icons.restaurant, 'label': 'Feeding', 'color': const Color(0xFFFFB7B2)},
      {'icon': Icons.bedtime, 'label': 'Sleep', 'color': const Color(0xFFB5EAEA)},
      {'icon': Icons.vaccines, 'label': 'Vaccine', 'color': const Color(0xFFE2D5F8)},
      {'icon': Icons.favorite, 'label': 'Health', 'color': const Color(0xFFFFDFD3)},
      {'icon': Icons.show_chart, 'label': 'Growth', 'color': const Color(0xFFC7CEEA)},
      {'icon': Icons.chat_bubble_outline, 'label': 'Doctor', 'color': const Color(0xFFF1F1F1)},
      {'icon': Icons.medical_services, 'label': 'SOS', 'color': const Color(0xFFFF9AA2)},
      {'icon': Icons.auto_awesome, 'label': 'AI Insights', 'color': const Color(0xFFFFE1A8)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 6 : 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _buildActionCard(
          action['icon'] as IconData,
          action['label'] as String,
          action['color'] as Color,
        );
      },
    );
  }

  Widget _buildActionCard(IconData icon, String label, Color bgColor) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: bgColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: bgColor.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: _darkenColor(bgColor), size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textDark,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _darkenColor(Color c, [int percent = 40]) {
    assert(1 <= percent && percent <= 100);
    var f = 1 - percent / 100;
    return Color.fromARGB(
      c.alpha,
      (c.red * f).round(),
      (c.green * f).round(),
      (c.blue * f).round(),
    );
  }

  Widget _buildSectionTitle(String title, {IconData? icon, Color? iconColor}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: iconColor ?? textDark, size: 24),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textDark,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildGrowthMonitoring() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Progress',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: textLight,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: softPink.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '+0.2 kg this week',
                  style: TextStyle(
                    color: _darkenColor(softPink),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBarChart(40, 'W1'),
              _buildBarChart(55, 'W2'),
              _buildBarChart(65, 'W3'),
              _buildBarChart(70, 'W4', isHighlighted: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(double height, String label, {bool isHighlighted = false}) {
    return Column(
      children: [
        Container(
          width: 40,
          height: height,
          decoration: BoxDecoration(
            color: isHighlighted ? babyBlue : babyBlue.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            boxShadow: isHighlighted
                ? [
                    BoxShadow(
                      color: babyBlue.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isHighlighted ? textDark : textLight,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFeedingSchedule() {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTimelineItem(
            time: '08:00 AM',
            title: 'Morning Milk',
            subtitle: '120 ml Formula',
            icon: Icons.water_drop,
            color: babyBlue,
            isCompleted: true,
          ),
          _buildTimelineItem(
            time: '11:00 AM',
            title: 'Mid-Day Feed',
            subtitle: 'Breastmilk (15 mins)',
            icon: Icons.child_care,
            color: lavender,
            isCompleted: true,
          ),
          _buildTimelineItem(
            time: '02:00 PM',
            title: 'Afternoon Milk',
            subtitle: 'Upcoming in 45 mins',
            icon: Icons.access_time_rounded,
            color: Colors.amber.shade200,
            isCompleted: false,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String time,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isCompleted,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isCompleted ? color : Colors.grey.shade100,
                shape: BoxShape.circle,
                boxShadow: isCompleted
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                icon,
                color: isCompleted ? _darkenColor(color) : textLight,
                size: 20,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? color.withOpacity(0.5) : Colors.grey.shade200,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      color: isCompleted ? textLight : _darkenColor(color),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: textLight,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSleepTracking() {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [lavender, const Color(0xFFC7CEEA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: lavender.withOpacity(0.5),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '14h\n30m',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSleepStat('Night Sleep', '10h 15m', Icons.nights_stay),
                const SizedBox(height: 12),
                _buildSleepStat('Day Naps', '4h 15m', Icons.wb_sunny),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: babyBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: _darkenColor(babyBlue), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Sleep target met! 🌟',
                        style: TextStyle(
                          color: _darkenColor(babyBlue),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
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

  Widget _buildSleepStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: textLight, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(color: textLight, fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildAIInsights() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.amber.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildInsightRow(
            icon: Icons.trending_up_rounded,
            title: 'Growth Projection',
            desc: 'Leo is in the 85th percentile for weight. Keep up the good feeding schedule!',
            color: Colors.green,
          ),
          const Divider(height: 24),
          _buildInsightRow(
            icon: Icons.restaurant,
            title: 'Nutrition Insight',
            desc: 'Consider introducing solid foods in 2 weeks based on developmental signs.',
            color: Colors.orange,
          ),
          const Divider(height: 24),
          _buildInsightRow(
            icon: Icons.sentiment_very_satisfied,
            title: 'Development Milestone',
            desc: 'Leo might start rolling over soon. Ensure safe sleep environments.',
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
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
              Text(
                title,
                style: TextStyle(
                  color: textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: TextStyle(
                  color: textLight,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPediatricianSection() {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: softPink,
              image: const DecorationImage(
                image: NetworkImage('https://i.pravatar.cc/150?img=32'),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: softPink.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dr. Sarah Jenkins',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                Text(
                  'Pediatrician • Next appt: Oct 12',
                  style: TextStyle(
                    fontSize: 13,
                    color: textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [lavender, babyBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: babyBlue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Chat',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
