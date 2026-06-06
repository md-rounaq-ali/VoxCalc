import 'package:flutter_test/flutter_test.dart';
import 'package:voxcalc/core/utils/math_parser.dart';

void main() {
  group('MathParser Tests', () {
    test('Basic Arithmetic Evaluation', () {
      expect(MathParser.evaluate('2 + 3 * 4'), '14');
      expect(MathParser.evaluate('(2 + 3) * 4'), '20');
      expect(MathParser.evaluate('10 - 5 - 2'), '3');
      expect(MathParser.evaluate('12 / 4'), '3');
    });

    test('Division by Zero Handling', () {
      expect(MathParser.evaluate('5 / 0'), 'Error: Division by zero');
    });

    test('Trigonometry and Math Functions', () {
      expect(MathParser.evaluate('sin(0)'), '0');
      expect(MathParser.evaluate('cos(0)'), '1');
    });

    test('Implicit Multiplication', () {
      expect(MathParser.evaluate('2(3)'), '6');
      expect(MathParser.evaluate('(2)(3)'), '6');
      expect(MathParser.evaluate('2pi'), '6.28318531');
    });

    test('Invalid Syntax Handling', () {
      expect(MathParser.evaluate('2 + * 3'), 'Error: Invalid Syntax');
      expect(MathParser.evaluate('sin('), 'Error: Invalid Syntax');
    });
  });
}
