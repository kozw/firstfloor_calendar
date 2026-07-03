import 'package:firstfloor_calendar/firstfloor_calendar.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
  });

  group('Semantic serialization', () {
    test('serializes a semantic component back to iCalendar text', () {
      final component = CalendarParser()
          .parseComponentFromString<EventComponent>(
            'BEGIN:VEVENT\r\n'
            'UID:evt-1\r\n'
            'DTSTAMP:20250703T120000Z\r\n'
            'DTSTART;TZID=America/New_York:20250703T090000\r\n'
            'SUMMARY:Serialization test\r\n'
            'END:VEVENT',
          );

      final serialized = component.toICalendarString();
      final reparsed = DocumentParser().parseComponent(serialized);

      expect(serialized, contains('BEGIN:VEVENT\r\n'));
      expect(serialized, contains('END:VEVENT\r\n'));
      expect(reparsed.value('DTSTART'), '20250703T090000');
      expect(reparsed.propertiesNamed('DTSTART').first.parameters['TZID'], [
        'America/New_York',
      ]);
      expect(reparsed.value('SUMMARY'), 'Serialization test');
    });

    test('serializes a semantic calendar with nested components', () {
      final calendar = CalendarParser().parseFromString(
        'BEGIN:VCALENDAR\r\n'
        'VERSION:2.0\r\n'
        'PRODID:-//firstfloor//serialization//EN\r\n'
        'BEGIN:VEVENT\r\n'
        'UID:evt-2\r\n'
        'DTSTAMP:20250703T120000Z\r\n'
        'DTSTART:20250710T100000Z\r\n'
        'SUMMARY:Calendar serialization\r\n'
        'END:VEVENT\r\n'
        'END:VCALENDAR',
      );

      final serialized = calendar.toICalendarString();
      final reparsed = DocumentParser().parse(serialized);

      expect(reparsed.value('VERSION'), '2.0');
      expect(reparsed.value('PRODID'), '-//firstfloor//serialization//EN');
      expect(reparsed.componentsNamed('VEVENT').single.value('UID'), 'evt-2');
    });
  });
}
