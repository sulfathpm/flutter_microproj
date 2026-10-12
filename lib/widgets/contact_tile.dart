import 'package:flutter/material.dart';
import '../models/emergency.dart';
import '../utils/dialer.dart';

class ContactTile extends StatelessWidget {
  final EmergencyContact contact;
  const ContactTile({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.phone_in_talk, color: Colors.green),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contact.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(contact.number,
                      style: const TextStyle(fontSize: 18, letterSpacing: 1.5)),
                ],
              ),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: Colors.green[700]),
              onPressed: () => callNumber(context, contact.number),
              icon: const Icon(Icons.call),
              label: const Text('Call'),
            ),
          ],
        ),
      ),
    );
  }
}
