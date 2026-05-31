import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:replai/core/llm/llm_service.dart';
import 'package:replai/core/llm/prompt_builder.dart';
import 'package:replai/data/repositories/settings_repository.dart';
import 'package:replai/features/settings/logic/settings_provider.dart';

enum ReplyState { idle, generating, done, error }

class ReplyData {
  final ReplyState state;
  final String content;
  final String? error;

  const ReplyData({
    this.state = ReplyState.idle,
    this.content = '',
    this.error,
  });

  ReplyData copyWith({
    ReplyState? state,
    String? content,
    String? error,
    bool clearError = false,
  }) {
    return ReplyData(
      state: state ?? this.state,
      content: content ?? this.content,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final replyStateProvider =
    StateNotifierProvider.autoDispose<ReplyStateNotifier, ReplyData>((ref) {
  final llmService = ref.watch(llmServiceProvider);
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  return ReplyStateNotifier(llmService, settingsRepo);
});

class ReplyStateNotifier extends StateNotifier<ReplyData> {
  final LlmService _llmService;
  final SettingsRepository _settingsRepo;
  StreamSubscription<String>? _subscription;

  ReplyStateNotifier(this._llmService, this._settingsRepo)
      : super(const ReplyData());

  Future<void> generateReply({
    required String emailContent,
    required String senderName,
  }) async {
    _subscription?.cancel();
    state = const ReplyData(state: ReplyState.generating);

    try {
      final settings = await _settingsRepo.loadSettings();

      final stream = _llmService.generateReplyStream(
        emailContent: emailContent,
        senderName: senderName,
        settings: settings,
      );

      final buffer = StringBuffer();

      _subscription = stream.listen(
        (token) {
          buffer.write(token);
          state = ReplyData(state: ReplyState.generating, content: buffer.toString());
        },
        onError: (e) {
          state = ReplyData(
            state: ReplyState.error,
            error: e.toString(),
            content: buffer.toString(),
          );
        },
        onDone: () {
          final cleaned = PromptBuilder.cleanResponse(buffer.toString());
          state = ReplyData(state: ReplyState.done, content: cleaned);
        },
        cancelOnError: false,
      );
    } catch (e) {
      state = ReplyData(
        state: ReplyState.error,
        error: e.toString(),
      );
    }
  }

  void reset() {
    _subscription?.cancel();
    state = const ReplyData();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
