import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class Persona extends Equatable {
  final String id;
  final String name;
  final String signature;
  final String toneHint;
  final String? systemPrompt;

  const Persona({
    required this.id,
    required this.name,
    this.signature = '',
    this.toneHint = '',
    this.systemPrompt,
  });

  factory Persona.create({
    required String name,
    String signature = '',
    String toneHint = '',
    String? systemPrompt,
  }) {
    return Persona(
      id: const Uuid().v4(),
      name: name,
      signature: signature,
      toneHint: toneHint,
      systemPrompt: systemPrompt,
    );
  }

  Persona copyWith({
    String? id,
    String? name,
    String? signature,
    String? toneHint,
    String? systemPrompt,
    bool clearSystemPrompt = false,
  }) {
    return Persona(
      id: id ?? this.id,
      name: name ?? this.name,
      signature: signature ?? this.signature,
      toneHint: toneHint ?? this.toneHint,
      systemPrompt: clearSystemPrompt ? null : (systemPrompt ?? this.systemPrompt),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'signature': signature,
      'toneHint': toneHint,
      'systemPrompt': systemPrompt,
    };
  }

  factory Persona.fromJson(Map<String, dynamic> json) {
    return Persona(
      id: json['id'] as String,
      name: json['name'] as String,
      signature: json['signature'] as String? ?? '',
      toneHint: json['toneHint'] as String? ?? '',
      systemPrompt: json['systemPrompt'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name, signature, toneHint, systemPrompt];
}
