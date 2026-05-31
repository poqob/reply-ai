class PromptTemplates {
  PromptTemplates._();

  static const Map<String, String> toneInstructions = {
    'casual': 'Write in a casual, relaxed, conversational tone.',
    'professional': 'Write in a professional, business-appropriate tone.',
    'formal':
        'Write in a formal, respectful tone. Do NOT add "Dear", "Kind regards" or similar.',
    'friendly': 'Write in a warm, friendly, approachable tone.',
  };

  static const Map<String, String> languageInstructions = {
    'en':
        'CRITICAL: Reply ONLY in English, regardless of the email language.',
    'tr':
        'KRITIK: SADECE Turkce yanit ver, email baska dilde olsa bile.',
    'de':
        'KRITISCH: Nur auf Deutsch antworten, unabhangig von der E-Mail-Sprache.',
  };

  static const String replyTemplate =
      'Write a brief (1-2 sentences) reply to this email from {sender_name}. '
      '{tone_instruction} {language_instruction} '
      'Rules: only the reply text, no headers, no signatures, '
      'no commentary, no quotes, no markdown.'
      '{persona_block}'
      '{signature_block}'
      '\n\n'
      'Email:\n'
      '{email_content}\n'
      '\n'
      'Reply:';

  static const String personaBlock =
      ' You are {persona_name}.{persona_style}';

  static const String signatureBlock = ' Sign: {signature}';

  static const String subjectTemplate =
      'Generate a VERY SHORT email subject (3-8 words) for this email body. '
      'Write the subject in the SAME language as the body text below. '
      'Output ONLY the subject, no quotes, no "Subject:" prefix, no extra text.'
      '\n\n'
      'Body:\n'
      '{body_content}\n'
      '\n'
      'Subject:';

  static const Map<String, String> transformActions = {
    'complete': 'Complete',
    'casual': 'Make casual',
    'professional': 'Make professional',
    'formal': 'Make formal',
    'friendly': 'Make friendly',
    'translate_en': 'Translate to English',
    'translate_tr': 'Translate to Turkish',
    'translate_de': 'Translate to German',
    'fix': 'Fix grammar',
    'shorter': 'Make shorter',
    'longer': 'Make longer',
    'emojify': 'Add emojis',
  };

  static const String transformTemplate =
      'Transform the following email text. {transform_instruction} '
      'Output ONLY the transformed text, nothing else.\n\n'
      'Original:\n'
      '{original_text}\n\n'
      'Transformed:';

  static const Map<String, String> transformInstructions = {
    'complete':
        'Complete any unfinished sentences naturally while preserving the existing text and tone.',
    'casual':
        'Rewrite in a casual, relaxed, conversational tone. Use everyday language.',
    'professional':
        'Rewrite in a professional, business-appropriate tone. Be clear and solution-oriented.',
    'formal':
        'Rewrite in a formal, respectful tone. Do NOT add "Dear" or "Kind regards".',
    'friendly':
        'Rewrite in a warm, friendly, approachable tone. Be personable.',
    'translate_en':
        'CRITICAL: Translate the text to English. Output ONLY English.',
    'translate_tr':
        'KRITIK: Metni Turkceye cevir. SADECE Turkce cikti ver.',
    'translate_de':
        'KRITISCH: Ubersetzen Sie den Text ins Deutsche. Nur Deutsch ausgeben.',
    'fix':
        'Fix grammar, spelling, and punctuation. Improve clarity without changing the meaning.',
    'shorter':
        'Make the text more concise. Remove unnecessary words. Keep the core message.',
    'longer':
        'Expand the text with more detail and elaboration. Maintain the original tone.',
    'emojify':
        'Add relevant emojis to the text while keeping the original message and tone.',
  };

  static const List<String> echoFragments = [
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

  static const List<String> metaLinePatterns = [
    'the response is',
    'here is',
    "here's",
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

  static final RegExp headerLinePattern = RegExp(
    r'^(to|from|cc|bcc|subject|re|fwd?)\s*:',
    caseSensitive: false,
  );

  static final RegExp placeholderNamePattern = RegExp(
    r'^\[?your\s*(full\s*)?name\]?$',
    caseSensitive: false,
  );

  static final RegExp placeholderEmailPattern = RegExp(
    r'^\[?your\s*email\s*(address)?\]?$',
    caseSensitive: false,
  );
}
