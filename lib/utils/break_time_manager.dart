import 'package:flutter/material.dart';

class BreakTimeManager {
  static final ValueNotifier<int> breakDuration = ValueNotifier<int>(0);  // Remove the ? to make it non-nullable
  static final ValueNotifier<DateTime?> breakEndTime = ValueNotifier<DateTime?>(null);

  static void applyBreak() {
    if (breakDuration.value > 0) {
      final now = DateTime.now();
      breakEndTime.value = now.add(Duration(minutes: breakDuration.value));
      breakDuration.value = 0;
    }
  }
}