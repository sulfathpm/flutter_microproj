import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/emergency.dart';
import '../providers/favorites_provider.dart';
import '../screens/instructions_screen.dart';
import 'severity_badge.dart';

class ScenarioCard extends StatelessWidget {
  final EmergencyScenario scenario;
  final bool isCustom;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const ScenarioCard({
    super.key,
    required this.scenario,
    this.isCustom = false,
    this.onLongPress,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isFav = context.select<FavoritesProvider, bool>((f) => f.isFavorite(scenario.id));
    final color = scenario.severity.color;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.pushNamed(
          context,
          InstructionsScreen.routeName,
          arguments: scenario,
        ),
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.warning_amber_rounded, color: color, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scenario.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      scenario.summary,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        SeverityBadge(severity: scenario.severity),
                        if (isCustom) ...[
                          const SizedBox(width: 8),
                          const Text(
                            'Custom',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: isFav ? 'Unpin' : 'Pin to top',
                icon: Icon(
                  isFav ? Icons.star : Icons.star_border,
                  color: isFav ? Colors.amber[700] : Colors.grey,
                ),
                onPressed: () => context.read<FavoritesProvider>().toggle(scenario.id),
              ),
              if (onEdit != null)
                IconButton(
                  tooltip: 'Edit',
                  icon: Icon(Icons.edit_outlined, color: Colors.blue[600]),
                  onPressed: onEdit,
                ),
              if (onDelete != null)
                IconButton(
                  tooltip: 'Delete',
                  icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}