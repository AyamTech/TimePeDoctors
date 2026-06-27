import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../constants/api_constants.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  // Make the state class public by removing the underscore
  NotificationSettingsScreenState createState() =>
      NotificationSettingsScreenState();
}

// Make the state class public by removing the underscore
class NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool notifyResume = true;
  bool notifyEnd = false;
  bool notifyFirstReady = false;
  bool notifyLast = false;
  bool notifyMessages = false;
  bool notify90Full = false;
  bool notifyFull = true;

  String? doctorId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotificationSettings();
  }

  // Fetch current notification settings
  Future<void> _fetchNotificationSettings() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) throw Exception('No token found');

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      doctorId = decodedToken['id'];

      var response = await http.get(
        Uri.parse(ApiConstants.getNotificationSettings(doctorId!)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          // Map API response to our local state variables
          notifyFirstReady = data['notifyFirstPatientArrival']['isSelected'] ?? false;
          notifyLast = data['notifyOnePatientRemaining']['isSelected'] ?? false;
          notifyMessages = data['notifyPatientMessage']['isSelected'] ?? false;
          notify90Full = data['notifyShiftNinetyPercentFull']['isSelected'] ?? false;
          notifyFull = data['notifyFullyBooked']['isSelected'] ?? false;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateNotificationSettings() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) throw Exception('No token found');

      if (doctorId == null) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        doctorId = decodedToken['id'];
      }

      // Create payload according to API requirements
      var payload = {
        "notifyFirstPatientArrival": {
          "isSelected": notifyFirstReady,
        },
        "notifyOnePatientRemaining": {
          "isSelected": notifyLast,
        },
        "notifyPatientMessage": {
          "isSelected": notifyMessages,
        },
        "notifyShiftNinetyPercentFull": {
          "isSelected": notify90Full,
        },
        "notifyFullyBooked": {
          "isSelected": notifyFull,
        }
      };

      var response = await http.put(
        Uri.parse(ApiConstants.updateNotificationSettings(doctorId!)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings Saved')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save settings')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saving settings')),
      );
    }
  }

  // Public method that can be called from outside
  void refreshSettings() {
    _fetchNotificationSettings();
  }

  Widget buildDisabledNotificationTile(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ),
          Switch(
            value: false,
            onChanged: null,
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  Widget buildNotificationTile(
      String title, String settingKey, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: (bool newValue) {
              setState(() {
                onChanged(newValue);
              });
            },
            activeColor: Color(0xFF6B0D24),
            trackColor: MaterialStateProperty.resolveWith((states) {
              return states.contains(MaterialState.selected)
                  ? Color(0xFFFAE1E9)
                  : Colors.white54;
            }),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF680C20),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF6F6F6),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF6B0D24)))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Notification',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 12),
                            buildNotificationTile(
                                'Notify when appointments are going to resume',
                                'notifyResume', notifyResume, (val) {
                              setState(() {
                                notifyResume = val;
                              });
                            }),
                            buildDisabledNotificationTile(
                                'Notify when appointments are going to end'),
                            buildNotificationTile(
                                'Notify when first appointment is ready',
                                'notifyFirstReady', notifyFirstReady, (val) {
                              setState(() {
                                notifyFirstReady = val;
                              });
                            }),
                            buildNotificationTile(
                                'Notify when patient messages',
                                'notifyMessages', notifyMessages, (val) {
                              setState(() {
                                notifyMessages = val;
                              });
                            }),
                            buildNotificationTile(
                                'Notify when appointments are 90% full',
                                'notify90Full', notify90Full, (val) {
                              setState(() {
                                notify90Full = val;
                              });
                            }),
                            buildNotificationTile(
                                'Notify when appointments are full',
                                'notifyFull', notifyFull, (val) {
                              setState(() {
                                notifyFull = val;
                              });
                            }),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Color(0xFFF6F6F6),
        padding: const EdgeInsets.only(bottom: 16, top: 8),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 46,
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B0D24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(27),
              ),
              padding: EdgeInsets.zero,
            ),
            onPressed: () {
              _updateNotificationSettings();
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}