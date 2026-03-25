import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onNavTapped;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onNavTapped,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF6B0D24);
    const inactiveColor = Color(0xFF99979F);

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex,
      onTap: onNavTapped,
      selectedItemColor: activeColor,
      unselectedItemColor: inactiveColor,
      showUnselectedLabels: true,
      items: [
        _buildNavBarItem(
          index: 0,
          selectedIndex: selectedIndex,
          label: 'Home',
          iconPath: 'assets/bar-icons/home_inactive.png',
          activeColor: activeColor,
          inactiveColor: inactiveColor,
        ),
        _buildNavBarItem(
          index: 1,
          selectedIndex: selectedIndex,
          label: 'Schedule',
          iconPath: 'assets/bar-icons/schedule_inactive.png',
          activeColor: activeColor,
          inactiveColor: inactiveColor,
        ),
        _buildNavBarItem(
          index: 2,
          selectedIndex: selectedIndex,
          label: 'Notification',
          iconPath: 'assets/bar-icons/notification_inactive.png',
          activeColor: activeColor,
          inactiveColor: inactiveColor,
        ),
        _buildNavBarItem(
          index: 3,
          selectedIndex: selectedIndex,
          label: 'Contact Us',
          iconPath: 'assets/bar-icons/contact_inactive.png',
          activeColor: activeColor,
          inactiveColor: inactiveColor,
        ),
      ],
    );
  }

  BottomNavigationBarItem _buildNavBarItem({
    required int index,
    required int selectedIndex,
    required String label,
    required String iconPath,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    bool isActive = selectedIndex == index;

    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Active Top Bar (full width)
          isActive
              ? Container(
                  width: double.infinity, // Full width of item
                  height: 3,
                  color: activeColor,
                )
              : const SizedBox(height: 3), // Reserve space for alignment
          const SizedBox(height: 4), // Space between bar and icon
          Image.asset(
            iconPath,
            width: 24,
            height: 24,
            color: isActive ? activeColor : inactiveColor,
          ),
        ],
      ),
      label: label,
    );
  }
}
