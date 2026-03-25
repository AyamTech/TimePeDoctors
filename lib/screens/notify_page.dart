import 'package:flutter/material.dart';
import '../widgets/header.dart';
import '../widgets/bottom_nav.dart';
import 'notification_screen.dart'; // This is the "another page" you want to display in the content area.

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPage();
}

class _NotificationPage extends State<NotificationPage> {
  int _selectedIndex = 2;

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
             // Reuse your custom header widget.
            // Main content area: Replace 'AnotherPage' with the widget you want to show.
            const Expanded(
              child: NotificationSettingsScreen(),
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
