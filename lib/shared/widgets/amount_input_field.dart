import 'dart:async';

import 'package:flutter/material.dart';

class AmountInputField extends StatefulWidget {
  const AmountInputField({
    super.key,
    required this.amountDisplay,
    required this.onTap,
    required this.accentColor,
    this.expressionPreview,
    this.placeholder = '0',
    this.isFocused = false,
  });

  final String amountDisplay;
  final String? expressionPreview;
  final String placeholder;
  final bool isFocused;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  State<AmountInputField> createState() => _AmountInputFieldState();
}

class _AmountInputFieldState extends State<AmountInputField> {
  bool _showCursor = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 520), (_) {
      if (mounted) setState(() => _showCursor = !_showCursor);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.amountDisplay.isNotEmpty;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.isFocused
                ? widget.accentColor
                : const Color(0xFFE2E8F0),
            width: widget.isFocused ? 1.6 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    hasValue ? widget.amountDisplay : widget.placeholder,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: hasValue
                          ? const Color(0xFF17212B)
                          : const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (widget.isFocused)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 120),
                    opacity: _showCursor ? 1 : 0,
                    child: Container(
                      width: 2,
                      height: 36,
                      color: widget.accentColor,
                    ),
                  ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              child: widget.expressionPreview == null
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        widget.expressionPreview!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
