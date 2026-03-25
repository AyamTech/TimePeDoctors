import 'package:flutter/material.dart';

import '../screens/main_page.dart';
import '../screens/login_page.dart';
import '../screens/otp_page.dart';
import 'dart:developer' as developer;


class SamplePageNav extends StatelessWidget {
  const SamplePageNav({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    //   appBar: AppBar(
    //     title: const Text('Patient Home'),
    //   ),
      body: ListView(
        children: [

          ListTile(
            title: const Text('Main Page for doctor'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DoctorMainPage()),
              );
            },
          ),
          ListTile(
            title: const Text('Login Page for doctor'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('OTP Page for doctor'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OTPVerificationScreen(phoneNumber: '',)),
              );
            },
          ),
        ],
      ),
    );
  }
}
