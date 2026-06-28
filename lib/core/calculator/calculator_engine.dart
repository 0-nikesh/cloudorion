import 'expression_parser.dart';

class CalculatorSnapshot {
  const CalculatorSnapshot({
    required this.expression,
    required this.display,
    required this.preview,
  });

  final String expression;
  final String display;
  final String? preview;
}

class CalculatorExpressionEngine {
  CalculatorExpressionEngine({ExpressionParser? parser})
    : _parser = parser ?? const ExpressionParser();

  final ExpressionParser _parser;

  CalculatorSnapshot apply(String expression, String key) {
    if (key == 'clear') return _snapshot('');
    if (key == 'backspace') {
      return _snapshot(
        expression.isEmpty
            ? ''
            : expression.substring(0, expression.length - 1),
      );
    }
    if (key == 'done') {
      return _snapshot(_cleanTrailingOperator(expression), done: true);
    }

    var next = expression;
    if (_isOperator(key)) {
      next = _appendOperator(next, key);
    } else if (key == '.') {
      next = _appendDecimal(next);
    } else {
      next = _appendDigits(next, key);
    }
    return _snapshot(next);
  }

  CalculatorSnapshot _snapshot(String expression, {bool done = false}) {
    if (expression.isEmpty) {
      return const CalculatorSnapshot(
        expression: '',
        display: '',
        preview: null,
      );
    }
    final cleaned = _cleanTrailingOperator(expression);
    final value = _parser.evaluate(cleaned);
    final display = _format(value);
    final preview = done ? null : '$expression = $display';
    return CalculatorSnapshot(
      expression: expression,
      display: display,
      preview: preview,
    );
  }

  String _appendOperator(String expression, String key) {
    if (expression.isEmpty) return '';
    if (_isOperator(expression[expression.length - 1])) {
      return expression.substring(0, expression.length - 1) + key;
    }
    return expression + key;
  }

  String _appendDecimal(String expression) {
    final number = _currentNumber(expression);
    if (number.contains('.')) return expression;
    return expression.isEmpty || _isOperator(expression[expression.length - 1])
        ? '${expression}0.'
        : '$expression.';
  }

  String _appendDigits(String expression, String key) {
    final number = _currentNumber(expression);
    final digitCount = number.replaceAll('.', '').length;
    if (digitCount + key.length > 10) return expression;
    if (number == '0' && key != '00') {
      return expression.substring(0, expression.length - 1) + key;
    }
    return expression + key;
  }

  String _currentNumber(String expression) {
    final index = expression.lastIndexOf(RegExp(r'[+\-x/%]'));
    return index == -1 ? expression : expression.substring(index + 1);
  }

  String _cleanTrailingOperator(String expression) {
    var value = expression;
    while (value.isNotEmpty && _isOperator(value[value.length - 1])) {
      value = value.substring(0, value.length - 1);
    }
    return value;
  }

  bool _isOperator(String value) => ['+', '-', 'x', '/', '%'].contains(value);

  String _format(double value) {
    if (value == value.roundToDouble()) return value.round().toString();
    return value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  }
}
