import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../../calculator/presentation/providers/calc_provider.dart';
import '../../../calculator/presentation/widgets/custom_scaffold.dart';

/// Elite step-by-step Equation Solver Wizards Screen.
class SolverScreen extends StatefulWidget {
  const SolverScreen({Key? key}) : super(key: key);

  @override
  State<SolverScreen> createState() => _SolverScreenState();
}

class _SolverScreenState extends State<SolverScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Quadratic parameters
  final TextEditingController _quadA = TextEditingController(text: "1");
  final TextEditingController _quadB = TextEditingController(text: "-5");
  final TextEditingController _quadC = TextEditingController(text: "6");
  String _quadSolution = "";

  // Linear system parameters (2x2 Cramer's rule)
  final TextEditingController _linA1 = TextEditingController(text: "2");
  final TextEditingController _linB1 = TextEditingController(text: "1");
  final TextEditingController _linC1 = TextEditingController(text: "8");
  final TextEditingController _linA2 = TextEditingController(text: "1");
  final TextEditingController _linB2 = TextEditingController(text: "-1");
  final TextEditingController _linC2 = TextEditingController(text: "1");
  String _linSolution = "";

  // Matrix parameters
  final TextEditingController _m00 = TextEditingController(text: "3");
  final TextEditingController _m01 = TextEditingController(text: "4");
  final TextEditingController _m10 = TextEditingController(text: "1");
  final TextEditingController _m11 = TextEditingController(text: "2");
  String _matSolution = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ==========================================
  // Quadratic Equation Formula Solver
  // ==========================================
  void _solveQuadratic() {
    HapticHelper.triggerMediumImpact();
    final double? a = double.tryParse(_quadA.text);
    final double? b = double.tryParse(_quadB.text);
    final double? c = double.tryParse(_quadC.text);

    if (a == null || b == null || c == null) {
      setState(() => _quadSolution = "Error: Please enter valid parameters");
      return;
    }
    if (a == 0) {
      setState(() => _quadSolution = "Error: 'a' parameter cannot be zero in quadratic forms");
      return;
    }

    final double disc = (b * b) - (4 * a * c);
    final StringBuffer steps = StringBuffer();
    steps.writeln("Solving: ${a}x² + (${b})x + (${c}) = 0\n");
    steps.writeln("1. Compute Discriminant (D):");
    steps.writeln("   D = b² - 4ac");
    steps.writeln("   D = (${b})² - 4*(${a})*(${c})");
    steps.writeln("   D = ${b * b} - ${4 * a * c}");
    steps.writeln("   D = $disc\n");

    if (disc > 0) {
      final double root1 = (-b + math.sqrt(disc)) / (2 * a);
      final double root2 = (-b - math.sqrt(disc)) / (2 * a);
      steps.writeln("2. Real & Distinct Roots (D > 0):");
      steps.writeln("   x = (-b ± √D) / 2a");
      steps.writeln("   x₁ = (-(${b}) + √$disc) / 2*($a) = ${root1.toStringAsFixed(4)}");
      steps.writeln("   x₂ = (-(${b}) - √$disc) / 2*($a) = ${root2.toStringAsFixed(4)}");
    } else if (disc == 0) {
      final double root = -b / (2 * a);
      steps.writeln("2. Real & Equal Roots (D = 0):");
      steps.writeln("   x = -b / 2a");
      steps.writeln("   x = -(${b}) / 2*($a) = ${root.toStringAsFixed(4)}");
    } else {
      final double realPart = -b / (2 * a);
      final double imagPart = math.sqrt(-disc) / (2 * a);
      steps.writeln("2. Complex Conjugate Roots (D < 0):");
      steps.writeln("   x = (-b ± i√|D|) / 2a");
      steps.writeln("   x₁ = ${realPart.toStringAsFixed(4)} + ${imagPart.toStringAsFixed(4)}i");
      steps.writeln("   x₂ = ${realPart.toStringAsFixed(4)} - ${imagPart.toStringAsFixed(4)}i");
    }

    setState(() {
      _quadSolution = steps.toString();
    });
  }

  // ==========================================
  // Simultaneous Linear System Solver (2 Variables)
  // ==========================================
  void _solveLinear() {
    HapticHelper.triggerMediumImpact();
    final double? a1 = double.tryParse(_linA1.text);
    final double? b1 = double.tryParse(_linB1.text);
    final double? c1 = double.tryParse(_linC1.text);
    final double? a2 = double.tryParse(_linA2.text);
    final double? b2 = double.tryParse(_linB2.text);
    final double? c2 = double.tryParse(_linC2.text);

    if (a1 == null || b1 == null || c1 == null || a2 == null || b2 == null || c2 == null) {
      setState(() => _linSolution = "Error: Please enter valid parameters");
      return;
    }

    // Solve using Cramer's Rule
    final double d = (a1 * b2) - (b1 * a2);
    final double dx = (c1 * b2) - (b1 * c2);
    final double dy = (a1 * c2) - (c1 * a2);

    final StringBuffer steps = StringBuffer();
    steps.writeln("Solving system:\n  1) (${a1})x + (${b1})y = $c1\n  2) (${a2})x + (${b2})y = $c2\n");
    steps.writeln("1. Compute Main Determinant (D):");
    steps.writeln("   D = a₁b₂ - b₁a₂ = ($a1)*($b2) - ($b1)*($a2) = $d");

    if (d == 0) {
      if (dx == 0 && dy == 0) {
        steps.writeln("\nOutcome: System has Infinite Solutions (Coincident lines)");
      } else {
        steps.writeln("\nOutcome: System has No Solution (Parallel lines)");
      }
    } else {
      final double x = dx / d;
      final double y = dy / d;
      steps.writeln("\n2. Compute Cramer's Variable Determinants:");
      steps.writeln("   Dx = c₁b₂ - b₁c₂ = ($c1)*($b2) - ($b1)*($c2) = $dx");
      steps.writeln("   Dy = a₁c₂ - c₁a₂ = ($a1)*($c2) - ($c1)*($a2) = $dy");
      steps.writeln("\n3. Solve variables x and y:");
      steps.writeln("   x = Dx / D = $dx / $d = ${x.toStringAsFixed(4)}");
      steps.writeln("   y = Dy / D = $dy / $d = ${y.toStringAsFixed(4)}");
    }

    setState(() {
      _linSolution = steps.toString();
    });
  }

  // ==========================================
  // Matrix calculations
  // ==========================================
  void _solveMatrix() {
    HapticHelper.triggerMediumImpact();
    final double? m00 = double.tryParse(_m00.text);
    final double? m01 = double.tryParse(_m01.text);
    final double? m10 = double.tryParse(_m10.text);
    final double? m11 = double.tryParse(_m11.text);

    if (m00 == null || m01 == null || m10 == null || m11 == null) {
      setState(() => _matSolution = "Error: Please enter valid parameters");
      return;
    }

    final double det = (m00 * m11) - (m01 * m10);
    final StringBuffer steps = StringBuffer();
    steps.writeln("Matrix Input:\n  [ $m00   $m01 ]\n  [ $m10   $m11 ]\n");
    steps.writeln("1. Compute Determinant:");
    steps.writeln("   det(A) = ad - bc = ($m00)*($m11) - ($m01)*($m10) = $det\n");
    
    steps.writeln("2. Compute Transpose Matrix:");
    steps.writeln("   [ $m00   $m10 ]");
    steps.writeln("   [ $m01   $m11 ]\n");

    if (det == 0) {
      steps.writeln("3. Matrix Inverse: Non-existent (Singular matrix, det = 0)");
    } else {
      final double invDet = 1 / det;
      steps.writeln("3. Compute Matrix Inverse (A⁻¹):");
      steps.writeln("   A⁻¹ = (1/det) * [ d  -b ]");
      steps.writeln("                   [ -c  a ]");
      steps.writeln("   A⁻¹ = [ ${(m11 * invDet).toStringAsFixed(3)}   ${(-m01 * invDet).toStringAsFixed(3)} ]");
      steps.writeln("         [ ${(-m10 * invDet).toStringAsFixed(3)}   ${(m00 * invDet).toStringAsFixed(3)} ]");
    }

    setState(() {
      _matSolution = steps.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalcProvider>(context);
    final mode = provider.themeMode;
    final accent = AppTheme.getAccentColor(mode);

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
          "EQUATION SOLVER WIZARDS",
          style: AppTextStyles.headerStyle(mode, fontSize: 16, glow: true),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: accent,
          labelColor: accent,
          unselectedLabelColor: AppTheme.getTextColor(mode).withOpacity(0.5),
          tabs: const [
            Tab(text: "Quadratic"),
            Tab(text: "2x2 Linear"),
            Tab(text: "2x2 Matrix"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQuadraticTab(mode, accent),
          _buildLinearTab(mode, accent),
          _buildMatrixTab(mode, accent),
        ],
      ),
    );
  }

  Widget _buildQuadraticTab(ThemeMode mode, Color accent) {
    return _buildTabWrapper(
      mode: mode,
      accent: accent,
      inputs: [
        Row(
          children: [
            Expanded(child: _buildInputField("a parameter", _quadA, mode)),
            const SizedBox(width: 8),
            Expanded(child: _buildInputField("b parameter", _quadB, mode)),
            const SizedBox(width: 8),
            Expanded(child: _buildInputField("c parameter", _quadC, mode)),
          ],
        ),
      ],
      onSolve: _solveQuadratic,
      solutionText: _quadSolution,
    );
  }

  Widget _buildLinearTab(ThemeMode mode, Color accent) {
    return _buildTabWrapper(
      mode: mode,
      accent: accent,
      inputs: [
        Row(
          children: [
            Expanded(child: _buildInputField("a₁ coeff", _linA1, mode)),
            const SizedBox(width: 8),
            Expanded(child: _buildInputField("b₁ coeff", _linB1, mode)),
            const SizedBox(width: 8),
            Expanded(child: _buildInputField("c₁ value", _linC1, mode)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildInputField("a₂ coeff", _linA2, mode)),
            const SizedBox(width: 8),
            Expanded(child: _buildInputField("b₂ coeff", _linB2, mode)),
            const SizedBox(width: 8),
            Expanded(child: _buildInputField("c₂ value", _linC2, mode)),
          ],
        ),
      ],
      onSolve: _solveLinear,
      solutionText: _linSolution,
    );
  }

  Widget _buildMatrixTab(ThemeMode mode, Color accent) {
    return _buildTabWrapper(
      mode: mode,
      accent: accent,
      inputs: [
        Row(
          children: [
            Expanded(child: _buildInputField("m₀₀", _m00, mode)),
            const SizedBox(width: 12),
            Expanded(child: _buildInputField("m₀₁", _m01, mode)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildInputField("m₁₀", _m10, mode)),
            const SizedBox(width: 12),
            Expanded(child: _buildInputField("m₁₁", _m11, mode)),
          ],
        ),
      ],
      onSolve: _solveMatrix,
      solutionText: _matSolution,
    );
  }

  Widget _buildTabWrapper({
    required ThemeMode mode,
    required Color accent,
    required List<Widget> inputs,
    required VoidCallback onSolve,
    required String solutionText,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Input Form Box
          ...inputs,
          const SizedBox(height: 16),

          // Solve Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onSolve,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                "COMPUTE STEP-BY-STEP",
                style: AppTextStyles.bodyStyle(mode, fontSize: 13, fontWeight: FontWeight.bold, customColor: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Derivation Steps Display Panel (Frosted glass container)
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.getKeyColor(mode, isOperator: true).withOpacity(0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.fromBorderSide(AppTheme.getBorderSide(mode)),
              ),
              child: SingleChildScrollView(
                child: Text(
                  solutionText.isEmpty ? "Tap Compute button to view steps derivations..." : solutionText,
                  style: AppTextStyles.monoStyle(mode, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController ctrl, ThemeMode mode) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.getKeyColor(mode, isOperator: true).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getAccentColor(mode).withOpacity(0.1), width: 1.2),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
        style: AppTextStyles.bodyStyle(mode, fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppTheme.getTextColor(mode).withOpacity(0.4)),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
