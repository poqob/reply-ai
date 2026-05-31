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
      '{transform_instruction}\n\n'
      'Text:\n'
      '{original_text}\n\n'
      'Transformed text (only the result):';

  static const Map<String, String> transformInstructions = {
    'complete':
        'Complete any unfinished sentences in the following text. '
        'Keep the existing text unchanged, only add what is missing. '
        'Output the completed text directly.',
    'casual':
        'Rewrite the following text in a casual, relaxed, conversational tone. '
        'Use everyday language. Output only the rewritten text.',
    'professional':
        'Rewrite the following text in a professional tone. '
        'Make it clear, polite, and business-appropriate. '
        'Output only the rewritten text. Do NOT add signatures, greetings, or closings.',
    'formal':
        'Rewrite the following text in a formal, respectful tone. '
        'Output only the rewritten text. Do NOT add signatures, greetings, or closings.',
    'friendly':
        'Rewrite the following text in a warm, friendly, approachable tone. '
        'Output only the rewritten text.',
    'translate_en':
        'Translate the following text to English. Output only the translation.',
    'translate_tr':
        'Translate the following text to Turkish. Output only the translation.',
    'translate_de':
        'Translate the following text to German. Output only the translation.',
    'fix':
        'Fix grammar, spelling, and punctuation in the following text. '
        'Improve clarity without changing the meaning. Output only the corrected text.',
    'shorter':
        'Make the following text more concise. Remove unnecessary words. '
        'Keep the core message. Output only the shortened text.',
    'longer':
        'Expand the following text with more detail while maintaining its tone. '
        'Output only the expanded text.',
    'emojify':
        'Add relevant emojis to the following text. Keep the original message. '
        'Output only the text with emojis added.',
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
