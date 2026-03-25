import 'package:flutter/material.dart';

class AppointmentCard extends StatelessWidget {
  final int index;

  const AppointmentCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(
                'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/WhatsApp%20Image%202025-02-18%20at%2015.47.05_9f1dbe53.jpg-CKwM2PmFFWRKqVvYV0OQax8Rhu3COE.jpeg',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mr. Raj Patel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Neuan Fever (8:30 AM)', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
