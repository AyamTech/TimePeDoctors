import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const ContactUsPage());
}

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  String? phoneNumber = '+91 9560447688';
  String? email = 'info@ayamtechs.com';
  String? contactInformation = 'B174, Vivek Vihar Delhi – 110095 India';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      phoneNumber = '+91 9560447688';
      email = 'info@ayamtechs.com';
      contactInformation = 'B174, Vivek Vihar Delhi – 110095 India';
    });
  }

  Future<void> loadDoctorDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? doctorData = prefs.getString('doctorDetails');

    if (doctorData != null) {
      Map<String, dynamic> storedData = json.decode(doctorData);
      setState(() {
        phoneNumber = storedData['phoneNumber'] ?? 'N/A';
        email = storedData['email'] ?? 'N/A';
        contactInformation = storedData['contactInformation'] ?? 'N/A';
        isLoading = false;
      });
    } else {
      setState(() {
        phoneNumber = '+91 9560447688';
        email = 'info@ayamtechs.com';
        contactInformation = 'B174, Vivek Vihar Delhi – 110095 India';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF680C20),
        body: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF6F6F6),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF680C20),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Contact Us",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Centered Image
                      Center(
                        child: Image.asset(
                          'assets/images/contact.png',
                          width: 250,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Contact Details
                      Center(
                        child: Column(
                          children: [
                            if (phoneNumber != null)
                              buildContactRow(
                                  'assets/images/phone.png', phoneNumber!),
                            const SizedBox(height: 14),
                            if (email != null)
                              buildContactRow('assets/images/sms.png', email!),
                            const SizedBox(height: 14),
                            if (contactInformation != null)
                              buildContactRow('assets/images/global.png',
                                  contactInformation!),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget buildContactRow(String imagePath, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          imagePath,
          width: 20,
          height: 20,
          color: const Color(0xFF6B0D24),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
