// import 'dart:convert';
// import 'package:http/http.dart' as http;

// // Session data class with selectedDays support
// class SessionData {
//   final bool enabled;
//   final String start;
//   final String end;
//   final List<bool>? selectedDays;

//   SessionData({
//     required this.enabled,
//     required this.start,
//     required this.end,
//     this.selectedDays,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'enabled': enabled,
//       'start': start,
//       'end': end,
//       'selectedDays': selectedDays ?? List<bool>.filled(7, false),
//     };
//   }

//   factory SessionData.fromJson(Map<String, dynamic> json) {
//     return SessionData(
//       enabled: json['enabled'] ?? false,
//       start: json['start'] ?? '',
//       end: json['end'] ?? '',
//       selectedDays: json['selectedDays'] != null
//           ? List<bool>.from(json['selectedDays'])
//           : null,
//     );
//   }
// }

// // Schedule data class
// class ScheduleData {
//   final String doctorId;
//   final String dayOfWeek;
//   final SessionData morningSession;
//   final SessionData eveningSession;
//   final String appointmentDuration;
//   final String repeatEvery;
//   final String repeatPeriod;
//   final List<bool> selectedDays;
//   final bool neverEnds;
//   final String status;
//   final DateTime? endDate;

//   ScheduleData({
//     required this.doctorId,
//     required this.dayOfWeek,
//     required this.morningSession,
//     required this.eveningSession,
//     required this.appointmentDuration,
//     required this.repeatEvery,
//     required this.repeatPeriod,
//     required this.selectedDays,
//     required this.neverEnds,
//     required this.status,
//     this.endDate,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'doctorId': doctorId,
//       'dayOfWeek': dayOfWeek,
//       'morningSession': morningSession.toJson(),
//       'eveningSession': eveningSession.toJson(),
//       'appointmentDuration': appointmentDuration,
//       'repeatEvery': repeatEvery,
//       'repeatPeriod': repeatPeriod,
//       'selectedDays': selectedDays,
//       'neverEnds': neverEnds,
//       'status': status,
//       'endDate': endDate?.toIso8601String(),
//     };
//   }

//   factory ScheduleData.fromJson(Map<String, dynamic> json) {
//     return ScheduleData(
//       doctorId: json['doctorId'] ?? '',
//       dayOfWeek: json['dayOfWeek'] ?? 'Monday',
//       morningSession: SessionData.fromJson(json['morningSession'] ?? {}),
//       eveningSession: SessionData.fromJson(json['eveningSession'] ?? {}),
//       appointmentDuration: json['appointmentDuration'] ?? '15 Minutes',
//       repeatEvery: json['repeatEvery'] ?? '1',
//       repeatPeriod: json['repeatPeriod'] ?? 'Week',
//       selectedDays: json['selectedDays'] != null
//           ? List<bool>.from(json['selectedDays'])
//           : List<bool>.filled(7, false),
//       neverEnds: json['neverEnds'] ?? true,
//       status: json['status'] ?? 'Active',
//       endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
//     );
//   }
// }

// // Slot data class
// class SlotData {
//   final String start;
//   final String end;
//   final String? session;
//   final bool isBooked;
//   final bool isLocked;

//   SlotData({
//     required this.start,
//     required this.end,
//     this.session,
//     this.isBooked = false,
//     this.isLocked = false,
//   });

//   factory SlotData.fromJson(Map<String, dynamic> json) {
//     return SlotData(
//       start: json['start'] ?? '',
//       end: json['end'] ?? '',
//       session: json['session'],
//       isBooked: json['isBooked'] ?? false,
//       isLocked: json['isLocked'] ?? false,
//     );
//   }
// }

// // Day slots data class (from slotsByDay in response)
// class DaySlots {
//   final String dayName;
//   final List<SlotData> slots;
//   final int totalSlots;
//   final int availableSlots;

//   DaySlots({
//     required this.dayName,
//     required this.slots,
//     required this.totalSlots,
//     required this.availableSlots,
//   });

