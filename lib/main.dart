import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';

import 'providers/patient_provider.dart';
import 'screens/login_page.dart';
import 'screens/main_page.dart';

// 🔔 Background Notification Handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "assets/.env");

  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } catch (e, stackTrace) {
      print("Firebase initialization error: $e\n$stackTrace");
      // Proceed to run the app even if Firebase fails
    }
  }

  final prefs = await SharedPreferences.getInstance();
  final String? authToken = prefs.getString('authToken');

  runApp(MyApp(isLoggedIn: authToken != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PatientProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF6B0D24),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6B0D24),
            primary: const Color(0xFF6B0D24),
          ),
        ),
        home: NotificationHandler(isLoggedIn: isLoggedIn),
      ),
    );
  }
}

class NotificationHandler extends StatefulWidget {
  final bool isLoggedIn;
  const NotificationHandler({Key? key, required this.isLoggedIn})
      : super(key: key);

  @override
  _NotificationHandlerState createState() => _NotificationHandlerState();
}

class _NotificationHandlerState extends State<NotificationHandler> {
  late bool _isLoggedIn;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = widget.isLoggedIn;
    setupFirebaseNotifications();
  }

  void setupFirebaseNotifications() async {
    if (kIsWeb) return;
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      print("🔐 Permission granted: ${settings.authorizationStatus}");

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // ✅ Permission Granted
        String? token = await messaging.getToken();
        print("📲 Device Token: $token");

        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print("📩 Foreground Message: ${message.notification?.title}");
          final title = message.notification?.title ?? "";
          final body = message.notification?.body ?? "";
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(title.isNotEmpty ? title : "New Notification"),
              content: Text(body),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        });

        FirebaseMessaging.instance.getInitialMessage().then((message) {
          if (message != null) {
            print(
                "🏁 App Opened from Notification: ${message.notification?.title}");
          }
        });

        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          print("➡️ Notification Clicked: ${message.notification?.title}");
        });
      } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
        // ❌ Permission Denied — Show settings dialog
        print("🚫 Permission Denied");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Notifications Disabled"),
            content: const Text(
                "You have denied notification permissions. Please enable them from settings."),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await openAppSettings();
                },
                child: const Text("Open Settings"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ],
          ),
        );
      } else {
        print("⚠️ Authorization status: ${settings.authorizationStatus}");
      }
    } catch (e, st) {
      print("Firebase Messaging setup error: $e\n$st");
    }
  }

  void updateLoginState(bool isLoggedIn) {
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.isLoggedIn ? const DoctorMainPage() : const LoginScreen();
  }
}
