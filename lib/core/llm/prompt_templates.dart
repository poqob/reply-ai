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
      '{transform_instruction}'
      '\n\n'
      '{original_text}';

  static const Map<String, String> transformInstructions = {
    'complete':
        'Complete any unfinished sentences. '
        'Keep the existing text, only add what is missing:',
    'casual':
        'Rewrite casually and conversationally:',
    'professional':
        'Rewrite in a professional business tone. '
        'No signatures, no greetings, no closings:',
    'formal':
        'Rewrite in a formal respectful tone. '
        'No signatures, no greetings, no closings:',
    'friendly':
        'Rewrite in a warm friendly tone:',
    'translate_en':
        'Translate to English:',
    'translate_tr':
        'Translate to Turkish:',
    'translate_de':
        'Translate to German:',
    'fix':
        'Fix grammar, spelling, and punctuation. '
        'Do not change the meaning:',
    'shorter':
        'Make more concise. Keep the core message:',
    'longer':
        'Expand with more detail. Keep the tone:',
    'emojify':
        'Add relevant emojis. Keep the original message:',
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
    'transformed text',
    'rewrite the following',
    'rewrite in a',
    'translate to',
    'translate the following',
    'complete any',
    'make the following',
    'fix grammar',
    'the following text',
    'original:',
    'transformed:',
    'text:',
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
