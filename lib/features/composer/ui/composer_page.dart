import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:replai/core/llm/llm_service.dart';
import 'package:replai/core/llm/prompt_templates.dart';
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

  bool _transforming = false;
  String? _backupBody;
  StreamSubscription<String>? _transformSub;

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
    _cancelTransform();
    _toController.dispose();
    _ccController.dispose();
    _bccController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _cancelTransform() {
    _transformSub?.cancel();
    _transformSub = null;
    if (_backupBody != null && _transforming) {
      _bodyController.text = _backupBody!;
      ref.read(composerProvider.notifier).setBody(_backupBody!);
      _backupBody = null;
    }
    if (mounted) setState(() => _transforming = false);
  }

  bool get _canAssist => _bodyController.text.trim().length >= 2;

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
      if (!llmService.isInitialized) throw Exception('Model not loaded');

      final subject =
          await llmService.generateSubject(bodyContent: body);

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

  void _showAssistSheet() {
    String selectedAction = '';
    final actions =
        PromptTemplates.transformActions.entries.toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(ctx)
                            .colorScheme
                            .onSurfaceVariant
                            .withAlpha(80),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.auto_awesome,
                          color: Theme.of(ctx).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('AI Assistant',
                          style: Theme.of(ctx)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select an action to transform your text',
                    style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                          color: Theme.of(ctx)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxHeight: 300),
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: actions.map((entry) {
                          final isSelected =
                              selectedAction == entry.key;
                          return ChoiceChip(
                            selected: isSelected,
                            label: Text(entry.value),
                            onSelected: (_) {
                              setSheetState(
                                  () => selectedAction = entry.key);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: selectedAction.isNotEmpty
                          ? () {
                              Navigator.pop(ctx);
                              _runTransform(selectedAction);
                            }
                          : null,
                      icon: const Icon(Icons.auto_awesome,
                          size: 20),
                      label: const Text('Generate'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _runTransform(String action) {
    _cancelTransform();
    _backupBody = _bodyController.text;

    setState(() => _transforming = true);

    final llmService = LlmService();

    try {
      final stream = llmService.generateTextTransform(
        originalText: _bodyController.text,
        action: action,
      );

      _bodyController.text = '';
      ref.read(composerProvider.notifier).setBody('');

      _transformSub = stream.listen(
        (token) {
          _bodyController.text += token;
          ref
              .read(composerProvider.notifier)
              .setBody(_bodyController.text);
        },
        onError: (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Transform failed: $e')),
            );
            _cancelTransform();
          }
        },
        onDone: () {
          if (mounted) {
            setState(() {
              _transforming = false;
              _backupBody = null;
            });
          }
        },
        cancelOnError: true,
      );
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transform failed: $e')),
        );
        _cancelTransform();
      }
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
            onPressed: () =>
                ref.read(composerProvider.notifier).toggleHtml(),
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
                          child: CircularProgressIndicator(
                              strokeWidth: 2),
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
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: isHtml ? 'HTML Body' : 'Body',
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                  hintText: composerState.isHtml
                      ? '<p>Write your email...</p>'
                      : 'Write your email...',
                  suffixIcon: _transforming
                      ? IconButton(
                          icon: const Icon(Icons.close,
                              color: Colors.red),
                          tooltip: 'Cancel and restore original',
                          onPressed: _cancelTransform,
                        )
                      : IconButton(
                          icon: Icon(
                            Icons.auto_awesome,
                            color: _canAssist
                                ? Theme.of(context)
                                    .colorScheme
                                    .primary
                                : Theme.of(context).disabledColor,
                          ),
                          tooltip: 'AI text transform',
                          onPressed:
                              _canAssist ? _showAssistSheet : null,
                        ),
                ),
              ),
            ),
            if (_transforming)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child:
                          CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Transforming...',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ],
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
                        child: CircularProgressIndicator(
                            strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(composerState.isSending
                    ? 'Sending...'
                    : 'Send'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