//   factory DaySlots.fromJson(Map<String, dynamic> json) {
//     return DaySlots(
//       dayName: json['dayName'] ?? '',
//       slots: (json['slots'] as List?)
//               ?.map((slot) => SlotData.fromJson(slot))
//               .toList() ??
//           [],
//       totalSlots: json['totalSlots'] ?? 0,
//       availableSlots: json['availableSlots'] ?? 0,
//     );
//   }
// }

// // Complete availability response
// class AvailabilityResponse {
//   final ScheduleData schedule;
//   final List<SlotData> dailySlots;
//   final Map<int, DaySlots> slotsByDay; // Key is day index (0-6)

//   AvailabilityResponse({
//     required this.schedule,
//     required this.dailySlots,
//     required this.slotsByDay,
//   });
// }


// // Simplified API Service - Only 2 methods needed!
// class ScheduleApiService {
//   final String baseUrl;

//   ScheduleApiService({required this.baseUrl});

//   /**
//    * Save or update schedule
//    * Backend handles all validation (overlaps, days, etc.)
//    */
//   Future<bool> saveSchedule(ScheduleData scheduleData) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/doctor/set-availability'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(scheduleData.toJson()),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return data['success'] == true;
//       } else if (response.statusCode == 400) {
//         // Validation error - parse and throw for UI to display
//         final data = jsonDecode(response.body);
//         throw Exception(data['message'] ?? 'Validation failed');
//       }
      
//       print('Save failed: ${response.statusCode} - ${response.body}');
//       return false;
//     } catch (e) {
//       print('Error saving schedule: $e');
//       rethrow; // Re-throw to handle in UI
//     }
//   }

//   /**
//    * Update existing schedule (same as save)
//    */
//   Future<bool> updateSchedule(ScheduleData scheduleData) async {
//     return saveSchedule(scheduleData);
//   }

//   /**
//    * Fetch complete schedule with all slots organized by day
//    * No need for separate slot fetching!
//    */
//   Future<AvailabilityResponse?> fetchSchedule(String doctorId) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/doctor/availability/$doctorId'),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['success'] == true && data['data'] != null) {
//           final responseData = data['data'];
          
//           // Parse schedule data
//           final schedule = ScheduleData.fromJson(responseData);
          
//           // Parse all daily slots
//           final dailySlots = (responseData['dailySlots'] as List?)
//               ?.map((slot) => SlotData.fromJson(slot))
//               .toList() ?? [];
          
//           // Parse slots organized by day
//           final slotsByDayMap = <int, DaySlots>{};
//           if (responseData['slotsByDay'] != null) {
//             final slotsMap = responseData['slotsByDay'] as Map<String, dynamic>;
//             slotsMap.forEach((key, value) {
//               final dayIndex = int.parse(key);
//               slotsByDayMap[dayIndex] = DaySlots.fromJson(value);
//             });
//           }
          
//           return AvailabilityResponse(
//             schedule: schedule,
//             dailySlots: dailySlots,
//             slotsByDay: slotsByDayMap,
//           );
//         }
//       } else if (response.statusCode == 404) {
//         // No schedule found - return null
//         return null;
//       }

//       throw Exception('Failed to load schedule');
//     } catch (e) {
//       print('Error fetching schedule: $e');
//       rethrow;
//     }
//   }

//   /**
//    * Helper method for backward compatibility with existing code
//    * Returns just the ScheduleData part
//    */
//   Future<ScheduleData> fetchScheduleData(String doctorId) async {
//     final availability = await fetchSchedule(doctorId);
//     print('Fetched availability: $availability');
    
//     if (availability != null) {
//       return availability.schedule;
//     }
//     print('No schedule found, returning default.');
    
//     // Return default schedule if none exists
//     return _getDefaultSchedule(doctorId);
//   }

//   /**
//    * Get slots for a specific day from the complete availability
//    * No separate API call needed!
//    */
//   DaySlots? getSlotsForDay(AvailabilityResponse availability, int dayOfWeek) {
//     return availability.slotsByDay[dayOfWeek];
//   }

