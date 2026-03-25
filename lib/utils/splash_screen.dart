import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate some async task or initialization
    Future.delayed(const Duration(seconds: 3), () {
      // Navigate to your main page
      Navigator.pushReplacementNamed(context, '/main');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
      
        child: Image.asset(
        'assets/splash.png',
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        ),
      ),
    );
  }
}
