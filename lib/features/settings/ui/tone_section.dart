import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:replai/features/settings/logic/settings_provider.dart';

class ToneSection extends ConsumerWidget {
  const ToneSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(replySettingsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tone',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Select the default tone for AI-generated replies',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            settingsAsync.when(
              data: (settings) => _buildToneSelector(context, ref, settings.tone),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToneSelector(
      BuildContext context, WidgetRef ref, String currentTone) {
    final tones = [
      ('casual', 'Casual', Icons.sentiment_satisfied_alt),
      ('professional', 'Professional', Icons.business_center),
      ('formal', 'Formal', Icons.gavel),
      ('friendly', 'Friendly', Icons.favorite_border),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tones.map((tone) {
        final isSelected = currentTone == tone.$1;
        return ChoiceChip(
          selected: isSelected,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(tone.$3, size: 18),
              const SizedBox(width: 6),
              Text(tone.$2),
            ],
          ),
          onSelected: (_) {
            ref.read(replySettingsProvider.notifier).updateTone(tone.$1);
          },
        );
      }).toList(),
    );
  }
}
