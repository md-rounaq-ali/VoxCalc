import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../../calculator/presentation/providers/calc_provider.dart';
import '../../../calculator/presentation/widgets/custom_scaffold.dart';

/// Elite Student Analytics Performance Profile Dashboard.
class StatsDashboard extends StatelessWidget {
  const StatsDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalcProvider>(context);
    final mode = provider.themeMode;
    final accent = AppTheme.getAccentColor(mode);

    // Target study goals
    final int targetGoal = 50;
    final double completionProgress = (provider.equationsSolvedCount / targetGoal).clamp(0.0, 1.0);

    return CustomScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: accent),
          onPressed: () {
            HapticHelper.triggerLightImpact();
            Navigator.pop(context);
          },
        ),
        title: Text(
          "STUDENT PERFORMANCE STATS",
          style: AppTextStyles.headerStyle(mode, fontSize: 16, glow: true),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Sleek Glass Profile Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.getKeyColor(mode, isOperator: true).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.fromBorderSide(AppTheme.getBorderSide(mode)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: accent.withOpacity(0.12),
                      child: Icon(Icons.school_rounded, color: accent, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Vox Scholar Profile",
                            style: AppTextStyles.headerStyle(mode, fontSize: 18),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Workspace Profile: Main Calculus",
                            style: AppTextStyles.bodyStyle(
                              mode,
                              fontSize: 12,
                              customColor: AppTheme.getTextColor(mode).withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. Weekly Study Goal Progress Circle Ring
              Text(
                "WEEKLY STUDY GOAL PROGRESS",
                style: AppTextStyles.bodyStyle(
                  mode,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  customColor: accent.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.getKeyColor(mode, isOperator: true).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.fromBorderSide(AppTheme.getBorderSide(mode)),
                ),
                child: Column(
                  children: [
                    // Glass circular ring
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: CircularProgressIndicator(
                            value: completionProgress,
                            strokeWidth: 10,
                            backgroundColor: Colors.white10,
                            valueColor: AlwaysStoppedAnimation<Color>(accent),
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              "${(completionProgress * 100).toInt()}%",
                              style: AppTextStyles.displayStyle(mode, fontSize: 22, glow: true),
                            ),
                            Text(
                              "COMPLETED",
                              style: AppTextStyles.bodyStyle(mode, fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Metrics totals
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildMetricCol("Solved", "${provider.equationsSolvedCount}", mode),
                        _buildMetricCol("Target", "$targetGoal", mode),
                        _buildMetricCol("Active Streak", "5 days", mode),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. User Active variables logs drawer
              Text(
                "USER ALGEBRA VARIABLES MATRIX (x, y, z)",
                style: AppTextStyles.bodyStyle(
                  mode,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  customColor: accent.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 12),
              ...provider.variables.entries.map((entry) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.getKeyColor(mode, isOperator: true).withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accent.withOpacity(0.06), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Variable Matrix: ${entry.key.toUpperCase()}",
                        style: AppTextStyles.bodyStyle(mode, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      Row(
                        children: [
                          Text(
                            entry.value,
                            style: AppTextStyles.monoStyle(mode, fontSize: 14),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: Icon(Icons.edit_note_rounded, color: accent, size: 18),
                            onPressed: () => _editVariableDialog(context, entry.key, entry.value, provider, mode, accent),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCol(String label, String value, ThemeMode mode) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.displayStyle(mode, fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: AppTextStyles.bodyStyle(mode, fontSize: 9, customColor: AppTheme.getTextColor(mode).withOpacity(0.4)),
        ),
      ],
    );
  }

  /// Interactive Dialog to edit algebraic variables
  void _editVariableDialog(
    BuildContext context,
    String key,
    String currentValue,
    CalcProvider provider,
    ThemeMode mode,
    Color accent,
  ) {
    final TextEditingController ctrl = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.currentTheme == "light_aurora"
            ? Colors.white
            : const Color(0xFF0F1016),
        title: Text("Modify Variable: ${key.toUpperCase()}", style: AppTextStyles.headerStyle(mode)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: AppTextStyles.bodyStyle(mode),
          decoration: InputDecoration(
            hintText: "Enter numerical value",
            hintStyle: TextStyle(color: AppTheme.getTextColor(mode).withOpacity(0.3)),
          ),
        ),
        actions: [
          TextButton(
            child: Text("CANCEL", style: TextStyle(color: AppTheme.getTextColor(mode))),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("SAVE", style: TextStyle(color: accent)),
            onPressed: () {
              provider.saveVariable(key, ctrl.text);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
