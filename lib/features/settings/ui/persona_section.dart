import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:replai/data/models/persona.dart';
import 'package:replai/features/settings/logic/settings_provider.dart';

class PersonaSection extends ConsumerWidget {
  const PersonaSection({super.key});

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Personas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showPersonaDialog(context, ref),
                ),
              ],
            ),
            Text(
              'Manage identities for AI replies',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            settingsAsync.when(
              data: (settings) {
                if (settings.personas.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'No personas yet. Add one to customize your AI replies.',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  );
                }
                return Column(
                  children: [
                    if (settings.personaId == null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                size: 16, color: colorScheme.onSurfaceVariant),
                            const SizedBox(width: 8),
                            Text('No persona selected',
                                style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                    ...settings.personas.map((persona) => _PersonaTile(
                          persona: persona,
                          isSelected: persona.id == settings.personaId,
                          onSelect: () {
                            ref
                                .read(replySettingsProvider.notifier)
                                .updatePersonaId(persona.id);
                          },
                          onEdit: () => _showPersonaDialog(
                              context, ref, existing: persona),
                          onDelete: () => _confirmDeletePersona(
                              context, ref, persona),
                        )),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPersonaDialog(BuildContext context, WidgetRef ref,
      {Persona? existing}) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final signatureController =
        TextEditingController(text: existing?.signature ?? '');
    final toneHintController =
        TextEditingController(text: existing?.toneHint ?? '');
    final systemPromptController =
        TextEditingController(text: existing?.systemPrompt ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing != null ? 'Edit Persona' : 'Add Persona'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g., Alex - Tech Lead',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: signatureController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Signature',
                  hintText: '--\nAlex\nTech Lead',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: toneHintController,
                decoration: const InputDecoration(
                  labelText: 'Tone Hint',
                  hintText: 'Technical, concise, solution-oriented',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: systemPromptController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'System Prompt (optional)',
                  hintText: 'Custom AI instructions...',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              if (existing != null) {
                ref.read(replySettingsProvider.notifier).updatePersona(
                      existing.copyWith(
                        name: name,
                        signature: signatureController.text,
                        toneHint: toneHintController.text,
                        systemPrompt: systemPromptController.text.isNotEmpty
                            ? systemPromptController.text
                            : null,
                      ),
                    );
              } else {
                ref.read(replySettingsProvider.notifier).addPersona(
                      Persona.create(
                        name: name,
                        signature: signatureController.text,
                        toneHint: toneHintController.text,
                        systemPrompt: systemPromptController.text.isNotEmpty
                            ? systemPromptController.text
                            : null,
                      ),
                    );
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeletePersona(
      BuildContext context, WidgetRef ref, Persona persona) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Persona'),
        content: Text('Delete "${persona.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              ref.read(replySettingsProvider.notifier).deletePersona(persona.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _PersonaTile extends StatelessWidget {
  final Persona persona;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PersonaTile({
    required this.persona,
    required this.isSelected,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color:
          isSelected ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          persona.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: persona.toneHint.isNotEmpty
            ? Text(
                persona.toneHint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Icon(Icons.check_circle, color: colorScheme.primary, size: 20),
            IconButton(
              icon: const Icon(Icons.edit, size: 18),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 18),
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onSelect,
      ),
    );
  }
}
