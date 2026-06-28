class ExpressionParser {
  const ExpressionParser();

  double evaluate(String expression) {
    final tokens = _tokenize(expression);
    if (tokens.isEmpty) return 0;
    final normalized = _normalizePercentages(tokens);
    final values = <double>[];
    final ops = <String>[];

    for (final token in normalized) {
      final number = double.tryParse(token);
      if (number != null) {
        values.add(number);
        continue;
      }
      while (ops.isNotEmpty && _precedence(ops.last) >= _precedence(token)) {
        _apply(values, ops.removeLast());
      }
      ops.add(token);
    }

    while (ops.isNotEmpty) {
      _apply(values, ops.removeLast());
    }
    return values.isEmpty ? 0 : values.last;
  }

  List<String> _tokenize(String input) {
    final result = <String>[];
    final buffer = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      if ('0123456789.'.contains(char)) {
        buffer.write(char);
      } else {
        if (buffer.isNotEmpty) {
          result.add(buffer.toString());
          buffer.clear();
        }
        if ('+-x/%'.contains(char)) result.add(char);
      }
    }
    if (buffer.isNotEmpty) result.add(buffer.toString());
    return result.where((token) => token.isNotEmpty).toList();
  }

  List<String> _normalizePercentages(List<String> tokens) {
    final normalized = <String>[];
    for (var i = 0; i < tokens.length; i++) {
      if (tokens[i] == '%' && normalized.isNotEmpty) {
        final percent = double.tryParse(normalized.removeLast()) ?? 0;
        final previousOp = normalized.isEmpty ? '' : normalized.last;
        var base = 1.0;
        if ((previousOp == '+' || previousOp == '-') &&
            normalized.length >= 2) {
          base = double.tryParse(normalized[normalized.length - 2]) ?? 1;
        }
        normalized.add((base * percent / 100).toString());
      } else {
        normalized.add(tokens[i]);
      }
    }
    return normalized;
  }

  int _precedence(String op) => (op == 'x' || op == '/') ? 2 : 1;

  void _apply(List<double> values, String op) {
    if (values.length < 2) return;
    final b = values.removeLast();
    final a = values.removeLast();
    switch (op) {
      case '+':
        values.add(a + b);
      case '-':
        values.add(a - b);
      case 'x':
        values.add(a * b);
      case '/':
        values.add(b == 0 ? 0 : a / b);
    }
  }
}
