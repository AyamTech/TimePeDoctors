// // lib/services/socket_service.dart
// import 'package:socket_io_client/socket_io_client.dart' as IO;

// class SocketService {
//   late IO.Socket _socket;

//   void connect({
//     required String baseUrl,
//     required String token,
//     required String clientId,
//     required String role,
//   }) {
//     _socket = IO.io(
//       baseUrl,
//       IO.OptionBuilder()
//           .setTransports(['websocket'])
//           .disableAutoConnect()
//           .setAuth({'token': token})
//           .setQuery({'clientId': clientId, 'role': role})
//           .build(),
//     );

//     _socket.connect();

//     _socket.onConnect((_) => print("✅ Connected: ${_socket.id}"));
//     _socket.onDisconnect((_) => print("❌ Disconnected"));
//     _socket.onError((err) => print("⚠️ Socket error: $err"));
//     _socket.onReconnect((_) => print("🔁 Reconnected"));

//     // Join events can be called after connect
//   }

//   void emit(String event, dynamic data) => _socket.emit(event, data);
//   void on(String event, Function(dynamic) handler) => _socket.on(event, handler);
//   void disconnect() => _socket.disconnect();
// }




// lib/services/socket_service.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket _socket;
  bool _connected = false;
  String? _baseUrl;
  String? _token;
  String? _clientId;
  String? _role;
  String? _doctorId;

  void connect({
    required String baseUrl,
    required String token,
    required String clientId,
    required String role,
    String? doctorId,
  }) {
    _baseUrl = baseUrl;
    _token = token;
    _clientId = clientId;
    _role = role;
    _doctorId = doctorId;

    _socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .setQuery({'clientId': clientId, 'role': role})
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .build(),
    );

    _registerCoreListeners();
    _socket.connect();
  }

  void _registerCoreListeners() {
    _socket.onConnect((_) {
      _connected = true;
      print("✅ Doctor socket connected: ${_socket.id}");
      _joinDoctorQueue();
    });

    _socket.onDisconnect((_) {
      _connected = false;
      print("❌ Doctor socket disconnected");
    });

    _socket.onReconnect((_) {
      print("🔁 Doctor socket reconnected — rejoining queue...");
      _joinDoctorQueue();
    });

    _socket.onError((err) => print("⚠️ Socket error: $err"));
    _socket.onConnectError((err) => print("⚠️ Connection error: $err"));
  }

  void _joinDoctorQueue() {
    if (_doctorId != null) {
      _socket.emitWithAck('join_doctor_queue', _doctorId, ack: (response) {
        print("📡 Ack for join_doctor_queue → $response");
      });
    } else {
      print("⚠️ Doctor ID not set — cannot join queue room");
    }
  }

  void on(String event, Function(dynamic) handler) {
    _socket.on(event, (data) {
      print("📥 Event [$event] → $data");
      handler(data);
    });
  }

  void emit(String event, dynamic data) {
    if (_connected) {
      print("📤 Emitting event [$event] → $data");
      _socket.emit(event, data);
    } else {
      print("⚠️ Tried to emit [$event] while disconnected");
    }
  }

  void disconnect() {
    _socket.disconnect();
    _connected = false;
  }

  bool get isConnected => _connected;
}
