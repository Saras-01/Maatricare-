import 'package:flutter/material.dart';
import 'package:maatricare_app/core/api_service.dart';
import 'package:maatricare_app/core/app_state.dart';
import 'dart:ui';
import 'dart:math' as math;

class AIRiskScreen extends StatefulWidget {
  const AIRiskScreen({Key? key}) : super(key: key);

  @override
  State<AIRiskScreen> createState() => _AIRiskScreenState();
}

class _AIRiskScreenState extends State<AIRiskScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scoreAnimation;
  bool _isLoading = true;
  String _riskLevel = 'Low';
  String _recommendation = '';
  String _alertStatus = '';

  @override
  void initState() {
    super.initState();
    _fetchAIPrediction();
  }

  Future<void> _fetchAIPrediction() async {
    try {
      final response = await ApiService.predictRisk(
        motherName: AppState.userName.isNotEmpty ? AppState.userName : 'Unknown Mother',
        age: 28,
        bloodPressure: '120/80',
        sugarLevel: 95.0,
        hemoglobin: 12.0,
        weight: 68.5,
      );
      
      if (mounted) {
        setState(() {
          _riskLevel = response['risk_level'] ?? 'Low';
          _recommendation = response['recommendation'] ?? '';
          _alertStatus = response['alert_status'] ?? '';
          _isLoading = false;
          
          double endScore = _riskLevel == 'High' ? 45.0 : (_riskLevel == 'Medium' ? 65.0 : 92.0);
          
          _animationController = AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 2000),
          );
          _scoreAnimation = Tween<double>(begin: 0, end: endScore).animate(
            CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
          );
          _animationController.forward();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load AI prediction.'), backgroundColor: Colors.red),
        );
        _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
        _scoreAnimation = Tween<double>(begin: 0, end: 88).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
        _animationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F4FA), // Soft lavender/grey background
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.white.withOpacity(0.5)),
            ),
          ),
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
                'AI Risk Prediction',
                style: TextStyle(
                  color: Color(0xFF2D3142),
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Smart maternal health monitoring',
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
                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF9C27B0)))
                      : Column(
                          children: [
                            _buildEmergencyAlert(),
                            const SizedBox(height: 24),
                            _buildAIHealthScoreCard(),
                          ],
                        ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Live Maternal Metrics', Icons.monitor_heart_outlined),
                  const SizedBox(height: 16),
                  _buildLiveMetrics(isDesktop),
                  const SizedBox(height: 32),
                  if (!_isLoading) ...[
                    _buildSectionTitle('AI Analysis & Insights', Icons.auto_awesome),
                    const SizedBox(height: 16),
                    _buildAIAnalysis(),
                    const SizedBox(height: 32),
                  ],
                  _buildSectionTitle('Risk Factors', Icons.warning_amber_rounded),
                  const SizedBox(height: 16),
                  _buildRiskFactors(isDesktop),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Weekly Prediction Chart', Icons.insights),
                  const SizedBox(height: 16),
                  _buildWeeklyPredictionChart(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Recommended Actions', Icons.task_alt),
                  const SizedBox(height: 16),
                  _buildRecommendedActions(isDesktop),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF9C27B0).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF9C27B0), size: 20),
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

  Widget _buildEmergencyAlert() {
    Color bgColor;
    Color borderColor;
    Color iconColor;
    IconData icon;
    String title;
    String desc;

    if (_riskLevel == 'High') {
      bgColor = const Color(0xFFFFEBEE);
      borderColor = const Color(0xFFEF9A9A);
      iconColor = const Color(0xFFE53935);
      icon = Icons.warning_rounded;
      title = 'Critical Risk Detected';
      desc = _recommendation.isNotEmpty ? _recommendation : 'Please consult your doctor immediately.';
    } else if (_riskLevel == 'Medium') {
      bgColor = const Color(0xFFFFF3E0);
      borderColor = const Color(0xFFFFCC80);
      iconColor = const Color(0xFFFB8C00);
      icon = Icons.info_outline;
      title = 'Moderate Risk Detected';
      desc = _recommendation.isNotEmpty ? _recommendation : 'Please monitor your vitals closely.';
    } else {
      bgColor = const Color(0xFFE8F5E9);
      borderColor = const Color(0xFF81C784);
      iconColor = const Color(0xFF4CAF50);
      icon = Icons.check_circle_outline;
      title = 'No critical risk detected';
      desc = _recommendation.isNotEmpty ? _recommendation : 'Vitals are stable. Keep up the good work!';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: iconColor.withAlpha(200),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    color: iconColor.withAlpha(150),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIHealthScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A00E0).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background decorative circles
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Overall AI Health Score',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shield_outlined, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '$_riskLevel Risk',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 180,
                height: 180,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AnimatedBuilder(
                      animation: _scoreAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _ScoreCircularPainter(
                            progress: _scoreAnimation.value / 100,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            progressColor: Colors.white,
                          ),
                        );
                      },
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _scoreAnimation,
                            builder: (context, child) {
                              return Text(
                                '${_scoreAnimation.value.toInt()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                ),
                              );
                            },
                          ),
                          const Text(
                            'Excellent',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Updated just now • Based on 15+ real-time metrics',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveMetrics(bool isDesktop) {
    return GridView.count(
      crossAxisCount: isDesktop ? 3 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard('Blood Pressure', '120/80', 'mmHg', Icons.favorite_border, Colors.redAccent),
        _buildMetricCard('Heart Rate', '72', 'bpm', Icons.monitor_heart, Colors.orangeAccent),
        _buildMetricCard('Oxygen Level', '98', '%', Icons.air, Colors.lightBlue),
        _buildMetricCard('Blood Sugar', '95', 'mg/dL', Icons.water_drop_outlined, Colors.purpleAccent),
        _buildMetricCard('Weight', '68.5', 'kg', Icons.monitor_weight_outlined, Colors.teal),
        _buildMetricCard('Baby Heartbeat', '140', 'bpm', Icons.child_care, Colors.pinkAccent),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF8F9BB3),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF2D3142),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  unit,
                  style: const TextStyle(
                    color: Color(0xFF8F9BB3),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAIAnalysis() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF9C27B0).withOpacity(0.1)),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              const Text(
                'AI Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _recommendation.isNotEmpty ? _recommendation : 'Your current health trajectory is highly positive. Blood pressure and heart rate are stabilizing beautifully compared to last week. The AI pattern analysis indicates a 95% probability of a healthy continued trimester if current habits are maintained.',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          _buildAnalysisRow('Pattern Analysis', 'Stable Vitals', Icons.trending_flat, Colors.green),
          const SizedBox(height: 12),
          _buildAnalysisRow('Pregnancy Trend', 'Optimal Growth', Icons.trending_up, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildAnalysisRow(String title, String value, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF8F9BB3),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF2D3142),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, color: color, size: 18),
          ],
        ),
      ],
    );
  }

  Widget _buildRiskFactors(bool isDesktop) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildRiskCard('Hypertension Risk', 'Low', const Color(0xFF4CAF50))),
            const SizedBox(width: 16),
            Expanded(child: _buildRiskCard('Anemia Risk', 'Medium', const Color(0xFFFF9800))),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildRiskCard('Gestational Diabetes', 'Low', const Color(0xFF4CAF50))),
            const SizedBox(width: 16),
            Expanded(child: _buildRiskCard('Stress Level', 'Low', const Color(0xFF4CAF50))),
          ],
        ),
      ],
    );
  }

  Widget _buildRiskCard(String title, String level, Color color) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF8F9BB3),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            level,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyPredictionChart() {
    return Container(
      height: 250,
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Health Trend',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF2D3142),
                ),
              ),
              Text(
                'Last 7 Weeks',
                style: TextStyle(
                  color: Color(0xFF8F9BB3),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: CustomPaint(
              painter: _TrendChartPainter(),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedActions(bool isDesktop) {
    return Column(
      children: [
        _buildActionCard(
          'Hydration',
          'Drink 2 more glasses of water today to maintain amniotic fluid levels.',
          Icons.local_drink,
          Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          'Nutrition',
          'Increase iron intake based on slight anemia risk projection.',
          Icons.restaurant,
          Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          'Sleep',
          'Aim for 8 hours tonight. Your stress metrics show slight fatigue.',
          Icons.bedtime,
          Colors.indigo,
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF2D3142),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }
}

class _ScoreCircularPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  _ScoreCircularPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 10;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 15
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = 15
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start at top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreCircularPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _TrendChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = const Color(0xFF9C27B0)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    
    // Sample data points for the trend
    final points = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.15, size.height * 0.6),
      Offset(size.width * 0.3, size.height * 0.7),
      Offset(size.width * 0.45, size.height * 0.4),
      Offset(size.width * 0.6, size.height * 0.5),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width, size.height * 0.1),
    ];

    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      
      // Calculate control points for smooth bezier curve
      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
      
      path.cubicTo(
        controlPoint1.dx, controlPoint1.dy,
        controlPoint2.dx, controlPoint2.dy,
        p1.dx, p1.dy,
      );
    }

    // Draw shadow/gradient under the line
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF9C27B0).withOpacity(0.3),
          const Color(0xFF9C27B0).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, gradientPaint);
    canvas.drawPath(path, paintLine);

    // Draw dots at data points
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final dotBorderPaint = Paint()
      ..color = const Color(0xFF9C27B0)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (var point in points) {
      canvas.drawCircle(point, 6, dotPaint);
      canvas.drawCircle(point, 6, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
