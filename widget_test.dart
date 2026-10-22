import 'package:flutter_test/flutter_test.dart';
import 'package:jalanku/main.dart';

void main() {
  testWidgets('JalanKu shows app title and destination field', (tester) async {
    await tester.pumpWidget(const JalanKuApp());
    expect(find.text('JalanKu'), findsOneWidget);
    expect(find.text('Mula navigasi'), findsOneWidget);
  });
}
