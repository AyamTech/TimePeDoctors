import 'package:flutter/material.dart';
import 'dart:async';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_toast.dart';

class BreakButton extends StatefulWidget {
  final VoidCallback? onApiSuccess;

  const BreakButton({super.key, this.onApiSuccess});

  @override
  State<BreakButton> createState() => _BreakButtonState();
}

class _BreakButtonState extends State<BreakButton> {
  Timer? _breakTimer;
  Timer? _syncTimer;
  int _remainingSeconds = 0;
  bool _onBreak = false;
  bool _isResuming = false;

  @override
  void initState() {
    super.initState();
    _loadBreakStatus();

    // 🔁 Periodic sync with backend (every 30s)
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_onBreak) _loadBreakStatus();
    });
  }

  @override
  void dispose() {
    _breakTimer?.cancel();
    _syncTimer?.cancel();
    super.dispose();
  }

  /// 🧠 Fetch current break info from backend and update state
  Future<void> _loadBreakStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');
      if (token == null) return;

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String doctorId = decodedToken['id'];

      final response = await http.get(
        Uri.parse(ApiConstants.getDoctorsUrl(doctorId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final breakData = data['break'];

        if (breakData != null && breakData['isOnBreak'] == true) {
          final String? startStr = breakData['lastBreakStart'];
          final String? endStr = breakData['lastBreakEnd'];

          if (startStr != null && endStr != null) {
            final start = DateTime.parse(startStr);
            final end = DateTime.parse(endStr);
            final now = DateTime.now();

            if (now.isBefore(end)) {
              final remaining = end.difference(now).inSeconds;
              setState(() {
                _onBreak = true;
                _remainingSeconds = remaining;
              });
              _startLocalCountdown();
            } else {
              setState(() {
                _onBreak = false;
                _remainingSeconds = 0;
              });
            }
          }
        } else {
          setState(() {
            _onBreak = false;
            _remainingSeconds = 0;
          });
        }
      } else {
        debugPrint("Failed to fetch doctor details: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error loading break status: $e");
    }
  }

  /// 🔄 Local countdown timer (for live display)
  void _startLocalCountdown() {
    _breakTimer?.cancel();
    _breakTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _onBreak = false;
        });
      }
    });
  }

  /// 🧍 Start a new break
  void _startBreak(int minutes) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');
      if (token == null) throw Exception('No token found');

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String doctorId = decodedToken['id'];

      final response = await http.patch(
        Uri.parse(ApiConstants.doctorBreak(doctorId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'doctorId': doctorId,
          'minutes': minutes.toString(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        await _loadBreakStatus(); // ⬅️ Immediately refresh from backend
        CustomToast.show(context, "Break started successfully", ToastType.success);
        widget.onApiSuccess?.call();
      } else {
        CustomToast.show(context, "Failed to start break.", ToastType.error);
      }
    } catch (e) {
      CustomToast.show(context, "Something went wrong", ToastType.error);
    }
  }

  /// ▶️ Resume / End the break early
  void _resumeBreak() async {
    setState(() {
      _isResuming = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');
      if (token == null) throw Exception('No token found');

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String doctorId = decodedToken['id'];

      int remainingMinutes = (_remainingSeconds / 60).ceil();

      final response = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/appointment/break/decreaseTime'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'doctorId': doctorId,
          'remainingminutes': remainingMinutes.toString(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          _onBreak = false;
          _breakTimer?.cancel();
          _remainingSeconds = 0;
        });
        CustomToast.show(context, "Break resumed successfully.", ToastType.success);
        widget.onApiSuccess?.call();
      } else {
        CustomToast.show(context, "Failed to resume break.", ToastType.error);
      }
    } catch (e) {
      CustomToast.show(context, "Error resuming break.", ToastType.error);
    } finally {
      setState(() {
        _isResuming = false;
      });
    }
  }

  /// 🍵 Show popup menu for selecting break duration
  void _showBreakOptions(BuildContext context, TapDownDetails details) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');
      if (token == null) return;

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String doctorId = decodedToken['id'];

      final response = await http.get(Uri.parse(ApiConstants.getDoctorAvailabilityUrl(doctorId)));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final now = DateTime.now();
        final currentTime = DateFormat('HH:mm').format(now);

        bool isWithinSession(String start, String end) {
          final startTime = DateFormat('hh:mm a').parse(start);
          final endTime = DateFormat('hh:mm a').parse(end);
          final nowTime = DateFormat('HH:mm').parse(currentTime);
          return nowTime.isAfter(startTime) && nowTime.isBefore(endTime);
        }

        final morning = data['morningSession'];
        final evening = data['eveningSession'];

        bool breakAllowed = (morning['enabled'] && isWithinSession(morning['start'], morning['end'])) ||
            (evening['enabled'] && isWithinSession(evening['start'], evening['end']));

        if (!breakAllowed) {
          CustomToast.show(context, "Break is allowed only during working hours.", ToastType.info);
          return;
        }

        // Show break options
        final List<int> breakMinutes = [15, 30, 45, 60];
        final RenderBox button = context.findRenderObject() as RenderBox;
        final Offset position = button.localToGlobal(Offset.zero);
        final double left = position.dx;
        final double top = position.dy + button.size.height;

        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(left, top, left + button.size.width, top + 200),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          items: [
            const PopupMenuItem(
              enabled: false,
              child: Text(
                'Choose Break time',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ),
            ...breakMinutes.map((minutes) {
              return PopupMenuItem(
                onTap: () => _startBreak(minutes),
                child: Text(
                  '$minutes Minutes',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Color(0xFF670E22),
                  ),
                ),
              );
            }).toList(),
          ],
        );
      } else {
        CustomToast.show(context, "Unable to fetch schedule.", ToastType.error);
      }
    } catch (e) {
      CustomToast.show(context, "Something went wrong", ToastType.error);
    }
  }

  /// 🕒 Format countdown display
  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return _onBreak
        ? Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: double.infinity,
                height: 36,
                child: OutlinedButton.icon(
                  onPressed: _isResuming ? null : _resumeBreak,
                  icon: _isResuming
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF670E22)),
                          ),
                        )
                      : const Icon(Icons.play_circle_outline, size: 20, color: Color(0xFF670E22)),
                  label: Text(
                    _isResuming ? 'Resuming...' : 'Resume Now',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: Color(0xFF670E22),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF670E22), width: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                    padding: const EdgeInsets.fromLTRB(11, 6, 11, 6),
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              Positioned(
                top: -10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Ends in ${_formatTime(_remainingSeconds)} M',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          )
        : SizedBox(
            width: 166.5,
            height: 36,
            child: GestureDetector(
              onTapDown: (details) => _showBreakOptions(context, details),
              child: OutlinedButton.icon(
                onPressed: null,
                icon: Image.asset(
                  'assets/images/tea-break.png',
                  width: 20,
                  height: 20,
                  color: const Color(0xFF670E22),
                ),
                label: const Text(
                  'Take a Break',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: Color(0xFF670E22),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF670E22), width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                  padding: const EdgeInsets.fromLTRB(11, 6, 11, 6),
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          );
  }
}
