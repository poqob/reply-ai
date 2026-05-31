import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:replai/data/models/email_message.dart';
import 'package:replai/features/accounts/logic/account_provider.dart';
import 'package:replai/features/ai_reply/ui/reply_widget.dart';

class EmailDetailPage extends ConsumerStatefulWidget {
  final String accountId;
  final String messageId;

  const EmailDetailPage({
    super.key,
    required this.accountId,
    required this.messageId,
  });

  @override
  ConsumerState<EmailDetailPage> createState() => _EmailDetailPageState();
}

class _EmailDetailPageState extends ConsumerState<EmailDetailPage> {
  WebViewController? _webViewController;
  EmailMessage? _email;

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  Future<void> _loadEmail() async {
    final repo = ref.read(emailRepositoryProvider);
    final seqId = int.tryParse(widget.messageId) ?? 0;
    final email = await repo.fetchMessage(seqId);
    if (mounted) {
      setState(() => _email = email);
      if (email?.bodyHtml != null) {
        _loadHtmlContent(email!.bodyHtml!);
      }
    }
  }

  void _loadHtmlContent(String html) {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {},
        ),
      )
      ..loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    if (_email == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Email')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final email = _email!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(email.subject.isNotEmpty ? email.subject : '(No subject)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.reply),
            tooltip: 'Reply',
            onPressed: () => context.push(
              '/compose?reply=${Uri.encodeComponent(email.from)}'
              '&subject=${Uri.encodeComponent('Re: ${email.subject}')}',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    email.subject.isNotEmpty ? email.subject : '(No subject)',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: colorScheme.primaryContainer,
                        child: Text(
                          email.from.isNotEmpty
                              ? email.from[0].toUpperCase()
                              : '?',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              email.from,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _formatDateFull(email.date),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (email.to.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'To: ${email.to.join(", ")}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                  const Divider(height: 32),
                  if (_webViewController != null && email.bodyHtml != null)
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: WebViewWidget(controller: _webViewController!),
                    )
                  else
                    HtmlWidget(
                      email.bodyText.isNotEmpty
                          ? email.bodyText
                          : email.bodyHtml ?? '',
                      textStyle: Theme.of(context).textTheme.bodyLarge,
                    ),
                ],
              ),
            ),
          ),
          AiReplyWidget(
            emailContent: email.bodyText.isNotEmpty
                ? email.bodyText
                : email.bodyHtml ?? '',
            senderName: email.from,
            recipientEmail: email.from,
            originalSubject: email.subject,
            accountId: widget.accountId,
          ),
        ],
      ),
    );
  }

  String _formatDateFull(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
