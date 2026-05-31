import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:replai/data/models/mail_account.dart';

class AccountStorage {
  static const _key = 'saved_accounts';
  final FlutterSecureStorage _secureStorage;

  AccountStorage({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  Future<List<MailAccount>> loadAccounts() async {
    final json = await _secureStorage.read(key: _key);
    if (json == null) return [];

    final list = jsonDecode(json) as List<dynamic>;
    return list.map((e) => MailAccount.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveAccounts(List<MailAccount> accounts) async {
    final json = jsonEncode(accounts.map((a) => a.toJson()).toList());
    await _secureStorage.write(key: _key, value: json);
  }

  Future<void> savePassword(String accountId, String password) async {
    await _secureStorage.write(key: 'pass_$accountId', value: password);
  }

  Future<String?> getPassword(String accountId) async {
    return _secureStorage.read(key: 'pass_$accountId');
  }

  Future<void> deletePassword(String accountId) async {
    await _secureStorage.delete(key: 'pass_$accountId');
  }
}
