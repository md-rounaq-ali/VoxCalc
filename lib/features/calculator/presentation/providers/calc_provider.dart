import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:uuid/uuid.dart';

import '../../../../core/services/export_service.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../../../core/utils/math_parser.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/history_item_model.dart';

/// Elite central State Provider coordinating calculations, speech recognition,
/// variable registries, theme states, haptics, and local db state hydration.
class CalcProvider extends ChangeNotifier {
  // Services
  final _storage = getIt<StorageService>();
  final _tts = getIt<TtsService>();
  final _export = getIt<ExportService>();
  final _speech = stt.SpeechToText();

  // App States
  int _currentTab = 0;
  String _expression = "";
  String _result = "0";
  String _activeTheme = "dark_fusion"; // 'dark_fusion', 'cyberpunk', 'light_aurora'
  bool _showScientific = false;

  // History and Stats Lists
  List<HistoryItemModel> _history = [];
  int _equationsSolvedCount = 0;

  // Variables and Constants Registers
  final Map<String, String> _variables = {
    'x': '0',
    'y': '0',
    'z': '0',
    'a': '0',
    'b': '0',
  };

  // Voice States
  bool _isListening = false;
  String _recognizedSpeechText = "";

  // Settings
  bool _hapticsEnabled = true;
  bool _soundsEnabled = true;
  bool _ttsEnabled = true;
  double _speechRate = 0.5;
  double _speechVolume = 1.0;

  // Getters
  int get currentTab => _currentTab;
  String get expression => _expression;
  String get result => _result;
  String get activeTheme => _activeTheme;
  bool get showScientific => _showScientific;
  List<HistoryItemModel> get history => _history;
  int get equationsSolvedCount => _equationsSolvedCount;
  Map<String, String> get variables => _variables;
  bool get isListening => _isListening;
  String get recognizedSpeechText => _recognizedSpeechText;

  bool get hapticsEnabled => _hapticsEnabled;
  bool get soundsEnabled => _soundsEnabled;
  bool get ttsEnabled => _ttsEnabled;
  double get speechRate => _speechRate;
  double get speechVolume => _speechVolume;

  /// Translates the custom theme string to a standard Flutter ThemeMode
  ThemeMode get themeMode {
    if (_activeTheme == "light_aurora") return ThemeMode.light;
    if (_activeTheme == "dark_fusion") return ThemeMode.dark;
    return ThemeMode.system; // Used as Cyberpunk token in UI theme resolver
  }

  // ==========================================
  // Initialization & Hydration
  // ==========================================

  CalcProvider() {
    _hydrateState();
  }

  void _hydrateState() {
    _activeTheme = _storage.getConfig('active_theme', defaultValue: 'dark_fusion');
    AppTheme.currentTheme = _activeTheme;
    _currentTab = _storage.getConfig('current_tab', defaultValue: 0);
    _showScientific = _storage.getConfig('show_scientific', defaultValue: false);
    _expression = _storage.getConfig('active_expression', defaultValue: '');
    _result = _storage.getConfig('active_result', defaultValue: '0');
    _equationsSolvedCount = _storage.getConfig('equations_solved_count', defaultValue: 0);

    // Hydrate variables
    _variables.forEach((key, _) {
      _variables[key] = _storage.getConfig('var_$key', defaultValue: '0');
    });

    // Hydrate configs
    _hapticsEnabled = _storage.getConfig('haptics_enabled', defaultValue: true);
    _soundsEnabled = _storage.getConfig('sounds_enabled', defaultValue: true);
    _ttsEnabled = _storage.getConfig('tts_enabled', defaultValue: true);
    _speechRate = _storage.getConfig('speech_rate', defaultValue: 0.5);
    _speechVolume = _storage.getConfig('speech_volume', defaultValue: 1.0);

    // Apply sensory values
    HapticHelper.configure(enableHaptics: _hapticsEnabled, enableSounds: _soundsEnabled);
    _tts.updateSettings(
      enabled: _ttsEnabled,
      volume: _speechVolume,
      rate: _speechRate,
      pitch: 1.0,
    );

    // Load History logs
    _history = _storage.getHistory();
    notifyListeners();
  }

