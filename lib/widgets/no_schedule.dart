import 'package:flutter/material.dart';
import '../screens/schedule_page.dart';

class NoSchedulePage extends StatelessWidget {
  final String doctorId;
  final VoidCallback onSetSchedule;
  final String? additionalInfo;

  const NoSchedulePage({
    super.key,
    required this.doctorId,
    required this.onSetSchedule,
    this.additionalInfo
  });

  void _navigateToSchedulePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SchedulePage(
          doctorId: doctorId,
          showAppBar: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // debugShowCheckedModeBanner: false,
      // home: Scaffold(
        backgroundColor: Color(0xFF680C20),
        body: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF6F6F6),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top Rounded White Container with "Your Schedule" text
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 16, top: 16, bottom: 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF6F6F6),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Your Schedule",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Image Centered
                Center(
                  child: Image.asset(
                    'assets/images/schedule_image.png', // Replace with your image
                    width: 200,
                  ),
                ),

                const SizedBox(height: 20),

                // No Schedule Text
                const Text(
                  "No Schedule Set",
                  style: TextStyle(
                      fontFamily: 'Poppins', // Font family
                      fontWeight: FontWeight.w600, // 500 weight
                      fontSize: 16, // Font size
                      height: 1, // Line height = 16px / 16px
                      letterSpacing: 0,
                      color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Column(
                  children: [
                    const Text(
                      "Define your time slots for appointments.",
                      style: TextStyle(
                        fontFamily: 'Poppins', // Font family
                        fontWeight: FontWeight.w400, // 400 weight
                        fontSize: 14, // Font size
                        height: 1, // Line height = 14px / 14px
                        letterSpacing: 0,
                        color: Color(0xFF99979F), // Hex color #99979F
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (additionalInfo != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        additionalInfo!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),

                const Spacer(),

                // Set Schedule Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 30, left: 16, right: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        onSetSchedule();
                        _navigateToSchedulePage(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B0D24), // Custom button color
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 60), // Padding as per spec
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              27), // Border radius as per spec
                        ),
                      ),
                      child: const Text(
                        "Set Schedule",
                        style: TextStyle(
                          fontFamily: 'Poppins', // Custom font
                          fontWeight: FontWeight.w500, // Font weight 500
                          fontSize: 18,
                          height: 1, // Line height: 18px / 18px = 1.0
                          letterSpacing: 0,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}