import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:replai/data/models/mail_account.dart';

class SmtpResult {
  final bool success;
  final String message;

  const SmtpResult({required this.success, this.message = ''});
}

class SmtpService {
  Future<SmtpResult> sendEmail({
    required MailAccount account,
    required String password,
    required String to,
    String? cc,
    String? bcc,
    required String subject,
    required String body,
    bool isHtml = false,
  }) async {
    try {
      final smtpServer = account.smtpSsl
          ? SmtpServer(
              account.smtpHost,
              port: account.smtpPort,
              username: account.username,
              password: password,
              ssl: true,
            )
          : SmtpServer(
              account.smtpHost,
              port: account.smtpPort,
              username: account.username,
              password: password,
              ssl: false,
              allowInsecure: true,
            );

      final message = Message()
        ..from = Address(account.email, account.name)
        ..recipients.add(to)
        ..subject = subject;

      if (cc != null && cc.isNotEmpty) {
        message.recipients.add(cc);
      }
      if (bcc != null && bcc.isNotEmpty) {
        message.recipients.add(bcc);
      }

      if (isHtml) {
        message.html = body;
      } else {
        message.text = body;
      }

      final response = await send(message, smtpServer);

      debugPrint('SMTP send result: ${response.toString()}');

      return SmtpResult(
        success: true,
        message: 'Email sent to $to',
      );
    } catch (e) {
      debugPrint('SMTP send error: $e');
      return SmtpResult(
        success: false,
        message: e.toString(),
      );
    }
  }
}
