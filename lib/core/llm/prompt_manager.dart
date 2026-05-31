import 'package:replai/core/llm/prompt_templates.dart';
import 'package:replai/data/models/reply_settings.dart';

class PromptManager {
  PromptManager._();

  static String buildReplyPrompt({
    required String emailContent,
    required String senderName,
    required ReplySettings settings,
  }) {
    final persona = settings.selectedPersona;
    final tone =
        PromptTemplates.toneInstructions[settings.tone] ??
        PromptTemplates.toneInstructions['professional']!;
    final lang =
        PromptTemplates.languageInstructions[settings.language] ??
        PromptTemplates.languageInstructions['en']!;

    String personaBlock = '';
    if (persona != null && persona.name.isNotEmpty) {
      final style =
          persona.toneHint.isNotEmpty ? ' ${persona.toneHint}' : '';
      personaBlock = ' You are ${persona.name}.$style';
    }

    String signatureBlock = '';
    if (persona != null && persona.signature.isNotEmpty) {
      signatureBlock = ' Sign: ${persona.signature}';
    }

    return PromptTemplates.replyTemplate
        .replaceAll('{sender_name}', senderName)
        .replaceAll('{tone_instruction}', tone)
        .replaceAll('{language_instruction}', lang)
        .replaceAll('{persona_block}', personaBlock)
        .replaceAll('{signature_block}', signatureBlock)
        .replaceAll('{email_content}', emailContent);
  }

  static String buildSubjectPrompt({
    required String bodyContent,
  }) {
    return PromptTemplates.subjectTemplate.replaceAll(
      '{body_content}',
      bodyContent,
    );
  }

  static String buildTransformPrompt({
    required String originalText,
    required String action,
  }) {
    final instruction = PromptTemplates.transformInstructions[action] ??
        PromptTemplates.transformInstructions['fix']!;
    return PromptTemplates.transformTemplate
        .replaceAll('{transform_instruction}', instruction)
        .replaceAll('{original_text}', originalText);
  }

  static String clean(String raw) {
    var text = raw.trim();
    text = text.replaceAll('"""', '');

    final lines = text.split('\n');
    final filtered = <String>[];

    for (final line in lines) {
      final trimmed = line.trim();

      if (trimmed.isEmpty) {
        filtered.add(line);
        continue;
      }

      if (_isDegenerate(trimmed)) break;
      if (_isMetaLine(trimmed)) continue;
      if (_isEchoedPromptLine(trimmed)) break;

      filtered.add(line);
    }

    text = filtered.join('\n').trim();
    text = text.replaceAll(RegExp(r'<[^>]+>'), '');
    text = text.replaceAll(RegExp(r'^[-–—]{2,}\s*', multiLine: true), '');

    if (text.startsWith('"') && text.endsWith('"')) {
      text = text.substring(1, text.length - 1);
    }

    return text.trim();
  }

  static String cleanSubject(String raw) {
    var text = raw.trim();
    text = text.replaceAll('"', '');
    text = text.replaceAll(
      RegExp(r'^Subject:\s*', caseSensitive: false),
      '',
    );
    text = text.replaceAll(RegExp(r'^Re:\s*', caseSensitive: false), '');
    text = text.replaceAll('\n', ' ');
    return text.trim();
  }

  static bool _isDegenerate(String line) {
    final upperCount = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        .split('')
        .where((c) => line.contains(c))
        .length;
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
    for (final frag in PromptTemplates.echoFragments) {
      if (lower.startsWith(frag)) return true;
    }
    return false;
  }

  static bool _isMetaLine(String line) {
    final lower = line.toLowerCase();

    if (PromptTemplates.headerLinePattern.hasMatch(line)) return true;
    if (PromptTemplates.placeholderNamePattern.hasMatch(line)) return true;
    if (PromptTemplates.placeholderEmailPattern.hasMatch(line)) return true;

    for (final pattern in PromptTemplates.metaLinePatterns) {
      if (lower.startsWith(pattern)) return true;
    }

    return false;
  }
}
