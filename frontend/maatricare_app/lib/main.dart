import 'package:flutter/material.dart';
import 'package:maatricare_app/screens/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maatricare_app/screens/mother/mother_dashboard.dart';
import 'package:maatricare_app/screens/doctor/doctor_dashboard.dart';
import 'package:maatricare_app/screens/admin/admin_dashboard.dart';
import 'package:maatricare_app/core/app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final String userRole = prefs.getString('userRole') ?? 'Mother';
  AppState.userName = prefs.getString('userName') ?? 'User';

  Widget initialScreen = const LoginScreen();
  if (isLoggedIn) {
    if (userRole == 'Admin') {
      initialScreen = const AdminDashboard();
    } else if (userRole == 'Doctor') {
      initialScreen = const DoctorDashboard();
    } else {
      initialScreen = const MotherDashboardScreen();
    }
  }

  runApp(MaatriCareApp(initialScreen: initialScreen));
}

class MaatriCareApp extends StatelessWidget {
  final Widget initialScreen;
  const MaatriCareApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MaatriCare',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: initialScreen,
    );
  }
}