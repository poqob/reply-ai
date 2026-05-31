import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:replai/data/models/reply_settings.dart';

class SettingsStorage {
  static const _key = 'reply_settings';
  final FlutterSecureStorage _secureStorage;

  SettingsStorage({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  Future<ReplySettings> loadSettings() async {
    final json = await _secureStorage.read(key: _key);
    if (json == null) return const ReplySettings();

    return ReplySettings.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<void> saveSettings(ReplySettings settings) async {
    final json = jsonEncode(settings.toJson());
    await _secureStorage.write(key: _key, value: json);
  }
}
