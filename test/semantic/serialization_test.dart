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
          .parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:evt-1
DTSTAMP:20250703T120000Z
DTSTART;TZID=America/New_York:20250703T090000
SUMMARY:Serialization test
END:VEVENT''');

      final serialized = component.toIcsString();
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
      final calendar = CalendarParser().parseFromString('''
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//firstfloor//serialization//EN
BEGIN:VEVENT
UID:evt-2
DTSTAMP:20250703T120000Z
DTSTART:20250710T100000Z
SUMMARY:Calendar serialization
END:VEVENT
END:VCALENDAR''');

      final serialized = calendar.toIcsString();
      final reparsed = DocumentParser().parse(serialized);

      expect(reparsed.value('VERSION'), '2.0');
      expect(reparsed.value('PRODID'), '-//firstfloor//serialization//EN');
      expect(reparsed.componentsNamed('VEVENT').single.value('UID'), 'evt-2');
    });

    test('preserves UTC date-time values with Z suffix', () {
      final component = CalendarParser()
          .parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:evt-utc
DTSTAMP:20250703T120000Z
DTSTART:20250703T130000Z
DTEND:20250703T140000Z
SUMMARY:UTC serialization
END:VEVENT''');

      final serialized = component.toIcsString();
      final reparsed = DocumentParser().parseComponent(serialized);

      expect(reparsed.value('DTSTART'), '20250703T130000Z');
      expect(reparsed.value('DTEND'), '20250703T140000Z');
      expect(
        reparsed.propertiesNamed('DTSTART').first.parameters['TZID'],
        isNull,
      );
    });

    test('preserves floating local date-time values (without TZID)', () {
      final component = CalendarParser()
          .parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:evt-floating
DTSTAMP:20250703T120000Z
DTSTART:20250703T090000
DTEND:20250703T100000
SUMMARY:Floating serialization
END:VEVENT''');

      final serialized = component.toIcsString();
      final reparsed = DocumentParser().parseComponent(serialized);

      expect(reparsed.value('DTSTART'), '20250703T090000');
      expect(reparsed.value('DTEND'), '20250703T100000');
      expect(
        reparsed.propertiesNamed('DTSTART').first.parameters['TZID'],
        isNull,
      );
    });

    test('preserves TZID parameters on date-time properties', () {
      final component = CalendarParser()
          .parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:evt-tzid
DTSTAMP:20250703T120000Z
DTSTART;TZID=Europe/Amsterdam:20250703T090000
EXDATE;TZID=Europe/Amsterdam:20250710T090000
SUMMARY:TZID serialization
END:VEVENT''');

      final serialized = component.toIcsString();
      final reparsed = DocumentParser().parseComponent(serialized);

      final dtstart = reparsed.propertiesNamed('DTSTART').single;
      final exdate = reparsed.propertiesNamed('EXDATE').single;
      expect(dtstart.parameters['TZID'], ['Europe/Amsterdam']);
      expect(exdate.parameters['TZID'], ['Europe/Amsterdam']);
      expect(dtstart.value, '20250703T090000');
      expect(exdate.value, '20250710T090000');
    });

    test('preserves VALUE=DATE for all-day date values', () {
      final component = CalendarParser()
          .parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:evt-date
DTSTAMP:20250703T120000Z
DTSTART;VALUE=DATE:20250703
DTEND;VALUE=DATE:20250704
SUMMARY:Date-only serialization
END:VEVENT''');

      final serialized = component.toIcsString();
      final reparsed = DocumentParser().parseComponent(serialized);

      final dtstart = reparsed.propertiesNamed('DTSTART').single;
      final dtend = reparsed.propertiesNamed('DTEND').single;
      expect(dtstart.parameters['VALUE'], ['DATE']);
      expect(dtend.parameters['VALUE'], ['DATE']);
      expect(dtstart.value, '20250703');
      expect(dtend.value, '20250704');
    });
  });
}
