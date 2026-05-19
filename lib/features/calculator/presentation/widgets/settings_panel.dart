import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../providers/calc_provider.dart';

/// Elite settings panel configuring haptics, TTS speech metrics, and dynamic themes.
class SettingsPanel extends StatelessWidget {
  const SettingsPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalcProvider>(context);
    final mode = provider.themeMode;
    final accent = AppTheme.getAccentColor(mode);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.currentTheme == "light_aurora"
            ? Colors.white.withOpacity(0.96)
            : const Color(0xFF0F1016).withOpacity(0.95),
        borderRadius: BorderRadius.circular(28),
        border: Border.fromBorderSide(AppTheme.getBorderSide(mode)),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 20, spreadRadius: 4),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.settings_rounded, color: accent, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "VoxCalc Parameters",
                          style: AppTextStyles.headerStyle(mode, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: AppTheme.getTextColor(mode).withOpacity(0.6)),
                  onPressed: () {
                    HapticHelper.triggerLightImpact();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const Divider(color: Colors.white12),
            const SizedBox(height: 16),

            // 1. Dynamic Visual Themes Selector
            Text(
              "VISUAL THEME INTERFACE",
              style: AppTextStyles.bodyStyle(
                mode,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                customColor: accent.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildThemeCard(context, "dark_fusion", "Fusion", provider, mode, accent),
                const SizedBox(width: 6),
                _buildThemeCard(context, "cyberpunk", "Cyber", provider, mode, accent),
                const SizedBox(width: 6),
                _buildThemeCard(context, "light_aurora", "Aurora", provider, mode, accent),
              ],
            ),
            const SizedBox(height: 24),

            // 2. Sensory Feedback Configs
            Text(
              "SENSORY SYSTEMS",
              style: AppTextStyles.bodyStyle(
                mode,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                customColor: accent.withOpacity(0.8),
              ),
            ),
            _buildSwitchTile(
              "Haptic Vibration Feedback",
              provider.hapticsEnabled,
              mode,
              accent,
              (val) => provider.updateSettings(
                haptics: val,
                sounds: provider.soundsEnabled,
                tts: provider.ttsEnabled,
                rate: provider.speechRate,
                volume: provider.speechVolume,
              ),
            ),
            _buildSwitchTile(
              "Tactile Key Click Sounds",
              provider.soundsEnabled,
              mode,
              accent,
              (val) => provider.updateSettings(
                haptics: provider.hapticsEnabled,
                sounds: val,
                tts: provider.ttsEnabled,
                rate: provider.speechRate,
                volume: provider.speechVolume,
              ),
            ),
            _buildSwitchTile(
              "Synthetic TTS Voice Readout",
              provider.ttsEnabled,
              mode,
              accent,
              (val) => provider.updateSettings(
                haptics: provider.hapticsEnabled,
                sounds: provider.soundsEnabled,
                tts: val,
                rate: provider.speechRate,
                volume: provider.speechVolume,
              ),
            ),
            const SizedBox(height: 16),

            // 3. Audio Rate and volume sliders
            if (provider.ttsEnabled) ...[
              Text(
                "TTS AUDIO READOUT VOLUME",
                style: AppTextStyles.bodyStyle(mode, fontSize: 9, fontWeight: FontWeight.bold),
              ),
              Slider(
                value: provider.speechVolume,
                onChanged: (val) => provider.updateSettings(
                  haptics: provider.hapticsEnabled,
                  sounds: provider.soundsEnabled,
                  tts: provider.ttsEnabled,
                  rate: provider.speechRate,
                  volume: val,
                ),
                activeColor: accent,
                inactiveColor: accent.withOpacity(0.2),
              ),
              Text(
                "TTS AUDIO READOUT SPEED",
                style: AppTextStyles.bodyStyle(mode, fontSize: 9, fontWeight: FontWeight.bold),
              ),
              Slider(
                value: provider.speechRate,
                onChanged: (val) => provider.updateSettings(
                  haptics: provider.hapticsEnabled,
                  sounds: provider.soundsEnabled,
                  tts: provider.ttsEnabled,
                  rate: val,
                  volume: provider.speechVolume,
                ),
                activeColor: accent,
                inactiveColor: accent.withOpacity(0.2),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(
    BuildContext context,
    String themeName,
    String label,
    CalcProvider provider,
    ThemeMode mode,
    Color accent,
  ) {
    final bool isSelected = provider.activeTheme == themeName;
    final bool isLight = AppTheme.currentTheme == "light_aurora";

    Color cardBg;
    Color textColor;

    if (isSelected) {
      cardBg = accent;
      textColor = isLight ? Colors.white : Colors.black;
    } else {
      cardBg = isLight ? Colors.black.withOpacity(0.04) : Colors.white.withOpacity(0.06);
      textColor = AppTheme.getTextColor(mode).withOpacity(0.6);
    }

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticHelper.triggerMediumImpact();
          provider.setTheme(themeName);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? accent : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Text(
            label.toUpperCase(),
            style: AppTextStyles.bodyStyle(
              mode,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              customColor: textColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    bool val,
    ThemeMode mode,
    Color accent,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: AppTextStyles.bodyStyle(mode, fontSize: 13, fontWeight: FontWeight.w500),
      ),
      trailing: Switch(
        value: val,
        onChanged: (val) {
          HapticHelper.triggerLightImpact();
          onChanged(val);
        },
        activeColor: accent,
      ),
    );
  }
}
