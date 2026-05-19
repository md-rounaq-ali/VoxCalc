import 'package:flutter/services.dart';

/// Centralized haptic feedback and click-sound audio coordinator.
/// Operates 100% locally and utilizes free native platform drivers.
class HapticHelper {
  static bool _hapticsEnabled = true;
  static bool _soundsEnabled = true;

  /// Updates sensory settings from user preferences
  static void configure({required bool enableHaptics, required bool enableSounds}) {
    _hapticsEnabled = enableHaptics;
    _soundsEnabled = enableSounds;
  }

  /// Triggers a brief, gentle tactile buzz suited for standard button taps
  static Future<void> triggerLightImpact() async {
    if (!_hapticsEnabled) return;
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Triggers a pronounced tactile bump suited for action submissions
  static Future<void> triggerMediumImpact() async {
    if (!_hapticsEnabled) return;
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Triggers haptic feedback during stylus/canvas drawing paths
  static Future<void> triggerSelectionClick() async {
    if (!_hapticsEnabled) return;
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// Triggers system-level tap audio clicks using system sound drivers
  static Future<void> playClickSound() async {
    if (!_soundsEnabled) return;
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }
}
