import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../constants/api_constants.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import 'package:intl/intl.dart';
import '../services/socket_service.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class AppointmentsPage extends StatefulWidget {
  final Function(int, bool, List<Map<String, dynamic>>) onTotalAppointmentsFetched;
  const AppointmentsPage({Key? key, required this.onTotalAppointmentsFetched})
      : super(key: key);

  @override
  AppointmentsPageState createState() => AppointmentsPageState();
}

class AppointmentsPageState extends State<AppointmentsPage> with RouteAware {
  List<Map<String, dynamic>> appointments = [];
  List<bool> statuses = [];
  bool isLoading = true;
  int totalAppointments = 0;
  Timer? _timer;
  bool isReordering = false;
  late SocketService socketService;
  bool socketConnected = false;


  @override
  void initState() {
    super.initState();
  connectSocket();
  setupFirebaseNotificationListener();
  fetchAppointments();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    _timer?.cancel();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    startPeriodicFetch();
  }

  @override
  void didPopNext() {
    startPeriodicFetch();
  }

  @override
  void didPop() {
    stopPeriodicFetch();
  }

  @override
  void didPushNext() {
    stopPeriodicFetch();
  }

//function to connect to socket server
  void connectSocket() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('authToken');
  if (token == null) return;

  final decoded = JwtDecoder.decode(token);
  final doctorId = decoded['id'];

  socketService = SocketService();
  socketService.connect(
    baseUrl:  'https://app.ayamtechs.com',
    token: token,
    clientId: doctorId,
    role: 'doctor',
    doctorId: doctorId, // pass it in here
  );

  // Listen for real-time events
  // socketService.on('queue_update', (data) {
  //   print("📡 Queue update received → $data");
  //   fetchAppointments();
  // });

socketService.on('queue_update', (data) {
    setState(() {
      appointments = data['appointments'].map((a) => {
        'id': a['_id'],
        'name': a['patient']['name'],
        'checkIn': a['checkIn'],
        'time': a['startTime'],
        'status': a['status'],
      }).toList();
    });
  });

  // socketService.on('patient_moved', (data) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text("${data['patientName']} is ${data['distanceMeters']}m away")),
  //   );
  // });
  // socketService.on('distance_update', (data) {
  //   print("🚗 Patient distance update → $data");
  // });

