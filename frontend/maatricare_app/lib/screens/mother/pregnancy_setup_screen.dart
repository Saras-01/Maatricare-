import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../core/app_state.dart';
import 'mother_dashboard.dart';

class PregnancySetupScreen extends StatefulWidget {
  const PregnancySetupScreen({super.key});

  @override
  State<PregnancySetupScreen> createState() => _PregnancySetupScreenState();
}

class _PregnancySetupScreenState extends State<PregnancySetupScreen> {
  DateTime? _selectedLmpDate;
  DateTime? _calculatedEdd;
  int _currentWeek = 0;
  int _currentTrimester = 1;
  bool _isLoading = false;

  void _calculatePregnancyDetails(DateTime lmpDate) {
    // EDD is LMP + 280 days
    final edd = lmpDate.add(const Duration(days: 280));
    
    // Current week = (Today - LMP) in days / 7
    final now = DateTime.now();
    final difference = now.difference(lmpDate).inDays;
    
    int week = 0;
    if (difference > 0) {
      week = (difference / 7).floor();
    }
    
    // Trimester
    int trimester = 1;
    if (week >= 14 && week < 28) {
      trimester = 2;
    } else if (week >= 28) {
      trimester = 3;
    }

    setState(() {
      _selectedLmpDate = lmpDate;
      _calculatedEdd = edd;
      _currentWeek = week;
      _currentTrimester = trimester;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime.now().subtract(const Duration(days: 300)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF9C27B0),
              onPrimary: Colors.white,
              onSurface: Color(0xFF2D3142),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF9C27B0),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _calculatePregnancyDetails(picked);
    }
  }

  Future<void> _saveAndContinue() async {
    if (_selectedLmpDate == null || _calculatedEdd == null) return;
    
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final lmpStr = _selectedLmpDate!.toIso8601String();
      final eddStr = _calculatedEdd!.toIso8601String();
      
      await prefs.setString('lmp_date', lmpStr);
      await prefs.setString('edd_date', eddStr);
      await prefs.setInt('pregnancy_week', _currentWeek);
      await prefs.setInt('trimester', _currentTrimester);

      AppState.pregnancyWeek = _currentWeek;
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MotherDashboardScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save details. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2FA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 40),
                      _buildDateSelectionCard(),
                      if (_selectedLmpDate != null) ...[
                        const SizedBox(height: 24),
                        _buildResultsCard(),
                      ],
                      const SizedBox(height: 40),
                      _buildContinueButton(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFE1BEE7).withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.pregnant_woman_rounded, size: 40, color: Color(0xFF8E24AA)),
        ),
        const SizedBox(height: 24),
        const Text(
          "Let's personalize your journey",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A148C),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "We need your Last Menstrual Period (LMP) date to calculate your pregnancy milestones.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF8F9BB3),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelectionCard() {
    final hasDate = _selectedLmpDate != null;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9C27B0).withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: hasDate ? const Color(0xFF9C27B0) : const Color(0xFFF3E5F5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    color: hasDate ? Colors.white : const Color(0xFF9C27B0),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select LMP Date',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: hasDate ? const Color(0xFF8F9BB3) : const Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasDate 
                          ? DateFormat('MMMM d, yyyy').format(_selectedLmpDate!)
                          : 'Tap to pick a date',
                        style: TextStyle(
                          fontSize: hasDate ? 18 : 16,
                          fontWeight: hasDate ? FontWeight.bold : FontWeight.normal,
                          color: hasDate ? const Color(0xFF2D3142) : const Color(0xFF8F9BB3),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFCE93D8), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMilestoneData('Expected Delivery', DateFormat('MMM d, yyyy').format(_calculatedEdd!)),
              _buildMilestoneData('Current Week', 'Week $_currentWeek'),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Trimester',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _currentTrimester == 1 ? '1st Trimester' : _currentTrimester == 2 ? '2nd Trimester' : '3rd Trimester',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (_currentWeek / 40).clamp(0.0, 1.0),
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${((_currentWeek / 40) * 100).clamp(0, 100).toStringAsFixed(0)}% to your due date',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneData(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _selectedLmpDate == null || _isLoading ? null : _saveAndContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9C27B0),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFE1BEE7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: _selectedLmpDate == null ? 0 : 4,
          shadowColor: const Color(0xFF9C27B0).withOpacity(0.5),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                'Continue to Dashboard',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}
