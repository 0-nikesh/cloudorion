import 'package:flutter/widgets.dart';

class KeyboardUtils {
  static void hide(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static Future<void> waitForDismissal() async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
  }
}
