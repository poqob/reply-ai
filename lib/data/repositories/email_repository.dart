import 'package:replai/data/datasources/local/account_storage.dart';
import 'package:replai/data/datasources/remote/imap_service.dart';
import 'package:replai/data/datasources/remote/smtp_service.dart';
import 'package:replai/data/models/email_message.dart';
import 'package:replai/data/models/mail_account.dart';

class EmailRepository {
  final AccountStorage _accountStorage;
  final ImapService _imapService;
  final SmtpService _smtpService;
  MailAccount? _currentAccount;
  String? _currentPassword;

  EmailRepository({
    AccountStorage? accountStorage,
    ImapService? imapService,
    SmtpService? smtpService,
  })  : _accountStorage = accountStorage ?? AccountStorage(),
        _imapService = imapService ?? ImapService(),
        _smtpService = smtpService ?? SmtpService();

  Future<List<MailAccount>> loadAccounts() async {
    return _accountStorage.loadAccounts();
  }

  Future<void> saveAccounts(List<MailAccount> accounts) async {
    await _accountStorage.saveAccounts(accounts);
  }

  Future<void> savePassword(String accountId, String password) async {
    await _accountStorage.savePassword(accountId, password);
    if (_currentAccount?.id == accountId) {
      _currentPassword = password;
    }
  }

  Future<String?> getPassword(String accountId) async {
    return _accountStorage.getPassword(accountId);
  }

  Future<void> deleteAccount(MailAccount account) async {
    final accounts = await loadAccounts();
    accounts.removeWhere((a) => a.id == account.id);
    await saveAccounts(accounts);
    await _accountStorage.deletePassword(account.id);
  }

  Future<void> connectToImap(MailAccount account, String password) async {
    await _imapService.connect(account, password);
    _currentAccount = account;
    _currentPassword = password;
  }

  Future<void> disconnectFromImap() async {
    await _imapService.disconnect();
    _currentAccount = null;
    _currentPassword = null;
  }

  Future<List<EmailMessage>> fetchInbox({int limit = 50}) async {
    return _imapService.fetchInboxHeaders(limit: limit);
  }

  Future<EmailMessage?> fetchMessage(int sequenceId) async {
    return _imapService.fetchMessageBody(
      sequenceId: sequenceId,
      accountId: _currentAccount?.id ?? '',
    );
  }

  Future<SmtpResult> sendEmail({
    required String to,
    String? cc,
    String? bcc,
    required String subject,
    required String body,
    bool isHtml = false,
  }) async {
    if (_currentAccount == null || _currentPassword == null) {
      return const SmtpResult(success: false, message: 'Not connected');
    }

    return _smtpService.sendEmail(
      account: _currentAccount!,
      password: _currentPassword!,
      to: to,
      cc: cc,
      bcc: bcc,
      subject: subject,
      body: body,
      isHtml: isHtml,
    );
  }

  MailAccount? get currentAccount => _currentAccount;
}
