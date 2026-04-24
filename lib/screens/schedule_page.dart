// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../services/schedule_api_service.dart';
// import 'main_page.dart';
// import '../constants/api_constants.dart';

// class SchedulePage extends StatefulWidget {
//   final String doctorId;
//   final bool showAppBar;

//   const SchedulePage({
//     required this.doctorId,
//     this.showAppBar = false,
//     super.key,
//     Map<String, dynamic>? scheduleData
//   });

//   @override
//   State<SchedulePage> createState() => _SchedulePageState();
// }

// class _SchedulePageState extends State<SchedulePage> {
//   late ScheduleApiService _apiService;
//   bool _isLoading = true;

//   // Morning session data
//  // ✅ SECTION A (Weekday Schedule)
// bool sectionA_MorningEnabled = true;
// String sectionA_MorningStart = '08:00 AM';
// String sectionA_MorningEnd = '02:00 PM';
// List<bool> sectionA_MorningDays = [false, true, true, true, true, true, false];

// bool sectionA_EveningEnabled = true;
// String sectionA_EveningStart = '04:00 PM';
// String sectionA_EveningEnd = '08:00 PM';
// List<bool> sectionA_EveningDays = [false, true, true, true, true, true, false];

// // ✅ SECTION B (Saturday-Sunday Schedule)
// bool sectionB_MorningEnabled = false;
// String sectionB_MorningStart = '09:00 AM';
// String sectionB_MorningEnd = '01:00 PM';
// List<bool> sectionB_MorningDays = [true, false, false, false, false, false, true];

// bool sectionB_EveningEnabled = false;
// String sectionB_EveningStart = '03:00 PM';
// String sectionB_EveningEnd = '06:00 PM';
// List<bool> sectionB_EveningDays = [true, false, false, false, false, false, true];

// // ✅ GLOBAL appointment duration (NOT per-section)
// String selectedDuration = "15 Minutes";

// // Common schedule settings (UNCHANGED)
// String repeatEvery = "1";
// String repeatPeriod = "Week";
// bool neverEnds = true;
// DateTime? endDate;
// String status = "Active";
// bool showSummary = false;
// DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));

//   final List<String> timeOptions = [
//     '12:00 AM', '12:30 AM', '01:00 AM', '01:30 AM', '02:00 AM', '02:30 AM',
//     '03:00 AM', '03:30 AM', '04:00 AM', '04:30 AM', '05:00 AM', '05:30 AM',
//     '06:00 AM', '06:30 AM', '07:00 AM', '07:30 AM', '08:00 AM', '08:30 AM',
//     '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM',
//     '12:00 PM', '12:30 PM', '01:00 PM', '01:30 PM', '02:00 PM', '02:30 PM',
//     '03:00 PM', '03:30 PM', '04:00 PM', '04:30 PM', '05:00 PM', '05:30 PM',
//     '06:00 PM', '06:30 PM', '07:00 PM', '07:30 PM', '08:00 PM', '08:30 PM',
//     '09:00 PM', '09:30 PM', '10:00 PM', '10:30 PM', '11:00 PM', '11:30 PM',
//   ];

//   final List<String> durationOptions = [
//     '5 Minutes',
//     '10 Minutes',
//     '15 Minutes',
//     '20 Minutes'
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _apiService = ScheduleApiService(baseUrl: ApiConstants.baseUrl);
//     _fetchScheduleData();
//   }

// //   Future<void> _fetchScheduleData() async {
// //     setState(() {
// //       _isLoading = true;
// //     });

// //     try {
// //       final availability = await _apiService.fetchSchedule(widget.doctorId);
// //   print('Fetched availability: $availability');
// // if (availability == null) {
// //   setState(() {
// //     _isLoading = false;
// //   });
// //   return;
// // }

// // final scheduleData = availability.schedule;
// // print('Schedule Data: $scheduleData');


// //       setState(() {
// //         // Morning session
// //         morningSessionEnabled = scheduleData.morningSession.enabled;
// //         morningStartTime = scheduleData.morningSession.start.isNotEmpty
// //             ? scheduleData.morningSession.start
// //             : '08:00 AM';
// //         morningEndTime = scheduleData.morningSession.end.isNotEmpty
// //             ? scheduleData.morningSession.end
// //             : '02:00 PM';
        
// //         // Load morning selected days if available
// //         if (scheduleData.morningSession.selectedDays != null && 
// //             scheduleData.morningSession.selectedDays!.length == 7) {
// //           morningSelectedDays = List<bool>.from(scheduleData.morningSession.selectedDays!);
// //         }

// //         // Evening session
// //         eveningSessionEnabled = scheduleData.eveningSession.enabled;
// //         eveningStartTime = scheduleData.eveningSession.start.isNotEmpty
// //             ? scheduleData.eveningSession.start
// //             : '04:00 PM';
// //         eveningEndTime = scheduleData.eveningSession.end.isNotEmpty
// //             ? scheduleData.eveningSession.end
// //             : '08:00 PM';
        
// //         // Load evening selected days if available
// //         if (scheduleData.eveningSession.selectedDays != null && 
// //             scheduleData.eveningSession.selectedDays!.length == 7) {
// //           eveningSelectedDays = List<bool>.from(scheduleData.eveningSession.selectedDays!);
// //         }

// //         // Common settings
// //         repeatEvery = scheduleData.repeatEvery;
// //         repeatPeriod = scheduleData.repeatPeriod;
// //         neverEnds = scheduleData.neverEnds;
        
// //         if (scheduleData.endDate != null) {
// //           endDate = scheduleData.endDate;
// //           _selectedDate = scheduleData.endDate!;
// //         }

// //         selectedDuration = scheduleData.appointmentDuration;
// //         status = scheduleData.status;
// //       });
// //     } catch (e) {
// //       print('Error fetching schedule data: $e');
// //       showCustomToast(context, "Failed to load schedule data", isSuccess: false);
// //     } finally {
// //       setState(() {
// //         _isLoading = false;
// //       });
// //     }
// //   }

// Future<void> _fetchScheduleData() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final availability = await _apiService.fetchSchedule(widget.doctorId);
//       print('Fetched availability: $availability');
      
//       if (availability == null) {
//         setState(() {
//           _isLoading = false;
//         });
//         return;
//       }

//       final scheduleData = availability.schedule;
//       print('Schedule Data: $scheduleData');

//       setState(() {
//         // Load global appointment duration
//         selectedDuration = scheduleData.appointmentDuration;

//         // Check if multi-section or legacy
//         if (scheduleData.useMultipleSections && 
//             scheduleData.scheduleSections != null && 
//             scheduleData.scheduleSections!.isNotEmpty) {
          
//           // ✅ Load Section A
//           final sectionA = scheduleData.scheduleSections!.firstWhere(
//             (s) => s.sectionName == 'A',
//             orElse: () => _getDefaultSection('A'),
//           );
          
//           sectionA_MorningEnabled = sectionA.morningSession.enabled;
//           sectionA_MorningStart = sectionA.morningSession.start.isNotEmpty 
//               ? sectionA.morningSession.start 
//               : '08:00 AM';
//           sectionA_MorningEnd = sectionA.morningSession.end.isNotEmpty 
//               ? sectionA.morningSession.end 
//               : '02:00 PM';
//           sectionA_MorningDays = sectionA.morningSession.selectedDays != null && 
//               sectionA.morningSession.selectedDays!.length == 7
//               ? List<bool>.from(sectionA.morningSession.selectedDays!)
//               : [false, true, true, true, true, true, false];

//           sectionA_EveningEnabled = sectionA.eveningSession.enabled;
//           sectionA_EveningStart = sectionA.eveningSession.start.isNotEmpty 
//               ? sectionA.eveningSession.start 
//               : '04:00 PM';
//           sectionA_EveningEnd = sectionA.eveningSession.end.isNotEmpty 
//               ? sectionA.eveningSession.end 
//               : '08:00 PM';
//           sectionA_EveningDays = sectionA.eveningSession.selectedDays != null && 
//               sectionA.eveningSession.selectedDays!.length == 7
//               ? List<bool>.from(sectionA.eveningSession.selectedDays!)
//               : [false, true, true, true, true, true, false];

//           // ✅ Load Section B (Saturday-Sunday)
//           final sectionB = scheduleData.scheduleSections!.firstWhere(
//             (s) => s.sectionName == 'Saturday-Sunday',
//             orElse: () => _getDefaultSection('Saturday-Sunday'),
//           );
          
