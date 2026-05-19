import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../../calculator/presentation/providers/calc_provider.dart';
import '../../../calculator/presentation/widgets/custom_scaffold.dart';

/// Elite Formulas catalog cheat sheet screen.
class FormulaCatalogScreen extends StatelessWidget {
  const FormulaCatalogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalcProvider>(context);
    final mode = provider.themeMode;
    final accent = AppTheme.getAccentColor(mode);

    // Dynamic catalog lists
    final List<FormulaGroup> catalog = [
      FormulaGroup(
        topic: "Algebra & Core Mathematics",
        items: [
          FormulaItem(name: "Quadratic Formula", math: "x = (-b ± sqrt(b^2 - 4*a*c)) / (2*a)", injection: "(-b + sqrt(b^2 - 4*a*c)) / (2*a)"),
          FormulaItem(name: "Difference of Squares", math: "a^2 - b^2 = (a-b)*(a+b)", injection: "(a-b)*(a+b)"),
          FormulaItem(name: "Binomial Expansion (Square)", math: "(a + b)^2 = a^2 + 2*a*b + b^2", injection: "a^2 + 2*a*b + b^2"),
          FormulaItem(name: "Logarithm Product Rule", math: "log(a*b) = log(a) + log(b)", injection: "log(a) + log(b)"),
          FormulaItem(name: "Logarithm Quotient Rule", math: "log(a/b) = log(a) - log(b)", injection: "log(a) - log(b)"),
        ],
      ),
      FormulaGroup(
        topic: "Trigonometry Identities",
        items: [
          FormulaItem(name: "Pythagorean Identity", math: "sin(x)^2 + cos(x)^2 = 1", injection: "sin(x)^2 + cos(x)^2"),
          FormulaItem(name: "Sine Double Angle Identity", math: "sin(2*x) = 2*sin(x)*cos(x)", injection: "2*sin(x)*cos(x)"),
          FormulaItem(name: "Cosine Double Angle Identity", math: "cos(2*x) = cos(x)^2 - sin(x)^2", injection: "cos(x)^2 - sin(x)^2"),
          FormulaItem(name: "Tangent Quotient Identity", math: "tan(x) = sin(x) / cos(x)", injection: "sin(x)/cos(x)"),
        ],
      ),
      FormulaGroup(
        topic: "Calculus & Analysis",
        items: [
          FormulaItem(name: "Basic Integral Power Rule", math: "∫ x^n dx = (x^(n+1)) / (n+1)", injection: "(x^(n+1)) / (n+1)"),
          FormulaItem(name: "Derivative of Sine", math: "d/dx[sin(x)] = cos(x)", injection: "cos(x)"),
          FormulaItem(name: "Derivative of Cosine", math: "d/dx[cos(x)] = -sin(x)", injection: "-sin(x)"),
          FormulaItem(name: "Integral of Exponential", math: "∫ e^x dx = e^x", injection: "e^x"),
        ],
      ),
      FormulaGroup(
        topic: "Geometry & Coordinate Space",
        items: [
          FormulaItem(name: "Area of a Circle", math: "A = π * r^2", injection: "π * r^2"),
          FormulaItem(name: "Perimeter (Circumference) of a Circle", math: "C = 2 * π * r", injection: "2 * π * r"),
          FormulaItem(name: "Volume of a Sphere", math: "V = (4/3) * π * r^3", injection: "(4/3) * π * r^3"),
          FormulaItem(name: "Area of a Triangle", math: "A = 0.5 * b * h", injection: "0.5 * b * h"),
          FormulaItem(name: "Surface Area of a Cylinder", math: "A = 2*π*r*h + 2*π*r^2", injection: "2*π*r*h + 2*π*r^2"),
        ],
      ),
      FormulaGroup(
        topic: "Physics & Natural Sciences",
        items: [
          FormulaItem(name: "Einstein's Mass-Energy Equivalence", math: "E = m * c^2", injection: "m * c^2"),
          FormulaItem(name: "Kinematic Velocity Formula", math: "v = u + a * t", injection: "u + a * t"),
          FormulaItem(name: "Newton's Second Law of Motion", math: "F = m * a", injection: "m * a"),
          FormulaItem(name: "Kinetic Energy", math: "KE = 0.5 * m * v^2", injection: "0.5 * m * v^2"),
          FormulaItem(name: "Newtonian Gravitational Force", math: "F = G * m1 * m2 / r^2", injection: "G * m1 * m2 / r^2"),
          FormulaItem(name: "Ohm's Law (Voltage)", math: "V = I * R", injection: "i * r"),
        ],
      ),
      FormulaGroup(
        topic: "Statistics & Probability",
        items: [
          FormulaItem(name: "Arithmetic Mean (Average)", math: "μ = (x₁ + x₂ + ... + x_n) / n", injection: "(x1 + x2 + x3)/n"),
          FormulaItem(name: "Permutations (nPr)", math: "P(n, r) = n! / (n-r)!", injection: "n! / (n-r)!"),
          FormulaItem(name: "Combinations (nCr)", math: "C(n, r) = n! / (r! * (n-r)!)", injection: "n! / (r! * (n-r)!)"),
          FormulaItem(name: "Bayes' Theorem", math: "P(A|B) = [P(B|A) * P(A)] / P(B)", injection: "(p_ba * p_a) / p_b"),
        ],
      ),
      FormulaGroup(
        topic: "Financial & Interest Models",
        items: [
          FormulaItem(name: "Simple Interest Earned", math: "I = P * r * t", injection: "p * r * t"),
          FormulaItem(name: "Compound Interest (Future Value)", math: "A = P * (1 + r)^t", injection: "p * (1 + r)^t"),
          FormulaItem(name: "Present Value (Discounting)", math: "PV = FV / (1 + r)^t", injection: "fv / (1 + r)^t"),
          FormulaItem(name: "Return on Investment (ROI)", math: "ROI = (Net Profit / Cost) * 100", injection: "(profit / cost) * 100"),
        ],
      ),
    ];

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
          "MATHEMATICAL FORMULAS",
          style: AppTextStyles.headerStyle(mode, fontSize: 16, glow: true),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListView.builder(
          itemCount: catalog.length,
          itemBuilder: (context, idx) {
            final group = catalog[idx];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Group Header title
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                  child: Text(
                    group.topic.toUpperCase(),
                    style: AppTextStyles.bodyStyle(
                      mode,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      customColor: accent.withOpacity(0.8),
                    ),
                  ),
                ),
                
                // Group Formula Cards
                ...group.items.map((item) => _buildFormulaCard(context, item, provider, mode, accent)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormulaCard(
    BuildContext context,
    FormulaItem item,
    CalcProvider provider,
    ThemeMode mode,
    Color accent,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getKeyColor(mode, isOperator: true).withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.fromBorderSide(AppTheme.getBorderSide(mode)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Formula Name
          Text(
            item.name,
            style: AppTextStyles.bodyStyle(mode, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),

          // Math Expression representation
          Container(
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.math,
              style: AppTextStyles.monoStyle(mode, fontSize: 13),
            ),
          ),
          const SizedBox(height: 12),

          // Action Injector button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: Icon(Icons.playlist_add_rounded, color: accent, size: 18),
              label: Text(
                "INJECT FORMULA",
                style: AppTextStyles.bodyStyle(
                  mode,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  customColor: accent,
                ),
              ),
              onPressed: () {
                HapticHelper.triggerMediumImpact();
                provider.injectFormula(item.injection);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: accent,
                    content: Text(
                      "Injected template: ${item.injection}",
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                );

                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper representing Group Categories in the formula book
class FormulaGroup {
  final String topic;
  final List<FormulaItem> items;

  FormulaGroup({required this.topic, required this.items});
}

/// Helper representing individual formulas in categories
class FormulaItem {
  final String name;
  final String math;
  final String injection;

  FormulaItem({required this.name, required this.math, required this.injection});
}
