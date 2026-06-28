import 'package:flutter/material.dart';

class CalculatorKeypad extends StatelessWidget {
  const CalculatorKeypad({
    super.key,
    required this.heightFactor,
    required this.onKeyPressed,
    required this.onDone,
    required this.accentColor,
  });

  final Animation<double> heightFactor;
  final ValueChanged<String> onKeyPressed;
  final VoidCallback onDone;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['%', '/', 'x', 'backspace'],
      ['7', '8', '9', '-'],
      ['4', '5', '6', '+'],
      ['1', '2', '3', 'up'],
      ['00', '0', '.', 'done'],
    ];

    return SizeTransition(
      sizeFactor: heightFactor,
      axisAlignment: -1,
      child: Container(
        height: 292,
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
        color: Colors.white,
        child: Column(
          children: [
            for (final row in keys)
              Expanded(
                child: Row(
                  children: [
                    for (final key in row)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: _CalcKey(
                            label: key,
                            accentColor: accentColor,
                            onTap: () =>
                                key == 'done' ? onDone() : onKeyPressed(key),
                            onLongPress: key == 'backspace'
                                ? () => onKeyPressed('clear')
                                : null,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CalcKey extends StatelessWidget {
  const _CalcKey({
    required this.label,
    required this.onTap,
    required this.accentColor,
    this.onLongPress,
  });

  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final isAction = ['done', 'up'].contains(label);
    final isOperator = ['%', '/', 'x', '-', '+', 'backspace'].contains(label);
    return Material(
      color: isAction
          ? accentColor
          : isOperator
          ? const Color(0xFFF1F5F9)
          : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Center(child: _child(context, isAction)),
      ),
    );
  }

  Widget _child(BuildContext context, bool isAction) {
    final color = isAction ? Colors.white : const Color(0xFF17212B);
    final icon = switch (label) {
      'backspace' => Icons.backspace_outlined,
      'up' => Icons.keyboard_arrow_down_rounded,
      'done' => Icons.check_rounded,
      _ => null,
    };
    if (icon != null) return Icon(icon, color: color);
    return Text(
      label,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
