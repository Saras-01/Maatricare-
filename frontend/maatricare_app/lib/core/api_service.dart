import 'dart:convert';
import 'package:http/http.dart' as http;
import '../screens/mother/doctor_selection_screen.dart';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000";

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Login failed');
    }
  }

  static Future<Map<String, dynamic>> register(String fullName, String email, String phone, String password, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'full_name': fullName,
        'email': email,
        'phone_number': phone,
        'password': password,
        'role': role,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Registration failed');
    }
  }

  static Future<Map<String, dynamic>> predictRisk({
    required String motherName,
    required int age,
    required String bloodPressure,
    required double sugarLevel,
    required double hemoglobin,
    required double weight,
    String symptoms = '',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ai-risk/predict/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'mother_name': motherName,
        'age': age,
        'blood_pressure': bloodPressure,
        'sugar_level': sugarLevel,
        'hemoglobin': hemoglobin,
        'weight': weight,
        'symptoms': symptoms,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('AI Prediction failed');
    }
  }

  static Future<List<dynamic>> fetchChatMessages() async {
    final response = await http.get(Uri.parse('$baseUrl/chat/messages/'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load chat messages');
    }
  }

  static Future<Map<String, dynamic>> sendChatMessage({
    required String senderName,
    required String receiverName,
    required String message,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/send/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'sender_name': senderName,
        'receiver_name': receiverName,
        'message': message,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to send message');
    }
  }

  static Future<List<Doctor>> fetchDoctors() async {
    final response = await http.get(Uri.parse('$baseUrl/doctors/'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Doctor(
        id: data['id'].toString(),
        name: data['name'] ?? '',
        specialty: data['specialization'] ?? '',
        hospital: data['hospital'] ?? '',
        availableDays: data['availability'] == true ? 'Mon - Fri' : 'Unavailable',
        experienceYears: data['experience'] ?? 0,
        rating: double.tryParse(data['rating']?.toString() ?? '0') ?? 0.0,
        patients: '1000+', // Mocked as not provided in API
        successRate: '98%', // Mocked as not provided in API
        responseTime: '< 1 hr', // Mocked as not provided in API
        image: data['profile_image'] ?? '',
      )).toList();
    } else {
      throw Exception('Failed to load doctors');
    }
  }
}