  socketService.on('queue_count', (data) {
    print("👥 Queue count update → ${data['appointmentCount']}");
  });
}
  void setupFirebaseNotificationListener() {
    if (kIsWeb) return;
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      fetchAppointments();
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      fetchAppointments();
    });
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) fetchAppointments();
    });
  }

  void startPeriodicFetch() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      fetchAppointments();
    });
  }

  void stopPeriodicFetch() {
    _timer?.cancel();
  }

  bool checkIfPast(String timeString) {
    try {
      DateFormat format = DateFormat("hh:mm a");
      DateTime parsedTime = format.parse(timeString);
      DateTime now = DateTime.now();
      DateTime appointmentTime = DateTime(
        now.year,
        now.month,
        now.day,
        parsedTime.hour,
        parsedTime.minute,
      );
      return appointmentTime.isBefore(now);
    } catch (e) {
      return false;
    }
  }

  Future<void> fetchAppointments() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');
      if (token == null) throw Exception('No token found');

      Map decodedToken = JwtDecoder.decode(token);
      String doctorId = decodedToken['id'];

      final response = await http.get(
        Uri.parse(ApiConstants.getActiveAppointmentsUrl(doctorId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('message') &&
            responseData['message'] == 'No appointments found for today.') {
          setState(() {
            isLoading = false;
            appointments = [];
            totalAppointments = 0;
            widget.onTotalAppointmentsFetched(totalAppointments, false, appointments);
            stopPeriodicFetch();
          });
          return;
        }
        List<dynamic> data = responseData['appointments'] ?? [];
        List<Map<String, dynamic>> filtered = data
            .where((item) => item['appointmentObj']?['status'] != 'Completed')
            .map((item) {
          var appointment = item['appointmentObj'];
          var patient = appointment['patient'];
          // Safely handle patient being null or empty
          if (patient == null || patient.isEmpty) {
            return {
              'id': item['_id'],
              'name': 'Unknown',
              'symptom': 'N/A',
              'time': appointment['startTime'],
              'image': 'assets/images/patient_icon.png',
              'checkIn': appointment['checkIn'],
              'isEmergency': false,
              'status': appointment['status'],
            };
          }
          int? emergencyDuration =
                  int.tryParse(appointment['emergencyDuration']?.toString() ?? '0');
          bool isEmergency = emergencyDuration != null && emergencyDuration > 0;

          return {
            'id': item['_id'],
            'name': patient['name'] ?? 'Unknown',
            'symptom': patient['symptoms'] ?? 'N/A',
            'time': appointment['startTime'],
            'image': 'assets/images/patient_icon.png',
            'checkIn': appointment['checkIn'],
            'isEmergency': isEmergency,
            'status': appointment['status'],
            'isPast': checkIfPast(appointment['startTime']),
          };
        }).toList();
        DateFormat format = DateFormat("hh:mm a");
        filtered.sort((a, b) {
          if (a['status'] == 'Active' && b['status'] != 'Active') return -1;
          if (a['status'] != 'Active' && b['status'] == 'Active') return 1;
          try {
            DateTime timeA = format.parse(a['time']);
            DateTime timeB = format.parse(b['time']);
            return timeA.compareTo(timeB);
          } catch (e) {
            return 0;
          }
        });
        bool isFirstCheckedIn =
            filtered.isNotEmpty && filtered[0]['checkIn'] == true;
        setState(() {
          isLoading = false;
          appointments = filtered;
          statuses = filtered.map((appt) => appt['checkIn'] as bool).toList();
          totalAppointments = filtered.length;
          widget.onTotalAppointmentsFetched(
              totalAppointments, isFirstCheckedIn, appointments);
          startPeriodicFetch();
        });
      } else {
        throw Exception('Failed to load appointments');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        appointments = [];
        totalAppointments = 0;
        widget.onTotalAppointmentsFetched(0, false, appointments);
        stopPeriodicFetch();
      });
    }
  }

  Future<void> reorderAppointments() async {
    try {
      setState(() => isReordering = true);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');
      if (token == null) throw Exception('No token found');

      Map decodedToken = JwtDecoder.decode(token);
      String doctorId = decodedToken['id'];
      final String appointmentDate =
          DateTime.now().toIso8601String().split('T')[0];

      List<String> appointmentIds =
          appointments.map((appt) => appt['id'].toString()).toList();

      final response = await http.put(
        Uri.parse(ApiConstants.reorderAppointmentsUrl(doctorId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'doctorId': doctorId,
          'appointmentDate': appointmentDate,
          'appointmentIds': appointmentIds,
        }),
      );
      if (response.statusCode == 200) {
        fetchAppointments();
      } else {
        print('❌ Failed to reorder appointments');
      }
    } catch (e) {
    } finally {
      setState(() => isReordering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : appointments.isEmpty
                ? const Center(
                    child: Text(
                      'No Appointments Today',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : Stack(
                    children: [
                      ReorderableListView.builder(
                        buildDefaultDragHandles: false,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: appointments.length,
                        onReorder: (oldIndex, newIndex) {
                          final fromItem = appointments[oldIndex];

                          if (fromItem['status'] == 'Active' ||
                              fromItem['isPast'] == true ||
                              (newIndex < appointments.length &&
                                  (appointments[newIndex]['status'] ==
                                          'Active' ||
                                      appointments[newIndex]['isPast'] ==
                                          true))) {
                            return;
                          }
                          setState(() {
                            if (newIndex > oldIndex) newIndex--;
                            final item = appointments.removeAt(oldIndex);
                            final status = statuses.removeAt(oldIndex);
                            appointments.insert(newIndex, item);
                            statuses.insert(newIndex, status);
                          });

                          reorderAppointments();
                        },
                        itemBuilder: (context, index) {
                          final appointment = appointments[index];
                          final status = statuses[index];
                          final isActive = appointment['status'] == 'Active';

                          return Container(
                            key: ValueKey('$index'),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isActive
                                    ? Colors.green
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                          color: Colors.green.withOpacity(0.2),
                                          blurRadius: 6,
                                          offset: Offset(0, 3))
                                    ]
                                  : [
                                      BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          offset: Offset(0, 2))
                                    ],
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundImage: AssetImage(
                                    'assets/images/patient_icon.png'),
                                backgroundColor: Colors.grey.shade200,
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      appointment['name']!,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ),
                                  if (appointment['isEmergency'] == true)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      child: Text(
                                        'Emergency',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Text(
                                '${appointment['symptom']} (${appointment['time']})',
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 14),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    status
                                        ? 'assets/images/location-check-in.png'
                                        : 'assets/images/location-not-check.png',
                                    width: 24,
                                    height: 24,
                                  ),
                                  SizedBox(width: 8),
                                  appointment['status'] != 'Active' &&
                                          appointment['isPast'] != true
                                      ? ReorderableDragStartListener(
                                          index: index,
                                          child: Icon(Icons.menu_sharp),
                                        )
                                      : SizedBox(width: 24),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      if (isReordering)
                        Positioned.fill(
                          child: Container(
                            color: Colors.white.withOpacity(0.5),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }
}
