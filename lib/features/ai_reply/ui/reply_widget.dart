import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:replai/features/ai_reply/logic/reply_provider.dart';

class AiReplyWidget extends ConsumerStatefulWidget {
  final String emailContent;
  final String senderName;
  final String recipientEmail;
  final String originalSubject;
  final String accountId;

  const AiReplyWidget({
    super.key,
    required this.emailContent,
    required this.senderName,
    required this.recipientEmail,
    required this.originalSubject,
    required this.accountId,
  });

  @override
  ConsumerState<AiReplyWidget> createState() => _AiReplyWidgetState();
}

class _AiReplyWidgetState extends ConsumerState<AiReplyWidget> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    try {
      ref.read(replyStateProvider.notifier).reset();
    } catch (_) {}
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final replyState = ref.watch(replyStateProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'AI Reply',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            switch (replyState.state) {
              ReplyState.idle => _buildIdleState(context),
              ReplyState.generating => _buildGeneratingState(context, replyState.content),
              ReplyState.done => _buildDoneState(context, replyState.content),
              ReplyState.error => _buildErrorState(context, replyState.error ?? 'Unknown error'),
            },
          ],
        ),
      ),
    );
  }

  Widget _buildIdleState(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Generate a reply to this email using AI',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _generate,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate Reply'),
          ),
        ),
      ],
    );
  }

  Widget _buildGeneratingState(BuildContext context, String content) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasContent = content.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!hasContent)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          )
        else ...[
          ConstrainedBox(
            constraints:
                const BoxConstraints(maxHeight: 200),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  content,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Text(
                'Generating...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ],
        if (hasContent) const SizedBox(height: 16),
        if (hasContent)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ref.read(replyStateProvider.notifier).reset();
              },
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Cancel'),
            ),
          ),
      ],
    );
  }

  Widget _buildDoneState(BuildContext context, String content) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                content,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: () => _useReply(context, content),
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Use This'),
            ),
            OutlinedButton.icon(
              onPressed: () => _editReply(context, content),
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit'),
            ),
            OutlinedButton.icon(
              onPressed: _regenerate,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Regenerate'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  error,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _generate,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ),
      ],
    );
  }

  void _generate() {
    ref.read(replyStateProvider.notifier).generateReply(
          emailContent: widget.emailContent,
          senderName: widget.senderName,
        );
  }

  void _regenerate() {
    _generate();
  }

  void _useReply(BuildContext context, String content) {
    final subject = widget.originalSubject.isNotEmpty
        ? 'Re: ${widget.originalSubject}'
        : 'Re: ';
    context.push(
      '/compose?to=${Uri.encodeComponent(widget.recipientEmail)}'
      '&subject=${Uri.encodeComponent(subject)}'
      '&body=${Uri.encodeComponent(content)}',
    );
  }

  void _editReply(BuildContext context, String content) {
    _useReply(context, content);
  }
}