//   /**
//    * Get default schedule for new doctors
//    */
//   ScheduleData _getDefaultSchedule(String doctorId) {
//     return ScheduleData(
//       doctorId: doctorId,
//       dayOfWeek: 'Monday',
//       morningSession: SessionData(
//         enabled: true,
//         start: '08:00 AM',
//         end: '02:00 PM',
//         selectedDays: [false, true, true, true, true, true, true],
//       ),
//       eveningSession: SessionData(
//         enabled: true,
//         start: '04:00 PM',
//         end: '08:00 PM',
//         selectedDays: [false, true, true, true, true, true, false],
//       ),
//       appointmentDuration: '15 Minutes',
//       repeatEvery: '1',
//       repeatPeriod: 'Week',
//       selectedDays: [false, true, true, true, true, true, true],
//       neverEnds: true,
//       status: 'Active',
//     );
//   }
// }

// import 'dart:convert';
// import 'package:http/http.dart' as http;

// // Session data class with selectedDays support
// class SessionData {
//   final bool enabled;
//   final String start;
//   final String end;
//   final List<bool>? selectedDays;

//   SessionData({
//     required this.enabled,
//     required this.start,
//     required this.end,
//     this.selectedDays,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'enabled': enabled,
//       'start': start,
//       'end': end,
//       'selectedDays': selectedDays ?? List<bool>.filled(7, false),
//     };
//   }

//   factory SessionData.fromJson(Map<String, dynamic> json) {
//     return SessionData(
//       enabled: json['enabled'] ?? false,
//       start: json['start'] ?? '',
//       end: json['end'] ?? '',
//       selectedDays: json['selectedDays'] != null
//           ? List<bool>.from(json['selectedDays'])
//           : null,
//     );
//   }
// }

// // Schedule data class
// // ============================================
// // CHECK YOUR AvailabilityResponse CLASS
// // ============================================

// // Your AvailabilityResponse class should look like this:

// // class AvailabilityResponse {
// //   final ScheduleData schedule;
// //   final List<SlotData> dailySlots;
// //   final Map<String, dynamic> slotsByDay;

// //   AvailabilityResponse({
// //     required this.schedule,
// //     required this.dailySlots,
// //     required this.slotsByDay,
// //   });

// //   factory AvailabilityResponse.fromJson(Map<String, dynamic> json) {
// //     return AvailabilityResponse(
// //       schedule: ScheduleData.fromJson(json['schedule'] ?? {}),
// //       dailySlots: (json['dailySlots'] as List?)
// //               ?.map((slot) => SlotData.fromJson(slot))
// //               .toList() ??
// //           [],
// //       slotsByDay: json['slotsByDay'] as Map<String, dynamic>? ?? {},
// //     );
// //   }
// // }

// // ============================================
// // CHECK YOUR ScheduleData CLASS
// // ============================================

// // Your ScheduleData class MUST have these fields:

// class ScheduleData {
//   final String doctorId;
//   final bool useMultipleSections;  // ⚠️ CRITICAL
//   final List<Map<String, dynamic>>? scheduleSections;  // ⚠️ CRITICAL
//   final SessionData morningSession;
//   final SessionData eveningSession;
//   final String appointmentDuration;
//   final String repeatEvery;
//   final String repeatPeriod;
//   final List<bool> selectedDays;
//   final bool neverEnds;
//   final String status;
//   final DateTime? endDate;

//   ScheduleData({
//     required this.doctorId,
//     required this.useMultipleSections,
//     this.scheduleSections,
//     required this.morningSession,
//     required this.eveningSession,
//     required this.appointmentDuration,
//     required this.repeatEvery,
//     required this.repeatPeriod,
//     required this.selectedDays,
//     required this.neverEnds,
//     required this.status,
//     this.endDate,
//   });

//   factory ScheduleData.fromJson(Map<String, dynamic> json) {
//     return ScheduleData(
//       doctorId: json['doctorId'] ?? '',
      
//       // ⚠️ CRITICAL: Parse useMultipleSections
//       useMultipleSections: json['useMultipleSections'] ?? false,
      
//       // ⚠️ CRITICAL: Parse scheduleSections as List<Map>
//       scheduleSections: json['scheduleSections'] != null
//           ? (json['scheduleSections'] as List)
//               .map((section) => section as Map<String, dynamic>)
//               .toList()
//           : null,
      
