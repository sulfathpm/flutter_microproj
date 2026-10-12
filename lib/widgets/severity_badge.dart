import 'package:flutter/material.dart';
import '../models/emergency.dart';

class SeverityBadge extends StatelessWidget {
  final Severity severity;
  final bool onDark;
  const SeverityBadge({super.key, required this.severity, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    final color = onDark ? Colors.white : severity.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: onDark ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(severity.label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
