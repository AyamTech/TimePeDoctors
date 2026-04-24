import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'main_page.dart';
import '../providers/patient_provider.dart';
import '../constants/api_constants.dart';
import '../widgets/custom_toast.dart';
import '../models/patient.dart';

class AddPatientPage extends StatefulWidget {
  @override
  _AddPatientPageState createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _phone = '';
  String _symptoms = '';
  DateTime _selectedDate = DateTime.now();
  String _selectedTimeSlot = '';
  List<Map<String, dynamic>> _availableSlots = [];
  bool _isLoading = false;
  bool _isFetchingSlots = false;
  bool _isFetchingPatient = false;
  int _selectedIndex = 0;
  int _selectedemergencyDuration = 0; // default
  bool _fieldsEnabled = false;
  bool _autoFilled = false;
  String? patientId = null; // <-- Added this line
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneController.text = _phone;
    _phoneController.addListener(() {
      setState(() {
        _phone = _phoneController.text;
      });
    });
    _fetchAvailableSlots();
  }

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  bool _isFormValid() {
    bool basicInfoValid = _nameController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _phoneController.text.length == 10;

    return basicInfoValid &&
        (_selectedemergencyDuration > 0 || _selectedTimeSlot.isNotEmpty);
  }

  void _updateDurationButton(int min) {
    setState(() {
      // If already selected, deselect it
      if (_selectedemergencyDuration == min) {
        _selectedemergencyDuration = 0;
      } else {
        _selectedemergencyDuration = min;
        // Clear time slot when emergency is selected
        _selectedTimeSlot = '';
      }
    });
  }

  // Future<Map<String, dynamic>> _fetchDoctorSchedule() async {
  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     String? token = prefs.getString('authToken');

  //     if (token == null) {
  //       throw Exception('No token found');
  //     }

  //     Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
  //     String doctorId = decodedToken['id'];

  //     final url = ApiConstants.getDoctorAvailabilityUrl(doctorId);

  //     final response = await http.get(
  //       Uri.parse(url),
  //       headers: {'Content-Type': 'application/json'},
  //     );

  //     if (response.statusCode == 200) {
  //       final responseData = jsonDecode(response.body);
  //       final data = jsonDecode(response.body)['data'];

  //       if (data['morningSession'] != null && data['eveningSession'] != null) {
  //         return {
  //           'morningSession': data['morningSession'],
  //           'eveningSession': data['eveningSession'],
  //         };
  //       } else {
  //         throw Exception('Failed to fetch doctor schedule');
  //       }
  //     } else {
  //       throw Exception('API returned status code ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('Error fetching doctor schedule');
  //   }
  // }
  Future<Map<String, dynamic>> _fetchDoctorSchedule() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    if (token == null) {
      throw Exception('No token found');
    }

    final decodedToken = JwtDecoder.decode(token);
    final doctorId = decodedToken['id'];

    final url = ApiConstants.getDoctorAvailabilityUrl(doctorId);

    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('API error ${response.statusCode}');
    }

    final responseBody = jsonDecode(response.body);
    final data = responseBody['data'];

    if (data == null) {
      throw Exception('Schedule data missing');
    }

    /// 🔹 CASE 1: New structure → schedule object
    if (data['schedule'] != null) {
      final schedule = data['schedule'];

      // Normal schedule (morning + evening)
      if (schedule['morningSession'] != null &&
          schedule['eveningSession'] != null) {
        return {
          'morningSession': schedule['morningSession'],
          'eveningSession': schedule['eveningSession'],
        };
      }

      // Multi-section schedule → allow all times (backend already filtered)
      if (schedule['useMultipleSections'] == true) {
        return {
          'morningSession': {
            'enabled': true,
            'start': '12:00 AM',
            'end': '11:59 PM',
          },
          'eveningSession': {
            'enabled': true,
            'start': '12:00 AM',
            'end': '11:59 PM',
          },
        };
      }
    }

    /// 🔹 CASE 2: Old backend structure (fallback)
    if (data['morningSession'] != null &&
        data['eveningSession'] != null) {
      return {
        'morningSession': data['morningSession'],
        'eveningSession': data['eveningSession'],
      };
    }

    /// 🔹 Final fallback → never crash UI
    return {
      'morningSession': {
        'enabled': true,
        'start': '12:00 AM',
        'end': '11:59 PM',
      },
      'eveningSession': {
        'enabled': true,
        'start': '12:00 AM',
        'end': '11:59 PM',
      },
    };
  } catch (e) {
    print('Schedule fetch warning (fallback used): $e');

    // 🔹 Safe fallback (never block slots)
    return {
      'morningSession': {
        'enabled': true,
        'start': '12:00 AM',
        'end': '11:59 PM',
      },
      'eveningSession': {
        'enabled': true,
        'start': '12:00 AM',
        'end': '11:59 PM',
      },
    };
  }
}


  Future<void> _fetchAvailableSlots() async {
    setState(() {
      _isFetchingSlots = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) throw Exception('No token found');

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String doctorId = decodedToken['id'];

      // First, fetch the doctor's schedule
      final schedule = await _fetchDoctorSchedule();
      print('Doctor Schedule in add patient page: $schedule');

      final response = await http.get(
        Uri.parse(ApiConstants.doctorAvailableSlots(doctorId)),
        headers: {'Content-Type': 'application/json'},
      );
   print('Fetching available slots for doctorId: $doctorId');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Available Slots Response Data: $data');
        if (data['success'] == true && data['availableSlots'] != null) {
          List<dynamic> slots = data['availableSlots'];

          DateTime now = DateTime.now();

          // Use a DateFormat to parse the time string (e.g. "8:00 AM")
          DateFormat timeFormat = DateFormat("h:mm a");

          // Filter slots to show only the ones that are after the current time AND within doctor's schedule
          List<Map<String, dynamic>> filteredSlots = slots
              .where((slot) {
                // Parse the start time
                DateTime parsedTime = timeFormat.parse(slot['start']);

                // Create a DateTime object using today's date and the parsed time
                DateTime slotStartTime = DateTime(now.year, now.month, now.day,
                    parsedTime.hour, parsedTime.minute);

                // Only include slots that are in the future AND within the doctor's schedule
                return !slotStartTime.isBefore(now) &&
                    _isTimeWithinSchedule(slot['start'], schedule);
              })
              .map<Map<String, dynamic>>((slot) => {
                    'start': slot['start'] as String,
                    'end': slot['end'] as String,
                  })
              .toList();

          setState(() {
            _availableSlots = filteredSlots;
          });
        }
      } else {
        print('Failed to load available slots, status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load available slots');
      }
    } catch (e) {
      print('Error fetching available slots: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error loading time slots')));
    } finally {
      setState(() {
        _isFetchingSlots = false;
      });
    }
  }

  Future<void> _fetchPatientByPhone(String phone) async {
    setState(() {
      _isFetchingPatient = true;
      _fieldsEnabled = false;
      _autoFilled = false;
    });
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.getPatients()}/phone/$phone'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null &&
            data is Map<String, dynamic> &&
            data['name'] != null) {
          setState(() {
            _nameController.text = data['name'] ?? '';
            _symptomsController.text = data['symptoms'] ?? '';
            _name = data['name'] ?? '';
            _symptoms = data['symptoms'] ?? '';
            _fieldsEnabled = false;
            _autoFilled = true;
            patientId = data['_id'];
          });
          CustomToast.show(
              context, "Patient fetched successfully", ToastType.success);
        } else if (data is List && data.isNotEmpty) {
          final patient = data[0];
          setState(() {
            _nameController.text = patient['name'] ?? '';
            _symptomsController.text = patient['symptoms'] ?? '';
            _name = patient['name'] ?? '';
            _symptoms = patient['symptoms'] ?? '';
            _fieldsEnabled = false;
            _autoFilled = true;
            patientId = patient['_id'];
          });
          CustomToast.show(
              context, "Patient fetched successfully", ToastType.success);
        } else {
          setState(() {
            _fieldsEnabled = true;
            _autoFilled = false;
            _nameController.clear();
            _symptomsController.clear();
            patientId = null;
          });
          CustomToast.show(
              context, "Patient not available, you can create a new patient", ToastType.error);
        }
      } else {
        setState(() {
          _fieldsEnabled = true;
          _autoFilled = false;
          _nameController.clear();
          _symptomsController.clear();
          patientId = null;
        });
        CustomToast.show(
            context, "Patient not available, you can create a new patient", ToastType.error);
      }
    } catch (e) {
      setState(() {
        _fieldsEnabled = true;
        _autoFilled = false;
        _nameController.clear();
        _symptomsController.clear();
        patientId = null;
      });
      CustomToast.show(
          context, "Patient not available, you can create a new patient", ToastType.error);
    } finally {
      setState(() {
        _isFetchingPatient = false;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('authToken');
        if (token == null) throw Exception('No token found');

        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String doctorId = decodedToken['id'];

        // Fetch doctor's schedule
        final schedule = await _fetchDoctorSchedule();

        // Check if the emergency queue system can be used at current time
        if (_selectedemergencyDuration > 0) {
          // Get current time in the format required by _isTimeWithinSchedule
          String currentTimeString =
              DateFormat('h:mm a').format(DateTime.now());

          if (!_isTimeWithinSchedule(currentTimeString, schedule)) {
            CustomToast.show(
                context,
                "The doctor is currently unavailable, so you cannot use the queue system at this time.",
                ToastType.error);
            setState(() {
              _isLoading = false;
            });
            return;
          }
        }
        // For regular appointments, we don't need validation here as
        // the dropdown will only contain valid time slots after our filtering

        // Create the request body
        Map<String, dynamic> requestBody = {
          'name': _name,
          'phoneNumber': _phone,
          'symptoms': _symptoms,
          'createdBy': doctorId,
          'appointmentDate': _selectedDate.toIso8601String(),
        };

        // Add either startTime OR emergencyDuration based on what was selected
        if (_selectedemergencyDuration > 0) {
          requestBody['emergencyDuration'] = _selectedemergencyDuration;
        } else if (_selectedTimeSlot.isNotEmpty) {
          requestBody['startTime'] = _selectedTimeSlot;
        }

        if (patientId != null) {
          requestBody['existingId'] = patientId; // <-- Add this line
        }

        final response = await http.post(
          Uri.parse(ApiConstants.getAddPatientUrl()),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestBody),
        );

        if (response.statusCode != 200 && response.statusCode != 201) {
          CustomToast.show(context, "Failed to add patient: ${response.body}",
              ToastType.error);
          setState(() {
            _isLoading = false;
          });
          return;
        }

        final patient = Patient(
          name: _name,
          phone: _phone,
          symptoms: _symptoms,
          appointmentTime: _selectedTimeSlot,
          appointmentDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
        );

        Provider.of<PatientProvider>(context, listen: false)
            .addPatient(patient);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DoctorMainPage()),
        );
        CustomToast.show(
            context, "Patient added successfully.", ToastType.success);
      } catch (e) {
        CustomToast.show(context, "Error: $e", ToastType.error);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildDateTimeRow() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFF6B0D24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Image.asset('assets/images/calendar-outline.png',
                    width: 24, height: 24, color: Color(0xFF6B0D24)),
                const SizedBox(width: 8),
                Text(DateFormat('dd-MM-yyyy').format(_selectedDate)),
              ],
            ),
          ),
          Container(width: 1, height: 24, color: Colors.grey[300]),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Image.asset('assets/images/clock-outline.png',
                    width: 24, height: 24, color: Color(0xFF6B0D24)),
                const SizedBox(width: 8),
                Expanded(
                  child: _isFetchingSlots
                      ? Center(
                          child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2)))
                      : DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: Text("Select time"),
                            value: _selectedTimeSlot.isEmpty
                                ? null
                                : _selectedTimeSlot,
                            items: _availableSlots.map((slot) {
                              return DropdownMenuItem<String>(
                                value: slot['start'],
                                child: Text(slot['start']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedTimeSlot = value ?? '';
                                // Clear emergency duration when time slot is selected
                                if (_selectedTimeSlot.isNotEmpty) {
                                  _selectedemergencyDuration = 0;
                                }
                              });
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

   Widget _buildDurationButton(int min) {
  bool noSlotsAvailable = _availableSlots.isEmpty;

  return OutlinedButton(
    onPressed: noSlotsAvailable ? null : () => _updateDurationButton(min),
    style: OutlinedButton.styleFrom(
      backgroundColor: _selectedemergencyDuration == min
          ? Color(0xFF6B0D24)
          : null,
      side: BorderSide(
        color: Color(0xFF6B0D24),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    child: Text(
      "$min Minutes",
      style: TextStyle(
        color: _selectedemergencyDuration == min
            ? Colors.white
            : Color(0xFF6B0D24),
      ),
    ),
  );
}

  Widget _buildDurationButton(int min) {
    return OutlinedButton(
      onPressed: () => _updateDurationButton(min),
      style: OutlinedButton.styleFrom(
        backgroundColor:
            _selectedemergencyDuration == min ? Color(0xFF6B0D24) : null,
        side: BorderSide(
          color: Color(0xFF6B0D24),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        "$min Minutes",
        style: TextStyle(
          color: _selectedemergencyDuration == min
              ? Colors.white
              : Color(0xFF6B0D24),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String icon,
    required String hintText,
    required Function(String?) onSaved,
    required Function(String) onChanged,
    FormFieldValidator<String>? validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    TextEditingController? controller,
    bool enabled = true, required TextStyle hintStyle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFF6B0D24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Image.asset(icon, width: 24, height: 24, color: Color(0xFF6B0D24)),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              enabled: enabled,
              decoration:
                  InputDecoration(border: InputBorder.none, hintText: hintText),
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              onSaved: onSaved,
              onChanged: onChanged,
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130),
        child: Container(
          height: 130,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            bottom: 12,
          ),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg-header.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const Center(
                child: Text(
                  "Add Patient",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Color(0xFF680C20),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF6F6F6),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isFetchingPatient)
                    // Center(child: CircularProgressIndicator()),
                    const Text("Phone",
                        style: TextStyle(fontSize: 14, fontFamily: 'Poppins')),
                  const SizedBox(height: 8),
                  _buildTextField(
                    icon: 'assets/images/call-outline.png',
                    hintText: "Enter phone number",
                    hintStyle: TextStyle(color: Colors.grey),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10)
                    ],
                    controller: _phoneController,
                    enabled: true,
                    onChanged: (val) async {
                      if (val.length == 10) {
                        await _fetchPatientByPhone(val);
                      } else {
                        setState(() {
                          _fieldsEnabled = false;
                          _autoFilled = false;
                          _nameController.clear();
                          _symptomsController.clear();
                        });
                      }
                    },
                    onSaved: (val) => _phone = val ?? '',
                    validator: (val) {
                      if (val == null || val.isEmpty)
                        return "Enter phone number";
                      if (!RegExp(r'^[0-9]{10}$').hasMatch(val))
                        return "Enter valid 10-digit number";
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text("Full Name",
                      style: TextStyle(fontSize: 14, fontFamily: 'Poppins')),
                  const SizedBox(height: 8),
                  if (_isFetchingPatient)
                    Center(child: CircularProgressIndicator()),
                  _buildTextField(
                    icon: 'assets/images/profile-icon.png',
                    hintText: "Enter patient name",
                    hintStyle: TextStyle(color: Colors.grey),
                    controller: _nameController,
                    enabled: _autoFilled
                        ? false
                        : _fieldsEnabled, // Disabled if patient found
                    onChanged: (val) => _name = val,
                    onSaved: (val) => _name = val ?? '',
                    validator: (val) {
                      if (val == null || val.isEmpty) return "Enter a name";
                      if (val.trim().isEmpty)
                        return "Name cannot be only spaces";
                      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(val.trim()))
                        return "Please enter a valid name";
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text("Symptoms",
                      style: TextStyle(fontSize: 14, fontFamily: 'Poppins')),
                      const SizedBox(height: 8),
                  _buildTextField(
                    icon: 'assets/images/symptoms-icon.png',
                    hintText: "Tell us about your symptoms/diseases",
                    hintStyle: TextStyle(color: Colors.grey),
                    controller: _symptomsController,
                    enabled: _autoFilled
                        ? true
                        : _fieldsEnabled, // Only enabled if patient found or all fields enabled
                    onChanged: (val) => _symptoms = val,
                    onSaved: (val) => _symptoms = val ?? '',
                  ),
                  const SizedBox(height: 20),
                  Text("Appointment Schedule",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  _buildDateTimeRow(),
                  const SizedBox(height: 25),
                  Center(
                    child: Text(
                      "Or add them to today's queue after",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildDurationButton(5),
                        const SizedBox(width: 10),
                        _buildDurationButton(10),
                        const SizedBox(width: 10),
                        _buildDurationButton(20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Color(0xFFF6F6F6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isLoading || !_isFormValid() ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6B0D24),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(27),
              ),
            ),
            child: _isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text("Submit", style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  bool _isTimeWithinSchedule(
      String selectedTime, Map<String, dynamic> schedule) {
    final selected = _parseTime(selectedTime);

    final morningStart = _parseTime(schedule['morningSession']['start']);
    final morningEnd = _parseTime(schedule['morningSession']['end']);
    final eveningStart = _parseTime(schedule['eveningSession']['start']);
    final eveningEnd = _parseTime(schedule['eveningSession']['end']);

    if (schedule['morningSession']['enabled'] &&
        !selected.isBefore(morningStart) &&
        selected.isBefore(morningEnd)) {
      return true;
    }

    if (schedule['eveningSession']['enabled'] &&
        !selected.isBefore(eveningStart) &&
        selected.isBefore(eveningEnd)) {
      return true;
    }

    return false;
  }

  // Helper method to parse time strings into DateTime objects
  DateTime _parseTime(String time) {
    final format = DateFormat.jm(); // e.g., "08:00 AM"
    return format.parse(time);
  }
}