//       morningSession: SessionData.fromJson(json['morningSession'] ?? {}),
//       eveningSession: SessionData.fromJson(json['eveningSession'] ?? {}),
//       appointmentDuration: json['appointmentDuration'] ?? '15 Minutes',
//       repeatEvery: json['repeatEvery']?.toString() ?? '1',
//       repeatPeriod: json['repeatPeriod'] ?? 'Week',
//       selectedDays: json['selectedDays'] != null
//           ? List<bool>.from(json['selectedDays'])
//           : List<bool>.filled(7, false),
//       neverEnds: json['neverEnds'] ?? true,
//       status: json['status'] ?? 'Active',
//       endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
//     );
//   }
// }

// // ============================================
// // IMPORTANT NOTES
// // ============================================

// /*
// The MOST LIKELY issue is that your ScheduleData class is missing:
// 1. useMultipleSections field
// 2. scheduleSections field

// Or these fields are not being parsed correctly in fromJson.

// Check your schedule_api_service.dart file and make sure:
// - ScheduleData has both fields
// - fromJson properly parses scheduleSections as List<Map<String, dynamic>>
// */

// // Slot data class
// class SlotData {
//   final String start;
//   final String end;
//   final String? session;
//   final bool isBooked;
//   final bool isLocked;

//   SlotData({
//     required this.start,
//     required this.end,
//     this.session,
//     this.isBooked = false,
//     this.isLocked = false,
//   });

//   factory SlotData.fromJson(Map<String, dynamic> json) {
//     return SlotData(
//       start: json['start'] ?? '',
//       end: json['end'] ?? '',
//       session: json['session'],
//       isBooked: json['isBooked'] ?? false,
//       isLocked: json['isLocked'] ?? false,
//     );
//   }
// }

// // Day slots data class (from slotsByDay in response)
// class DaySlots {
//   final String dayName;
//   final List<SlotData> slots;
//   final int totalSlots;
//   final int availableSlots;

//   DaySlots({
//     required this.dayName,
//     required this.slots,
//     required this.totalSlots,
//     required this.availableSlots,
//   });

//   factory DaySlots.fromJson(Map<String, dynamic> json) {
//     return DaySlots(
//       dayName: json['dayName'] ?? '',
//       slots: (json['slots'] as List?)
//               ?.map((slot) => SlotData.fromJson(slot))
//               .toList() ??
//           [],
//       totalSlots: json['totalSlots'] ?? 0,
//       availableSlots: json['availableSlots'] ?? 0,
//     );
//   }
// }

// // Complete availability response
// class AvailabilityResponse {
//   final ScheduleData schedule;
//   final List<SlotData> dailySlots;
//   final Map<String, dynamic> slotsByDay;

//   AvailabilityResponse({
//     required this.schedule,
//     required this.dailySlots,
//     required this.slotsByDay,
//   });

//   factory AvailabilityResponse.fromJson(Map<String, dynamic> json) {
//     return AvailabilityResponse(
//       schedule: ScheduleData.fromJson(json['schedule'] ?? {}),
//       dailySlots: (json['dailySlots'] as List?)
//               ?.map((slot) => SlotData.fromJson(slot))
//               .toList() ??
//           [],
//       slotsByDay: json['slotsByDay'] as Map<String, dynamic>? ?? {},
//     );
//   }
// }


// // Simplified API Service - Only 2 methods needed!
// class ScheduleApiService {
//   final String baseUrl;

//   ScheduleApiService({required this.baseUrl});

//   /**
//    * Save or update schedule
//    * Backend handles all validation (overlaps, days, etc.)
//    */
//   Future<bool> saveSchedule(ScheduleData scheduleData) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/doctor/set-availability'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(scheduleData.toJson()),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return data['success'] == true;
//       } else if (response.statusCode == 400) {
//         // Validation error - parse and throw for UI to display
//         final data = jsonDecode(response.body);
//         throw Exception(data['message'] ?? 'Validation failed');
//       }
      
//       print('Save failed: ${response.statusCode} - ${response.body}');
//       return false;
//     } catch (e) {
//       print('Error saving schedule: $e');
//       rethrow; // Re-throw to handle in UI
//     }
//   }

