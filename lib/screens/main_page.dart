import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';

import 'doctor_home_page.dart';
import 'appointments_page.dart';
import 'notification_screen.dart';

import '../widgets/bottom_nav.dart';
import '../widgets/header.dart';
import '../widgets/no_schedule.dart';
import 'schedule_page.dart';
import 'contact.dart';
import '../constants/api_constants.dart';

class DoctorMainPage extends StatefulWidget {
  const DoctorMainPage({super.key});

  @override
  State<DoctorMainPage> createState() => _DoctorMainPageState();
}

class _DoctorMainPageState extends State<DoctorMainPage> {
  int _selectedIndex = 0;
  bool _isScheduleAvailable = false;
  bool _isLoading = true;
  bool refreshDoctorHome = false;
  String? _doctorId;
  Map<String, dynamic>? _scheduleData;
  bool _hasDailySlots = false;

  // Use the public state class NotificationSettingsScreenState
  final GlobalKey<NotificationSettingsScreenState> _notificationKey =
      GlobalKey<NotificationSettingsScreenState>();

  final GlobalKey<DoctorHomePageState> _homeKey =
      GlobalKey<DoctorHomePageState>();

  @override
  void initState() {
    super.initState();
    _fetchDoctorDetails();
  }

  Future<void> _fetchDoctorDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) {
        throw Exception('No token found');
      }

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String doctorId = decodedToken['id'];

      setState(() {
        _doctorId = doctorId;
      });

      // Once we have the doctor ID, check schedule availability
      await _checkScheduleAvailability();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isScheduleAvailable = false;
      });
      _showErrorDialog('Failed to fetch doctor details');
    }
  }

  Future<void> _checkScheduleAvailability() async {
    if (_doctorId == null) {
      setState(() {
        _isLoading = false;
        _isScheduleAvailable = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.getDoctorAvailabilityUrl(_doctorId!)),
      );

      if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      print('Schedule Response Data: $responseData');
final Map<String, dynamic> data = responseData['data'];

   final dailySlots = data['dailySlots'];
final Map<String, dynamic> schedule =
    data['schedule'] as Map<String, dynamic>;

bool isAvailable = false;

// 1️⃣ schedule must be active
if (schedule['status'] == 'Active') {

  // 2️⃣ MULTI-SECTION MODE
  if (schedule['useMultipleSections'] == true &&
      schedule['scheduleSections'] != null) {

    final List sections = schedule['scheduleSections'];

    for (final section in sections) {
      final morning = section['morningSession'];
      final evening = section['eveningSession'];

      if ((morning != null &&
              morning['enabled'] == true &&
              (morning['selectedDays'] as List).contains(true)) ||
          (evening != null &&
              evening['enabled'] == true &&
              (evening['selectedDays'] as List).contains(true))) {
        isAvailable = true;
        break;
      }
    }
  }

  // 3️⃣ LEGACY MODE
  else {
    isAvailable =
        (schedule['morningSession']?['enabled'] == true ||
            schedule['eveningSession']?['enabled'] == true) &&
        schedule['selectedDays'] != null &&
        (schedule['selectedDays'] as List).contains(true);
  }
}

setState(() {
  _scheduleData = schedule;
  _isScheduleAvailable = isAvailable;
  _isLoading = false;
   _hasDailySlots = dailySlots != null && (dailySlots as List).isNotEmpty;
});


      } else {
        // Handle error case
        setState(() {
          _isScheduleAvailable = false;
          _isLoading = false;
        });
        _showNoScheduleDialog('Please set up your schedule to add appointments.');
      }
    } catch (e) {
      // Handle network or parsing errors
      print('Error checking schedule availability: $e');
      setState(() {
        _isScheduleAvailable = false;
        _isLoading = false;
      });
      //_showErrorDialog('Network error');
    }
  }

   void _showNoScheduleDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Schedule Available'),
        content: Text(message),
        actions: [
          
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToSchedulePage(context);
            },
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _navigateToSchedulePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SchedulePage(
          doctorId: _doctorId!,
          showAppBar: true,
        ),
      ),
    );
  }

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == index && index == 0) {
        _homeKey.currentState?.refreshAppointments(); // <-- trigger refresh
        _homeKey.currentState?.startPeriodicFetch(); // <-- Call to stop the periodic fetch
      }
      // Re-check schedule availability when navigating to Schedule page
      if (index == 0 || index == 1) {
        _fetchDoctorDetails();
      }
      if (index > 0) {
        _homeKey.currentState?.stopPeriodicFetch(); // <-- Call to stop the periodic fetch
      }
      if (index == 2) {
        _notificationKey.currentState?.refreshSettings();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130),
        child: const Header(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _selectedIndex,
              children: [
                 DoctorHomePage(key: _homeKey, hasDailySlots: _hasDailySlots), // Pass the daily slots info
                _isScheduleAvailable && _doctorId != null
                    ? SchedulePage(
                        doctorId: _doctorId!,
                        scheduleData: _scheduleData,
                        showAppBar: false,
                      )
                    : NoSchedulePage(
                        doctorId: _doctorId!,
                        onSetSchedule: _fetchDoctorDetails,
                        additionalInfo: _getNoScheduleReason(),
                      ),
                NotificationSettingsScreen(key: _notificationKey),
                const ContactUsPage(),
              ],
            ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onNavTapped: _onNavTapped,
      ),
    );
  }

  // Helper method to provide more context about why no schedule is available
  String _getNoScheduleReason() {
    if (_scheduleData == null) return "No schedule data available";

    if (_scheduleData!['status'] != 'Active') {
      return "Doctor's schedule is not currently active";
    }

    if (!(_scheduleData!['morningSession']['enabled'] ||
        _scheduleData!['eveningSession']['enabled'])) {
      return "No active sessions available";
    }

    if (!_scheduleData!['selectedDays'].contains(true)) {
      return "No days selected for scheduling";
    }

    return "Unable to retrieve schedule";
  }
}
