import 'dart:math' as math;
import 'package:math_expressions/math_expressions.dart';

/// Elite, robust utility for parsing and evaluating scientific expressions safely.
class MathParser {
  /// Evaluates a raw expression string and returns a formatted result or error description.
  static String evaluate(String expression) {
    if (expression.trim().isEmpty) return "0";

    try {
      String sanitized = _sanitize(expression);
      
      // Parse using math_expressions
      Parser p = Parser();
      Expression exp = p.parse(sanitized);
      ContextModel cm = ContextModel();
      
      // Bind standard math constants to the context model
      cm.bindVariable(Variable('pi'), Number(math.pi));
      cm.bindVariable(Variable('e'), Number(math.e));

      double eval = exp.evaluate(EvaluationType.REAL, cm);

      if (eval.isNaN) return "Error: Undefined";
      if (eval.isInfinite) return "Error: Division by zero";

      // Format result beautifully
      return _formatResult(eval);
    } catch (e) {
      return "Error: Invalid Syntax";
    }
  }

  /// Sanitizes raw algebraic strings into standard formats acceptable by the parser.
  static String _sanitize(String expr) {
    String formatted = expr;

    // Convert display operators to standard engine symbols
    formatted = formatted.replaceAll('×', '*');
    formatted = formatted.replaceAll('÷', '/');
    formatted = formatted.replaceAll('mod', '%');

    // Convert visual constants
    formatted = formatted.replaceAll('π', 'pi');
    formatted = formatted.replaceAll('e', 'e');

    // Handle implicit multiplication like 2(3+5) -> 2*(3+5)
    formatted = RegExp(r'(\d)(\()').allMatches(formatted).fold(
          formatted,
          (expr, match) => expr.replaceFirst('${match.group(1)}(', '${match.group(1)}*('),
        );
    formatted = RegExp(r'(\))(\()').allMatches(formatted).fold(
          formatted,
          (expr, match) => expr.replaceFirst(')(', ')*('),
        );
    formatted = RegExp(r'(\))(\d)').allMatches(formatted).fold(
          formatted,
          (expr, match) => expr.replaceFirst(')${match.group(2)}', ')*${match.group(2)}'),
        );

    // Support implicit multiplication on constants like 2pi -> 2*pi
    formatted = formatted.replaceAllMapped(RegExp(r'(\d)(pi)'), (m) => '${m.group(1)}*pi');
    formatted = formatted.replaceAllMapped(RegExp(r'(\d)(e)'), (m) => '${m.group(1)}*e');

    // Support degree conversions if trigonometry functions are called
    // (math_expressions evaluates functions like sin, cos in radians, so we provide direct helpers if required)

    return formatted;
  }

  /// Formats double outputs cleanly, truncating decimal tails if they represent integers.
  static String _formatResult(double val) {
    // If integer, drop the .0 decimal suffix
    if (val == val.roundToDouble()) {
      return val.toInt().toString();
    }
    
    // Otherwise limit to highly accurate decimal places
    String result = val.toStringAsFixed(8);
    
    // Trim trailing zeroes
    while (result.endsWith('0') && result.contains('.')) {
      result = result.substring(0, result.length - 1);
    }
    if (result.endsWith('.')) {
      result = result.substring(0, result.length - 1);
    }
    
    return result;
  }
}
