import 'package:replai/data/models/reply_settings.dart';

class PromptBuilder {
  PromptBuilder._();

  static final Map<String, String> _toneInstructions = {
    'casual':
        'Write in a casual, relaxed, conversational tone.',
    'professional':
        'Write in a professional, business-appropriate tone.',
    'formal':
        'Write in a formal, respectful tone. Do NOT add "Dear", "Kind regards" or similar.',
    'friendly':
        'Write in a warm, friendly, approachable tone.',
  };

  static final Map<String, String> languageInstructions = {
    'en': 'CRITICAL: Reply ONLY in English, regardless of the email language.',
    'tr': 'KRITIK: SADECE Turkce yanit ver, email baska dilde olsa bile.',
    'de': 'KRITISCH: Nur auf Deutsch antworten, unabhangig von der E-Mail-Sprache.',
  };

  static String build({
    required String emailContent,
    required String senderName,
    required ReplySettings settings,
    String? additionalContext,
  }) {
    final buffer = StringBuffer();
    final persona = settings.selectedPersona;

    buffer.write('Write a brief (1-2 sentences) reply to this email from $senderName. '
        '${_toneInstructions[settings.tone] ?? _toneInstructions['professional']!} '
        '${languageInstructions[settings.language] ?? languageInstructions['en']!} '
        'Rules: only the reply text, no headers, no signatures, no commentary, no quotes, no markdown.');

    if (persona != null && persona.name.isNotEmpty) {
      buffer.write(' You are ${persona.name}.');
      if (persona.toneHint.isNotEmpty) {
        buffer.write(' ${persona.toneHint}');
      }
    }

    if (persona != null && persona.signature.isNotEmpty) {
      buffer.write(' Sign: ${persona.signature}');
    }

    buffer.writeln();
    buffer.writeln();
    buffer.writeln('Email:');
    buffer.writeln(emailContent);
    buffer.writeln();
    buffer.writeln('Reply:');

    return buffer.toString();
  }

  static String cleanResponse(String response) {
    var text = response.trim();

    text = text.replaceAll('"""', '');

    final lines = text.split('\n');
    final filtered = <String>[];

    for (int i = 0; i < lines.length; i++) {
      final trimmed = lines[i].trim();

      if (trimmed.isEmpty) {
        filtered.add(lines[i]);
        continue;
      }

      if (_isDegenerate(trimmed)) break;
      if (_isMetaLine(trimmed)) continue;
      if (_isEchoedPromptLine(trimmed)) break;

      filtered.add(lines[i]);
    }

    text = filtered.join('\n').trim();

    text = text.replaceAll(RegExp(r'<[^>]+>'), '');
    text = text.replaceAll(RegExp(r'^[-–—]{2,}\s*', multiLine: true), '');

    if (text.startsWith('"') && text.endsWith('"')) {
      text = text.substring(1, text.length - 1);
    }

    return text.trim();
  }

  static bool _isDegenerate(String line) {
    final upperCount = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('').where((c) => line.contains(c)).length;
    if (upperCount >= 10 && line.length < 50) return true;

    final words = line.split(RegExp(r'\s+'));
    if (words.isEmpty) return false;
    final upperWords = words.where((w) {
      if (w.length < 3) return false;
      return w == w.toUpperCase() && w.contains(RegExp(r'[A-Z]'));
    }).length;
    if (upperWords >= 3 && upperWords == words.length) return true;

    if (line.startsWith(RegExp(r'^[A-Z\s]{10,}$'))) return true;

    return false;
  }

  static bool _isEchoedPromptLine(String line) {
    final lower = line.toLowerCase();
    const echoedFragments = [
      'you are an email',
      'output only the raw',
      'do not add commentary',
      '=== critical',
      '=== tone ===',
      '=== strict format',
      '=== signature ===',
      '=== language rule',
      'rules: only the reply',
      'critical language rule',
      'write a brief',
      'email reply generator',
    ];
    for (final frag in echoedFragments) {
      if (lower.startsWith(frag)) return true;
    }
    return false;
  }

  static bool _isMetaLine(String line) {
    final lower = line.toLowerCase();

    if (RegExp(r'^(to|from|cc|bcc|subject|re|fwd?)\s*:', caseSensitive: false).hasMatch(line)) {
      return true;
    }

    if (RegExp(r'^\[?your\s*(full\s*)?name\]?$', caseSensitive: false).hasMatch(line)) {
      return true;
    }

    if (RegExp(r'^\[?your\s*email\s*(address)?\]?$', caseSensitive: false).hasMatch(line)) {
      return true;
    }

    const patterns = [
      'the response is',
      'here is',
      'here\'s',
      'certainly',
      'sure!',
      'of course',
      'i hope this',
      'this maintains',
      'this acknowledges',
      'the reply is',
      'end of',
      '---end',
      'reply:',
      'what do you',
      'beste grusse',
      'mit freundlichen',
      'kind regards',
    ];

    for (final pattern in patterns) {
      if (lower.startsWith(pattern)) return true;
    }

    return false;
  }
}
