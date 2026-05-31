import 'package:flutter/foundation.dart';
import 'package:enough_mail/enough_mail.dart' as em;
import 'package:replai/data/models/email_message.dart';
import 'package:replai/data/models/mail_account.dart';

class ImapService {
  em.ImapClient? _client;

  Future<void> connect(MailAccount account, String password) async {
    _client = em.ImapClient(isLogEnabled: false);

    if (account.imapSsl) {
      await _client!.connectToServer(account.imapHost, account.imapPort,
          isSecure: true);
    } else {
      await _client!.connectToServer(account.imapHost, account.imapPort,
          isSecure: false);
    }

    await _client!.login(account.username, password);
    await _client!.selectInbox();
    debugPrint('IMAP connected to ${account.imapHost}');
  }

  Future<List<EmailMessage>> fetchInboxHeaders({
    int limit = 50,
  }) async {
    if (_client == null) throw Exception('Not connected');

    try {
      final mailbox = await _client!.selectInbox();
      final totalMessages = mailbox.messagesExists;
      if (totalMessages == 0) return [];

      final startSeq = (totalMessages - limit + 1).clamp(1, totalMessages);
      final endSeq = totalMessages;

      if (startSeq > endSeq || endSeq < 1) return [];

      final sequence = em.MessageSequence.fromRange(startSeq, endSeq);
      final fetchResult = await _client!.fetchMessages(sequence, 'ENVELOPE');

      return fetchResult.messages.reversed.map((msg) {
        final envelope = msg.envelope;
        final fromAddr = envelope?.from?.isNotEmpty == true
            ? envelope!.from!.first
            : null;
        final fromStr = fromAddr?.email ?? 'Unknown';
        final toAddrList = envelope?.to;
        final toList = toAddrList
                ?.map((a) => a.email)
                .where((e) => e.isNotEmpty)
                .toList() ??
            [];
        final ccAddrList = envelope?.cc;
        final ccList = ccAddrList
                ?.map((a) => a.email)
                .where((e) => e.isNotEmpty)
                .toList() ??
            [];
        return EmailMessage(
          id: msg.sequenceId?.toString() ?? '',
          accountId: '',
          subject: envelope?.subject ?? '(No subject)',
          from: fromStr,
          to: toList,
          cc: ccList,
          date: envelope?.date ?? DateTime.now(),
          bodyText: '',
          isRead: msg.isSeen,
          hasAttachments: msg.hasAttachments(),
          uid: msg.uid ?? 0,
        );
      }).toList();
    } catch (e) {
      debugPrint('IMAP fetch error: $e');
      rethrow;
    }
  }

  Future<EmailMessage?> fetchMessageBody({
    required int sequenceId,
    required String accountId,
  }) async {
    if (_client == null) return null;

    try {
      final sequence = em.MessageSequence.fromId(sequenceId);
      final result = await _client!.fetchMessages(
        sequence,
        '(ENVELOPE BODY[])',
      );

      if (result.messages.isEmpty) return null;

      final msg = result.messages.first;

      final htmlBody = msg.decodeTextHtmlPart();
      final plainBody = msg.decodeTextPlainPart();
      final bodyText = plainBody ?? msg.decodeContentText() ?? '';

      final envelope = msg.envelope;
      final fromAddr = envelope?.from?.isNotEmpty == true
          ? envelope!.from!.first
          : null;
      final fromStr = fromAddr?.email ?? 'Unknown';

      return EmailMessage(
        id: msg.sequenceId?.toString() ?? '',
        accountId: accountId,
        subject: envelope?.subject ?? '(No subject)',
        from: fromStr,
        date: envelope?.date ?? msg.decodeDate() ?? DateTime.now(),
        bodyText: bodyText,
        bodyHtml: htmlBody,
        isRead: msg.isSeen,
        hasAttachments: msg.hasAttachments(),
        uid: msg.uid ?? 0,
      );
    } catch (e) {
      debugPrint('IMAP fetch message body error: $e');
      return null;
    }
  }

  Future<void> disconnect() async {
    if (_client != null) {
      try {
        await _client!.logout();
      } catch (_) {}
      _client = null;
    }
  }
}
