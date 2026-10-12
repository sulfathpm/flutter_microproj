import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../models/emergency.dart';
import '../providers/custom_scenarios_provider.dart';

class AddScenarioScreen extends StatefulWidget {
  static const routeName = '/add';

  /// When not null, the form edits this case instead of creating a new one.
  final EmergencyScenario? existing;
  const AddScenarioScreen({super.key, this.existing});

  @override
  State<AddScenarioScreen> createState() => _AddScenarioScreenState();
}

class _AddScenarioScreenState extends State<AddScenarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _summary = TextEditingController();
  final _steps = TextEditingController();
  final _donts = TextEditingController();
  final _contactName = TextEditingController();
  final _contactNumber = TextEditingController();

  Severity _severity = Severity.high;
  String _iconKey = 'warning';
  String _svg = svgOptions.values.first;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      final raw = context.read<CustomScenariosProvider>().rawById(e.id);
      if (raw != null) _prefill(raw);
    }
  }

  void _prefill(Map<String, dynamic> m) {
    _title.text = m['title'] as String;
    _summary.text = m['summary'] as String;
    _severity = Severity.values.byName(m['severity'] as String);

    final icon = m['icon'] as String;
    _iconKey = iconOptions.containsKey(icon) ? icon : 'warning';

    final svg = m['svg'] as String;
    _svg = svgOptions.containsValue(svg) ? svg : svgOptions.values.first;

    // Plain "Step N" titles go back to plain lines; others to "Title: detail".
    _steps.text = (m['steps'] as List).map((s) {
      final t = s['title'] as String;
      final d = s['detail'] as String;
      return RegExp(r'^Step \d+$').hasMatch(t) ? d : '$t: $d';
    }).join('\n');

    _donts.text = (m['donts'] as List).join('\n');

    // 112 and 108 are added automatically; only show an extra contact.
    final extras = (m['contacts'] as List)
        .where((c) => c['number'] != '112' && c['number'] != '108')
        .toList();
    if (extras.isNotEmpty) {
      _contactName.text = extras.first['name'] as String;
      _contactNumber.text = extras.first['number'] as String;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _summary.dispose();
    _steps.dispose();
    _donts.dispose();
    _contactName.dispose();
    _contactNumber.dispose();
    super.dispose();
  }

  List<String> _lines(String text) =>
      text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

  /// "Title: detail" becomes a titled step; a plain line becomes "Step N".
  Map<String, String> _stepFromLine(int i, String line) {
    final idx = line.indexOf(':');
    if (idx > 0 && idx < line.length - 1) {
      return {
        'title': line.substring(0, idx).trim(),
        'detail': line.substring(idx + 1).trim(),
      };
    }
    return {'title': 'Step ${i + 1}', 'detail': line};
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final stepLines = _lines(_steps.text);
    final extraNumber = _contactNumber.text.trim();
    final extraName = _contactName.text.trim();

    final data = <String, dynamic>{
      // Keep the same id when editing, so pins and the list position stay valid.
      'id': widget.existing?.id ??
          'custom_${DateTime.now().millisecondsSinceEpoch}',
      'title': _title.text.trim(),
      'summary': _summary.text.trim(),
      'severity': _severity.name,
      'icon': _iconKey,
      'svg': _svg,
      'steps': [
        for (var i = 0; i < stepLines.length; i++) _stepFromLine(i, stepLines[i]),
      ],
      'donts': _lines(_donts.text),
      'contacts': [
        {'name': 'National Emergency', 'number': '112'},
        {'name': 'Ambulance', 'number': '108'},
        if (extraNumber.isNotEmpty)
          {'name': extraName.isEmpty ? 'Contact' : extraName, 'number': extraNumber},
      ],
    };

    final provider = context.read<CustomScenariosProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    if (_isEditing) {
      await provider.update(widget.existing!.id, data);
    } else {
      await provider.add(data);
    }

    messenger.showSnackBar(SnackBar(
      content: Text(_isEditing ? 'Emergency case updated' : 'Emergency case added'),
    ));
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Emergency Case' : 'Add Emergency Case'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Title (e.g. Snake Bite)'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _summary,
              decoration: const InputDecoration(labelText: 'Short summary'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a summary' : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<Severity>(
              value: _severity,
              decoration: const InputDecoration(labelText: 'Severity'),
              items: [
                for (final s in Severity.values)
                  DropdownMenuItem(
                    value: s,
                    child: Row(children: [
                      Icon(Icons.circle, color: s.color, size: 14),
                      const SizedBox(width: 8),
                      Text(s.label),
                    ]),
                  ),
              ],
              onChanged: (v) => setState(() => _severity = v ?? _severity),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _iconKey,
              decoration: const InputDecoration(labelText: 'Icon'),
              items: [
                for (final e in iconOptions.entries)
                  DropdownMenuItem(
                    value: e.key,
                    child: Row(children: [
                      Icon(e.value),
                      const SizedBox(width: 8),
                      Text(e.key),
                    ]),
                  ),
              ],
              onChanged: (v) => setState(() => _iconKey = v ?? _iconKey),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _svg,
              decoration: const InputDecoration(labelText: 'Illustration'),
              items: [
                for (final e in svgOptions.entries)
                  DropdownMenuItem(
                    value: e.value,
                    child: Row(children: [
                      SvgPicture.asset(e.value, width: 24, height: 24),
                      const SizedBox(width: 8),
                      Text(e.key),
                    ]),
                  ),
              ],
              onChanged: (v) => setState(() => _svg = v ?? _svg),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _steps,
              minLines: 4,
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Steps (one per line)',
                helperText: 'Optional "Title: detail" format. A plain line becomes "Step N".',
                helperMaxLines: 2,
                alignLabelWithHint: true,
              ),
              validator: (v) =>
                  _lines(v ?? '').isEmpty ? 'Enter at least one step' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _donts,
              minLines: 2,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: "Don'ts (one per line, optional)",
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 14),
            Text('Extra contact (optional)', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            TextFormField(
              controller: _contactName,
              decoration: const InputDecoration(labelText: 'Contact name'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _contactNumber,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone number'),
              validator: (v) {
                final t = (v ?? '').trim();
                if (t.isEmpty) return null;
                return RegExp(r'^\+?[0-9]{3,15}$').hasMatch(t)
                    ? null
                    : 'Enter a valid number';
              },
            ),
            const SizedBox(height: 8),
            const Text('112 and 108 are added automatically.',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red[700],
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: Text(_isEditing ? 'Save changes' : 'Save case'),
            ),
          ],
        ),
      ),
    );
  }
}