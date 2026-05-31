import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:replai/features/settings/ui/tone_section.dart';
import 'package:replai/features/settings/ui/language_section.dart';
import 'package:replai/features/settings/ui/persona_section.dart';
import 'package:replai/features/settings/ui/model_section.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ToneSection(),
          SizedBox(height: 24),
          LanguageSection(),
          SizedBox(height: 24),
          PersonaSection(),
          SizedBox(height: 24),
          ModelSection(),
        ],
      ),
    );
  }
}
