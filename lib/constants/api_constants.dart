import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String baseUrl =
   // dotenv.env['TEST_BASE_URL'] ?? 'http://192.168.1.20:4000/api';
      // dotenv.env['LIV_BASE_URL'] ?? 'http://3.110.121.55:4000/api';
  dotenv.env['LIV_DOMAIN_BASE_URL'] ?? 'https://app.ayamtechs.com/api';

  static String getLoginUrl() => '$baseUrl/auth/login';
  static String checkDoctorPhone() => '$baseUrl/auth/check-phone';
  static String checkWithoutOtp() => '$baseUrl/auth/login-otp';
  static String getAddPatientUrl() => '$baseUrl/patient/add';
  static String getDoctorAppointmentsUrl(String doctorId) =>
      '$baseUrl/appointment/doctor/todays/$doctorId';
  static String getDoctorAvailabilityUrl(String doctorId) =>
      '$baseUrl/doctor/availability/$doctorId';
  static String getDoctorsUrl(String doctorId) =>
      '$baseUrl/auth/doctors/$doctorId';
  static String otpVerify() => '$baseUrl/patient/loginOtp';
  static String getPatients() => '$baseUrl/patient';
  static String doctorSetAvailability() => '$baseUrl/doctor/set-availability';
  static String nextAppointment(String doctorId) =>
      '$baseUrl/doctor/appointment/$doctorId';
  static String doctorBreak(String doctorId) =>
      '$baseUrl/appointment/break/updateTime';
  static String getNotificationSettings(String doctorId) =>
      '$baseUrl/notification/$doctorId';
  static String updateNotificationSettings(String doctorId) =>
      '$baseUrl/notification/settings/$doctorId';
  static String doctorAvailableSlots(String doctorId) =>
      '$baseUrl/appointment/doctor/availability/$doctorId';
  static String getActiveAppointmentsUrl(String doctorId) =>
      '$baseUrl/appointment/doctor/active/$doctorId';
  static String getAllAppointmentsUrl(String doctorId) =>
      '$baseUrl/appointment/doctor/todays/$doctorId';
 static String cancelAllAppointments(String doctorId) =>
      '$baseUrl/doctor/cancel-appointments/$doctorId';
  static String reorderAppointmentsUrl(String doctorId) =>
      '$baseUrl/appointment/reorder/$doctorId';
static String deleteAccount() =>
      '$baseUrl/auth/delete';
}