  // ==========================================
  // Layout Controls
  // ==========================================

  void setTab(int tabIndex) {
    _currentTab = tabIndex;
    _storage.saveConfig('current_tab', tabIndex);
    HapticHelper.triggerLightImpact();
    notifyListeners();
  }

  void toggleScientific() {
    _showScientific = !_showScientific;
    _storage.saveConfig('show_scientific', _showScientific);
    HapticHelper.triggerLightImpact();
    notifyListeners();
  }

  // ==========================================
  // Manual Calculator Input Controls
  // ==========================================

  void inputKey(String key) {
    HapticHelper.triggerLightImpact();
    HapticHelper.playClickSound();

    if (key == "C") {
      clearWorkspace();
      return;
    }
    if (key == "DEL") {
      deleteLast();
      return;
    }
    if (key == "=") {
      evaluate(inputMethod: 'manual');
      return;
    }

    if (key == "sin" || key == "cos" || key == "tan" || key == "log" || key == "ln" || key == "sqrt") {
      _expression += "$key(";
      _storage.saveConfig('active_expression', _expression);
      notifyListeners();
      return;
    }

    // Append standard keys
    _expression += key;
    _storage.saveConfig('active_expression', _expression);
    notifyListeners();
  }

  void clearWorkspace() {
    _expression = "";
    _result = "0";
    _storage.saveConfig('active_expression', "");
    _storage.saveConfig('active_result', "0");
    notifyListeners();
  }

  void deleteLast() {
    if (_expression.isNotEmpty) {
      _expression = _expression.substring(0, _expression.length - 1);
      _storage.saveConfig('active_expression', _expression);
      notifyListeners();
    }
  }

  /// Explicitly inserts equations templates from the Formula database
  void injectFormula(String formulaTemplate) {
    _expression += formulaTemplate;
    _storage.saveConfig('active_expression', _expression);
    notifyListeners();
  }

  // ==========================================
  // Core Math Evaluation Engine
  // ==========================================

  void evaluate({required String inputMethod}) {
    if (_expression.isEmpty) return;

    HapticHelper.triggerMediumImpact();

    // Map user variables back to numerical constants before calculation
    String evaluationExpression = _expression;
    _variables.forEach((key, val) {
      evaluationExpression = evaluationExpression.replaceAll(key, '($val)');
    });

    final String calcResult = MathParser.evaluate(evaluationExpression);

    if (!calcResult.startsWith("Error")) {
      _result = calcResult;
      _equationsSolvedCount++;
      _storage.saveConfig('equations_solved_count', _equationsSolvedCount);

      // Save log item into Hive storage
      final historyItem = HistoryItemModel(
        id: const Uuid().v4(),
        expression: _expression,
        result: _result,
        timestamp: DateTime.now(),
        inputMethod: inputMethod,
      );
      _storage.saveHistory(historyItem);
      _history.insert(0, historyItem);

      // Trigger Text-to-Speech synthesis
      _tts.speakAnswer(_result);
    } else {
      _result = calcResult;
      _tts.speakAnswer("Error in input expression");
    }

    _storage.saveConfig('active_result', _result);
    notifyListeners();
  }

  // ==========================================
  // Handwriting OCR Stroke Injection Handler
  // ==========================================

  void inputHandwrittenMath(String mathExpression) {
    _expression = mathExpression;
    _storage.saveConfig('active_expression', _expression);
    evaluate(inputMethod: 'handwriting');
  }

  // ==========================================
  // Variable Memory Handlers
  // ==========================================

  void saveVariable(String key, String value) {
    if (_variables.containsKey(key)) {
      _variables[key] = value;
      _storage.saveConfig('var_$key', value);
      HapticHelper.triggerMediumImpact();
      notifyListeners();
    }
  }

