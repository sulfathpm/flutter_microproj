import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/emergency.dart';
import '../utils/dialer.dart';
import '../widgets/contact_tile.dart';
import '../widgets/severity_badge.dart';

class InstructionsScreen extends StatefulWidget {
  static const routeName = '/instructions';
  final EmergencyScenario scenario;
  const InstructionsScreen({super.key, required this.scenario});

  @override
  State<InstructionsScreen> createState() => _InstructionsScreenState();
}

class _InstructionsScreenState extends State<InstructionsScreen> {
  final Set<int> _done = {};

  EmergencyScenario get s => widget.scenario;

  @override
  Widget build(BuildContext context) {
    final progress = _done.length / s.steps.length;

    return Scaffold(
      appBar: AppBar(title: Text(s.title)),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        onPressed: () => callNumber(context, '112'),
        icon: const Icon(Icons.call),
        label: const Text('Call 112'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 90),
        children: [
          _header(),
          LinearProgressIndicator(value: progress, minHeight: 6),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Immediate Steps (${_done.length}/${s.steps.length})',
                style: Theme.of(context).textTheme.titleLarge),
          ),
          for (var i = 0; i < s.steps.length; i++) _stepRow(i),
          _donts(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('Emergency Contacts', style: Theme.of(context).textTheme.titleLarge),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(children: [for (final c in s.contacts) ContactTile(contact: c)]),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'This guide is for quick reference only and does not replace professional medical care or first-aid training.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Container(height: 160, width: double.infinity, color: s.severity.color),
        Positioned(
          right: -24,
          bottom: -24,
          child: Icon(s.icon, size: 170, color: Colors.white.withValues(alpha: 0.15)),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 128,
            child: Row(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: SvgPicture.asset(s.svgAsset),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SeverityBadge(severity: s.severity, onDark: true),
                      const SizedBox(height: 8),
                      Text(s.title,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(s.summary, style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _stepRow(int i) {
    final step = s.steps[i];
    final done = _done.contains(i);
    return Card(
      color: done ? Colors.green[50] : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => done ? _done.remove(i) : _done.add(i)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: done ? Colors.green : s.severity.color,
                child: done
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : Text('${i + 1}', style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(step.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          decoration: done ? TextDecoration.lineThrough : null,
                        )),
                    const SizedBox(height: 4),
                    Text(step.detail),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _donts() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.block, color: Colors.red),
            SizedBox(width: 8),
            Text("Don't", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ]),
          const SizedBox(height: 8),
          for (final d in s.donts)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('\u2022  '),
                  Expanded(child: Text(d)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
