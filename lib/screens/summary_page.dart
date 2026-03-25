import 'package:flutter/material.dart';
import '../widgets/header.dart';
import '../widgets/bottom_nav.dart';
import 'schedule_page.dart'; // This is the "another page" you want to display in the content area.

class SimpleDoctorPage extends StatefulWidget {
  const SimpleDoctorPage({super.key});

  @override
  State<SimpleDoctorPage> createState() => _SimpleDoctorPageState();
}

class _SimpleDoctorPageState extends State<SimpleDoctorPage> {
  int _selectedIndex = 1;

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Optional: extend body behind app bar if header styling requires it.
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Column(
          children: [
            const Header(), // Reuse your custom header widget.
            // Main content area: Replace 'AnotherPage' with the widget you want to show.
            const Expanded(
              child: SchedulePage(doctorId: '',),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onNavTapped: _onNavTapped,
      ),
    );
  }
}
