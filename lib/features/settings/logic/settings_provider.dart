import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:replai/core/llm/llm_service.dart';
import 'package:replai/data/models/persona.dart';
import 'package:replai/data/models/reply_settings.dart';
import 'package:replai/data/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final replySettingsProvider =
    AsyncNotifierProvider<ReplySettingsNotifier, ReplySettings>(
  ReplySettingsNotifier.new,
);

class ReplySettingsNotifier extends AsyncNotifier<ReplySettings> {
  @override
  Future<ReplySettings> build() async {
    final repo = ref.read(settingsRepositoryProvider);
    return repo.loadSettings();
  }

  Future<void> updateTone(String tone) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.updateTone(tone);
    state = AsyncData(state.value!.copyWith(tone: tone));
  }

  Future<void> updateLanguage(String language) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.updateLanguage(language);
    state = AsyncData(state.value!.copyWith(language: language));
  }

  Future<void> updatePersonaId(String? personaId) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.updatePersonaId(personaId);
    state = AsyncData(state.value!.copyWith(
      personaId: personaId,
      clearPersonaId: personaId == null,
    ));
  }

  Future<void> updateTemperature(double temperature) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.updateTemperature(temperature);
    state = AsyncData(state.value!.copyWith(temperature: temperature));
  }

  Future<void> updateMaxTokens(int maxTokens) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.updateMaxTokens(maxTokens);
    state = AsyncData(state.value!.copyWith(maxTokens: maxTokens));
  }

  Future<void> addPersona(Persona persona) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.addPersona(persona);
    final current = state.value!;
    state = AsyncData(current.copyWith(personas: [...current.personas, persona]));
  }

  Future<void> updatePersona(Persona persona) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.updatePersona(persona);
    final current = state.value!;
    state = AsyncData(current.copyWith(
      personas: current.personas.map((p) => p.id == persona.id ? persona : p).toList(),
    ));
  }

  Future<void> deletePersona(String personaId) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.deletePersona(personaId);
    final current = state.value!;
    state = AsyncData(current.copyWith(
      personas: current.personas.where((p) => p.id != personaId).toList(),
      personaId: current.personaId == personaId ? null : current.personaId,
      clearPersonaId: current.personaId == personaId,
    ));
  }
}

final llmModelStateProvider = StateNotifierProvider<LlmModelStateNotifier, LlmModelState>((ref) {
  return LlmModelStateNotifier(ref.read(llmServiceProvider));
});

final llmServiceProvider = Provider<LlmService>((ref) {
  return LlmService();
});

class LlmModelState {
  final bool isLoaded;
  final bool isLoading;
  final String? modelName;
  final String? error;

  const LlmModelState({
    this.isLoaded = false,
    this.isLoading = false,
    this.modelName,
    this.error,
  });

  LlmModelState copyWith({
    bool? isLoaded,
    bool? isLoading,
    String? modelName,
    String? error,
    bool clearError = false,
  }) {
    return LlmModelState(
      isLoaded: isLoaded ?? this.isLoaded,
      isLoading: isLoading ?? this.isLoading,
      modelName: modelName ?? this.modelName,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class LlmModelStateNotifier extends StateNotifier<LlmModelState> {
  final LlmService _llmService;

  LlmModelStateNotifier(this._llmService) : super(const LlmModelState()) {
    _init();
  }

  Future<void> _init() async {
    final hasModel = await _llmService.hasModel();
    final modelName = _llmService.getModelName();
    state = state.copyWith(isLoaded: hasModel, modelName: modelName);
    if (hasModel && _llmService.currentModelPath != null) {
      await loadModel(_llmService.currentModelPath!);
    }
  }

  Future<void> loadModel(String modelPath) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _llmService.loadModel(modelPath);
      state = state.copyWith(
        isLoaded: true,
        isLoading: false,
        modelName: _llmService.getModelName(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoaded: false,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> checkModel() async {
    final hasModel = await _llmService.hasModel();
    state = state.copyWith(isLoaded: hasModel, modelName: _llmService.getModelName());
  }
}
