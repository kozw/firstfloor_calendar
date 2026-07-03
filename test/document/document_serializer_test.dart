import 'package:firstfloor_calendar/firstfloor_calendar.dart';
import 'package:test/test.dart';

void main() {
  String crlf(String value) => value.replaceAll('\n', '\r\n');

  group('Document serialization', () {
    test('serializes a simple component with CRLF line endings', () {
      final component = DocumentParser().parseComponent(
        crlf('''
BEGIN:VEVENT
UID:test-event
SUMMARY:Test Event
END:VEVENT'''),
      );

      final serialized = component.toIcsString();

      expect(
        serialized,
        crlf('''
BEGIN:VEVENT
UID:test-event
SUMMARY:Test Event
END:VEVENT
'''),
      );
    });

    test('folds long content lines and remains parseable', () {
      const description =
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
      final component = CalendarDocumentComponent(
        name: 'VEVENT',
        properties: const [
          CalendarProperty(name: 'UID', value: 'event-1'),
          CalendarProperty(name: 'DESCRIPTION', value: description),
        ],
      );

      final serialized = component.toIcsString();
      final reparsed = DocumentParser().parseComponent(serialized);

      expect(serialized, contains('\r\n '));
      expect(reparsed.value('DESCRIPTION'), description);
    });

    test('can disable line folding for a single property', () {
      final property = CalendarProperty(name: 'DESCRIPTION', value: 'a' * 120);

      final serialized = property.toIcsString(foldLine: false);
      expect(serialized, isNot(contains('\r\n ')));
    });
  });
}
