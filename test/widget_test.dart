import 'package:cloudorion_assessment/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home screen lists assessment forms', (tester) async {
    await tester.pumpWidget(const CloudOrionApp());

    expect(find.text('Add Party Transaction'), findsOneWidget);
    expect(find.text('Add Personal Expense'), findsOneWidget);
    expect(find.text('Add Group Expense'), findsOneWidget);
  });
}
