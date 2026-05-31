import 'package:equatable/equatable.dart';

class EmailMessage extends Equatable {
  final String id;
  final String accountId;
  final String subject;
  final String from;
  final List<String> to;
  final List<String> cc;
  final DateTime date;
  final String bodyText;
  final String? bodyHtml;
  final bool isRead;
  final bool hasAttachments;
  final List<EmailAttachment> attachments;
  final int uid;

  const EmailMessage({
    required this.id,
    required this.accountId,
    this.subject = '',
    required this.from,
    this.to = const [],
    this.cc = const [],
    required this.date,
    this.bodyText = '',
    this.bodyHtml,
    this.isRead = false,
    this.hasAttachments = false,
    this.attachments = const [],
    this.uid = 0,
  });

  EmailMessage copyWith({
    String? id,
    String? accountId,
    String? subject,
    String? from,
    List<String>? to,
    List<String>? cc,
    DateTime? date,
    String? bodyText,
    String? bodyHtml,
    bool? isRead,
    bool? hasAttachments,
    List<EmailAttachment>? attachments,
    int? uid,
    bool clearHtml = false,
  }) {
    return EmailMessage(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      subject: subject ?? this.subject,
      from: from ?? this.from,
      to: to ?? this.to,
      cc: cc ?? this.cc,
      date: date ?? this.date,
      bodyText: bodyText ?? this.bodyText,
      bodyHtml: clearHtml ? null : (bodyHtml ?? this.bodyHtml),
      isRead: isRead ?? this.isRead,
      hasAttachments: hasAttachments ?? this.hasAttachments,
      attachments: attachments ?? this.attachments,
      uid: uid ?? this.uid,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'subject': subject,
      'from': from,
      'to': to,
      'cc': cc,
      'date': date.toIso8601String(),
      'bodyText': bodyText,
      'bodyHtml': bodyHtml,
      'isRead': isRead,
      'hasAttachments': hasAttachments,
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'uid': uid,
    };
  }

  factory EmailMessage.fromJson(Map<String, dynamic> json) {
    return EmailMessage(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      subject: json['subject'] as String? ?? '',
      from: json['from'] as String,
      to: (json['to'] as List<dynamic>?)?.cast<String>() ?? [],
      cc: (json['cc'] as List<dynamic>?)?.cast<String>() ?? [],
      date: DateTime.parse(json['date'] as String),
      bodyText: json['bodyText'] as String? ?? '',
      bodyHtml: json['bodyHtml'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      hasAttachments: json['hasAttachments'] as bool? ?? false,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => EmailAttachment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      uid: json['uid'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, accountId, subject, from, date, uid];
}

class EmailAttachment extends Equatable {
  final String id;
  final String fileName;
  final int size;
  final String? mimeType;

  const EmailAttachment({
    required this.id,
    required this.fileName,
    this.size = 0,
    this.mimeType,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'size': size,
      'mimeType': mimeType,
    };
  }

  factory EmailAttachment.fromJson(Map<String, dynamic> json) {
    return EmailAttachment(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      size: json['size'] as int? ?? 0,
      mimeType: json['mimeType'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, fileName, size, mimeType];
}
