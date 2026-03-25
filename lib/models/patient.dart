class Patient {
  final String name;
  final String phone;
  final String appointmentTime;
  final String appointmentDate;
  final String symptoms;
  final String email;  // Added email field

  Patient({
    required this.name,
    required this.phone,
    required this.appointmentTime,
    required this.appointmentDate,
    required this.symptoms,
    this.email = '',  // Added email parameter with default empty string
  });
}
