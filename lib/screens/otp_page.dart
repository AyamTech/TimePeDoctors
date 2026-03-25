import 'package:flutter/gestures.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'main_page.dart';
import 'dart:async';
import '../../../constants/api_constants.dart';
import '../../../services/otp_service.dart';
import '../../../widgets/custom_toast.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  const OTPVerificationScreen({Key? key, required this.phoneNumber})
      : super(key: key);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final OTPService otpService = OTPService();
  late TextEditingController otpController;
  int _resendSeconds = 30;
  String? reqId;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    otpController = TextEditingController();
    sendOtp();
  }

  void sendOtp() async {
    final response = await otpService.sendOtp(widget.phoneNumber);
    if (response?['type'] == 'success') {
      reqId = response?['message'];
      startResendTimer();
    } else {
      CustomToast.show(context, 'Failed to send OTP', ToastType.info);
    }
  }
 void startResendTimer() {
    _resendTimer?.cancel(); // Cancel any existing timer
    setState(() {
      _resendSeconds = 30;
    });
    
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() {
          _resendSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

@override
void dispose() {
  _resendTimer?.cancel();
  super.dispose();
  // Remove otpController.dispose() completely
}

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();
    if (otp.length != 6) {
      CustomToast.show(
          context, 'Please enter a valid 6-digit OTP', ToastType.error);
      return;
    }
    final msg91response =
        await otpService.verifyOtp(reqId!, otpController.text);
    if (msg91response?['type'] == 'success') {
      try {
        String? fcmToken;
        if (!kIsWeb) {
          // 🔥 Firebase Token only for Mobile
          fcmToken = await FirebaseMessaging.instance.getToken();
        } else {
          fcmToken =
              "eDA1djA1ZHpQd2M2T21rNzJvM0RhQmZlQzVpQkVqZlhmU0JXbU5YTzZmWQ==";
        }
        final response = await http.post(
          Uri.parse(ApiConstants.getLoginUrl()),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'phoneNumber': "+91${widget.phoneNumber}",
            'accessToken': msg91response?['message'],
            'deviceToken': fcmToken
          }),
        );
        final data = jsonDecode(response.body);
        if (response.statusCode == 200 &&
            data['message'] == 'Login successful with OTP.' &&
            data['token'] != null) {
          // Navigate to HomeScreen after successful OTP
          final token = data['token'];

          // Store token in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('authToken', token); // 🔐 Save the token
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const DoctorMainPage(),
            ),
          );
        } else {
          CustomToast.show(
              context, data['message'] ?? 'Invalid OTP', ToastType.info);
        }
      } catch (e) {
        CustomToast.show(
            context, 'Error verifying OTP: ${e.toString()}', ToastType.info);
      } finally {
        setState(() {
          // hide loading if added
        });
      }
    } else {
      CustomToast.show(context, 'Invalid OTP', ToastType.info);
    }
  }

  void retryOtp() async {
    final response = await otpService.sendOtp(widget.phoneNumber);
    if (response?['type'] == 'success') {
      reqId = response?['message'];
      otpController.clear(); // Use clear() instead of text = ''
      startResendTimer(); // This now resets _resendSeconds to 30
      CustomToast.show(context, 'OTP resent successfully', ToastType.success);
    } else {
      CustomToast.show(context, 'Failed to resend OTP', ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
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
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 40,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Icon(Icons.arrow_back),
                              ),
                            ),
                            const Text(
                              'Verification',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                height: 1.2,
                                letterSpacing: 0,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      Image.asset(
                        'assets/images/otp_illustration.png',
                        height: 185,
                        width: 185,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'OTP Verification',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          height: 1,
                          letterSpacing: 0,
                          color: Colors.black,
                          textBaseline: TextBaseline.alphabetic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "We’ve sent a 6-digit code to +91 ${widget.phoneNumber}",
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          height: 1.7,
                          letterSpacing: 0,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: PinCodeTextField(
                          appContext: context,
                          length: 6,
                          obscureText: false,
                          animationType: AnimationType.fade,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(10),
                            fieldHeight: 50,
                            fieldWidth: 40,
                            activeColor: Colors.black,
                            inactiveColor: Colors.grey.shade300,
                            selectedColor: Colors.black,
                          ),
                          controller: otpController,
                          onChanged: (value) {},
                        ),
                      ),
                      const SizedBox(height: 10),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            height: 1.7,
                            letterSpacing: 0,
                            color: Colors.grey,
                          ),
                          children: [
                            TextSpan(
                                text:
                                    "Didn't receive the code? Resend OTP in 00:${_resendSeconds.toString().padLeft(2, '0')} seconds. "),
                            if (_resendSeconds == 0)
                              TextSpan(
                                text: 'Retry OTP',
                                style: const TextStyle(
                                  color: Color(0xFF8D1B3D),
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = retryOtp,
                              )
                            else
                              const TextSpan(
                                text: 'Retry OTP',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: SizedBox(
                          width: 335,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () {
                              verifyOtp();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8D1B3D),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(27),
                              ),
                            ),
                            child: const Text(
                              'Verify and Continue',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                                height: 1,
                                color: Colors.white,
                                letterSpacing: 0,
                                textBaseline: TextBaseline.alphabetic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