  // ==========================================
  // Speech Recognition & Voice Commands Systems
  // ==========================================

  Future<void> toggleVoiceListening() async {
    HapticHelper.triggerMediumImpact();

    if (_isListening) {
      await _speech.stop();
      _isListening = false;
      notifyListeners();
      return;
    }

    bool available = await _speech.initialize(
      onError: (val) {
        _isListening = false;
        if (val.errorMsg == "error_language_unavailable" || val.errorMsg == "error_speech_timeout") {
          _recognizedSpeechText = "Speech Error: ${val.errorMsg}\n\n"
              "💡 HOW TO FIX ON VIVO:\n"
              "1. Go to phone Settings > Apps > Default apps > Assist & voice input.\n"
              "2. Tap 'Assist app' and set it to 'Google' (instead of Vivo assistant).\n"
              "3. Ensure the official 'Google' app is installed from the Play Store.";
        } else {
          _recognizedSpeechText = "Speech Error: ${val.errorMsg}\nEnsure mic permission is granted!";
        }
        notifyListeners();
      },
      onStatus: (status) {
        if (status == "done" || status == "notListening") {
          _isListening = false;
          notifyListeners();
        }
      },
    );

    if (available) {
      _isListening = true;
      _recognizedSpeechText = "Listening for audio equations...";

      String targetLocale = "en_US";
      try {
        final systemLocale = await _speech.systemLocale();
        if (systemLocale != null) {
          targetLocale = systemLocale.localeId;
        }
      } catch (_) {}

      _speech.listen(
        localeId: targetLocale,
        onResult: (result) {
          _recognizedSpeechText = result.recognizedWords;
          _parseVoiceTranscripts(result.recognizedWords);
          if (result.finalResult && _expression.isNotEmpty) {
            // Auto evaluate dynamically when user pauses or stops speaking
            evaluate(inputMethod: 'voice');
          }
          notifyListeners();
        },
      );
    } else {
      _recognizedSpeechText = "Speech recognition unavailable.\nPlease verify system Google Speech services are enabled.";
    }
    notifyListeners();
  }

