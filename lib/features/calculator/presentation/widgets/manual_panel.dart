import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/text_styles.dart';
import '../providers/calc_provider.dart';

/// Elite tactile scientific keypad grid.
class ManualPanel extends StatelessWidget {
  const ManualPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalcProvider>(context);
    final mode = provider.themeMode;
    final accent = AppTheme.getAccentColor(mode);

    // Standard Buttons Matrix
    final List<String> standardKeys = [
      "C", "(", ")", "DEL",
      "7", "8", "9", "÷",
      "4", "5", "6", "×",
      "1", "2", "3", "-",
      "0", ".", "=", "+"
    ];

    // Scientific Buttons Matrix
    final List<String> scientificKeys = [
      "sin", "cos", "tan", "^",
      "log", "ln", "sqrt", "mod",
      "π", "e", "!", "%"
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // 1. Digital Display Screen Box (Glassmorphic Container)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.getKeyColor(mode, isOperator: true).withOpacity(0.08),
              borderRadius: BorderRadius.circular(24),
              border: Border.fromBorderSide(AppTheme.getBorderSide(mode)),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.02),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Branded Screen Header: Watermark + Equation Input
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Glowing Screen Logo Watermark
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: accent.withOpacity(0.1), width: 0.5),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calculate_rounded,
                            size: 11,
                            color: accent.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "VOXCALC",
                            style: AppTextStyles.displayStyle(
                              mode,
                              fontSize: 9,
                              customColor: accent.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms),
                    
                    // Scrolling equation preview
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            provider.expression.isEmpty ? "0" : provider.expression,
                            style: AppTextStyles.displayStyle(mode, fontSize: 26, glow: false),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Result text (pulsing preview) or gorgeous glowing logo placeholder
                if (provider.expression.isNotEmpty)
                  Text(
                    provider.result,
                    style: AppTextStyles.displayStyle(
                      mode,
                      fontSize: 22,
                      customColor: accent.withOpacity(0.9),
                      glow: true,
                    ),
                  ).animate(key: ValueKey(provider.result)).scale(begin: const Offset(0.95, 0.95), duration: 200.ms)
                else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Left audio wave indicators
                          Container(width: 3, height: 10, decoration: BoxDecoration(color: accent.withOpacity(0.3), borderRadius: BorderRadius.circular(1.5))),
                          const SizedBox(width: 3),
                          Container(width: 3, height: 18, decoration: BoxDecoration(color: accent.withOpacity(0.4), borderRadius: BorderRadius.circular(1.5))),
                          const SizedBox(width: 3),
                          Container(width: 3, height: 26, decoration: BoxDecoration(color: accent.withOpacity(0.55), borderRadius: BorderRadius.circular(1.5))),
                          const SizedBox(width: 8),
                          
                          // Circular logo ring containing calculator icon (matching user screenshot theme)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: accent.withOpacity(0.4), width: 1.2),
                              boxShadow: [
                                BoxShadow(color: accent.withOpacity(0.12), blurRadius: 6),
                              ],
                            ),
                            child: Icon(Icons.calculate_rounded, color: accent, size: 20),
                          ).animate(onPlay: (c) => c.repeat(reverse: true))
                           .scale(begin: const Offset(0.96, 0.96), end: const Offset(1.04, 1.04), duration: 1200.ms),
                          
                          const SizedBox(width: 8),
                          // Right audio wave indicators
                          Container(width: 3, height: 26, decoration: BoxDecoration(color: accent.withOpacity(0.55), borderRadius: BorderRadius.circular(1.5))),
                          const SizedBox(width: 3),
                          Container(width: 3, height: 18, decoration: BoxDecoration(color: accent.withOpacity(0.4), borderRadius: BorderRadius.circular(1.5))),
                          const SizedBox(width: 3),
                          Container(width: 3, height: 10, decoration: BoxDecoration(color: accent.withOpacity(0.3), borderRadius: BorderRadius.circular(1.5))),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 2. Tactile Keypad Grids (SingleChildScrollView wrapper to prevent any squishing or overlaps)
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Scientific Panel
                  if (provider.showScientific)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 2.1,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: scientificKeys.length,
                      itemBuilder: (context, idx) {
                        final key = scientificKeys[idx];
                        return _buildKeyButton(context, key, provider, mode, accent, isScientific: true);
                      },
                    ).animate().slideY(begin: 0.1, end: 0, duration: 300.ms).fadeIn(),
                  
                  if (provider.showScientific) const SizedBox(height: 10),
                  
                  // Standard Keypad
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1.45,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: standardKeys.length,
                    itemBuilder: (context, idx) {
                      final key = standardKeys[idx];
                      return _buildKeyButton(context, key, provider, mode, accent, isScientific: false);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a stunning tactile mechanical styled calculator key with press micro-scaling animations
  Widget _buildKeyButton(
    BuildContext context,
    String label,
    CalcProvider provider,
    ThemeMode mode,
    Color accent, {
    required bool isScientific,
  }) {
    // Styling checks
    final bool isAction = label == "=";
    final bool isClearDel = label == "C" || label == "DEL";
    final bool isOperator = RegExp(r'[÷×\-+=()]').hasMatch(label) || isScientific;

    Color buttonColor = AppTheme.getKeyColor(mode, isOperator: isOperator, isAction: isAction);
    Color labelColor = Colors.white;

    if (isClearDel) {
      buttonColor = Colors.redAccent.withOpacity(0.18);
      labelColor = Colors.redAccent;
    } else if (isAction) {
      labelColor = Colors.black;
    } else if (!isOperator) {
      labelColor = AppTheme.getTextColor(mode);
    } else {
      labelColor = AppTheme.getSecondaryAccent(mode);
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isAction
                ? Colors.transparent
                : isClearDel
                    ? Colors.redAccent.withOpacity(0.3)
                    : accent.withOpacity(0.15),
            width: 1.2,
          ),
          boxShadow: isAction
              ? [
                  BoxShadow(
                    color: accent.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: InkWell(
          onTap: () => provider.inputKey(label),
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.shareTechMono(
                fontSize: isScientific ? 15 : 22,
                fontWeight: FontWeight.bold,
                color: labelColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
