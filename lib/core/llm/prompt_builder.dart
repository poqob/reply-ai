import 'package:replai/core/llm/prompt_manager.dart';
import 'package:replai/data/models/reply_settings.dart';

class PromptBuilder {
  PromptBuilder._();

  static String build({
    required String emailContent,
    required String senderName,
    required ReplySettings settings,
    String? additionalContext,
  }) {
    return PromptManager.buildReplyPrompt(
      emailContent: emailContent,
      senderName: senderName,
      settings: settings,
    );
  }

  static String cleanResponse(String response) {
    return PromptManager.clean(response);
  }
}
