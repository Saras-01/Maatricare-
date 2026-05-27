import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import '../../core/app_state.dart';

class BirthCertificateScreen extends StatefulWidget {
  const BirthCertificateScreen({super.key});

  @override
  State<BirthCertificateScreen> createState() => _BirthCertificateScreenState();
}

class _BirthCertificateScreenState extends State<BirthCertificateScreen> {
  // Premium Theme Colors
  final Color primaryLavender = const Color(0xFF6B4E71); 
  final Color softLavender = const Color(0xFFF3E5F5);
  final Color goldAccent = const Color(0xFFD4AF37); 
  final Color backgroundLight = const Color(0xFFFAFAFC);
  final Color textDark = const Color(0xFF2C3E50);
  final Color textLight = const Color(0xFF7F8C8D);

  bool _isLoading = true;
  bool _isUnlocked = false;
  Map<String, dynamic>? _certData;
  String _generatedCertId = '';

  @override
  void initState() {
    super.initState();
    _generatedCertId = _generateCertId();
    _fetchCertificateData();
  }

  String _generateCertId() {
    final random = Random();
    final year = DateTime.now().year;
    final num = random.nextInt(900000) + 100000;
    return 'B-$year-$num';
  }

  Future<void> _fetchCertificateData() async {
    setState(() => _isLoading = true);
    try {
      final userName = AppState.userName.isNotEmpty ? AppState.userName : 'Mother';
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/baby/certificate/$userName/')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _certData = data;
            _isUnlocked = data['delivery_status']?.toString().toLowerCase() == 'completed';
            if (_certData != null && _certData!['certificate_id'] != null) {
              _generatedCertId = _certData!['certificate_id'];
            }
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _certData = null;
            _isUnlocked = false;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _certData = null;
          _isUnlocked = false;
          _isLoading = false;
        });
      }
    }
  }

  String _getVal(String key, String fallback) {
    if (_certData == null) return fallback;
    return _certData![key]?.toString() ?? fallback;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: _isLoading 
          ? Center(child: CircularProgressIndicator(color: primaryLavender))
          : LayoutBuilder(
              builder: (context, constraints) {
                bool isDesktop = constraints.maxWidth > 900;
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40.0 : 20.0, vertical: 24.0),
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: _buildCertificateArea(context)),
                            const SizedBox(width: 40),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  _buildActionButtons(),
                                  const SizedBox(height: 24),
                                  _buildSecuritySection(),
                                  const SizedBox(height: 24),
                                  _buildAIInsights(),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildCertificateArea(context),
                            const SizedBox(height: 32),
                            _buildActionButtons(),
                            const SizedBox(height: 24),
                            _buildSecuritySection(),
                            const SizedBox(height: 24),
                            _buildAIInsights(),
                            const SizedBox(height: 40),
                          ],
                        ),
                );
              },
            ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundLight,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: primaryLavender.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(Icons.arrow_back_ios_new, color: primaryLavender, size: 18),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        children: [
          Text(
            'Digital Birth Certificate',
            style: TextStyle(
              color: textDark,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            'Secure baby birth registration',
            style: TextStyle(
              color: primaryLavender,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateArea(BuildContext context) {
    return Stack(
      children: [
        _buildCertificateCard(context),
        if (!_isUnlocked)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: Colors.white.withOpacity(0.4),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: primaryLavender.withOpacity(0.2),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: softLavender,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.lock_rounded, size: 64, color: primaryLavender),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Certificate Locked",
                            style: TextStyle(color: textDark, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "This birth certificate will automatically unlock\nonce your delivery status is marked as 'Completed'.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54, fontSize: 14, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCertificateCard(BuildContext context) {
    // Dynamic values
    final childName = _getVal('baby_name', 'Pending...');
    final dob = _getVal('birth_date', 'Pending...');
    final time = _getVal('birth_time', 'Pending...');
    final weight = _getVal('birth_weight', 'Pending...');
    final gender = _getVal('gender', 'Pending...');
    final motherName = _getVal('mother_name', AppState.userName.isNotEmpty ? AppState.userName : 'Pending...');
    final fatherName = _getVal('father_name', 'Pending...');
    final hospital = _getVal('hospital_name', 'MaatriCare Maternity Center');
    final doctor = _getVal('doctor_name', AppState.selectedDoctor != null ? AppState.selectedDoctor!['name'] : 'Assigned Doctor');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryLavender.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
        border: Border.all(color: goldAccent.withOpacity(0.5), width: 2),
      ),
      child: Stack(
        children: [
          // Background Watermark Logo
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: Icon(Icons.account_balance, size: 300, color: primaryLavender),
            ),
          ),
          // Certificate Content
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.verified_user, color: goldAccent, size: 40),
                    Column(
                      children: [
                        Text(
                          'GOVERNMENT OF HEALTH',
                          style: TextStyle(color: textDark, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
                        ),
                        Text(
                          'CERTIFICATE OF BIRTH',
                          style: TextStyle(color: primaryLavender, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1),
                        ),
                      ],
                    ),
                    Icon(Icons.health_and_safety, color: primaryLavender, size: 40),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(thickness: 2),
                const SizedBox(height: 24),
                Text(
                  'This is to certify that the following information has been taken from the original record of birth.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textLight, fontSize: 13, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 32),
                _buildCertificateDetailRow('Name of Child', childName),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildCertificateDetailRow('Date of Birth', dob)),
                    Expanded(child: _buildCertificateDetailRow('Time of Birth', time)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildCertificateDetailRow('Birth Weight', weight)),
                    Expanded(child: _buildCertificateDetailRow('Gender', gender)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildCertificateDetailRow('Mother\'s Name', motherName),
                const SizedBox(height: 16),
                _buildCertificateDetailRow('Father\'s Name', fatherName),
                const SizedBox(height: 16),
                _buildCertificateDetailRow('Place of Birth', hospital),
                const SizedBox(height: 16),
                _buildCertificateDetailRow('Attending Doctor', doctor),
                const SizedBox(height: 32),
                const Divider(thickness: 2),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildQRCode(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Certificate ID: $_generatedCertId', style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('Issued: ${DateTime.now().toLocal().toString().split(' ')[0]}', style: TextStyle(color: textLight, fontSize: 12)),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: goldAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: goldAccent),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.verified, color: goldAccent, size: 16),
                              const SizedBox(width: 8),
                              Text('Verified Digital Record', style: TextStyle(color: goldAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: TextStyle(color: textLight, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: textDark, fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildQRCode() {
    return Container(
      width: 100,
      height: 100,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: primaryLavender, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_2, size: 64, color: primaryLavender),
          Text(_isUnlocked ? 'SCAN' : 'LOCKED', style: TextStyle(color: primaryLavender, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: primaryLavender.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          _buildActionButton(Icons.picture_as_pdf, 'Download PDF', primaryLavender, true),
          const SizedBox(height: 16),
          _buildActionButton(Icons.share, 'Share Certificate', primaryLavender, false),
          const SizedBox(height: 16),
          _buildActionButton(Icons.print, 'Print Certificate', primaryLavender, false),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, bool isPrimary) {
    return SizedBox(
      width: double.infinity,
      child: isPrimary
          ? ElevatedButton.icon(
              onPressed: _isUnlocked ? () {} : null,
              icon: Icon(icon, color: Colors.white),
              label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                disabledBackgroundColor: Colors.grey.shade400,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            )
          : OutlinedButton.icon(
              onPressed: _isUnlocked ? () {} : null,
              icon: Icon(icon, color: _isUnlocked ? color : Colors.grey),
              label: Text(label, style: TextStyle(color: _isUnlocked ? color : Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: _isUnlocked ? color.withOpacity(0.5) : Colors.grey.withOpacity(0.3)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
    );
  }

  Widget _buildSecuritySection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: primaryLavender.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Document Security', style: TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildSecurityBadge(Icons.link, 'Blockchain Secured', 'Tamper-proof distributed ledger record', const Color(0xFF2E86DE)),
          const SizedBox(height: 16),
          _buildSecurityBadge(Icons.health_and_safety, 'Hospital Seal', 'Digitally signed by City Hospital', primaryLavender),
          const SizedBox(height: 16),
          _buildSecurityBadge(Icons.verified, 'Gov Verified', 'National population registry active', goldAccent),
        ],
      ),
    );
  }

  Widget _buildSecurityBadge(IconData icon, String title, String subtitle, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 14)),
              Text(subtitle, style: TextStyle(color: textLight, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAIInsights() {
    if (!_isUnlocked) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [softLavender, primaryLavender.withOpacity(0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryLavender.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: primaryLavender),
              const SizedBox(width: 8),
              Text('Smart Registration', style: TextStyle(color: primaryLavender, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Baby successfully registered in national healthcare system.', style: TextStyle(color: textDark, fontWeight: FontWeight.w600, fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: goldAccent, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Next Step: Access the Baby Dashboard to start tracking vaccination schedules automatically derived from this birth record.', style: TextStyle(color: textLight, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
