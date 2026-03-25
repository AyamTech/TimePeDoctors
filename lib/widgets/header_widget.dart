import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  final String title;
  final IconData icon;

  const HeaderWidget({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background Image
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg-header.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Centered Text and Icon
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
