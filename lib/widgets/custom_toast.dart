import 'package:flutter/material.dart';

enum ToastType { success, info, error }

class CustomToast {
  static void show(BuildContext context, String message, ToastType type) {
    IconData icon;
    Color iconColor;

    switch (type) {
      case ToastType.success:
        icon = Icons.check_circle;
        iconColor = Colors.greenAccent;
        break;
      case ToastType.info:
        icon = Icons.info;
        iconColor = Colors.blueAccent;
        break;
      case ToastType.error:
        icon = Icons.error;
        iconColor = Colors.redAccent;
        break;
    }

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50,
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
}
