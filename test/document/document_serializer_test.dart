import 'package:firstfloor_calendar/firstfloor_calendar.dart';
import 'package:test/test.dart';

void main() {
  group('Document serialization', () {
    test('serializes a simple component with CRLF line endings', () {
      final component = DocumentParser().parseComponent(
        'BEGIN:VEVENT\r\n'
        'UID:test-event\r\n'
        'SUMMARY:Test Event\r\n'
        'END:VEVENT',
      );

      final serialized = component.toICalendarString();

      expect(
        serialized,
        'BEGIN:VEVENT\r\n'
        'UID:test-event\r\n'
        'SUMMARY:Test Event\r\n'
        'END:VEVENT\r\n',
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

      final serialized = component.toICalendarString();
      final reparsed = DocumentParser().parseComponent(serialized);

      expect(serialized, contains('\r\n '));
      expect(reparsed.value('DESCRIPTION'), description);
    });

    test('can disable line folding for a single property', () {
      final property = CalendarProperty(name: 'DESCRIPTION', value: 'a' * 120);

      final serialized = property.toICalendarString(foldLine: false);
      expect(serialized, isNot(contains('\r\n ')));
    });
  });
}