//   /**
//    * Update existing schedule (same as save)
//    */
//   Future<bool> updateSchedule(ScheduleData scheduleData) async {
//     return saveSchedule(scheduleData);
//   }

//   /**
//    * NEW METHOD: Save multi-section schedule
//    * Sends payload with useMultipleSections=true and scheduleSections array
//    * Backend will handle OR logic for selectedDays and slot generation
//    */
//   Future<bool> saveScheduleMultiSection(Map<String, dynamic> payload) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/doctor/set-availability'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(payload),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return data['success'] == true;
//       } else if (response.statusCode == 400) {
//         // Validation error - parse and throw for UI to display
//         final data = jsonDecode(response.body);
//         throw Exception(data['message'] ?? 'Validation failed');
//       }
      
//       print('Multi-section save failed: ${response.statusCode} - ${response.body}');
//       return false;
//     } catch (e) {
//       print('Error saving multi-section schedule: $e');
//       rethrow; // Re-throw to handle in UI
//     }
//   }

//   /**
//    * Fetch complete schedule with all slots organized by day
//    * No need for separate slot fetching!
//    */
//   Future<AvailabilityResponse?> fetchSchedule(String doctorId) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/doctor/availability/$doctorId'),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         print('Schedule fetch response data in schedule_api_service: $data');
//         if (data['success'] == true && data['data'] != null) {
//           final responseData = data['data'];
          
//           // Parse schedule data
//           final schedule = ScheduleData.fromJson(responseData);
          
//           // Parse all daily slots
//           final dailySlots = (responseData['dailySlots'] as List?)
//               ?.map((slot) => SlotData.fromJson(slot))
//               .toList() ?? [];
          
//           // Parse slots organized by day
//           final slotsByDayMap = <int, DaySlots>{};
//           if (responseData['slotsByDay'] != null) {
//             final slotsMap = responseData['slotsByDay'] as Map<String, dynamic>;
//             slotsMap.forEach((key, value) {
//               final dayIndex = int.parse(key);
//               slotsByDayMap[dayIndex] = DaySlots.fromJson(value);
//             });
//           }
          
//           return AvailabilityResponse(
//             schedule: schedule,
//             dailySlots: dailySlots,
//             slotsByDay: slotsByDayMap,
//           );
//         }
//       } else if (response.statusCode == 404) {
//         // No schedule found - return null
//         return null;
//       }

//       throw Exception('Failed to load schedule');
//     } catch (e) {
//       print('Error fetching schedule: $e');
//       rethrow;
//     }
//   }

//   /**
//    * Helper method for backward compatibility with existing code
//    * Returns just the ScheduleData part
//    */
//   Future<ScheduleData> fetchScheduleData(String doctorId) async {
//     final availability = await fetchSchedule(doctorId);
//     print('Fetched availability in api service helper: $availability');
    
//     if (availability != null) {
//       return availability.schedule;
//     }
//     print('No schedule found, returning default.');
    
//     // Return default schedule if none exists
//     return _getDefaultSchedule(doctorId);
//   }

//   /**
//    * Get slots for a specific day from the complete availability
//    * No separate API call needed!
//    */
//   DaySlots? getSlotsForDay(AvailabilityResponse availability, int dayOfWeek) {
//     return availability.slotsByDay[dayOfWeek];
//   }

//   /**
//    * Get default schedule for new doctors
//    */
//   ScheduleData _getDefaultSchedule(String doctorId) {
//   return ScheduleData(
//     doctorId: doctorId,

//     useMultipleSections: false,
//     scheduleSections: null,

//     morningSession: SessionData(
//       enabled: true,
//       start: '08:00 AM',
//       end: '02:00 PM',
//       selectedDays: [false, true, true, true, true, true, true],
//     ),
//     eveningSession: SessionData(
//       enabled: true,
//       start: '04:00 PM',
//       end: '08:00 PM',
//       selectedDays: [false, true, true, true, true, true, false],
//     ),
//     appointmentDuration: '15 Minutes',
//     repeatEvery: '1',
//     repeatPeriod: 'Week',
//     selectedDays: [false, true, true, true, true, true, true],
//     neverEnds: true,
//     status: 'Active',
//   );
// }