//           sectionB_MorningEnabled = sectionB.morningSession.enabled;
//           sectionB_MorningStart = sectionB.morningSession.start.isNotEmpty 
//               ? sectionB.morningSession.start 
//               : '09:00 AM';
//           sectionB_MorningEnd = sectionB.morningSession.end.isNotEmpty 
//               ? sectionB.morningSession.end 
//               : '01:00 PM';
//           sectionB_MorningDays = sectionB.morningSession.selectedDays != null && 
//               sectionB.morningSession.selectedDays!.length == 7
//               ? List<bool>.from(sectionB.morningSession.selectedDays!)
//               : [true, false, false, false, false, false, true];

//           sectionB_EveningEnabled = sectionB.eveningSession.enabled;
//           sectionB_EveningStart = sectionB.eveningSession.start.isNotEmpty 
//               ? sectionB.eveningSession.start 
//               : '03:00 PM';
//           sectionB_EveningEnd = sectionB.eveningSession.end.isNotEmpty 
//               ? sectionB.eveningSession.end 
//               : '06:00 PM';
//           sectionB_EveningDays = sectionB.eveningSession.selectedDays != null && 
//               sectionB.eveningSession.selectedDays!.length == 7
//               ? List<bool>.from(sectionB.eveningSession.selectedDays!)
//               : [true, false, false, false, false, false, true];
//         } else {
//           // 🔄 Legacy data - load into Section A, keep Section B disabled
//           sectionA_MorningEnabled = scheduleData.morningSession!.enabled;
//           sectionA_MorningStart = scheduleData.morningSession!.start.isNotEmpty
//               ? scheduleData.morningSession!.start
//               : '08:00 AM';
//           sectionA_MorningEnd = scheduleData.morningSession!.end.isNotEmpty
//               ? scheduleData.morningSession!.end
//               : '02:00 PM';
          
//           if (scheduleData.morningSession!.selectedDays != null && 
//               scheduleData.morningSession!.selectedDays!.length == 7) {
//             sectionA_MorningDays = List<bool>.from(scheduleData.morningSession!.selectedDays!);
//           }

//           sectionA_EveningEnabled = scheduleData.eveningSession!.enabled;
//           sectionA_EveningStart = scheduleData.eveningSession!.start.isNotEmpty
//               ? scheduleData.eveningSession!.start
//               : '04:00 PM';
//           sectionA_EveningEnd = scheduleData.eveningSession!.end.isNotEmpty
//               ? scheduleData.eveningSession!.end
//               : '08:00 PM';
          
//           if (scheduleData.eveningSession!.selectedDays != null && 
//               scheduleData.eveningSession!.selectedDays!.length == 7) {
//             sectionA_EveningDays = List<bool>.from(scheduleData.eveningSession!.selectedDays!);
//           }

//           // Section B remains disabled (default values already set)
//         }

//         // Common settings
//         repeatEvery = scheduleData.repeatEvery;
//         repeatPeriod = scheduleData.repeatPeriod;
//         neverEnds = scheduleData.neverEnds;
        
//         if (scheduleData.endDate != null) {
//           endDate = scheduleData.endDate;
//           _selectedDate = scheduleData.endDate!;
//         }

//         status = scheduleData.status;
//       });
//     } catch (e) {
//       print('Error fetching schedule data: $e');
//       showCustomToast(context, "Failed to load schedule data", isSuccess: false);
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
  
//   // Helper: Get default section structure
//   SectionData _getDefaultSection(String sectionName) {
//     if (sectionName == 'A') {
//       return SectionData(
//         sectionName: 'A',
//         morningSession: SessionData(
//           enabled: true,
//           start: '08:00 AM',
//           end: '02:00 PM',
//           selectedDays: [false, true, true, true, true, true, false],
//         ),
//         eveningSession: SessionData(
//           enabled: true,
//           start: '04:00 PM',
//           end: '08:00 PM',
//           selectedDays: [false, true, true, true, true, true, false],
//         ),
//         isActive: true,
//       );
//     } else {
//       return SectionData(
//         sectionName: 'Saturday-Sunday',
//         morningSession: SessionData(
//           enabled: false,
//           start: '09:00 AM',
//           end: '01:00 PM',
//           selectedDays: [true, false, false, false, false, false, true],
//         ),
//         eveningSession: SessionData(
//           enabled: false,
//           start: '03:00 PM',
//           end: '06:00 PM',
//           selectedDays: [true, false, false, false, false, false, true],
//         ),
//         isActive: true,
//       );
//     }
//   }

//   // Future<void> _saveScheduleData() async {
//   //   // Validation: Check for time overlaps
//   //   if (morningSessionEnabled && eveningSessionEnabled) {
//   //     if (!_validateNoTimeOverlap()) {
//   //       showCustomToast(
//   //         context, 
//   //         "Morning and Evening sessions have overlapping times!", 
//   //         isSuccess: false
//   //       );
//   //       return;
//   //     }
//   //   }

//   //   // Validation: At least one day must be selected for enabled sessions
//   //   if (morningSessionEnabled && !morningSelectedDays.contains(true)) {
//   //     showCustomToast(
//   //       context, 
//   //       "Please select at least one day for Morning session", 
//   //       isSuccess: false
//   //     );
//   //     return;
//   //   }

//   //   if (eveningSessionEnabled && !eveningSelectedDays.contains(true)) {
//   //     showCustomToast(
//   //       context, 
//   //       "Please select at least one day for Evening session", 
//   //       isSuccess: false
//   //     );
//   //     return;
//   //   }

//   //   setState(() {
//   //     _isLoading = true;
//   //   });

//   //   try {
//   //     final morningSession = SessionData(
//   //       enabled: morningSessionEnabled,
//   //       start: morningStartTime,
//   //       end: morningEndTime,
//   //       selectedDays: List<bool>.from(morningSelectedDays),
//   //     );

//   //     final eveningSession = SessionData(
//   //       enabled: eveningSessionEnabled,
//   //       start: eveningStartTime,
//   //       end: eveningEndTime,
//   //       selectedDays: List<bool>.from(eveningSelectedDays),
//   //     );

//   //     final scheduleData = ScheduleData(
//   //       doctorId: widget.doctorId,
//   //       dayOfWeek: 'Monday', // Legacy field
//   //       morningSession: morningSession,
//   //       eveningSession: eveningSession,
//   //       appointmentDuration: selectedDuration,
//   //       repeatEvery: repeatEvery,
//   //       repeatPeriod: repeatPeriod,
//   //       selectedDays: _getCombinedSelectedDays(), // Legacy combined days
//   //       neverEnds: neverEnds,
//   //       status: status,
//   //       endDate: neverEnds ? null : _selectedDate,
//   //     );

//   //     bool success = await _apiService.updateSchedule(scheduleData);

//   //     if (!success) {
//   //       success = await _apiService.saveSchedule(scheduleData);
//   //     }

//   //     if (success) {
//   //       setState(() {
//   //         showSummary = true;
//   //       });
//   //       showCustomToast(context, "Schedule saved successfully.", isSuccess: true);
//   //       if (widget.showAppBar) {
//   //         Navigator.push(
//   //           context,
//   //           MaterialPageRoute(builder: (context) => DoctorMainPage()),
//   //         );
//   //       }
//   //     } else {
//   //       showCustomToast(context, "Failed to save schedule.", isSuccess: false);
//   //     }
//   //   } catch (e) {
//   //     showCustomToast(context, "Error saving schedule data", isSuccess: false);
//   //   } finally {
//   //     setState(() {
//   //       _isLoading = false;
//   //     });
//   //   }
//   // }
  
//   Future<void> _saveScheduleData() async {
//     // -------- VALIDATION --------
    
//     // Validate Section A overlap (reuse existing validation logic)
//     if (sectionA_MorningEnabled && sectionA_EveningEnabled) {
//       if (!_validateNoTimeOverlap(sectionA_MorningEnd, sectionA_EveningStart)) {
//         showCustomToast(
//           context, 
//           "Section A: Morning and Evening sessions overlap!", 
//           isSuccess: false
//         );
//         return;
//       }
//     }
    
//     // Validate Section B overlap
//     if (sectionB_MorningEnabled && sectionB_EveningEnabled) {
//       if (!_validateNoTimeOverlap(sectionB_MorningEnd, sectionB_EveningStart)) {
//         showCustomToast(
//           context, 
//           "Saturday-Sunday: Morning and Evening sessions overlap!", 
//           isSuccess: false
//         );
//         return;
//       }
//     }

//     // Validate day selection for enabled sessions
//     if (sectionA_MorningEnabled && !sectionA_MorningDays.contains(true)) {
//       showCustomToast(
//         context, 
//         "Section A: Please select at least one day for Morning session", 
//         isSuccess: false
//       );
//       return;
//     }
    
//     if (sectionA_EveningEnabled && !sectionA_EveningDays.contains(true)) {
//       showCustomToast(
//         context, 
//         "Section A: Please select at least one day for Evening session", 
//         isSuccess: false
//       );
//       return;
//     }

