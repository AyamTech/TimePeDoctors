import 'package:sendotp_flutter_sdk/sendotp_flutter_sdk.dart';

class OTPService {
  final String widgetId = '35657a746547393638303833';  // Replace with real widgetId
  final String authToken = '452379TpHW82SbNb68372454P1';           // Replace with real token

  OTPService() {
    OTPWidget.initializeWidget(widgetId, authToken);
  }

  Future<Map<String, dynamic>?> sendOtp(String phone) async {
    final data = {'identifier': '91$phone'};
    return await OTPWidget.sendOTP(data);
  }

  Future<Map<String, dynamic>?> verifyOtp(String reqId, String otp) async {
    final data = {'reqId': reqId, 'otp': otp};
    return await OTPWidget.verifyOTP(data);
  }

  Future<Map<String, dynamic>?> retryOtp(String reqId) async {
    final data = {'reqId': '91$reqId', 'retryChannel': 11};
    return await OTPWidget.retryOTP(data);
  }
}
