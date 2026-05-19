import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:math_expressions/math_expressions.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../../calculator/presentation/providers/calc_provider.dart';
import '../../../calculator/presentation/widgets/custom_scaffold.dart';

/// Elite gesture-driven 2D coordinate mathematical Graph Plotter.
class GrapherScreen extends StatefulWidget {
  const GrapherScreen({Key? key}) : super(key: key);

  @override
  State<GrapherScreen> createState() => _GrapherScreenState();
}

class _GrapherScreenState extends State<GrapherScreen> {
  final TextEditingController _formulaController = TextEditingController(text: "sin(x)");
  
  // Coordinate transformations parameters
  Offset _panOffset = Offset.zero;
  double _zoomScale = 35.0; // Pixels per coordinate unit

  Offset _lastFocalPoint = Offset.zero;

  void _resetView() {
    HapticHelper.triggerMediumImpact();
    setState(() {
      _panOffset = Offset.zero;
      _zoomScale = 35.0;
    });
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
          // 1. Formula Input Bar
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.getKeyColor(mode, isOperator: true).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.fromBorderSide(AppTheme.getBorderSide(mode)),
                  ),
                  child: TextField(
                    controller: _formulaController,
                    onChanged: (_) => setState(() {}),
                    style: AppTextStyles.bodyStyle(mode, fontSize: 15, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: "Enter function, e.g. x^2 or sin(x)",
                      hintStyle: TextStyle(color: AppTheme.getTextColor(mode).withOpacity(0.4)),
                      border: InputBorder.none,
                      prefixText: "y = ",
                      prefixStyle: AppTextStyles.bodyStyle(mode, fontSize: 15, fontWeight: FontWeight.bold, customColor: accent),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // Reset Camera View Button
              IconButton(
                icon: Icon(Icons.center_focus_weak_rounded, color: accent),
                onPressed: _resetView,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 2. Gesture Detector Graph Viewport
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.getKeyColor(mode, isOperator: true).withOpacity(0.04),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.fromBorderSide(AppTheme.getBorderSide(mode)),
                ),
                child: GestureDetector(
                  onScaleStart: (details) {
                    _lastFocalPoint = details.localFocalPoint;
                  },
                  onScaleUpdate: (details) {
                    setState(() {
                      // Handle panning translations
                      final Offset delta = details.localFocalPoint - _lastFocalPoint;
                      _panOffset += delta;
                      _lastFocalPoint = details.localFocalPoint;

                      // Handle pinch-to-zoom bounds
                      _zoomScale = (_zoomScale * details.scale).clamp(8.0, 150.0);
                    });
                  },
                  child: CustomPaint(
                    painter: _GraphPainter(
                      expression: _formulaController.text,
                      panOffset: _panOffset,
                      zoomScale: _zoomScale,
                      mode: mode,
                      accentColor: accent,
                      secondaryAccent: AppTheme.getSecondaryAccent(mode),
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          Text(
            "Pinch to Zoom • Drag to Pan coordinates",
            style: AppTextStyles.bodyStyle(
              mode,
              fontSize: 11,
              customColor: AppTheme.getTextColor(mode).withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Custom Coordinate Math Graph Painter
class _GraphPainter extends CustomPainter {
  final String expression;
  final Offset panOffset;
  final double zoomScale;
  final ThemeMode mode;
  final Color accentColor;
  final Color secondaryAccent;

  _GraphPainter({
    required this.expression,
    required this.panOffset,
    required this.zoomScale,
    required this.mode,
    required this.accentColor,
    required this.secondaryAccent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double midX = size.width / 2 + panOffset.dx;
    final double midY = size.height / 2 + panOffset.dy;

    final Paint axisPaint = Paint()
      ..color = AppTheme.getTextColor(mode).withOpacity(0.4)
      ..strokeWidth = 1.8;

    final Paint gridPaint = Paint()
      ..color = AppTheme.getTextColor(mode).withOpacity(0.06)
      ..strokeWidth = 0.8;

    // 1. Draw Grid Lines dynamically
    final double step = zoomScale;
    
    // Vertical grids left and right
    for (double x = midX % step; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    // Horizontal grids top and bottom
    for (double y = midY % step; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Draw Main Central Axis
    canvas.drawLine(Offset(0, midY), Offset(size.width, midY), axisPaint); // X Axis
    canvas.drawLine(Offset(midX, 0), Offset(midX, size.height), axisPaint); // Y Axis

    // 3. Draw Axis Labels
    final TextPainter tp = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // X Axis markings
    int xCount = -((size.width / 2 + panOffset.dx) / step).floor();
    for (double x = midX % step; x < size.width; x += step) {
      if (xCount != 0) {
        tp.text = TextSpan(
          text: xCount.toString(),
          style: TextStyle(color: AppTheme.getTextColor(mode).withOpacity(0.4), fontSize: 9),
        );
        tp.layout();
        tp.paint(canvas, Offset(x - tp.width / 2, midY + 4));
      }
      xCount++;
    }

    // Y Axis markings
    int yCount = ((size.height / 2 + panOffset.dy) / step).floor();
    for (double y = midY % step; y < size.height; y += step) {
      if (yCount != 0) {
        tp.text = TextSpan(
          text: yCount.toString(),
          style: TextStyle(color: AppTheme.getTextColor(mode).withOpacity(0.4), fontSize: 9),
        );
        tp.layout();
        tp.paint(canvas, Offset(midX + 6, y - tp.height / 2));
      }
      yCount--;
    }

    // 4. Plot curves math function points
    if (expression.trim().isEmpty) return;

    final Paint curvePaint = Paint()
      ..color = accentColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Paint glowPaint = Paint()
      ..color = accentColor.withOpacity(0.3)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

    final Path curvePath = Path();
    bool firstPoint = true;

    // Scan every horizontal pixel to evaluate curve coordinates
    for (double screenX = 0; screenX < size.width; screenX += 2) {
      // Convert screen pixel position to coordinate math X value
      final double xVal = (screenX - midX) / zoomScale;

      try {
        final double yVal = _evaluateFunction(expression, xVal);
        
        // Convert math coordinate Y to screen pixel position
        final double screenY = midY - (yVal * zoomScale);

        if (screenY.isFinite && !screenY.isNaN) {
          if (firstPoint) {
            curvePath.moveTo(screenX, screenY);
            firstPoint = false;
          } else {
            curvePath.lineTo(screenX, screenY);
          }
        }
      } catch (_) {}
    }

    // Draw the glow, then main curve
    if (!firstPoint) {
      canvas.drawPath(curvePath, glowPaint);
      canvas.drawPath(curvePath, curvePaint);
    }
  }

  /// Extremely fast dynamic interpreter for common graphing curves offline.
  /// Deciphers mathematical functions containing variable x.
  double _evaluateFunction(String func, double xVal) {
    final String sanitized = func
        .toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('mod', '%')
        .replaceAll('π', 'pi');

    try {
      Parser p = Parser();
      Expression exp = p.parse(sanitized);
      ContextModel cm = ContextModel();
      
      cm.bindVariable(Variable('x'), Number(xVal));
      cm.bindVariable(Variable('pi'), Number(math.pi));
      cm.bindVariable(Variable('e'), Number(math.e));

      double eval = exp.evaluate(EvaluationType.REAL, cm);
      return eval;
    } catch (_) {
      return double.nan;
    }
  }

  @override
  bool shouldRepaint(covariant _GraphPainter oldDelegate) {
    return oldDelegate.expression != expression ||
        oldDelegate.panOffset != panOffset ||
        oldDelegate.zoomScale != zoomScale ||
        oldDelegate.mode != mode;
  }
}
