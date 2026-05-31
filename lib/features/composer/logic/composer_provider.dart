import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:replai/data/repositories/email_repository.dart';
import 'package:replai/features/accounts/logic/account_provider.dart';

class ComposerState {
  final String to;
  final String cc;
  final String bcc;
  final String subject;
  final String body;
  final bool isSending;
  final bool isHtml;
  final String? error;
  final String? successMessage;

  const ComposerState({
    this.to = '',
    this.cc = '',
    this.bcc = '',
    this.subject = '',
    this.body = '',
    this.isSending = false,
    this.isHtml = false,
    this.error,
    this.successMessage,
  });

  ComposerState copyWith({
    String? to,
    String? cc,
    String? bcc,
    String? subject,
    String? body,
    bool? isSending,
    bool? isHtml,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ComposerState(
      to: to ?? this.to,
      cc: cc ?? this.cc,
      bcc: bcc ?? this.bcc,
      subject: subject ?? this.subject,
      body: body ?? this.body,
      isSending: isSending ?? this.isSending,
      isHtml: isHtml ?? this.isHtml,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  bool get canSend => to.isNotEmpty && body.isNotEmpty && !isSending;
}

final composerProvider =
    StateNotifierProvider.autoDispose<ComposerNotifier, ComposerState>((ref) {
  return ComposerNotifier(ref.read(emailRepositoryProvider));
});

class ComposerNotifier extends StateNotifier<ComposerState> {
  final EmailRepository _emailRepository;

  ComposerNotifier(this._emailRepository) : super(const ComposerState());

  void initialize({
    String to = '',
    String cc = '',
    String bcc = '',
    String subject = '',
    String body = '',
  }) {
    state = ComposerState(
      to: to,
      cc: cc,
      bcc: bcc,
      subject: subject,
      body: body,
    );
  }

  void setTo(String value) => state = state.copyWith(to: value);
  void setCc(String value) => state = state.copyWith(cc: value);
  void setBcc(String value) => state = state.copyWith(bcc: value);
  void setSubject(String value) => state = state.copyWith(subject: value);
  void setBody(String value) => state = state.copyWith(body: value);
  void toggleHtml() => state = state.copyWith(isHtml: !state.isHtml);
  void clearErrors() =>
      state = state.copyWith(clearError: true, clearSuccess: true);

  Future<bool> send() async {
    if (!state.canSend) return false;

    state =
        state.copyWith(isSending: true, clearError: true, clearSuccess: true);

    final result = await _emailRepository.sendEmail(
      to: state.to,
      cc: state.cc.isNotEmpty ? state.cc : null,
      bcc: state.bcc.isNotEmpty ? state.bcc : null,
      subject: state.subject,
      body: state.body,
      isHtml: state.isHtml,
    );

    if (result.success) {
      state = state.copyWith(
        isSending: false,
        successMessage: 'Email sent',
      );
    } else {
      state = state.copyWith(
        isSending: false,
        error: result.message,
      );
    }

    return result.success;
  }
}
