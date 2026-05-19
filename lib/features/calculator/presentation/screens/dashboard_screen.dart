import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../../converter/presentation/screens/converter_screen.dart';
import '../../../formulas/presentation/screens/formula_catalog_screen.dart';
import '../../../grapher/presentation/screens/grapher_screen.dart';
import '../../../lens/presentation/screens/camera_lens_screen.dart';
import '../../../solver/presentation/screens/solver_screen.dart';
import '../../../stats/presentation/screens/stats_dashboard.dart';
import '../providers/calc_provider.dart';
import '../widgets/custom_scaffold.dart';
import '../widgets/handwriting_panel.dart';
import '../widgets/history_panel.dart';
import '../widgets/manual_panel.dart';
import '../widgets/settings_panel.dart';
import '../widgets/voice_panel.dart';

/// Main Dashboard housing the bottom navigation bar and the sliding drawer mathematical wizards portal.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Returns the corresponding tab views
  Widget _getTabView(int index) {
    switch (index) {
      case 0:
        return const ManualPanel();
      case 1:
        return const VoicePanel();
      case 2:
        return const GrapherScreen();
      case 3:
        return const HistoryPanel();
      default:
        return const ManualPanel();
    }
  }

  /// Helper strings for active display titles
  String _getTabTitle(int index) {
    switch (index) {
      case 0:
        return "VOXCALC KEYPAD";
      case 1:
        return "VOXCALC VOICE";
      case 2:
        return "VOXCALC GRAPH";
      case 3:
        return "VOXCALC HISTORY";
      default:
        return "VOXCALC";
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalcProvider>(context);
    final themeName = provider.activeTheme;
    final mode = provider.themeMode;
    final accent = AppTheme.getAccentColor(themeName);

    return CustomScaffold(
      appBar: AppBar(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.grid_view_rounded, color: accent),
              onPressed: () {
                HapticHelper.triggerLightImpact();
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _getTabTitle(provider.currentTab),
            style: AppTextStyles.headerStyle(mode, fontSize: 15, glow: true),
          ),
        ),
        actions: [
          // Dynamic camera OCR lens scan trigger
          IconButton(
            icon: Icon(Icons.center_focus_strong_rounded, color: accent),
            onPressed: () {
              HapticHelper.triggerMediumImpact();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CameraLensScreen(),
                ),
              );
            },
          ),
          // Scientific toggle button (only on keypad screen)
          if (provider.currentTab == 0)
            IconButton(
              icon: Icon(
                provider.showScientific ? Icons.science_rounded : Icons.science_outlined,
                color: accent,
              ),
              onPressed: provider.toggleScientific,
            ),
        ],
      ),
      drawer: _buildWizardsDrawer(context, provider, themeName, mode, accent),
      body: _getTabView(provider.currentTab),
      bottomNavigationBar: _buildGlassBottomBar(provider, themeName, mode, accent),
    );
  }

  /// Builds the ultimate Glassmorphic Drawer math portal containing Solvers, Stats, Formulas, Settings, and Converters.
  Widget _buildWizardsDrawer(BuildContext context, CalcProvider provider, String themeName, ThemeMode mode, Color accent) {
    final bgGradients = AppTheme.getBgGradient(themeName);
    final textStyle = AppTextStyles.bodyStyle(mode, fontSize: 14, fontWeight: FontWeight.w600);

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: bgGradients,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Drawer Header
            DrawerHeader(
              decoration: BoxDecoration(
                border: Border(bottom: AppTheme.getBorderSide(themeName)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calculate_rounded, color: accent, size: 36),
                      const SizedBox(width: 12),
                      Text(
                        "VOXCALC SYSTEM",
                        style: AppTextStyles.displayStyle(mode, fontSize: 20, glow: true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Advanced Mathematical Utilities Suite",
                    style: AppTextStyles.bodyStyle(
                      mode,
                      fontSize: 10,
                      customColor: AppTheme.getTextColor(themeName).withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Drawer List Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildDrawerTile(
                    icon: Icons.functions_rounded,
                    title: "Formula Reference Database",
                    style: textStyle,
                    accent: accent,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const FormulaCatalogScreen()));
                    },
                  ),
                  _buildDrawerTile(
                    icon: Icons.square_foot_rounded,
                    title: "Multi-Equation Solver",
                    style: textStyle,
                    accent: accent,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SolverScreen()));
                    },
                  ),
                  _buildDrawerTile(
                    icon: Icons.sync_alt_rounded,
                    title: "Unit & Currency Converter",
                    style: textStyle,
                    accent: accent,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ConverterScreen()));
                    },
                  ),
                  _buildDrawerTile(
                    icon: Icons.account_circle_outlined,
                    title: "Analytics & History Dashboard",
                    style: textStyle,
                    accent: accent,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const StatsDashboard()));
                    },
                  ),
                  _buildDrawerTile(
                    icon: Icons.settings_rounded,
                    title: "System Settings",
                    style: textStyle,
                    accent: accent,
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (context) => const Dialog(
                          backgroundColor: Colors.transparent,
                          child: SettingsPanel(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Brand Stamp
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "VOXCALC v1.0.0 • 100% FREE",
                style: AppTextStyles.bodyStyle(
                  mode,
                  fontSize: 10,
                  customColor: AppTheme.getTextColor(themeName).withOpacity(0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerTile({
    required IconData icon,
    required String title,
    required TextStyle style,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.03),
      ),
      child: ListTile(
        leading: Icon(icon, color: accent),
        title: Text(title, style: style),
        trailing: const Icon(Icons.chevron_right_rounded, size: 18),
        onTap: () {
          HapticHelper.triggerLightImpact();
          onTap();
        },
      ),
    );
  }

  /// Builds a stunning glassmorphic bottom bar coordinate system.
  Widget _buildGlassBottomBar(CalcProvider provider, String themeName, ThemeMode mode, Color accent) {
    return Container(
      height: 72,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: AppTheme.getKeyColor(themeName, isOperator: true).withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.fromBorderSide(AppTheme.getBorderSide(themeName)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, Icons.keyboard_rounded, provider, themeName, accent),
          _buildNavItem(1, Icons.mic_rounded, provider, themeName, accent),
          _buildNavItem(2, Icons.show_chart_rounded, provider, themeName, accent),
          _buildNavItem(3, Icons.history_rounded, provider, themeName, accent),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, CalcProvider provider, String themeName, Color accent) {
    final bool isSelected = provider.currentTab == index;

    return GestureDetector(
      onTap: () => provider.setTab(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? accent.withOpacity(0.15) : Colors.transparent,
            ),
            child: Icon(
              icon,
              color: isSelected ? accent : AppTheme.getTextColor(themeName).withOpacity(0.6),
              size: 24,
            ),
          )
              .animate(target: isSelected ? 1 : 0)
              .scale(end: const Offset(1.15, 1.15), duration: 200.ms),
        ],
      ),
    );
  }
}
