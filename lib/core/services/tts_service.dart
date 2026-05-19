import 'package:flutter_tts/flutter_tts.dart';

/// Elite local Text-to-Speech (TTS) coordinator.
/// Uses on-device speech synthesizers, making voice announcements completely free.
class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _enabled = true;
  double _volume = 1.0;
  double _rate = 0.5;
  double _pitch = 1.0;

  TtsService() {
    _initializeTts();
  }

  /// Initial configs for synthetic voice streams
  void _initializeTts() async {
    try {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setVolume(_volume);
      await _flutterTts.setSpeechRate(_rate);
      await _flutterTts.setPitch(_pitch);
    } catch (_) {}
  }

  /// Updates TTS voice parameters dynamically from settings panel
  void updateSettings({
    required bool enabled,
    required double volume,
    required double rate,
    required double pitch,
  }) {
    _enabled = enabled;
    _volume = volume;
    _rate = rate;
    _pitch = pitch;

    _flutterTts.setVolume(volume);
    _flutterTts.setSpeechRate(rate);
    _flutterTts.setPitch(pitch);
  }

  /// Speaks the mathematical answer outcome dynamically in a futuristic style
  Future<void> speakAnswer(String answer) async {
    if (!_enabled) return;
    try {
      await _flutterTts.stop();
      String utterance = "The result is $answer";
      if (answer.startsWith("Error")) {
        utterance = answer;
      }
      await _flutterTts.speak(utterance);
    } catch (_) {}
  }

  /// Mutes or stops any current active voice announcements
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (_) {}
  }
}
