import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/emergency.dart';

/// Icons the user can pick in the form (stored by key).
const Map<String, IconData> iconOptions = {
  'warning': Icons.warning_amber_rounded,
  'heart': Icons.favorite,
  'fire': Icons.local_fire_department,
  'water': Icons.water_drop,
  'air': Icons.air,
  'bone': Icons.healing,
  'person': Icons.accessibility_new,
  'bug': Icons.pest_control,
  'bolt': Icons.bolt,
  'thermo': Icons.thermostat,
};

/// Illustrations the user can pick (label -> asset path).
const Map<String, String> svgOptions = {
  'Heart': 'assets/svg/cpr.svg',
  'Flame': 'assets/svg/burn.svg',
  'Person': 'assets/svg/choking.svg',
  'Blood drop': 'assets/svg/bleeding.svg',
  'Ankle': 'assets/svg/sprain.svg',
  'Bone': 'assets/svg/fracture.svg',
};

class CustomScenariosProvider extends ChangeNotifier {
  static const _key = 'custom_scenarios';
  final List<Map<String, dynamic>> _raw = [];

  List<EmergencyScenario> get scenarios => _raw.map(_fromJson).toList();

  bool isCustom(String id) => _raw.any((m) => m['id'] == id);

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _raw.clear();
      for (final s in prefs.getStringList(_key) ?? const <String>[]) {
        try {
          final m = jsonDecode(s) as Map<String, dynamic>;
          _fromJson(m); // validates the data; skips corrupt entries
          _raw.add(m);
        } catch (_) {}
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load custom cases: $e');
    }
  }

  Future<void> add(Map<String, dynamic> data) async {
    _raw.add(data);
    notifyListeners();
    await _save();
  }

  Future<void> remove(String id) async {
    _raw.removeWhere((m) => m['id'] == id);
    notifyListeners();
    await _save();
  }
  /// Raw saved data for a custom case (used to pre-fill the edit form).
  Map<String, dynamic>? rawById(String id) {
    for (final m in _raw) {
      if (m['id'] == id) return m;
    }
    return null;
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    final i = _raw.indexWhere((m) => m['id'] == id);
    if (i == -1) return;
    _raw[i] = data;
    notifyListeners();
    await _save();
  }
  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, _raw.map(jsonEncode).toList());
    } catch (e) {
      debugPrint('Failed to save custom cases: $e');
    }
  }

  EmergencyScenario _fromJson(Map<String, dynamic> m) => EmergencyScenario(
        id: m['id'] as String,
        title: m['title'] as String,
        summary: m['summary'] as String,
        severity: Severity.values.byName(m['severity'] as String),
        icon: iconOptions[m['icon']] ?? Icons.warning_amber_rounded,
        svgAsset: m['svg'] as String,
        steps: (m['steps'] as List)
            .map((e) => FirstAidStep(e['title'] as String, e['detail'] as String))
            .toList(),
        donts: List<String>.from(m['donts'] as List),
        contacts: (m['contacts'] as List)
            .map((e) => EmergencyContact(e['name'] as String, e['number'] as String))
            .toList(),
      );
}