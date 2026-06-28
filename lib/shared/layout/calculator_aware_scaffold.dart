import 'package:flutter/material.dart';

import '../../core/utils/keyboard_utils.dart';
import '../widgets/calculator_keypad.dart';
import '../widgets/form_save_button.dart';

class CalculatorAwareScaffold extends StatefulWidget {
  const CalculatorAwareScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.accentColor,
    required this.saveLabel,
    required this.onSave,
    required this.onCalculatorKey,
    required this.onCalculatorDone,
    this.isSaveLoading = false,
    this.calculatorOpen = false,
    this.saveEnabled = false,
    this.onCalculatorVisibilityChanged,
    this.floatingBody,
  });

  final String title;
  final Widget body;
  final Widget? floatingBody;
  final Color accentColor;
  final String saveLabel;
  final bool saveEnabled;
  final bool isSaveLoading;
  final bool calculatorOpen;
  final VoidCallback? onSave;
  final ValueChanged<String> onCalculatorKey;
  final VoidCallback onCalculatorDone;
  final ValueChanged<bool>? onCalculatorVisibilityChanged;

  @override
  State<CalculatorAwareScaffold> createState() =>
      CalculatorAwareScaffoldState();
}

class CalculatorAwareScaffoldState extends State<CalculatorAwareScaffold>
    with SingleTickerProviderStateMixin {
  static const calculatorHeight = 292.0;
  static const savePanelHeight = 76.0;

  late final AnimationController _controller;
  late final Animation<double> _heightFactor;
  double _frozenKeyboardInset = 0;
  bool _isPopping = false;

  bool get isCalculatorVisible => _controller.value > 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
      reverseDuration: const Duration(milliseconds: 190),
    );
    _heightFactor = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.calculatorOpen) openCalculator();
    });
  }

  @override
  void didUpdateWidget(covariant CalculatorAwareScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.calculatorOpen != oldWidget.calculatorOpen) {
      widget.calculatorOpen ? openCalculator() : closeCalculator();
    }
  }

  Future<void> openCalculator() async {
    KeyboardUtils.hide(context);
    await KeyboardUtils.waitForDismissal();
    if (!mounted) return;
    widget.onCalculatorVisibilityChanged?.call(true);
    await _controller.forward();
  }

  Future<void> closeCalculator() async {
    if (_controller.value == 0) return;
    await _controller.reverse();
    widget.onCalculatorVisibilityChanged?.call(false);
  }

  Future<void> focusNativeField(FocusNode focusNode) async {
    await closeCalculator();
    if (!mounted) return;
    focusNode.requestFocus();
  }

  Future<void> closeCalculatorBefore(Future<void> Function() action) async {
    await closeCalculator();
    if (!mounted) return;
    await action();
  }

  Future<bool> _handlePop() async {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    if (keyboardInset > 0) {
      setState(() {
        _isPopping = true;
        _frozenKeyboardInset = keyboardInset;
      });
      KeyboardUtils.hide(context);
      await Future<void>.delayed(const Duration(milliseconds: 90));
      if (mounted) Navigator.of(context).pop();
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final liveKeyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final keyboardInset = _isPopping ? _frozenKeyboardInset : liveKeyboardInset;
    final bottomPanelHeight = widget.calculatorOpen
        ? calculatorHeight + savePanelHeight
        : keyboardInset + savePanelHeight;

    return PopScope(
      canPop: liveKeyboardInset == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handlePop();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: Text(widget.title)),
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: bottomPanelHeight),
              child: widget.body,
            ),
            if (widget.floatingBody != null) widget.floatingBody!,
            Positioned(
              left: 0,
              right: 0,
              bottom: widget.calculatorOpen ? calculatorHeight : keyboardInset,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                color: Theme.of(context).scaffoldBackgroundColor,
                child: SafeArea(
                  top: false,
                  child: FormSaveButton(
                    label: widget.saveLabel,
                    accentColor: widget.accentColor,
                    isLoading: widget.isSaveLoading,
                    onPressed: widget.saveEnabled ? widget.onSave : null,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CalculatorKeypad(
                heightFactor: _heightFactor,
                accentColor: widget.accentColor,
                onKeyPressed: widget.onCalculatorKey,
                onDone: widget.onCalculatorDone,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
