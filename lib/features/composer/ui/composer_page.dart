import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:replai/core/llm/llm_service.dart';
import 'package:replai/data/repositories/settings_repository.dart';
import 'package:replai/features/composer/logic/composer_provider.dart';

class ComposerPage extends ConsumerStatefulWidget {
  final String? to;
  final String? subject;
  final String? body;

  const ComposerPage({
    super.key,
    this.to,
    this.subject,
    this.body,
  });

  @override
  ConsumerState<ComposerPage> createState() => _ComposerPageState();
}

class _ComposerPageState extends ConsumerState<ComposerPage> {
  final _toController = TextEditingController();
  final _ccController = TextEditingController();
  final _bccController = TextEditingController();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _generatingSubject = false;

  @override
  void initState() {
    super.initState();
    if (widget.to != null) _toController.text = widget.to!;
    if (widget.subject != null) _subjectController.text = widget.subject!;
    if (widget.body != null) _bodyController.text = widget.body!;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(composerProvider.notifier).initialize(
              to: widget.to ?? '',
              subject: widget.subject ?? '',
              body: widget.body ?? '',
            );
      }
    });
  }

  @override
  void dispose() {
    _toController.dispose();
    _ccController.dispose();
    _bccController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _generateSubject() async {
    final body = _bodyController.text.trim();
    if (body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write the email body first')),
      );
      return;
    }

    setState(() => _generatingSubject = true);

    try {
      final llmService = LlmService();
      if (!llmService.isInitialized) {
        throw Exception('Model not loaded');
      }

      final settings =
          await SettingsRepository().loadSettings();

      final subject = await llmService.generateSubject(
        bodyContent: body,
        settings: settings,
      );

      if (subject.isNotEmpty) {
        _subjectController.text = subject;
        ref.read(composerProvider.notifier).setSubject(subject);
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subject generation failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _generatingSubject = false);
    }
  }

  Future<void> _send() async {
    final notifier = ref.read(composerProvider.notifier);
    notifier.setTo(_toController.text.trim());
    notifier.setCc(_ccController.text.trim());
    notifier.setBcc(_bccController.text.trim());
    notifier.setSubject(_subjectController.text.trim());
    notifier.setBody(_bodyController.text.trim());

    final success = await notifier.send();

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email sent')),
        );
        context.pop();
      } else {
        final error = ref.read(composerProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Failed to send')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final composerState = ref.watch(composerProvider);
    final isHtml = composerState.isHtml;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compose'),
        actions: [
          IconButton(
            icon: Icon(isHtml ? Icons.html : Icons.text_fields),
            tooltip: isHtml ? 'HTML mode' : 'Text mode',
            onPressed: () => ref.read(composerProvider.notifier).toggleHtml(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _toController,
              decoration: const InputDecoration(
                labelText: 'To',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _ccController,
              decoration: const InputDecoration(
                labelText: 'Cc',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _bccController,
              decoration: const InputDecoration(
                labelText: 'Bcc',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: 'Subject',
                border: const OutlineInputBorder(),
                suffixIcon: _generatingSubject
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.auto_awesome),
                        tooltip: 'Generate subject from body',
                        onPressed: _generateSubject,
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _bodyController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  labelText: isHtml ? 'HTML Body' : 'Body',
                  border: const OutlineInputBorder(),
                  hintText: composerState.isHtml
                      ? '<p>Write your email...</p>'
                      : 'Write your email...',
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed:
                    composerState.isSending ? null : _send,
                icon: composerState.isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(composerState.isSending ? 'Sending...' : 'Send'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
