import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../constants/api_constants.dart';
import '../widgets/custom_toast.dart';

class NextButton extends StatefulWidget {
  final VoidCallback? onApiSuccess;
  final bool isEnabled;
  final int totalAppointments;
  final Map<String, dynamic>? appointment; // Changed to Map<String, dynamic>?

  const NextButton({
    super.key,
    this.onApiSuccess,
    required this.totalAppointments,
    required this.isEnabled,
    this.appointment, // Now accepts an appointment map
  });

  @override
  State<NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<NextButton> {
  bool _isLoading = false;

  Future<void> _updateAppointment(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception('No token found');
      }

      Map decodedToken = JwtDecoder.decode(token);
      String doctorId = decodedToken['id'];

      if (widget.appointment == null || widget.appointment!['id'] == null) {
        throw Exception('No valid appointment ID found');
      }

      // Assuming the API endpoint needs the appointment ID to mark it as "next"
      final response = await http.patch(
        Uri.parse(ApiConstants.nextAppointment(doctorId)), // Adjust if endpoint needs appointment ID
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'status': 'next',
          'appointmentId': widget.appointment!['id'], // Include appointment ID
        }),
      );

      if (response.statusCode == 200) {
        widget.onApiSuccess?.call();
        CustomToast.show(
          context,
          "Appointment updated successfully",
          ToastType.success,
        );
      } else {
        throw Exception('Failed to update appointment: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleNext(BuildContext context) async {
  if (!widget.isEnabled) {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmation"),
        content: Text(
          widget.totalAppointments == 1
              ? "No patient seems to be checked in. Are you sure you want to end today's queue?"
              : "Patient seems to be not in the clinic. Are you sure you want to press NEXT?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B0D24),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return; // User cancelled
    }
  }

  await _updateAppointment(context);
}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 46,
        child: ElevatedButton(
          onPressed: _isLoading ? null : () => _handleNext(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6B0D24),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(27),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  widget.totalAppointments == 1 ? 'Finish' : 'Next',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    height: 1,
                    letterSpacing: 0,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
        ),
      ),
    );
  }
}
