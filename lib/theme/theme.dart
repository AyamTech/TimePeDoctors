import 'package:flutter/material.dart';

const Color primaryColor = Colors.blue; // Define primary color

ThemeData appTheme = ThemeData(
  primarySwatch: Colors.blue,
  fontFamily: 'Poppins', // Set Poppins as the default font
  appBarTheme: const AppBarTheme(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    titleTextStyle: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontFamily: 'Poppins', fontSize: 18),
    bodyMedium: TextStyle(fontFamily: 'Poppins', fontSize: 16),
    titleLarge: TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.bold),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return Colors.white;
      }
      return Colors.white;
    }),
    trackColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return const Color(0xFF6B0D24);
      }
      return Colors.grey[300];
    }),
  ),
);