// }


import 'dart:convert';
import 'package:http/http.dart' as http;

//
// =========================
// Session Data
// =========================
//
class SessionData {
  final bool enabled;
  final String start;
  final String end;
  final List<bool>? selectedDays;

  SessionData({
    required this.enabled,
    required this.start,
    required this.end,
    this.selectedDays,
  });

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'start': start,
      'end': end,
      'selectedDays': selectedDays ?? List<bool>.filled(7, false),
    };
  }

  factory SessionData.fromJson(Map<String, dynamic> json) {
    return SessionData(
      enabled: json['enabled'] ?? false,
      start: json['start'] ?? '',
      end: json['end'] ?? '',
      selectedDays: json['selectedDays'] != null
          ? List<bool>.from(json['selectedDays'])
          : null,
    );
  }
}

//
// =========================
// Schedule Data
// =========================
//
class ScheduleData {
  final String doctorId;
  final bool useMultipleSections;
  final List<Map<String, dynamic>>? scheduleSections;
  final SessionData morningSession;
  final SessionData eveningSession;
  final String appointmentDuration;
  final String repeatEvery;
  final String repeatPeriod;
  final List<bool> selectedDays;
  final bool neverEnds;
  final String status;
  final DateTime? endDate;

  ScheduleData({
    required this.doctorId,
    required this.useMultipleSections,
    this.scheduleSections,
    required this.morningSession,
    required this.eveningSession,
    required this.appointmentDuration,
    required this.repeatEvery,
    required this.repeatPeriod,
    required this.selectedDays,
    required this.neverEnds,
    required this.status,
    this.endDate,
  });

  factory ScheduleData.fromJson(Map<String, dynamic> json) {
    return ScheduleData(
      doctorId: json['doctorId'] ?? '',
      useMultipleSections: json['useMultipleSections'] ?? false,
      scheduleSections: json['scheduleSections'] != null
          ? (json['scheduleSections'] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList()
          : null,
      morningSession: SessionData.fromJson(json['morningSession'] ?? {}),
      eveningSession: SessionData.fromJson(json['eveningSession'] ?? {}),
      appointmentDuration: json['appointmentDuration'] ?? '15 Minutes',
      repeatEvery: json['repeatEvery']?.toString() ?? '1',
      repeatPeriod: json['repeatPeriod'] ?? 'Week',
      selectedDays: json['selectedDays'] != null
          ? List<bool>.from(json['selectedDays'])
          : List<bool>.filled(7, false),
      neverEnds: json['neverEnds'] ?? true,
      status: json['status'] ?? 'Active',
      endDate:
          json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    );
  }

  /// ✅ REQUIRED for save/update API
  Map<String, dynamic> toJson() {
    return {
      'doctorId': doctorId,
      'useMultipleSections': useMultipleSections,
      'scheduleSections': scheduleSections,
      'morningSession': morningSession.toJson(),
      'eveningSession': eveningSession.toJson(),
      'appointmentDuration': appointmentDuration,
      'repeatEvery': repeatEvery,
      'repeatPeriod': repeatPeriod,
      'selectedDays': selectedDays,
      'neverEnds': neverEnds,
      'status': status,
      'endDate': endDate?.toIso8601String(),
    };
  }
}

//
// =========================
// Slot Data
// =========================
//
class SlotData {
  final String start;
  final String end;
  final String? session;
  final bool isBooked;
  final bool isLocked;

  SlotData({
    required this.start,
    required this.end,
    this.session,
    this.isBooked = false,
    this.isLocked = false,
  });

  factory SlotData.fromJson(Map<String, dynamic> json) {
    return SlotData(
      start: json['start'] ?? '',
      end: json['end'] ?? '',
      session: json['session'],
      isBooked: json['isBooked'] ?? false,
      isLocked: json['isLocked'] ?? false,
    );
  }
}

//
// =========================
// Day Slots
// =========================
//
class DaySlots {
  final String dayName;
  final List<SlotData> slots;
  final int totalSlots;
  final int availableSlots;

