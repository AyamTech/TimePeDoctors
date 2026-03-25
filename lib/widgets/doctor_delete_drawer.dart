import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import './custom_toast.dart';
import '../screens/login_page.dart';

class DoctorDeleteDrawer extends StatelessWidget {
  const DoctorDeleteDrawer({super.key});

  Future<void> _handleDeleteAccount(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('authToken');

        if (token == null) {
          throw Exception('No token found');
        }

        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String doctorId = decodedToken['id'];
        print('Doctor ID for deletion: $doctorId');
        
        final response = await http.put(
          Uri.parse(ApiConstants.deleteAccount()),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({'id': doctorId}),
        );

        if (response.statusCode == 200) {
          await prefs.clear();

          if (context.mounted) {
            CustomToast.show(
              context,
              'Account deleted successfully',
              ToastType.success,
            );

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
              (route) => false,
            );
          }
        } else {
          throw Exception('Failed to delete account');
        }
      } catch (e) {
        if (context.mounted) {
          CustomToast.show(
            context,
            'Error deleting account: $e',
            ToastType.error,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              "Account Settings",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),

            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
              title: const Text(
                'Delete Account',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () => _handleDeleteAccount(context),
            ),
          ],
        ),
      ),
    );
  }
}
