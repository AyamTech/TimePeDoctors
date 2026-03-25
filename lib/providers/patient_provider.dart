import 'package:flutter/material.dart';
import '../models/patient.dart';

class PatientProvider with ChangeNotifier {
  final List<Patient> _patients = [];

  List<Patient> get patients => _patients;

  void addPatient(Patient patient) {
    _patients.add(patient);
    notifyListeners();
  }

  void setPatients(List<dynamic> apiPatients) {
    _patients.clear();
    _patients.addAll(apiPatients.map((patient) => Patient(
      name: patient['name'],
      phone: patient['phoneNumber'] ?? '',
      appointmentTime: patient['timeSlot']?['time'] ?? '',
      appointmentDate: patient['timeSlot']?['date'] ?? '',
      email: patient['email'] ?? '',
      symptoms: patient['symptoms'] ?? '',
    )).toList());
    notifyListeners();
  }
}
