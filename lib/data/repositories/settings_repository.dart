import 'package:replai/data/datasources/local/settings_storage.dart';
import 'package:replai/data/models/reply_settings.dart';
import 'package:replai/data/models/persona.dart';

class SettingsRepository {
  final SettingsStorage _storage;

  SettingsRepository({SettingsStorage? storage})
      : _storage = storage ?? SettingsStorage();

  Future<ReplySettings> loadSettings() async {
    return _storage.loadSettings();
  }

  Future<void> saveSettings(ReplySettings settings) async {
    await _storage.saveSettings(settings);
  }

  Future<void> updateTone(String tone) async {
    final settings = await loadSettings();
    await saveSettings(settings.copyWith(tone: tone));
  }

  Future<void> updateLanguage(String language) async {
    final settings = await loadSettings();
    await saveSettings(settings.copyWith(language: language));
  }

  Future<void> updatePersonaId(String? personaId) async {
    final settings = await loadSettings();
    await saveSettings(settings.copyWith(
      personaId: personaId,
      clearPersonaId: personaId == null,
    ));
  }

  Future<void> updateTemperature(double temperature) async {
    final settings = await loadSettings();
    await saveSettings(settings.copyWith(temperature: temperature));
  }

  Future<void> updateMaxTokens(int maxTokens) async {
    final settings = await loadSettings();
    await saveSettings(settings.copyWith(maxTokens: maxTokens));
  }

  Future<void> addPersona(Persona persona) async {
    final settings = await loadSettings();
    final updatedPersonas = [...settings.personas, persona];
    await saveSettings(settings.copyWith(personas: updatedPersonas));
  }

  Future<void> updatePersona(Persona persona) async {
    final settings = await loadSettings();
    final updatedPersonas = settings.personas.map((p) {
      return p.id == persona.id ? persona : p;
    }).toList();
    await saveSettings(settings.copyWith(personas: updatedPersonas));
  }

  Future<void> deletePersona(String personaId) async {
    final settings = await loadSettings();
    final updatedPersonas = settings.personas.where((p) => p.id != personaId).toList();
    await saveSettings(settings.copyWith(
      personas: updatedPersonas,
      personaId: settings.personaId == personaId ? null : settings.personaId,
      clearPersonaId: settings.personaId == personaId,
    ));
  }
}
