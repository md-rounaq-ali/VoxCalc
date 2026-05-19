import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../providers/calc_provider.dart';

/// Elite persistent math logs viewport panel.
class HistoryPanel extends StatelessWidget {
  const HistoryPanel({Key? key}) : super(key: key);

  /// Helper mapping visual icons to input methods
  IconData _getMethodIcon(String method) {
    switch (method) {
      case 'voice':
        return Icons.mic_rounded;
      case 'handwriting':
        return Icons.gesture_rounded;
      case 'scanner':
        return Icons.center_focus_strong_rounded;
      default:
        return Icons.keyboard_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalcProvider>(context);
    final mode = provider.themeMode;
    final accent = AppTheme.getAccentColor(mode);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // 1. Export Action Header controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Calculations History",
                  style: AppTextStyles.headerStyle(mode, fontSize: 16, glow: false),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (provider.history.isNotEmpty)
                Row(
                  children: [
                    // Export to PDF
                    IconButton(
                      icon: Icon(Icons.picture_as_pdf_rounded, color: accent),
                      onPressed: () => provider.exportHistory(isPdf: true),
                      tooltip: "Export to PDF",
                    ),
                    
                    // Export to CSV
                    IconButton(
                      icon: Icon(Icons.table_rows_rounded, color: accent),
                      onPressed: () => provider.exportHistory(isPdf: false),
                      tooltip: "Export to CSV",
                    ),
                    
                    // Clear all logs
                    IconButton(
                      icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
                      onPressed: () {
                        HapticHelper.triggerMediumImpact();
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppTheme.currentTheme == "light_aurora"
                                ? Colors.white
                                : const Color(0xFF0F1016),
                            title: Text("Clear Logs?", style: AppTextStyles.headerStyle(mode)),
                            content: Text(
                              "Are you sure you want to delete all historical logs? This cannot be undone.",
                              style: AppTextStyles.bodyStyle(mode),
                            ),
                            actions: [
                              TextButton(
                                child: Text("CANCEL", style: TextStyle(color: AppTheme.getTextColor(mode))),
                                onPressed: () => Navigator.pop(context),
                              ),
                              TextButton(
                                child: const Text("CLEAR ALL", style: TextStyle(color: Colors.redAccent)),
                                onPressed: () {
                                  provider.clearAllHistory();
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),

          // 2. Main History Timeline list viewport
          Expanded(
            child: provider.history.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_toggle_off_rounded, size: 64, color: AppTheme.getTextColor(mode).withOpacity(0.2)),
                        const SizedBox(height: 16),
                        Text(
                          "No historical calculations logged yet",
                          style: AppTextStyles.bodyStyle(
                            mode,
                            fontSize: 14,
                            customColor: AppTheme.getTextColor(mode).withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: provider.history.length,
                    itemBuilder: (context, idx) {
                      final item = provider.history[idx];
                      final timeStr = DateFormat('yyyy-MM-dd HH:mm').format(item.timestamp);
                      final icon = _getMethodIcon(item.inputMethod);

                      return Dismissible(
                        key: Key(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_forever_rounded, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          provider.deleteHistory(item.id);
                          HapticHelper.triggerMediumImpact();
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.getKeyColor(mode, isOperator: true).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.fromBorderSide(AppTheme.getBorderSide(mode)),
                          ),
                          child: InkWell(
                            onTap: () {
                              // Tap loads values back to keypad and switches tab index
                              HapticHelper.triggerMediumImpact();
                              provider.injectFormula(item.expression);
                              provider.setTab(0);
                            },
                            child: Row(
                              children: [
                                // Left Icon Badge indicating method
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: accent.withOpacity(0.12),
                                  ),
                                  child: Icon(icon, color: accent, size: 18),
                                ),
                                const SizedBox(width: 16),

                                // Central content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Equation formula
                                      Text(
                                        item.expression,
                                        style: AppTextStyles.bodyStyle(mode, fontSize: 15, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 4),
                                      // Result values
                                      Text(
                                        "= ${item.result}",
                                        style: AppTextStyles.bodyStyle(
                                          mode,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          customColor: AppTheme.getSecondaryAccent(mode),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Timestamp
                                Text(
                                  timeStr,
                                  style: AppTextStyles.bodyStyle(
                                    mode,
                                    fontSize: 10,
                                    customColor: AppTheme.getTextColor(mode).withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 300.ms, delay: (idx * 50).ms)
                          .slideX(begin: 0.1, end: 0, duration: 300.ms, delay: (idx * 50).ms);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
