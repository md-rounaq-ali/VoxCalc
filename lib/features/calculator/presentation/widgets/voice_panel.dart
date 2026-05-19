import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/text_styles.dart';
import '../providers/calc_provider.dart';

/// Elite Voice Recognition Panel featuring pulsing audio waves.
class VoicePanel extends StatelessWidget {
  const VoicePanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalcProvider>(context);
    final mode = provider.themeMode;
    final accent = AppTheme.getAccentColor(mode);
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    Widget instructionSection = Column(
      children: [
        Text(
          provider.isListening ? "I am Listening... Speak now" : "Tap the Mic and speak your equation",
          style: AppTextStyles.headerStyle(mode, fontSize: isLandscape ? 13 : 16, glow: provider.isListening),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          "Try: \"45 plus 10 divided by 5\"",
          style: AppTextStyles.bodyStyle(
            mode,
            fontSize: 9,
            customColor: AppTheme.getTextColor(mode).withOpacity(0.5),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );

    Widget transcriptBox = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.getKeyColor(mode, isOperator: true).withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.fromBorderSide(AppTheme.getBorderSide(mode)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: isLandscape ? 8 : 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notes_rounded, color: accent.withOpacity(0.4), size: 18),
            const SizedBox(height: 6),
            Text(
              provider.recognizedSpeechText.isEmpty
                  ? "(Transcription will stream here...)"
                  : "\"${provider.recognizedSpeechText}\"",
              style: AppTextStyles.bodyStyle(
                mode,
                fontSize: 12,
                customColor: provider.recognizedSpeechText.isEmpty
                    ? AppTheme.getTextColor(mode).withOpacity(0.4)
                    : AppTheme.getTextColor(mode),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white10),
            const SizedBox(height: 8),
            Text(
              "TRANSLATED MATH:",
              style: AppTextStyles.bodyStyle(
                mode,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                customColor: accent.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              provider.expression.isEmpty ? "0" : provider.expression,
              style: AppTextStyles.displayStyle(mode, fontSize: 18, glow: false),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white10),
            const SizedBox(height: 8),
            Text(
              "RESULT:",
              style: AppTextStyles.bodyStyle(
                mode,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                customColor: AppTheme.getSecondaryAccent(mode).withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              provider.result.isEmpty ? "0" : provider.result,
              style: AppTextStyles.displayStyle(
                mode,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                glow: !provider.result.startsWith("Error") && provider.result != "0",
                customColor: provider.result.startsWith("Error")
                    ? Colors.redAccent
                    : AppTheme.getSecondaryAccent(mode),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    Widget micControl = Stack(
      alignment: Alignment.center,
      children: [
        if (provider.isListening && !isLandscape)
          Positioned(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(16, (index) {
                final int dist = (index - 8).abs();
                final double waveHeight = dist == 0 ? 40 : (dist == 1 ? 32 : (dist == 2 ? 24 : (dist == 3 ? 16 : 8)));
                return Container(
                  width: 2.5,
                  height: waveHeight,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      colors: [accent, Colors.pinkAccent],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                 .scaleY(begin: 0.5, end: 1.3, duration: (500 + index * 25).ms, curve: Curves.easeInOut);
              }),
            ),
          ),
        if (provider.isListening) ...[
          _buildRipple(isLandscape ? 80 : 120, accent, 1.2.seconds),
          _buildRipple(isLandscape ? 100 : 140, accent, 1.8.seconds),
        ],
        GestureDetector(
          onTap: provider.toggleVoiceListening,
          child: Container(
            width: isLandscape ? 60 : 75,
            height: isLandscape ? 60 : 75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: provider.isListening ? accent : AppTheme.getKeyColor(mode, isOperator: true),
              border: Border.all(color: accent, width: 2),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(provider.isListening ? 0.6 : 0.2),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              provider.isListening ? Icons.graphic_eq_rounded : Icons.mic_rounded,
              size: isLandscape ? 24 : 28,
              color: provider.isListening ? Colors.black : Colors.white,
            ),
          ),
        ).animate(target: provider.isListening ? 1 : 0)
         .scale(end: const Offset(1.08, 1.08), duration: 300.ms, curve: Curves.bounceOut),
      ],
    );

    if (isLandscape) {
      // Landscape Side-by-Side Split layout
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Left split: Transcript Box + Mini instruction
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  instructionSection,
                  const SizedBox(height: 6),
                  Expanded(child: transcriptBox),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Right split: Big elegant microphone button
            Expanded(
              flex: 2,
              child: Center(child: micControl),
            ),
          ],
        ),
      );
    }

    // Default Portrait Layout
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          instructionSection,
          const SizedBox(height: 16),
          Expanded(child: transcriptBox),
          const SizedBox(height: 20),
          micControl,
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildRipple(double size, Color color, Duration duration) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .scale(begin: const Offset(0.7, 0.7), end: const Offset(1.3, 1.3), duration: duration)
        .fadeOut(duration: duration);
  }
}
