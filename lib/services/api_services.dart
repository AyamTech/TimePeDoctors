import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiService {

  // Add new patient
  static Future<Map<String, dynamic>> addPatient({
    required String name,
    required String phone,
    required DateTime appointmentDate,
    required String appointmentTime,
    required String symptoms,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'appointmentDate': appointmentDate.toIso8601String(),
          'appointmentTime': appointmentTime,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to add patient: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // Get all patients
  static Future<List<dynamic>> getPatients() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.baseUrl));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load patients: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }
}
