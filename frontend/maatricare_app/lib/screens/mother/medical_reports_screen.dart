import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/app_state.dart';

class MedicalReportsScreen extends StatefulWidget {
  const MedicalReportsScreen({super.key});

  @override
  State<MedicalReportsScreen> createState() => _MedicalReportsScreenState();
}

class _MedicalReportsScreenState extends State<MedicalReportsScreen> {
  bool _isLoading = true;
  List<dynamic> _reports = [];

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    setState(() => _isLoading = true);
    try {
      final userName = AppState.userName;
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/reports/mother/$userName/'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _reports = data is List ? data : [];
        });
      } else {
        setState(() {
          _reports = [];
        });
      }
    } catch (e) {
      setState(() {
        _reports = [];
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Map<String, String> _generateDynamicInsight() {
    if (_reports.isEmpty) {
      return {
        "risk": "Low",
        "title": "Awaiting Initial Reports",
        "description": "Upload your first medical report to receive AI-powered health insights.",
        "color": "0xFF4CAF50"
      };
    }

    final latestReport = _reports.first;
    final status = latestReport['status'] ?? 'Pending Review';
    final type = latestReport['type'] ?? 'Report';

    if (status == 'Requires Attention') {
      return {
        "risk": "High",
        "title": "Attention Needed: $type",
        "description": "AI detected anomalies in your latest $type. Please consult your assigned doctor immediately.",
        "color": "0xFFE53935"
      };
    } else if (status == 'Pending Review') {
      return {
        "risk": "Evaluating",
        "title": "Analyzing $type",
        "description": "Your $type is currently being evaluated by our AI and your doctor. Check back soon.",
        "color": "0xFFF57C00"
      };
    } else {
      return {
        "risk": "Low",
        "title": "$type Looks Normal",
        "description": "AI detected all parameters within normal range in your latest $type. Continue with your regular routine.",
        "color": "0xFF4CAF50"
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalReports = _reports.length;
    int pendingReview = _reports.where((r) => r['status'] == 'Pending Review').length;
    int reviewed = _reports.where((r) => r['status'] == 'Reviewed').length;
    int upcomingScan = _reports.where((r) => r['status'] == 'Upcoming Scan').length;

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
              "Medical Reports",
              style: TextStyle(
                color: Color(0xFF4A148C),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              "View and manage your medical records",
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
                return SingleChildScrollView(
                  padding: EdgeInsets.all(isDesktop ? 40 : 20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryCards(isDesktop, totalReports, pendingReview, reviewed, upcomingScan),
                          const SizedBox(height: 32),
                          if (isDesktop)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: _buildRecentReportsList(),
                                ),
                                const SizedBox(width: 32),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      _buildAIInsightsCard(),
                                      const SizedBox(height: 32),
                                      _buildUploadSection(),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                _buildAIInsightsCard(),
                                const SizedBox(height: 32),
                                _buildRecentReportsList(),
                                const SizedBox(height: 32),
                                _buildUploadSection(),
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
    );
  }

  Widget _buildSummaryCards(bool isDesktop, int total, int pending, int reviewed, int upcoming) {
    return GridView.count(
      crossAxisCount: isDesktop ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isDesktop ? 1.5 : 1.2,
      children: [
        _buildSummaryCard("Total Reports", "$total", Icons.folder_rounded, const Color(0xFF9C27B0)),
        _buildSummaryCard("Pending Review", "$pending", Icons.pending_actions_rounded, const Color(0xFFF57C00)),
        _buildSummaryCard("Reviewed", "$reviewed", Icons.fact_check_rounded, const Color(0xFF43A047)),
        _buildSummaryCard("Upcoming Scan", "$upcoming", Icons.event_rounded, const Color(0xFF039BE5)),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        mainAxisAlignment: MainAxisAlignment.center,
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
              Text(
                count,
                style: const TextStyle(
                  color: Color(0xFF4A148C),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsightsCard() {
    final insight = _generateDynamicInsight();
    final riskColor = Color(int.parse(insight["color"]!));

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8E24AA), Color(0xFFD81B60)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD81B60).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                "AI Health Insights",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: riskColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "Status: ${insight["risk"]}",
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            insight["title"]!,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            insight["description"]!,
            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReportsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent Reports",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4A148C)),
        ),
        const SizedBox(height: 16),
        if (_reports.isEmpty)
          _buildEmptyState()
        else
          ..._reports.map((report) {
            Color statusColor = const Color(0xFF43A047); // default reviewed green
            if (report['status'] == 'Pending Review') {
              statusColor = const Color(0xFFF57C00); // orange
            } else if (report['status'] == 'Requires Attention') {
              statusColor = const Color(0xFFE53935); // red
            }
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildReportCard(
                report['title'] ?? report['type'] ?? 'Medical Report',
                report['doctor'] ?? (AppState.selectedDoctor != null ? AppState.selectedDoctor!['name'] : 'Assigned Doctor'),
                report['hospital'] ?? 'MaatriCare Center',
                report['date'] ?? 'N/A',
                report['status'] ?? 'Reviewed',
                Icons.image_rounded, // default icon
                statusColor,
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE1BEE7).withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.folder_off_rounded, size: 64, color: Color(0xFF9C27B0)),
            ),
            const SizedBox(height: 24),
            const Text(
              "No Reports Uploaded",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4A148C)),
            ),
            const SizedBox(height: 12),
            const Text(
              "Upload your first medical report to securely store it and get AI insights.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(String title, String doctor, String hospital, String date, String status, IconData fileIcon, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(fileIcon, color: const Color(0xFF9C27B0), size: 32),
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
                            title,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "$doctor • $hospital",
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF3E5F5)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text("Download"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF9C27B0),
                    side: const BorderSide(color: Color(0xFFCE93D8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.visibility_rounded, size: 18),
                  label: const Text("View Report"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C27B0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Upload Reports",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4A148C)),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFCE93D8), width: 2),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF3E5F5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cloud_upload_rounded, color: Color(0xFF9C27B0), size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                "Drag & Drop your files here",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              const Text(
                "PDF, JPG, PNG up to 10MB",
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Upload integration coming soon!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3E5F5),
                  foregroundColor: const Color(0xFF9C27B0),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text("Browse Files", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