  /// Parses transcribing texts real-time, executing actions or math translations
  void _parseVoiceTranscripts(String words) {
    final String transcript = words.toLowerCase().trim();

    // 1. App Smart Command Routes
    if (transcript.contains("vox clear workspace") || transcript.contains("vox restart")) {
      clearWorkspace();
      _recognizedSpeechText = "Command: Clear Workspace";
      return;
    }
    if (transcript.contains("vox show history") || transcript.contains("vox open logs")) {
      setTab(3); // History tab index
      _recognizedSpeechText = "Command: Show History";
      return;
    }
    if (transcript.contains("vox set theme to cyberpunk")) {
      setTheme("cyberpunk");
      _recognizedSpeechText = "Theme Updated: Cyberpunk";
      return;
    }
    if (transcript.contains("vox set theme to dark fusion")) {
      setTheme("dark_fusion");
      _recognizedSpeechText = "Theme Updated: Dark Fusion";
      return;
    }
    if (transcript.contains("vox set theme to light aurora")) {
      setTheme("light_aurora");
      _recognizedSpeechText = "Theme Updated: Light Aurora";
      return;
    }
    if (transcript.contains("vox export calculations")) {
      exportHistory(isPdf: true);
      _recognizedSpeechText = "Command: Export PDF Report";
      return;
    }

    // 2. Math Formula translations mapping
    String translated = words.toLowerCase();

    // Detect verbal triggers for equals/evaluation
    bool shouldTriggerEvaluation = false;
    if (translated.contains("equal to") ||
        translated.contains("equals") ||
        translated.contains("equal") ||
        translated.contains("is") ||
        translated.contains("makes")) {
      shouldTriggerEvaluation = true;
    }

    // Strip out all verbal equals/calculate triggers from equation
    translated = translated.replaceAll("equal to", "");
    translated = translated.replaceAll("equals", "");
    translated = translated.replaceAll("equal", "");
    translated = translated.replaceAll("is", "");
    translated = translated.replaceAll("makes", "");
    
    // Multiplications
    translated = translated.replaceAll("multiplied by", "×");
    translated = translated.replaceAll("times", "×");
    translated = translated.replaceAll("into", "×");
    translated = translated.replaceAll("multiply", "×");
    
    // Divisions
    translated = translated.replaceAll("divided by", "÷");
    translated = translated.replaceAll("division", "÷");
    translated = translated.replaceAll("divided", "÷");
    translated = translated.replaceAll("over", "÷");

    // Additions & Subtractions
    translated = translated.replaceAll("plus", "+");
    translated = translated.replaceAll("add", "+");
    translated = translated.replaceAll("minus", "-");
    translated = translated.replaceAll("subtract", "-");
    translated = translated.replaceAll("take away", "-");

    // Parentheses
    translated = translated.replaceAll("open bracket", "(");
    translated = translated.replaceAll("close bracket", ")");
    translated = translated.replaceAll("open parenthesis", "(");
    translated = translated.replaceAll("close parenthesis", ")");
    
    // Constant parameters
    translated = translated.replaceAll("pi", "π");
    translated = translated.replaceAll("pie", "π");
    
    // Modulus / Modulo
    translated = translated.replaceAll("modulus", "mod");
    translated = translated.replaceAll("modulo", "mod");
    
    // Special functions
    translated = translated.replaceAll("square root of", "sqrt(");
    translated = translated.replaceAll("square root", "sqrt");
    translated = translated.replaceAll("sqrt of", "sqrt(");

    // Clean extra whitespace
    translated = translated.trim();

    _expression = translated;
    _storage.saveConfig('active_expression', _expression);

    // Trigger instant evaluation if verbal trigger was matched
    if (shouldTriggerEvaluation && _expression.isNotEmpty) {
      evaluate(inputMethod: 'voice');
    }
  }

  // ==========================================
  // Theme Controls
  // ==========================================

  void setTheme(String themeName) {
    _activeTheme = themeName;
    AppTheme.currentTheme = themeName;
    _storage.saveConfig('active_theme', themeName);
    HapticHelper.triggerMediumImpact();
    notifyListeners();
  }

  // ==========================================
  // Export Suite Pipelines
  // ==========================================

  void exportHistory({required bool isPdf}) {
    HapticHelper.triggerMediumImpact();
    if (isPdf) {
      _export.exportHistoryToPdf(_history);
    } else {
      _export.exportHistoryToCsv(_history);
    }
  }

  void deleteHistory(String id) {
    _storage.deleteHistory(id);
    _history.removeWhere((item) => item.id == id);
    HapticHelper.triggerMediumImpact();
    notifyListeners();
  }

  void clearAllHistory() {
    _storage.clearHistory();
    _history.clear();
    HapticHelper.triggerMediumImpact();
    notifyListeners();
  }

  // ==========================================
  // Settings Modifiers
  // ==========================================

  void updateSettings({
    required bool haptics,
    required bool sounds,
    required bool tts,
    required double rate,
    required double volume,
  }) {
    _hapticsEnabled = haptics;
    _soundsEnabled = sounds;
    _ttsEnabled = tts;
    _speechRate = rate;
    _speechVolume = volume;

    _storage.saveConfig('haptics_enabled', haptics);
    _storage.saveConfig('sounds_enabled', sounds);
    _storage.saveConfig('tts_enabled', tts);
    _storage.saveConfig('speech_rate', rate);
    _storage.saveConfig('speech_volume', volume);

    HapticHelper.configure(enableHaptics: haptics, enableSounds: sounds);
    _tts.updateSettings(
      enabled: tts,
      volume: volume,
      rate: rate,
      pitch: 1.0,
    );
    notifyListeners();
  }
}
