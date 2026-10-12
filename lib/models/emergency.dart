import 'package:flutter/material.dart';

enum Severity { critical, high, moderate }

extension SeverityX on Severity {
  String get label => switch (this) {
        Severity.critical => 'CRITICAL',
        Severity.high => 'HIGH',
        Severity.moderate => 'MODERATE',
      };

  Color get color => switch (this) {
        Severity.critical => const Color(0xFFC62828),
        Severity.high => const Color(0xFFEF6C00),
        Severity.moderate => const Color(0xFFF9A825),
      };
}

/// One action in the step-by-step list.
class FirstAidStep {
  final String title;
  final String detail;
  const FirstAidStep(this.title, this.detail);
}

class EmergencyContact {
  final String name;
  final String number;
  const EmergencyContact(this.name, this.number);
}

class EmergencyScenario {
  final String id;
  final String title;
  final String summary;
  final Severity severity;
  final IconData icon;
  final String svgAsset;
  final List<FirstAidStep> steps;
  final List<String> donts;
  final List<EmergencyContact> contacts;

  const EmergencyScenario({
    required this.id,
    required this.title,
    required this.summary,
    required this.severity,
    required this.icon,
    required this.svgAsset,
    required this.steps,
    required this.donts,
    required this.contacts,
  });
}
