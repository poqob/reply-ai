import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class MailAccount extends Equatable {
  final String id;
  final String name;
  final String email;
  final String imapHost;
  final int imapPort;
  final bool imapSsl;
  final String smtpHost;
  final int smtpPort;
  final bool smtpSsl;
  final String username;
  final bool isDefault;

  const MailAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.imapHost,
    this.imapPort = 993,
    this.imapSsl = true,
    required this.smtpHost,
    this.smtpPort = 465,
    this.smtpSsl = true,
    required this.username,
    this.isDefault = false,
  });

  factory MailAccount.create({
    required String name,
    required String email,
    required String imapHost,
    int imapPort = 993,
    bool imapSsl = true,
    required String smtpHost,
    int smtpPort = 465,
    bool smtpSsl = true,
    required String username,
    bool isDefault = false,
  }) {
    return MailAccount(
      id: const Uuid().v4(),
      name: name,
      email: email,
      imapHost: imapHost,
      imapPort: imapPort,
      imapSsl: imapSsl,
      smtpHost: smtpHost,
      smtpPort: smtpPort,
      smtpSsl: smtpSsl,
      username: username,
      isDefault: isDefault,
    );
  }

  MailAccount copyWith({
    String? id,
    String? name,
    String? email,
    String? imapHost,
    int? imapPort,
    bool? imapSsl,
    String? smtpHost,
    int? smtpPort,
    bool? smtpSsl,
    String? username,
    bool? isDefault,
  }) {
    return MailAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      imapHost: imapHost ?? this.imapHost,
      imapPort: imapPort ?? this.imapPort,
      imapSsl: imapSsl ?? this.imapSsl,
      smtpHost: smtpHost ?? this.smtpHost,
      smtpPort: smtpPort ?? this.smtpPort,
      smtpSsl: smtpSsl ?? this.smtpSsl,
      username: username ?? this.username,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'imapHost': imapHost,
      'imapPort': imapPort,
      'imapSsl': imapSsl,
      'smtpHost': smtpHost,
      'smtpPort': smtpPort,
      'smtpSsl': smtpSsl,
      'username': username,
      'isDefault': isDefault,
    };
  }

  factory MailAccount.fromJson(Map<String, dynamic> json) {
    return MailAccount(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      imapHost: json['imapHost'] as String,
      imapPort: json['imapPort'] as int? ?? 993,
      imapSsl: json['imapSsl'] as bool? ?? true,
      smtpHost: json['smtpHost'] as String,
      smtpPort: json['smtpPort'] as int? ?? 465,
      smtpSsl: json['smtpSsl'] as bool? ?? true,
      username: json['username'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        imapHost,
        imapPort,
        imapSsl,
        smtpHost,
        smtpPort,
        smtpSsl,
        username,
        isDefault,
      ];
}