//     if (sectionB_MorningEnabled && !sectionB_MorningDays.contains(true)) {
//       showCustomToast(
//         context, 
//         "Saturday-Sunday: Please select at least one day for Morning session", 
//         isSuccess: false
//       );
//       return;
//     }
    
//     if (sectionB_EveningEnabled && !sectionB_EveningDays.contains(true)) {
//       showCustomToast(
//         context, 
//         "Saturday-Sunday: Please select at least one day for Evening session", 
//         isSuccess: false
//       );
//       return;
//     }

//     // At least one session must be enabled across both sections
//     if (!sectionA_MorningEnabled && !sectionA_EveningEnabled && 
//         !sectionB_MorningEnabled && !sectionB_EveningEnabled) {
//       showCustomToast(
//         context, 
//         "Please enable at least one session", 
//         isSuccess: false
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // ✅ Always send multi-section format
//       final payload = {
//         'doctorId': widget.doctorId,
//         'scheduleSections': [
//           {
//             'sectionName': 'A',
//             'morningSession': {
//               'enabled': sectionA_MorningEnabled,
//               'start': sectionA_MorningStart,
//               'end': sectionA_MorningEnd,
//               'selectedDays': sectionA_MorningDays,
//             },
//             'eveningSession': {
//               'enabled': sectionA_EveningEnabled,
//               'start': sectionA_EveningStart,
//               'end': sectionA_EveningEnd,
//               'selectedDays': sectionA_EveningDays,
//             },
//             'isActive': true,
//           },
//           {
//             'sectionName': 'Saturday-Sunday',
//             'morningSession': {
//               'enabled': sectionB_MorningEnabled,
//               'start': sectionB_MorningStart,
//               'end': sectionB_MorningEnd,
//               'selectedDays': sectionB_MorningDays,
//             },
//             'eveningSession': {
//               'enabled': sectionB_EveningEnabled,
//               'start': sectionB_EveningStart,
//               'end': sectionB_EveningEnd,
//               'selectedDays': sectionB_EveningDays,
//             },
//             'isActive': true,
//           },
//         ],
//         'appointmentDuration': selectedDuration, // ✅ Global duration
//         'repeatEvery': repeatEvery,
//         'repeatPeriod': repeatPeriod,
//         'neverEnds': neverEnds,
//         'status': status,
//         'endDate': neverEnds ? null : _selectedDate.toIso8601String(),
//       };

//       print('Sending payload: ${jsonEncode(payload)}');

//       bool success = await _apiService.saveScheduleMultiSection(payload);

//       if (success) {
//         setState(() {
//           showSummary = true;
//         });
//         showCustomToast(context, "Schedule saved successfully.", isSuccess: true);
//         if (widget.showAppBar) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => DoctorMainPage()),
//           );
//         }
//       } else {
//         showCustomToast(context, "Failed to save schedule.", isSuccess: false);
//       }
//     } catch (e) {
//       print('Error saving schedule: $e');
//       showCustomToast(context, "Error saving schedule data: ${e.toString()}", isSuccess: false);
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//    // Validate no time overlap between sessions (reuse existing logic)
//   bool _validateNoTimeOverlap(String morningEnd, String eveningStart) {
//     int morningEndIndex = timeOptions.indexOf(morningEnd);
//     int eveningStartIndex = timeOptions.indexOf(eveningStart);
    
//     // Evening should start after morning ends
//     return eveningStartIndex > morningEndIndex;
//   }

//   // Get combined selected days (any day selected in either session)
//   List<bool> _getCombinedSelectedDays() {
//     List<bool> combined = List<bool>.filled(7, false);
//     for (int i = 0; i < 7; i++) {
//       combined[i] = morningSelectedDays[i] || eveningSelectedDays[i];
//     }
//     return combined;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: widget.showAppBar
//           ? PreferredSize(
//               preferredSize: const Size.fromHeight(130),
//               child: Container(
//                 height: 130,
//                 padding: EdgeInsets.only(
//                   top: MediaQuery.of(context).padding.top + 16,
//                   left: 16,
//                   right: 16,
//                   bottom: 12,
//                 ),
//                 decoration: const BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage('assets/images/bg-header.jpg'),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 child: Stack(
//                   children: [
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: GestureDetector(
//                         onTap: () => Navigator.pop(context),
//                         child: Container(
//                           width: 40,
//                           height: 40,
//                           decoration: BoxDecoration(
//                             color: Colors.transparent,
//                             shape: BoxShape.circle,
//                             border: Border.all(color: Colors.white, width: 1),
//                           ),
//                           child: const Center(
//                             child: Icon(
//                               Icons.arrow_back,
//                               color: Colors.white,
//                               size: 16,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const Center(
//                       child: Text(
//                         "Add Schedule",
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                           fontFamily: 'Poppins',
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             )
//           : null,
//       backgroundColor: const Color(0xFF680C20),
//       body: SafeArea(
//         child: Container(
//           decoration: const BoxDecoration(
//             color: Color(0xFFF6F6F6),
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(20),
//               topRight: Radius.circular(20),
//             ),
//           ),
//           child: _isLoading
//               ? const Center(
//                   child: CircularProgressIndicator(
//                     color: Color(0xFF6B0D24),
//                   ),
//                 )
//               : SingleChildScrollView(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Text(
//                               'Your Schedule',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF1A1A1A),
//                                 fontFamily: 'Poppins'
//                               ),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.refresh),
//                               onPressed: _fetchScheduleData,
//                               color: const Color(0xFF6B0D24),
//                             )
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         if (showSummary) _buildSummaryCard(),
                        
//                         // Morning Session Card with Days
//                         _buildSessionCardWithDays(
//                           'Morning Session',
//                           morningSessionEnabled,
//                           morningStartTime,
//                           morningEndTime,
//                           morningSelectedDays,
//                           (value) {
//                             setState(() => morningSessionEnabled = value);
//                           },
//                           (index) {
//                             setState(() {
//                               morningSelectedDays[index] = !morningSelectedDays[index];
//                             });
//                           },
//                         ),
//                         const SizedBox(height: 16),
                        
//                         // Evening Session Card with Days
//                         _buildSessionCardWithDays(
//                           'Evening Session',
//                           eveningSessionEnabled,
//                           eveningStartTime,
//                           eveningEndTime,
//                           eveningSelectedDays,
//                           (value) {
//                             setState(() => eveningSessionEnabled = value);
//                           },
//                           (index) {
//                             setState(() {
//                               eveningSelectedDays[index] = !eveningSelectedDays[index];
//                             });
//                           },
//                         ),
//                         const SizedBox(height: 16),
                        
//                         _buildCustomRecurrenceCard(),
//                         if (!showSummary) _buildAppointmentDurationCard(),
//                         const SizedBox(height: 24),
//                         _buildSaveButton(),
//                         const SizedBox(height: 20),
//                       ],
//                     ),
//                   ),
//                 ),
//         ),
//       ),
//     );
//   }

// // ✅ NEW: Build UI for each section
//   Widget _buildSectionUI(String sectionId) {
//     // Determine which state variables to use
//     bool morningEnabled, eveningEnabled;
//     String morningStart, morningEnd, eveningStart, eveningEnd;
//     List<bool> morningDays, eveningDays;

//     if (sectionId == 'A') {
//       morningEnabled = sectionA_MorningEnabled;
//       morningStart = sectionA_MorningStart;
//       morningEnd = sectionA_MorningEnd;
//       morningDays = sectionA_MorningDays;
      
//       eveningEnabled = sectionA_EveningEnabled;
//       eveningStart = sectionA_EveningStart;
//       eveningEnd = sectionA_EveningEnd;
//       eveningDays = sectionA_EveningDays;
//     } else {
//       morningEnabled = sectionB_MorningEnabled;
//       morningStart = sectionB_MorningStart;
//       morningEnd = sectionB_MorningEnd;
//       morningDays = sectionB_MorningDays;
      
//       eveningEnabled = sectionB_EveningEnabled;
//       eveningStart = sectionB_EveningStart;
//       eveningEnd = sectionB_EveningEnd;
//       eveningDays = sectionB_EveningDays;
//     }

//     return SingleChildScrollView(
//       // ✅ UNCHANGED: Reuse existing padding
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ✅ UNCHANGED: Only show global appointment duration on Section A tab
//           if (sectionId == 'A') ...[
//             _buildAppointmentDuration(),
//             SizedBox(height: 16),
//           ],
          
//           // ✅ REUSE existing session UI
//           _buildSessionSection(
//             sectionId: sectionId,
//             sessionType: 'Morning',
//             enabled: morningEnabled,
//             startTime: morningStart,
//             endTime: morningEnd,
//             selectedDays: morningDays,
//           ),
          
//           SizedBox(height: 16),
          
