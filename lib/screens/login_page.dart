import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../widgets/custom_toast.dart';
import 'main_page.dart';
import '../constants/api_constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'otp_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String selectedCountryCode = '+91';
  String selectedCountryFlag = '🇮🇳';
  bool isDropdownOpen = false;
  bool _phoneFieldTouched = false;
  bool isPhoneValid = false;
  final FocusNode _phoneFocusNode = FocusNode();

  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  final List<Map<String, String>> countryCodes = [
    {'code': '+91', 'flag': '🇮🇳', 'name': 'India'},
    {'code': '+1', 'flag': '🇺🇸', 'name': 'United States'},
    {'code': '+44', 'flag': '🇬🇧', 'name': 'United Kingdom'},
    {'code': '+61', 'flag': '🇦🇺', 'name': 'Australia'},
    {'code': '+86', 'flag': '🇨🇳', 'name': 'China'},
  ];

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhone);
    _phoneFocusNode.addListener(() {
      if (!_phoneFocusNode.hasFocus) {
        setState(() {
          _phoneFieldTouched = true;
        });
      }
    });
  }

  void _validatePhone() {
    setState(() {
      isPhoneValid = RegExp(r'^\d{10}$').hasMatch(_phoneController.text.trim());
    });
  }

  @override
  void dispose() {
    _phoneController.removeListener(_validatePhone);
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void toggleDropdown() {
    setState(() {
      isDropdownOpen = !isDropdownOpen;
    });
  }

  void selectCountry(String code, String flag) {
    setState(() {
      selectedCountryCode = code;
      selectedCountryFlag = flag;
      isDropdownOpen = false;
    });
  }

  bool _validateLoginInput() {
    String phone = _phoneController.text.trim();
    // Check if phone number is empty
    if (phone.isEmpty) {
      CustomToast.show(
        context,
        'Please enter your phone number',
        ToastType.error,
      );
      return false;
    }
    // Check if phone number is valid format
    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      CustomToast.show(
        context,
        'Please enter a valid 10-digit phone number',
        ToastType.error,
      );
      return false;
    }
    return true;
  }

  Future<void> loginWithPhone() async {
    // Validate input before proceeding
    if (!_validateLoginInput()) {
      return;
    }
    String phone = _phoneController.text.trim();
    setState(() {
      isLoading = true;
    });
    try {
      final checkPhoneResponse = await http.post(
        Uri.parse(ApiConstants.checkDoctorPhone()),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': '$selectedCountryCode$phone'}),
      );
      final responseData = jsonDecode(checkPhoneResponse.body);
      if (checkPhoneResponse.statusCode == 201 &&
          responseData['message'] == 'OTP sent successfully.') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('phoneNumber', phone);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationScreen(phoneNumber: phone),
          ),
        );
      } else {
        CustomToast.show(
          context,
          'Login failed: ${responseData['message'] ?? 'Unknown error'}',
          ToastType.error,
        );
      }
    } catch (e) {
      CustomToast.show(
        context,
        'Error: ${e.toString()}',
        ToastType.error,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loginWithOutOtp() async {
    // Validate input before proceeding
    if (!_validateLoginInput()) {
      return;
    }
    String phone = _phoneController.text.trim();
    setState(() {
      isLoading = true;
    });
    String? fcmToken;
    if (!kIsWeb) {
      // 🔥 Firebase Token only for Mobile
      fcmToken = await FirebaseMessaging.instance.getToken();
    } else {
      fcmToken = "eDA1djA1ZHpQd2M2T21rNzJvM0RhQmZlQzVpQkVqZlhmU0JXbU5YTzZmWQ==";
    }
    try {
      final checkPhoneResponse = await http.post(
        Uri.parse(ApiConstants.checkWithoutOtp()),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': '$selectedCountryCode$phone',
          'deviceToken': fcmToken
        }),
      );
      final responseData = jsonDecode(checkPhoneResponse.body);
      if (checkPhoneResponse.statusCode == 200 &&
          responseData['token'] != null &&
          responseData['message'] == 'Login successfully.') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('phoneNumber', phone);
        final token = responseData['token'];
        await prefs.setString('authToken', token); // 🔐 Save the token
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DoctorMainPage(),
          ),
        );
      } else {
        CustomToast.show(
          context,
          'Login failed: ${responseData['message'] ?? 'Unknown error'}',
          ToastType.error,
        );
      }
    } catch (e) {
      CustomToast.show(
        context,
        'Error: ${e.toString()}',
        ToastType.error,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF680C20),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                height: 130,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bg-header.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(
                      'assets/images/time_icon_image.png',
                      height: 80,
                      fit: BoxFit
                          .cover, // Optional: ensures the image fills the rounded container nicely
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF6F6F6),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          const Center(
                            child: Column(
                              children: [
                                Text(
                                  'Welcome Back',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Login to your account',
                                  style: TextStyle(
                                    color: Color(0xFF99979F),
                                    fontSize: 14,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: toggleDropdown,
                                  child: Container(
                                    height: 42,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white, // Red background
                                      borderRadius: BorderRadius.circular(
                                          6), // Optional rounded corners
                                    ),
                                    child: Row(
                                      children: [
                                        Text(selectedCountryFlag,
                                            style:
                                                const TextStyle(fontSize: 18)),
                                        const SizedBox(width: 6),
                                        Text(selectedCountryCode,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black)),
                                        const Icon(Icons.arrow_drop_down,
                                            size: 20, color: Colors.black),
                                      ],
                                    ),
                                  ),
                                ),
                                const VerticalDivider(
                                  width: 12,
                                  thickness: 1,
                                  color: Colors.black,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: TextFormField(
                                          controller: _phoneController,
                                          focusNode: _phoneFocusNode,
                                          keyboardType: TextInputType.phone,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(
                                                10),
                                          ],
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            color: Color(0xFF10152E),
                                          ),
                                          decoration: const InputDecoration(
                                            hintText: '999 999 9999',
                                            hintStyle:
                                                TextStyle(color: Colors.grey),
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 12),
                                          ),
                                          validator: (value) {
                                            if (!_phoneFieldTouched)
                                              return null;
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return 'Enter your phone number';
                                            }
                                            if (!RegExp(r'^\d{10}$')
                                                .hasMatch(value.trim())) {
                                              return 'Enter a valid phone number';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isDropdownOpen)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                                itemCount: countryCodes.length,
                                itemBuilder: (context, index) {
                                  final country = countryCodes[index];
                                  return InkWell(
                                    onTap: () => selectCountry(
                                        country['code']!, country['flag']!),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      child: Row(
                                        children: [
                                          Text(country['flag']!,
                                              style: const TextStyle(
                                                  fontSize: 16)),
                                          const SizedBox(width: 8),
                                          Text(country['code']!,
                                              style: const TextStyle(
                                                  fontSize: 14)),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(country['name']!,
                                                style: const TextStyle(
                                                    fontSize: 14)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          const SizedBox(height: 45),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : loginWithPhone,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF680C20),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(27),
                                ),
                              ),
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text(
                                      'Get OTP',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
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