  DaySlots({
    required this.dayName,
    required this.slots,
    required this.totalSlots,
    required this.availableSlots,
  });

  factory DaySlots.fromJson(Map<String, dynamic> json) {
    return DaySlots(
      dayName: json['dayName'] ?? '',
      slots: (json['slots'] as List?)
              ?.map((slot) => SlotData.fromJson(slot))
              .toList() ??
          [],
      totalSlots: json['totalSlots'] ?? 0,
      availableSlots: json['availableSlots'] ?? 0,
    );
  }
}

//
// =========================
// Availability Response
// =========================
//
class AvailabilityResponse {
  final ScheduleData schedule;
  final List<SlotData> dailySlots;
  final Map<int, DaySlots> slotsByDay;

  AvailabilityResponse({
    required this.schedule,
    required this.dailySlots,
    required this.slotsByDay,
  });
}

//
// =========================
// API Service
// =========================
//
class ScheduleApiService {
  final String baseUrl;

  ScheduleApiService({required this.baseUrl});

  /// Save or update schedule
  Future<bool> saveSchedule(ScheduleData scheduleData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/doctor/set-availability'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(scheduleData.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }

      if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Validation failed');
      }

      return false;
    } catch (e) {
      print('Error saving schedule: $e');
      rethrow;
    }
  }

  Future<bool> updateSchedule(ScheduleData scheduleData) {
    return saveSchedule(scheduleData);
  }

  /// Fetch full availability
  Future<AvailabilityResponse?> fetchSchedule(String doctorId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/doctor/availability/$doctorId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final responseData = data['data'];

          // ✅ CORRECT
final schedule = ScheduleData.fromJson(responseData['schedule']);

          final dailySlots = (responseData['dailySlots'] as List?)
                  ?.map((e) => SlotData.fromJson(e))
                  .toList() ??
              [];

          final Map<int, DaySlots> slotsByDay = {};
          if (responseData['slotsByDay'] != null) {
            final map = responseData['slotsByDay'] as Map<String, dynamic>;
            map.forEach((key, value) {
              slotsByDay[int.parse(key)] = DaySlots.fromJson(value);
            });
          }

          return AvailabilityResponse(
            schedule: schedule,
            dailySlots: dailySlots,
            slotsByDay: slotsByDay,
          );
        }
      }

      if (response.statusCode == 404) return null;

      throw Exception('Failed to load schedule');
    } catch (e) {
      print('Error fetching schedule: $e');
      rethrow;
    }
  }

  /// Save multi-section schedule
/// Payload already contains:
/// - useMultipleSections: true
/// - scheduleSections: [...]
Future<bool> saveScheduleMultiSection(Map<String, dynamic> payload) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/doctor/set-availability'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] == true;
    }

    if (response.statusCode == 400) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Validation failed');
    }

    print(
        'Multi-section save failed: ${response.statusCode} - ${response.body}');
    return false;
  } catch (e) {
    print('Error saving multi-section schedule: $e');
    rethrow;
  }
}


  /// Helper
  Future<ScheduleData> fetchScheduleData(String doctorId) async {
    final availability = await fetchSchedule(doctorId);
    if (availability != null) return availability.schedule;
    return _getDefaultSchedule(doctorId);
  }

  DaySlots? getSlotsForDay(
      AvailabilityResponse availability, int dayOfWeek) {
    return availability.slotsByDay[dayOfWeek];
  }

  ScheduleData _getDefaultSchedule(String doctorId) {
    return ScheduleData(
      doctorId: doctorId,
      useMultipleSections: false,
      scheduleSections: null,
      morningSession: SessionData(
        enabled: true,
        start: '08:00 AM',
        end: '02:00 PM',
        selectedDays: [false, true, true, true, true, true, true],
      ),
      eveningSession: SessionData(
        enabled: true,
        start: '04:00 PM',
        end: '08:00 PM',
        selectedDays: [false, true, true, true, true, true, false],
      ),
      appointmentDuration: '15 Minutes',
      repeatEvery: '1',
      repeatPeriod: 'Week',
      selectedDays: [false, true, true, true, true, true, true],
      neverEnds: true,
      status: 'Active',
    );
  }
}
