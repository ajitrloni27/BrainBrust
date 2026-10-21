import 'package:flutter_test/flutter_test.dart';
import 'package:brain_burst/main.dart';

void main() {
  testWidgets('BrainBurstApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BrainBurstApp());
    expect(find.text('BrainBurst'), findsWidgets);
  });
}