//           _buildSessionSection(
//             sectionId: sectionId,
//             sessionType: 'Evening',
//             enabled: eveningEnabled,
//             startTime: eveningStart,
//             endTime: eveningEnd,
//             selectedDays: eveningDays,
//           ),
          
//           // ✅ UNCHANGED: Only show common settings and save button on Section A tab
//           if (sectionId == 'A') ...[
//             SizedBox(height: 16),
//             _buildCommonSettings(),
//             SizedBox(height: 16),
//             _buildSaveButton(),
//           ],
//         ],
//       ),
//     );
//   }

//   // ✅ NEW: Appointment duration dropdown (global)
//   Widget _buildAppointmentDuration() {
//     // ✅ UNCHANGED: Reuse existing Card, Text, and DropdownButtonFormField styling
//     return Card(
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Appointment Duration',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//             ),
//             SizedBox(height: 8),
//             DropdownButtonFormField<String>(
//               value: selectedDuration,
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(),
//                 contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               ),
//               items: durationOptions.map((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//               onChanged: (String? newValue) {
//                 if (newValue != null) {
//                   setState(() {
//                     selectedDuration = newValue;
//                   });
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ✅ REUSE existing session section UI with section-specific state updates
//   Widget _buildSessionSection({
//     required String sectionId,
//     required String sessionType,
//     required bool enabled,
//     required String startTime,
//     required String endTime,
//     required List<bool> selectedDays,
//   }) {
//     // ✅ UNCHANGED: Reuse existing Card, SwitchListTile styling
//     return Card(
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SwitchListTile(
//               title: Text('$sessionType Session'),
//               value: enabled,
//               onChanged: (value) {
//                 setState(() {
//                   // Update appropriate section state
//                   if (sectionId == 'A' && sessionType == 'Morning') {
//                     sectionA_MorningEnabled = value;
//                   } else if (sectionId == 'A' && sessionType == 'Evening') {
//                     sectionA_EveningEnabled = value;
//                   } else if (sectionId == 'Saturday-Sunday' && sessionType == 'Morning') {
//                     sectionB_MorningEnabled = value;
//                   } else if (sectionId == 'Saturday-Sunday' && sessionType == 'Evening') {
//                     sectionB_EveningEnabled = value;
//                   }
//                 });
//               },
//             ),
            
//             if (enabled) ...[
//               Divider(),
//               SizedBox(height: 12),
              
//               // ✅ UNCHANGED: Reuse existing time selectors
//               Row(
//                 children: [
//                   Expanded(
//                     child: _buildTimeSelector('Start Time', startTime, (value) {
//                       setState(() {
//                         if (sectionId == 'A' && sessionType == 'Morning') {
//                           sectionA_MorningStart = value;
//                         } else if (sectionId == 'A' && sessionType == 'Evening') {
//                           sectionA_EveningStart = value;
//                         } else if (sectionId == 'Saturday-Sunday' && sessionType == 'Morning') {
//                           sectionB_MorningStart = value;
//                         } else if (sectionId == 'Saturday-Sunday' && sessionType == 'Evening') {
//                           sectionB_EveningStart = value;
//                         }
//                       });
//                     }),
//                   ),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: _buildTimeSelector('End Time', endTime, (value) {
//                       setState(() {
//                         if (sectionId == 'A' && sessionType == 'Morning') {
//                           sectionA_MorningEnd = value;
//                         } else if (sectionId == 'A' && sessionType == 'Evening') {
//                           sectionA_EveningEnd = value;
//                         } else if (sectionId == 'Saturday-Sunday' && sessionType == 'Morning') {
//                           sectionB_MorningEnd = value;
//                         } else if (sectionId == 'Saturday-Sunday' && sessionType == 'Evening') {
//                           sectionB_EveningEnd = value;
//                         }
//                       });
//                     }),
//                   ),
//                 ],
//               ),
              
//               SizedBox(height: 16),
              
//               Text(
//                 'Available Days',
//                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//               ),
//               SizedBox(height: 8),
//               _buildDaySelector(selectedDays, sectionId, sessionType),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   // ✅ UNCHANGED: Reuse existing time selector
//   Widget _buildTimeSelector(String label, String currentTime, Function(String) onChanged) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
//         SizedBox(height: 4),
//         DropdownButtonFormField<String>(
//           value: currentTime,
//           decoration: InputDecoration(
//             border: OutlineInputBorder(),
//             contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           ),
//           items: timeOptions.map((String value) {
//             return DropdownMenuItem<String>(
//               value: value,
//               child: Text(value, style: TextStyle(fontSize: 14)),
//             );
//           }).toList(),
//           onChanged: (String? newValue) {
//             if (newValue != null) {
//               onChanged(newValue);
//             }
//           },
//         ),
//       ],
//     );
//   }

//   // ✅ UNCHANGED: Reuse existing day selector with section-specific state updates
//   Widget _buildDaySelector(List<bool> selectedDays, String sectionId, String sessionType) {
//     final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    
//     return Wrap(
//       spacing: 8,
//       runSpacing: 8,
//       children: List.generate(7, (index) {
//         return FilterChip(
//           label: Text(days[index]),
//           selected: selectedDays[index],
//           onSelected: (value) {
//             setState(() {
//               if (sectionId == 'A' && sessionType == 'Morning') {
//                 sectionA_MorningDays[index] = value;
//               } else if (sectionId == 'A' && sessionType == 'Evening') {
//                 sectionA_EveningDays[index] = value;
//               } else if (sectionId == 'Saturday-Sunday' && sessionType == 'Morning') {
//                 sectionB_MorningDays[index] = value;
//               } else if (sectionId == 'Saturday-Sunday' && sessionType == 'Evening') {
//                 sectionB_EveningDays[index] = value;
//               }
//             });
//           },
//         );
//       }),
//     );
//   }

//   Widget _buildSummaryCard() {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Summary',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey,
//               fontFamily: 'Poppins',
//               fontWeight: FontWeight.bold
//             ),
//           ),
//           const SizedBox(height: 12),
          
//           // Morning session summary
//           if (morningSessionEnabled) ...[
//             Row(
//               children: [
//                 const Icon(Icons.wb_sunny, size: 20, color: Color(0xFF6B0D24)),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Morning: $morningStartTime - $morningEndTime',
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           fontFamily: 'Poppins',
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       _buildDaySummary(morningSelectedDays),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             if (eveningSessionEnabled) const SizedBox(height: 16),
//           ],
          
//           // Evening session summary
//           if (eveningSessionEnabled) ...[
//             Row(
//               children: [
//                 const Icon(Icons.nightlight_round, size: 20, color: Color(0xFF6B0D24)),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Evening: $eveningStartTime - $eveningEndTime',
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           fontFamily: 'Poppins',
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       _buildDaySummary(eveningSelectedDays),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildDaySummary(List<bool> selectedDays) {
//     final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
//     final selectedDayNames = <String>[];
    
//     for (int i = 0; i < 7; i++) {
//       if (selectedDays[i]) {
//         selectedDayNames.add(days[i]);
//       }
//     }
    
//     return Text(
//       selectedDayNames.join(', '),
//       style: const TextStyle(
//         fontSize: 12,
//         color: Colors.grey,
//         fontFamily: 'Poppins',
//       ),
//     );
//   }

//   Widget _buildSessionCardWithDays(
//     String title,
//     bool enabled,
//     String startTime,
//     String endTime,
//     List<bool> selectedDays,
//     ValueChanged<bool> onEnabledChanged,
//     Function(int) onDayToggled,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Icon(
//                     title == 'Morning Session' 
//                         ? Icons.wb_sunny 
//                         : Icons.nightlight_round,
//                     color: const Color(0xFF6B0D24),
//                     size: 20,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       fontFamily: 'Poppins',
//                     ),
//                   ),
//                 ],
//               ),
//               Switch(
//                 value: enabled,
//                 onChanged: onEnabledChanged,
//                 activeColor: Colors.green,
//                 activeTrackColor: Colors.green.withOpacity(0.5),
//                 inactiveThumbColor: Colors.white,
//                 inactiveTrackColor: Colors.grey.withOpacity(0.5),
//               ),
//             ],
//           ),
          
//           if (enabled) ...[
//             const Divider(height: 30),
            
//             // Time selection
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Start Time',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                           fontFamily: 'Poppins',
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       _buildTimeSelector(
//                         startTime,
//                         (newTime) {
//                           setState(() {
//                             if (title == 'Morning Session') {
//                               morningStartTime = newTime;
//                             } else {
//                               eveningStartTime = newTime;
//                             }
//                           });
//                         },
//                         timeOptions,
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'End Time',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                           fontFamily: 'Poppins',
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       _buildTimeSelector(
//                         endTime,
//                         (newTime) {
//                           setState(() {
//                             if (title == 'Morning Session') {
//                               morningEndTime = newTime;
//                             } else {
//                               eveningEndTime = newTime;
//                             }
//                           });
//                         },
//                         timeOptions.where((time) =>
//                           timeOptions.indexOf(time) > timeOptions.indexOf(startTime)
//                         ).toList(),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
            
//             const SizedBox(height: 20),
            
//             // Days selection
//             const Text(
//               'Available Days',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 fontFamily: 'Poppins',
//               ),
//             ),
//             const SizedBox(height: 12),
//             _buildDaySelector(selectedDays, onDayToggled),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildTimeSelector(
//     String time, 
//     ValueChanged<String> onChanged, 
//     List<String> options
//   ) {
//     String validTime = time;
//     if (time.isEmpty && options.isNotEmpty) {
//       validTime = options[0];
//     } else if (!options.contains(time) && options.isNotEmpty) {
//       validTime = options[0];
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: validTime,
//           isExpanded: true,
//           icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.bold,
//             fontFamily: 'Poppins',
//             color: Colors.black,
//           ),
//           items: options.map((String value) {
//             return DropdownMenuItem<String>(
//               value: value,
//               child: Row(
//                 children: [
//                   const Icon(Icons.access_time, color: Color(0xFF6B0D24), size: 16),
//                   const SizedBox(width: 8),
//                   Text(value),
//                 ],
//               ),
//             );
//           }).toList(),
//           onChanged: (newValue) {
//             if (newValue != null) {
//               onChanged(newValue);
//             }
//           },
//         ),
//       ),
//     );
//   }
//  Widget _buildNumberSelector() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           IconButton(
//             icon: Icon(Icons.remove, color: Colors.grey[600]),
//             onPressed: () {
//               final current = int.parse(repeatEvery);
//               if (current > 1) {
//                 setState(() {
//                   repeatEvery = (current - 1).toString().padLeft(2, '0');
//                 });
//               }
//             },
//           ),
//           Text(
//             repeatEvery,
//             style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 fontFamily: 'Poppins'),
//           ),
//           IconButton(
//             icon: Icon(Icons.add, color: Colors.grey[600]),
//             onPressed: () {
//               final current = int.parse(repeatEvery);
//               setState(() {
//                 repeatEvery = (current + 1).toString().padLeft(2, '0');
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPeriodSelector() {
//     // Define the available options
//     final List<String> periodOptions = ['Week', 'Month', 'Year'];

//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           color: Colors.grey[100],
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: DropdownButtonHideUnderline(
//           child: DropdownButton<String>(
//             value: repeatPeriod,
//             isExpanded: true,
//             icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//               fontFamily: 'Poppins',
//               color: Colors.black,
//             ),
//             items: periodOptions.map((String value) {
//               return DropdownMenuItem<String>(
//                 value: value,
//                 child: Row(
//                   children: [
//                     Icon(Icons.calendar_today,
//                         color: const Color(0xFF6B0D24), size: 24),
//                     const SizedBox(width: 12),
//                     Text(value),
//                   ],
//                 ),
//               );
//             }).toList(),
//             onChanged: (String? newValue) {
//               if (newValue != null) {
//                 setState(() {
//                   repeatPeriod = newValue;
//                 });
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }
  
//   Widget _buildDaySelector(List<bool> selectedDays, Function(int) onDayToggled) {
//     final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: List.generate(7, (index) {
//         return GestureDetector(
//           onTap: () => onDayToggled(index),
//           child: Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: selectedDays[index] 
//                   ? const Color(0xFF6B0D24) 
//                   : Colors.grey[100],
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Center(
//               child: Text(
//                 days[index],
//                 style: TextStyle(
//                   color: selectedDays[index] ? Colors.white : Colors.grey[600],
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           ),
//         );
//       }),
//     );
//   }

//   Widget _buildCustomRecurrenceCard() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Custom Recurrence',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               fontFamily: 'Poppins'
//             ),
//           ),
//           const Divider(height: 30),
//            const Text(
//             'Repeat Every',
//             style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 fontFamily: 'Poppins'),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               _buildNumberSelector(),
//               const SizedBox(width: 16),
//               _buildPeriodSelector(),
//             ],
//           ),
//           Row(
//             children: [
//               const Text(
//                 'Ends',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                   fontFamily: 'Poppins'
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           _buildEndOptions(),
//         ],
//       ),
//     );
//   }

//   Widget _buildEndOptions() {
//     return Row(
//       children: [
//         Radio(
//           value: true,
//           groupValue: neverEnds,
//           onChanged: (value) {
//             setState(() {
//               neverEnds = value as bool;
//             });
//           },
//           activeColor: const Color(0xFF6B0D24),
//         ),
//         const Text(
//           'Never',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             fontFamily: 'Poppins'
//           ),
//         ),
//         const SizedBox(width: 24),
//         Radio(
//           value: false,
//           groupValue: neverEnds,
//           onChanged: (value) {
//             setState(() {
//               neverEnds = value as bool;
//             });
//           },
//           activeColor: const Color(0xFF6B0D24),
//         ),
//         const Text(
//           'On',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             fontFamily: 'Poppins'
//           ),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             decoration: BoxDecoration(
//               color: neverEnds ? Colors.grey[200] : Colors.grey[100],
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: InkWell(
//               onTap: neverEnds ? null : () async {
//                 final currentYear = DateTime.now().year;
//                 final maxYear = currentYear + 10;
//                 DateTime? pickedDate = await showDatePicker(
//                   context: context,
//                   initialDate: _selectedDate,
//                   firstDate: DateTime.now(),
//                   lastDate: DateTime(maxYear),
//                 );
//                 if (pickedDate != null) {
//                   setState(() {
//                     _selectedDate = pickedDate;
//                   });
//                 }
//               },
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     DateFormat('dd-MM-yy').format(_selectedDate),
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       color: neverEnds ? Colors.grey : Colors.black,
//                       fontFamily: 'Poppins',
//                     ),
//                   ),
//                   const SizedBox(width: 6),
//                   Icon(
//                     Icons.calendar_today,
//                     color: neverEnds ? Colors.grey : const Color(0xFF6B0D24),
//                     size: 16,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildAppointmentDurationCard() {
//     return Container(
//       margin: const EdgeInsets.only(top: 16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Appointment Duration',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               fontFamily: 'Poppins',
//             ),
//           ),
//           const Divider(height: 30),
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: durationOptions
//                 .map((duration) => _buildDurationButton(duration))
//                 .toList(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDurationButton(String duration) {
//     final isSelected = selectedDuration == duration;
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedDuration = duration;
//         });
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           color: isSelected ? const Color(0xFF6B0D24) : Colors.white,
//           borderRadius: BorderRadius.circular(24),
//           border: Border.all(
//             color: isSelected ? const Color(0xFF6B0D24) : Colors.grey[300]!,
//           ),
//         ),
//         child: Text(
//           duration,
//           style: TextStyle(
//             color: isSelected ? Colors.white : const Color(0xFF6B0D24),
//             fontWeight: FontWeight.w500,
//             fontSize: 14,
//             fontFamily: 'Poppins'
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSaveButton() {
//     return SizedBox(
//       width: double.infinity,
//       height: 46,
//       child: ElevatedButton(
//         onPressed: _saveScheduleData,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color(0xFF6B0D24),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(27),
//           ),
//         ),
//         child: const Text(
//           'Save',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//             fontFamily: 'Poppins'
//           ),
//         ),
//       ),
//     );
//   }

//   void showCustomToast(BuildContext context, String message, {bool isSuccess = true}) {
//     IconData iconData = isSuccess ? Icons.check_circle : Icons.error;
//     Color iconColor = isSuccess ? Colors.greenAccent : Colors.redAccent;

//     OverlayEntry overlayEntry = OverlayEntry(
//       builder: (context) => Positioned(
//         bottom: 50,
//         left: MediaQuery.of(context).size.width * 0.1,
//         right: MediaQuery.of(context).size.width * 0.1,
//         child: Material(
//           color: Colors.transparent,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: BoxDecoration(
//               color: Colors.black87,
//               borderRadius: BorderRadius.circular(30),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(iconData, color: iconColor),
//                 const SizedBox(width: 8),
//                 Text(
//                   message,
//                   style: const TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );

//     Overlay.of(context).insert(overlayEntry);

//     Future.delayed(const Duration(seconds: 2), () {
//       overlayEntry.remove();
//     });
//   }
// }


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/schedule_api_service.dart';
import 'main_page.dart';
import '../constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class SchedulePage extends StatefulWidget {
  final String doctorId;
  final bool showAppBar;

  const SchedulePage({
    required this.doctorId,
    this.showAppBar = false,
    super.key,
    Map<String, dynamic>? scheduleData
  });

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> with SingleTickerProviderStateMixin {
  late ScheduleApiService _apiService;
  late TabController _tabController;
  bool _isLoading = true;

  // Whether doctor has active/pending appointments (checked on load)
  bool _hasActiveOrPendingAppointments = false;
  bool _isCancellingAppointments = false;

  // Section A (Weekdays) - Morning session
  bool sectionA_morningSessionEnabled = true;
  String sectionA_morningStartTime = '08:00 AM';
  String sectionA_morningEndTime = '02:00 PM';
  List<bool> sectionA_morningSelectedDays = [false, true, true, true, true, true, false];

  // Section A (Weekdays) - Evening session
  bool sectionA_eveningSessionEnabled = true;
  String sectionA_eveningStartTime = '04:00 PM';
  String sectionA_eveningEndTime = '08:00 PM';
  List<bool> sectionA_eveningSelectedDays = [false, true, true, true, true, true, false];

  // Section B (Saturday-Sunday) - Morning session
  bool sectionB_morningSessionEnabled = false;
  String sectionB_morningStartTime = '09:00 AM';
  String sectionB_morningEndTime = '01:00 PM';
  List<bool> sectionB_morningSelectedDays = [true, false, false, false, false, false, true];

  // Section B (Saturday-Sunday) - Evening session
  bool sectionB_eveningSessionEnabled = false;
  String sectionB_eveningStartTime = '03:00 PM';
  String sectionB_eveningEndTime = '06:00 PM';
  List<bool> sectionB_eveningSelectedDays = [true, false, false, false, false, false, true];

  // Common schedule settings (GLOBAL)
  String repeatEvery = "1";
  String repeatPeriod = "Week";
  bool neverEnds = true;
  DateTime? endDate;
  String selectedDuration = "15 Minutes";
  String status = "Active";
  bool showSummary = false;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));

  final List<String> timeOptions = [
    '12:00 AM', '12:30 AM', '01:00 AM', '01:30 AM', '02:00 AM', '02:30 AM',
    '03:00 AM', '03:30 AM', '04:00 AM', '04:30 AM', '05:00 AM', '05:30 AM',
    '06:00 AM', '06:30 AM', '07:00 AM', '07:30 AM', '08:00 AM', '08:30 AM',
    '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM',
    '12:00 PM', '12:30 PM', '01:00 PM', '01:30 PM', '02:00 PM', '02:30 PM',
    '03:00 PM', '03:30 PM', '04:00 PM', '04:30 PM', '05:00 PM', '05:30 PM',
    '06:00 PM', '06:30 PM', '07:00 PM', '07:30 PM', '08:00 PM', '08:30 PM',
    '09:00 PM', '09:30 PM', '10:00 PM', '10:30 PM', '11:00 PM', '11:30 PM',
  ];

  final List<String> durationOptions = [
    '5 Minutes',
    '10 Minutes',
    '15 Minutes',
    '20 Minutes'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _apiService = ScheduleApiService(baseUrl: ApiConstants.baseUrl);
    _fetchScheduleData();
    _checkActiveOrPendingAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // Check if doctor has any Active or Pending appointments today
  // ─────────────────────────────────────────────────────────────
  Future<void> _checkActiveOrPendingAppointments() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');
      if (token == null) return;

      final response = await http.get(
        Uri.parse(ApiConstants.getAllAppointmentsUrl(widget.doctorId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final appointments = data['appointments'] as List<dynamic>? ?? [];

        final hasActiveOrPending = appointments.any((item) {
          final status = item['appointmentObj']?['status'];
          return status == 'Active' || status == 'Pending';
        });

        setState(() {
          _hasActiveOrPendingAppointments = hasActiveOrPending;
        });
      }
    } catch (e) {
      print('❌ Error checking appointments: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Cancel all appointments via API then proceed with save
  // ─────────────────────────────────────────────────────────────
  Future<void> _cancelAllAndSave() async {
    setState(() => _isCancellingAppointments = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');
      if (token == null) throw Exception('No token found');

      final response = await http.put(
        Uri.parse(ApiConstants.cancelAllAppointments(widget.doctorId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _hasActiveOrPendingAppointments = false;
          _isCancellingAppointments = false;
        });
        // Proceed with saving the schedule
        await _saveScheduleData();
      } else {
        setState(() => _isCancellingAppointments = false);
        showCustomToast(context, "Failed to cancel appointments. Please try again.", isSuccess: false);
      }
    } catch (e) {
      setState(() => _isCancellingAppointments = false);
      showCustomToast(context, "Error cancelling appointments: $e", isSuccess: false);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Show confirmation popup before saving if appointments exist
  // ─────────────────────────────────────────────────────────────
  Future<void> _onSavePressed() async {
    if (_hasActiveOrPendingAppointments) {
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B0D24).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFF6B0D24),
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Active Appointments Found',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'You have active or pending appointments scheduled for today. Updating your schedule will cancel all of them.\n\nDo you want to cancel all booked patients and proceed?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    // Keep Appointments button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF6B0D24)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Go Back',
                          style: TextStyle(
                            color: Color(0xFF6B0D24),
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Cancel & Save button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B0D24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Cancel & Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      if (confirmed == true) {
        await _cancelAllAndSave();
      }
    } else {
      // No active/pending appointments — save directly
      await _saveScheduleData();
    }
  }

  // ============================================
  // DIAGNOSTIC VERSION - Use this to find the issue
  // ============================================
  Future<void> _fetchScheduleData() async {
    print('🔵 Starting _fetchScheduleData');
    
    setState(() {
      _isLoading = true;
    });

    try {
      print('🔵 Calling fetchSchedule API for doctorId: ${widget.doctorId}');
      final availability = await _apiService.fetchSchedule(widget.doctorId);
      print('🔵 Fetched availability in schedule page: $availability');
      
      if (availability == null) {
        print('⚠️ Availability is NULL');
        setState(() {
          _isLoading = false;
          showSummary = false;
        });
        return;
      }

      print('✅ Availability is NOT null');
      print('🔍 Type of availability: ${availability.runtimeType}');
      
      final scheduleData = availability.schedule;
      print('🔍 Schedule data: $scheduleData');
      print('🔍 Type of schedule: ${scheduleData.runtimeType}');
      
      print('🔍 useMultipleSections: ${scheduleData.useMultipleSections}');
      print('🔍 scheduleSections: ${scheduleData.scheduleSections}');
      
      if (scheduleData.scheduleSections != null) {
        print('🔍 Number of sections: ${scheduleData.scheduleSections!.length}');
        for (var i = 0; i < scheduleData.scheduleSections!.length; i++) {
          print('🔍 Section $i: ${scheduleData.scheduleSections![i]}');
        }
      }

      setState(() {
        print('🟢 Entering setState block');
        
        if (scheduleData.useMultipleSections &&
            scheduleData.scheduleSections != null) {

          print('🟢 Using multiple sections mode');
          final sections = scheduleData.scheduleSections!;

          Map<String, dynamic>? sectionA;
          for (var section in sections) {
            print('🔍 Checking section: ${section['sectionName']}');
            if (section['sectionName'] == 'A') {
              sectionA = section;
              print('✅ Found Section A: $sectionA');
              break;
            }
          }

          Map<String, dynamic>? sectionB;
          for (var section in sections) {
            if (section['sectionName'] == 'Saturday-Sunday') {
              sectionB = section;
              print('✅ Found Section B: $sectionB');
              break;
            }
          }

          if (sectionA != null) {
            print('🟢 Processing Section A');
            final m = sectionA['morningSession'];
            final e = sectionA['eveningSession'];

            if (m != null) {
              sectionA_morningSessionEnabled = m['enabled'] ?? true;
              sectionA_morningStartTime = m['start'] ?? '08:00 AM';
              sectionA_morningEndTime = m['end'] ?? '02:00 PM';
              sectionA_morningSelectedDays = List<bool>.from(
                m['selectedDays'] ?? [false, true, true, true, true, true, false]
              );
            }

            if (e != null) {
              sectionA_eveningSessionEnabled = e['enabled'] ?? true;
              sectionA_eveningStartTime = e['start'] ?? '04:00 PM';
              sectionA_eveningEndTime = e['end'] ?? '08:00 PM';
              sectionA_eveningSelectedDays = List<bool>.from(
                e['selectedDays'] ?? [false, true, true, true, true, true, false]
              );
            }
          }

          if (sectionB != null) {
            print('🟢 Processing Section B');
            final m = sectionB['morningSession'];
            final e = sectionB['eveningSession'];

            if (m != null) {
              sectionB_morningSessionEnabled = m['enabled'] ?? false;
              sectionB_morningStartTime = m['start'] ?? '09:00 AM';
              sectionB_morningEndTime = m['end'] ?? '01:00 PM';
              sectionB_morningSelectedDays = List<bool>.from(
                m['selectedDays'] ?? [true, false, false, false, false, false, true]
              );
            }

            if (e != null) {
              sectionB_eveningSessionEnabled = e['enabled'] ?? false;
              sectionB_eveningStartTime = e['start'] ?? '03:00 PM';
              sectionB_eveningEndTime = e['end'] ?? '06:00 PM';
              sectionB_eveningSelectedDays = List<bool>.from(
                e['selectedDays'] ?? [true, false, false, false, false, false, true]
              );
            }
          }
        } else {
          print('🟡 Using legacy mode (not multiple sections)');
          sectionA_morningSessionEnabled = scheduleData.morningSession.enabled;
          sectionA_eveningSessionEnabled = scheduleData.eveningSession.enabled;
        }

        selectedDuration = scheduleData.appointmentDuration;
        repeatEvery = scheduleData.repeatEvery;
        repeatPeriod = scheduleData.repeatPeriod;
        neverEnds = scheduleData.neverEnds;
        status = scheduleData.status;
        showSummary = true; 
      });

    } catch (e, stackTrace) {
      print('❌ Error fetching schedule data: $e');
      print('❌ Stack trace: $stackTrace');
    } finally {
      setState(() {
        _isLoading = false;
        print('🔵 Loading set to false');
      });
    }
    
    print('🔵 _fetchScheduleData completed');
  }

  Future<void> _saveScheduleData() async {
    // Validation: Section A
    if (sectionA_morningSessionEnabled && sectionA_eveningSessionEnabled) {
      if (!_validateNoTimeOverlap(sectionA_morningEndTime, sectionA_eveningStartTime)) {
        showCustomToast(context, "Section A: Morning and Evening sessions overlap!", isSuccess: false);
        return;
      }
    }
    if (sectionA_morningSessionEnabled && !sectionA_morningSelectedDays.contains(true)) {
      showCustomToast(context, "Section A: Select at least one day for Morning session", isSuccess: false);
      return;
    }
    if (sectionA_eveningSessionEnabled && !sectionA_eveningSelectedDays.contains(true)) {
      showCustomToast(context, "Section A: Select at least one day for Evening session", isSuccess: false);
      return;
    }

    // Validation: Section B
    if (sectionB_morningSessionEnabled && sectionB_eveningSessionEnabled) {
      if (!_validateNoTimeOverlap(sectionB_morningEndTime, sectionB_eveningStartTime)) {
        showCustomToast(context, "Section B: Morning and Evening sessions overlap!", isSuccess: false);
        return;
      }
    }
    if (sectionB_morningSessionEnabled && !sectionB_morningSelectedDays.contains(true)) {
      showCustomToast(context, "Section B: Select at least one day for Morning session", isSuccess: false);
      return;
    }
    if (sectionB_eveningSessionEnabled && !sectionB_eveningSelectedDays.contains(true)) {
      showCustomToast(context, "Section B: Select at least one day for Evening session", isSuccess: false);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final payload = {
        "doctorId": widget.doctorId,
        "useMultipleSections": true,
        "scheduleSections": [
          {
            "sectionName": "A",
            "morningSession": {
              "enabled": sectionA_morningSessionEnabled,
              "start": sectionA_morningStartTime,
              "end": sectionA_morningEndTime,
              "selectedDays": List<bool>.from(sectionA_morningSelectedDays),
            },
            "eveningSession": {
              "enabled": sectionA_eveningSessionEnabled,
              "start": sectionA_eveningStartTime,
              "end": sectionA_eveningEndTime,
              "selectedDays": List<bool>.from(sectionA_eveningSelectedDays),
            },
            "isActive": true,
          },
          {
            "sectionName": "Saturday-Sunday",
            "morningSession": {
              "enabled": sectionB_morningSessionEnabled,
              "start": sectionB_morningStartTime,
              "end": sectionB_morningEndTime,
              "selectedDays": List<bool>.from(sectionB_morningSelectedDays),
            },
            "eveningSession": {
              "enabled": sectionB_eveningSessionEnabled,
              "start": sectionB_eveningStartTime,
              "end": sectionB_eveningEndTime,
              "selectedDays": List<bool>.from(sectionB_eveningSelectedDays),
            },
            "isActive": true,
          },
        ],
        "appointmentDuration": selectedDuration,
        "repeatEvery": repeatEvery,
        "repeatPeriod": repeatPeriod,
        "neverEnds": neverEnds,
        "status": status,
        "endDate": neverEnds ? null : _selectedDate.toIso8601String(),
      };
      print('Saving schedule with payload: $payload');

      bool success = await _apiService.saveScheduleMultiSection(payload);

      if (success) {
        setState(() {
          _fetchScheduleData();
        });
        showCustomToast(context, "Schedule saved successfully.", isSuccess: true);
        if (widget.showAppBar) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => DoctorMainPage()));
        }
      } else {
        showCustomToast(context, "Failed to save schedule.", isSuccess: false);
      }
    } catch (e) {
      String errorMessage = e.toString().replaceFirst("Exception: ", "");
      showCustomToast(
        context,
        "Error saving schedule: $errorMessage",
        isSuccess: false,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _validateNoTimeOverlap(String morningEnd, String eveningStart) {
    int morningEndIndex = timeOptions.indexOf(morningEnd);
    int eveningStartIndex = timeOptions.indexOf(eveningStart);
    return eveningStartIndex > morningEndIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? PreferredSize(
              preferredSize: const Size.fromHeight(130),
              child: Container(
                height: 130,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 16,
                  right: 16,
                  bottom: 12,
                ),
                decoration: const BoxDecoration(
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
                        "Add Schedule",
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
            )
          : null,
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
          child: _isLoading || _isCancellingAppointments
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Color(0xFF6B0D24)),
                      if (_isCancellingAppointments) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Cancelling appointments...',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Your Schedule',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                                fontFamily: 'Poppins'
                              ),
                            ),
                            Row(
                              children: [
                                // Warning badge if active/pending appointments exist
                                if (_hasActiveOrPendingAppointments)
                                  Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.orange.shade300),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.warning_amber_rounded,
                                            size: 14, color: Colors.orange.shade700),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Active appointments',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontFamily: 'Poppins',
                                            color: Colors.orange.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: () {
                                    _fetchScheduleData();
                                    _checkActiveOrPendingAppointments();
                                  },
                                  color: const Color(0xFF6B0D24),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (showSummary) _buildSummaryCard(),
                        
                        // Section A - Weekdays
                        const Text(
                          'Regular Days',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                            fontFamily: 'Poppins'
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        _buildSessionCardWithDays(
                          'Morning Session',
                          sectionA_morningSessionEnabled,
                          sectionA_morningStartTime,
                          sectionA_morningEndTime,
                          sectionA_morningSelectedDays,
                          (value) => setState(() => sectionA_morningSessionEnabled = value),
                          (index) => setState(() => sectionA_morningSelectedDays[index] = !sectionA_morningSelectedDays[index]),
                          'A',
                        ),
                        const SizedBox(height: 16),
                        
                        _buildSessionCardWithDays(
                          'Evening Session',
                          sectionA_eveningSessionEnabled,
                          sectionA_eveningStartTime,
                          sectionA_eveningEndTime,
                          sectionA_eveningSelectedDays,
                          (value) => setState(() => sectionA_eveningSessionEnabled = value),
                          (index) => setState(() => sectionA_eveningSelectedDays[index] = !sectionA_eveningSelectedDays[index]),
                          'A',
                        ),
                        const SizedBox(height: 24),
                        
                        // Section B - Saturday-Sunday
                        const Text(
                          'Other Days',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                            fontFamily: 'Poppins'
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        _buildSessionCardWithDays(
                          'Morning Session',
                          sectionB_morningSessionEnabled,
                          sectionB_morningStartTime,
                          sectionB_morningEndTime,
                          sectionB_morningSelectedDays,
                          (value) => setState(() => sectionB_morningSessionEnabled = value),
                          (index) => setState(() => sectionB_morningSelectedDays[index] = !sectionB_morningSelectedDays[index]),
                          'B',
                        ),
                        const SizedBox(height: 16),
                        
                        _buildSessionCardWithDays(
                          'Evening Session',
                          sectionB_eveningSessionEnabled,
                          sectionB_eveningStartTime,
                          sectionB_eveningEndTime,
                          sectionB_eveningSelectedDays,
                          (value) => setState(() => sectionB_eveningSessionEnabled = value),
                          (index) => setState(() => sectionB_eveningSelectedDays[index] = !sectionB_eveningSelectedDays[index]),
                          'B',
                        ),
                        const SizedBox(height: 24),
                        
                        _buildCustomRecurrenceCard(),
                        if (!showSummary) _buildAppointmentDurationCard(),
                        const SizedBox(height: 24),
                        _buildSaveButton(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Summary',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 12),
          
          if (sectionA_morningSessionEnabled || sectionA_eveningSessionEnabled) ...[
            const Text(
              'Regular Days',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Color(0xFF6B0D24),
              ),
            ),
            const SizedBox(height: 8),
          ],
          
          if (sectionA_morningSessionEnabled) ...[
            Row(
              children: [
                const Icon(Icons.wb_sunny, size: 20, color: Color(0xFF6B0D24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Morning: $sectionA_morningStartTime - $sectionA_morningEndTime',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildDaySummary(sectionA_morningSelectedDays),
                    ],
                  ),
                ),
              ],
            ),
            if (sectionA_eveningSessionEnabled) const SizedBox(height: 16),
          ],
          
          if (sectionA_eveningSessionEnabled) ...[
            Row(
              children: [
                const Icon(Icons.nightlight_round, size: 20, color: Color(0xFF6B0D24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Evening: $sectionA_eveningStartTime - $sectionA_eveningEndTime',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildDaySummary(sectionA_eveningSelectedDays),
                    ],
                  ),
                ),
              ],
            ),
          ],
          
          if (sectionB_morningSessionEnabled || sectionB_eveningSessionEnabled) ...[
            if (sectionA_morningSessionEnabled || sectionA_eveningSessionEnabled) 
              const SizedBox(height: 20),
            const Text(
              'Other Days',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Color(0xFF6B0D24),
              ),
            ),
            const SizedBox(height: 8),
          ],
          
          if (sectionB_morningSessionEnabled) ...[
            Row(
              children: [
                const Icon(Icons.wb_sunny, size: 20, color: Color(0xFF6B0D24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Morning: $sectionB_morningStartTime - $sectionB_morningEndTime',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildDaySummary(sectionB_morningSelectedDays),
                    ],
                  ),
                ),
              ],
            ),
            if (sectionB_eveningSessionEnabled) const SizedBox(height: 16),
          ],
          
          if (sectionB_eveningSessionEnabled) ...[
            Row(
              children: [
                const Icon(Icons.nightlight_round, size: 20, color: Color(0xFF6B0D24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Evening: $sectionB_eveningStartTime - $sectionB_eveningEndTime',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildDaySummary(sectionB_eveningSelectedDays),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDaySummary(List<bool> selectedDays) {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final selectedDayNames = <String>[];
    for (int i = 0; i < 7; i++) {
      if (selectedDays[i]) selectedDayNames.add(days[i]);
    }
    return Text(
      selectedDayNames.join(', '),
      style: const TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'Poppins'),
    );
  }

  Widget _buildSessionCardWithDays(
    String title,
    bool enabled,
    String startTime,
    String endTime,
    List<bool> selectedDays,
    ValueChanged<bool> onEnabledChanged,
    Function(int) onDayToggled,
    String sectionIdentifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    title == 'Morning Session' ? Icons.wb_sunny : Icons.nightlight_round,
                    color: const Color(0xFF6B0D24),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              Switch(
                value: enabled,
                onChanged: onEnabledChanged,
                activeColor: Colors.green,
                activeTrackColor: Colors.green.withOpacity(0.5),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey.withOpacity(0.5),
              ),
            ],
          ),
          
          if (enabled) ...[
            const Divider(height: 30),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Start Time', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Poppins')),
                      const SizedBox(height: 8),
                      _buildTimeSelector(
                        startTime,
                        (newTime) {
                          setState(() {
                            if (sectionIdentifier == 'A') {
                              if (title == 'Morning Session') sectionA_morningStartTime = newTime;
                              else sectionA_eveningStartTime = newTime;
                            } else {
                              if (title == 'Morning Session') sectionB_morningStartTime = newTime;
                              else sectionB_eveningStartTime = newTime;
                            }
                          });
                        },
                        timeOptions,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('End Time', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Poppins')),
                      const SizedBox(height: 8),
                      _buildTimeSelector(
                        endTime,
                        (newTime) {
                          setState(() {
                            if (sectionIdentifier == 'A') {
                              if (title == 'Morning Session') sectionA_morningEndTime = newTime;
                              else sectionA_eveningEndTime = newTime;
                            } else {
                              if (title == 'Morning Session') sectionB_morningEndTime = newTime;
                              else sectionB_eveningEndTime = newTime;
                            }
                          });
                        },
                        timeOptions.where((time) => timeOptions.indexOf(time) > timeOptions.indexOf(startTime)).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Available Days', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Poppins')),
            const SizedBox(height: 12),
            _buildDaySelector(selectedDays, onDayToggled),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeSelector(String time, ValueChanged<String> onChanged, List<String> options) {
    String validTime = time;
    if (time.isEmpty && options.isNotEmpty) {
      validTime = options[0];
    } else if (!options.contains(time) && options.isNotEmpty) {
      validTime = options[0];
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: validTime,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Poppins', color: Colors.black),
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Color(0xFF6B0D24), size: 16),
                  const SizedBox(width: 8),
                  Text(value),
                ],
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) onChanged(newValue);
          },
        ),
      ),
    );
  }

  Widget _buildNumberSelector() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.remove, color: Colors.grey[600]),
            onPressed: () {
              final current = int.parse(repeatEvery);
              if (current > 1) setState(() => repeatEvery = (current - 1).toString().padLeft(2, '0'));
            },
          ),
          Text(repeatEvery, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          IconButton(
            icon: Icon(Icons.add, color: Colors.grey[600]),
            onPressed: () {
              final current = int.parse(repeatEvery);
              setState(() => repeatEvery = (current + 1).toString().padLeft(2, '0'));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final List<String> periodOptions = ['Week', 'Month', 'Year'];
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: repeatPeriod,
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'Poppins', color: Colors.black),
            items: periodOptions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xFF6B0D24), size: 24),
                    const SizedBox(width: 12),
                    Text(value),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) setState(() => repeatPeriod = newValue);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDaySelector(List<bool> selectedDays, Function(int) onDayToggled) {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        return GestureDetector(
          onTap: () => onDayToggled(index),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: selectedDays[index] ? const Color(0xFF6B0D24) : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                days[index],
                style: TextStyle(
                  color: selectedDays[index] ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCustomRecurrenceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Custom Recurrence', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          const Divider(height: 30),
          const Text('Repeat Every', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Poppins')),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildNumberSelector(),
              const SizedBox(width: 16),
              _buildPeriodSelector(),
            ],
          ),
          Row(children: [const Text('Ends', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Poppins'))]),
          const SizedBox(height: 16),
          _buildEndOptions(),
        ],
      ),
    );
  }

  Widget _buildEndOptions() {
    return Row(
      children: [
        Radio(value: true, groupValue: neverEnds, onChanged: (value) => setState(() => neverEnds = value as bool), activeColor: const Color(0xFF6B0D24)),
        const Text('Never', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Poppins')),
        const SizedBox(width: 24),
        Radio(value: false, groupValue: neverEnds, onChanged: (value) => setState(() => neverEnds = value as bool), activeColor: const Color(0xFF6B0D24)),
        const Text('On', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Poppins')),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: neverEnds ? Colors.grey[200] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: neverEnds ? null : () async {
                final currentYear = DateTime.now().year;
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(currentYear + 10),
                );
                if (pickedDate != null) setState(() => _selectedDate = pickedDate);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('dd-MM-yy').format(_selectedDate),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: neverEnds ? Colors.grey : Colors.black, fontFamily: 'Poppins'),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.calendar_today, color: neverEnds ? Colors.grey : const Color(0xFF6B0D24), size: 16),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentDurationCard() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Appointment Duration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          const Divider(height: 30),
          Wrap(spacing: 8, runSpacing: 8, children: durationOptions.map((d) => _buildDurationButton(d)).toList()),
        ],
      ),
    );
  }

  Widget _buildDurationButton(String duration) {
    final isSelected = selectedDuration == duration;
    return GestureDetector(
      onTap: () => setState(() => selectedDuration = duration),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6B0D24) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? const Color(0xFF6B0D24) : Colors.grey[300]!),
        ),
        child: Text(
          duration,
          style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF6B0D24), fontWeight: FontWeight.w500, fontSize: 14, fontFamily: 'Poppins'),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        // ← Now calls _onSavePressed instead of _saveScheduleData directly
        onPressed: _onSavePressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B0D24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
        ),
        child: const Text(
          'Save',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Poppins'),
        ),
      ),
    );
  }

  void showCustomToast(BuildContext context, String message, {bool isSuccess = true}) {
    IconData iconData = isSuccess ? Icons.check_circle : Icons.error;
    Color iconColor = isSuccess ? Colors.greenAccent : Colors.redAccent;

    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 80,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(30)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(iconData, color: iconColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () => overlayEntry.remove());
  }
}