import 'package:flutter/material.dart';

class ProgressiveReveal extends StatelessWidget {
  const ProgressiveReveal({
    super.key,
    required this.visible,
    required this.child,
  });

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: visible ? 1 : 0,
        child: visible ? child : const SizedBox(width: double.infinity),
      ),
    );
  }
}
