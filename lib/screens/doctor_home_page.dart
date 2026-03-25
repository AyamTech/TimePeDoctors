import 'package:flutter/material.dart';
import '../widgets/status_section.dart';
import '../widgets/break_button.dart';
import '../widgets/next_button.dart';
import 'appointments_page.dart';
import 'add_patients_page.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => DoctorHomePageState();
}

class DoctorHomePageState extends State<DoctorHomePage> {
  int _selectedIndex = 0;
  bool isFirstCheckedIn = false;
  int totalAppointments = 0;
  List<Map<String, dynamic>> appointments = []; // Declared to store appointments

  final GlobalKey<AppointmentsPageState> appointmentsKey =
      GlobalKey<AppointmentsPageState>();

  // Removed duplicate getter for appointments

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void updateTotalAppointments(int count, bool isCheckedIn, List<Map<String, dynamic>> appts) {
    setState(() {
      totalAppointments = count;
      isFirstCheckedIn = isCheckedIn;
      appointments = appts; // Updates class-level list
      print('Updated in DoctorHomePage: $totalAppointments appointments, isFirstCheckedIn: $isCheckedIn, appointments: $appointments'); // Debug print
    });
  }

  void refreshAppointments() {
    appointmentsKey.currentState?.fetchAppointments();
    print('Refreshing appointments with key: $appointmentsKey'); // Debug print
  }

  void startPeriodicFetch() {
    appointmentsKey.currentState?.startPeriodicFetch();
  }

  void stopPeriodicFetch() {
    appointmentsKey.currentState?.stopPeriodicFetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF680C20),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF6F6F6),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              const StatusSection(),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: OutlinedButton.icon(
                          icon: Image.asset(
                            'assets/images/add-patient.png',
                            width: 20,
                            height: 20,
                            color: Color(0xFF670E22),
                          ),
                          label: const Text(
                            'Add Patient',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              color: Color(0xFF670E22),
                            ),
                          ),
                          onPressed: () async {
                            stopPeriodicFetch();
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddPatientPage()),
                            );
                            startPeriodicFetch(); // Restart periodic fetch
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF670E22)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      flex: 1,
                      child: SizedBox(
                        width: double.infinity,
                        child: BreakButton(
                          onApiSuccess: refreshAppointments,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Today Appointments',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF10152E),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Text(
                        '$totalAppointments Patients',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: Color(0xFF670E22),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: AppointmentsPage(
                  key: appointmentsKey,
                  onTotalAppointmentsFetched: updateTotalAppointments,
                ),
              ),
              if (totalAppointments > 0)
                NextButton(
                  totalAppointments: totalAppointments,
                  onApiSuccess: refreshAppointments,
                  isEnabled: isFirstCheckedIn,
                  appointment: appointments.isNotEmpty ? appointments[0] : null, // Pass first appointment
                ),
            ],
          ),
        ),
      ),
    );
  }
}