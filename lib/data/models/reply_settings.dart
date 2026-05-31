import 'package:equatable/equatable.dart';
import 'package:replai/data/models/persona.dart';

class ReplySettings extends Equatable {
  final String tone;
  final String language;
  final String? personaId;
  final List<Persona> personas;
  final double temperature;
  final int maxTokens;

  const ReplySettings({
    this.tone = 'professional',
    this.language = 'en',
    this.personaId,
    this.personas = const [],
    this.temperature = 0.7,
    this.maxTokens = 64,
  });

  Persona? get selectedPersona {
    if (personaId == null) return null;
    try {
      return personas.firstWhere((p) => p.id == personaId);
    } catch (_) {
      return null;
    }
  }

  ReplySettings copyWith({
    String? tone,
    String? language,
    String? personaId,
    List<Persona>? personas,
    double? temperature,
    int? maxTokens,
    bool clearPersonaId = false,
  }) {
    return ReplySettings(
      tone: tone ?? this.tone,
      language: language ?? this.language,
      personaId: clearPersonaId ? null : (personaId ?? this.personaId),
      personas: personas ?? this.personas,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tone': tone,
      'language': language,
      'personaId': personaId,
      'personas': personas.map((p) => p.toJson()).toList(),
      'temperature': temperature,
      'maxTokens': maxTokens,
    };
  }

  factory ReplySettings.fromJson(Map<String, dynamic> json) {
    return ReplySettings(
      tone: json['tone'] as String? ?? 'professional',
      language: json['language'] as String? ?? 'en',
      personaId: json['personaId'] as String?,
      personas: (json['personas'] as List<dynamic>?)
              ?.map((e) => Persona.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      maxTokens: (json['maxTokens'] as num?)?.toInt() ?? 64,
    );
  }

  @override
  List<Object?> get props => [
        tone,
        language,
        personaId,
        personas,
        temperature,
        maxTokens,
      ];
}
