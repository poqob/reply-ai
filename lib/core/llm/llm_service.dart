import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:llama_flutter_android/llama_flutter_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:replai/core/llm/prompt_builder.dart';
import 'package:replai/data/models/reply_settings.dart';

class LlmService {
  static final LlmService _instance = LlmService._internal();
  factory LlmService() => _instance;
  LlmService._internal();

  static const _prefKey = 'last_model_path';

  LlamaController? _controller;
  bool _isInitialized = false;
  String? _modelPath;

  bool get isInitialized => _isInitialized;
  String? get currentModelPath => _modelPath;

  Future<String?> _getSavedModelPath() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_prefKey);
    if (path != null && File(path).existsSync()) {
      return path;
    }
    return null;
  }

  Future<void> _saveModelPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, path);
  }

  Future<bool> hasModel() async {
    if (_modelPath != null && File(_modelPath!).existsSync()) {
      return true;
    }

    final saved = await _getSavedModelPath();
    if (saved != null) {
      _modelPath = saved;
      return true;
    }

    _modelPath = null;
    return false;
  }

  Future<void> loadModel(String modelPath) async {
    final file = File(modelPath);
    if (!await file.exists()) {
      throw Exception('Model file not found: $modelPath');
    }

    final sizeMB = (await file.length()) / (1024 * 1024);
    debugPrint('Model file size: ${sizeMB.toStringAsFixed(1)} MB');

    if (sizeMB > 8000) {
      throw Exception(
        'Model is too large (${sizeMB.toStringAsFixed(0)} MB) for mobile. '
        'Use a quantized version (Q4_K_M, Q5_K_M) instead of bf16/f16.',
      );
    }

    await _controller?.dispose();
    _isInitialized = false;

    _controller = LlamaController();

    final gpu = await _controller!.detectGpu();
    final gpuLayers = gpu.vulkanSupported ? gpu.recommendedGpuLayers : null;
    debugPrint('GPU Vulkan: ${gpu.vulkanSupported}');
    debugPrint('GPU layers: $gpuLayers');

    await _controller!.loadModel(
      modelPath: modelPath,
      contextSize: 2048,
      threads: 4,
      gpuLayers: gpuLayers,
    );

    _modelPath = modelPath;
    _isInitialized = true;
    await _saveModelPath(modelPath);
    debugPrint('Model loaded and saved: $modelPath');
  }

  String? getModelName() {
    if (_modelPath == null) return null;
    return File(_modelPath!).uri.pathSegments.last;
  }

  Stream<String> generateReplyStream({
    required String emailContent,
    required String senderName,
    required ReplySettings settings,
    String? additionalContext,
  }) async* {
    if (!_isInitialized || _controller == null) {
      throw Exception('Model not loaded. Please load a model first.');
    }

    final prompt = PromptBuilder.build(
      emailContent: emailContent,
      senderName: senderName,
      settings: settings,
      additionalContext: additionalContext,
    );

    debugPrint('Prompt: $prompt');

    try {
      yield* _controller!.generate(
        prompt: prompt,
        maxTokens: settings.maxTokens,
        temperature: settings.temperature,
      );
    } catch (e) {
      debugPrint('Generation error: $e');
      rethrow;
    }
  }

  Future<String> generateReply({
    required String emailContent,
    required String senderName,
    required ReplySettings settings,
    String? additionalContext,
  }) async {
    final buffer = StringBuffer();
    await for (final token in generateReplyStream(
      emailContent: emailContent,
      senderName: senderName,
      settings: settings,
      additionalContext: additionalContext,
    )) {
      buffer.write(token);
    }
    return PromptBuilder.cleanResponse(buffer.toString());
  }

  Future<String> generateSubject({
    required String bodyContent,
    required ReplySettings settings,
  }) async {
    if (!_isInitialized || _controller == null) {
      throw Exception('Model not loaded. Please load a model first.');
    }

    final prompt = 'Generate a VERY SHORT email subject (3-8 words) for this email body. '
        '${PromptBuilder.languageInstructions[settings.language] ?? PromptBuilder.languageInstructions['en']!} '
        'Output ONLY the subject, no quotes, no "Subject:" prefix, no extra text.\n\n'
        'Body:\n$bodyContent\n\nSubject:';

    debugPrint('Subject prompt: $prompt');

    final buffer = StringBuffer();
    await for (final token in _controller!.generate(
      prompt: prompt,
      maxTokens: 32,
      temperature: 0.3,
    )) {
      buffer.write(token);
    }

    var subject = buffer.toString().trim();
    subject = subject.replaceAll('"', '');
    subject = subject.replaceAll(RegExp(r'^Subject:\s*', caseSensitive: false), '');
    subject = subject.replaceAll(RegExp(r'^Re:\s*', caseSensitive: false), '');
    subject = subject.replaceAll('\n', ' ');

    return subject.trim();
  }

  Future<void> dispose() async {
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
    _modelPath = null;
  }
}
