import 'package:flutter_test/flutter_test.dart';
import 'package:recicla_p/main.dart';

void main() {
  testWidgets('ReciclaApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ReciclaApp());
    expect(find.byType(ReciclaApp), findsOneWidget);
  });
}
