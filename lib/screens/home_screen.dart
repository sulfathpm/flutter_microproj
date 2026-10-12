import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/emergency_data.dart';
import '../models/emergency.dart';
import '../providers/custom_scenarios_provider.dart';
import '../providers/favorites_provider.dart';
import '../screens/add_scenario_screen.dart';
import '../utils/dialer.dart';
import '../widgets/scenario_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }
  void _edit(EmergencyScenario s) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddScenarioScreen(existing: s)),
    );
  }
  Future<void> _confirmDelete(EmergencyScenario s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this case?'),
        content: Text('"${s.title}" will be removed from this device.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true && mounted) {
      context.read<CustomScenariosProvider>().remove(s.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritesProvider>();
    final custom = context.watch<CustomScenariosProvider>();

    final all = [...scenarios, ...custom.scenarios];
    final filtered = all
        .where((s) => s.title.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    final ordered = [
      ...filtered.where((s) => favs.isFavorite(s.id)),
      ...filtered.where((s) => !favs.isFavorite(s.id)),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.medical_services),
            SizedBox(width: 8),
            Text('First-Aid Quick Guide'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AddScenarioScreen.routeName),
        icon: const Icon(Icons.add),
        label: const Text('Add case'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.red[50],
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.red),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Life in danger? Call emergency services first.',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.red[700]),
                  onPressed: () => callNumber(context, '112'),
                  child: const Text('112'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _search,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search emergencies',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _search.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
            ),
          ),
          Expanded(
            child: ordered.isEmpty
                ? const Center(child: Text('No matching emergency found'))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 90),
                    itemCount: ordered.length,
                    itemBuilder: (_, i) {
                      final s = ordered[i];
                      final isCustom = custom.isCustom(s.id);
                      return ScenarioCard(
                        scenario: s,
                        isCustom: isCustom,
                        onLongPress: isCustom ? () => _confirmDelete(s) : null,
                        onDelete: isCustom ? () => _confirmDelete(s) : null,
                        onEdit: isCustom ? () => _edit(s) : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}