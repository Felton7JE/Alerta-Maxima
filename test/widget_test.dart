import 'package:flutter_test/flutter_test.dart';
import 'package:blind_spot/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AlertaSosApp());
    expect(find.text('ALERTA SOS INVISÍVEL'), findsOneWidget);
  });
}
