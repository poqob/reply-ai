import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:replai/features/settings/logic/settings_provider.dart';

class ModelSection extends ConsumerStatefulWidget {
  const ModelSection({super.key});

  @override
  ConsumerState<ModelSection> createState() => _ModelSectionState();
}

class _ModelSectionState extends ConsumerState<ModelSection> {
  Future<String> get _modelsDir async {
    final dir = await getApplicationDocumentsDirectory();
    final modelsDir = Directory('${dir.path}/replyai_models');
    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }
    return modelsDir.path;
  }

  Future<void> _pickModel() async {
    try {
      debugPrint('Opening file picker for GGUF models...');
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        debugPrint('File picker cancelled or no file selected');
        return;
      }

      final pickedFile = result.files.first;
      debugPrint('Picked file: ${pickedFile.name}, path: ${pickedFile.path}');

      if (!pickedFile.name.toLowerCase().endsWith('.gguf')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a .gguf model file')),
          );
        }
        return;
      }

      if (pickedFile.path == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cannot access selected file')),
          );
        }
        return;
      }

      final destDir = await _modelsDir;
      final fileName = pickedFile.name;
      final destPath = '$destDir/$fileName';

      final sourceFile = File(pickedFile.path!);
      await sourceFile.copy(destPath);
      debugPrint('Model copied to: $destPath');

      if (mounted) {
        ref.read(llmModelStateProvider.notifier).loadModel(destPath);
      }
    } on Exception catch (e, stackTrace) {
      debugPrint('Error picking model: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final modelState = ref.watch(llmModelStateProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Model Settings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Select an on-device LLM model (GGUF format)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  modelState.isLoaded
                      ? Icons.check_circle
                      : Icons.warning_amber,
                  color: modelState.isLoaded
                      ? Colors.green
                      : colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    modelState.isLoaded
                        ? 'Model: ${modelState.modelName ?? "Unknown"}'
                        : 'No model loaded',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            if (modelState.error != null) ...[
              const SizedBox(height: 8),
              Text(
                modelState.error!,
                style: TextStyle(color: colorScheme.error, fontSize: 12),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: modelState.isLoading
                  ? const FilledButton(
                      onPressed: null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Loading...'),
                        ],
                      ),
                    )
                  : FilledButton.icon(
                      onPressed: _pickModel,
                      icon: const Icon(Icons.folder_open),
                      label: const Text('Pick Model File (.gguf)'),
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              'Supports 1.5B-3B parameter models in GGUF format.\n'
              'Recommended: Gemma 2 2B, Llama 3.2 1B/3B, Phi-3-mini, Qwen2.5 1.5B/3B',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
