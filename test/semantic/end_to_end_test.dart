import 'dart:io';

import 'package:firstfloor_calendar/firstfloor_calendar.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
  });

  group('Calendar parsing', () {
    final ics =
        'BEGIN:VCALENDAR\r\n'
        'VERSION:2.0\r\n'
        'PRODID:-//hacksw/handcal//NONSGML v1.0//EN\r\n'
        'X-APPLE-CALENDAR-COLOR:#DC0E0E\r\n'
        'X-FOO:bar\r\n'
        'X-foo:baz\r\n'
        'BEGIN:VEVENT\r\n'
        'UID:19970610T172345Z-AF23B2@example.com\r\n'
        'DTSTAMP:19970610T172345Z\r\n'
        'DTSTART:19970714T170000Z\r\n'
        'DTEND:19970715T040000Z\r\n'
        'SUMMARY:Bastille Day Party\r\n'
        'END:VEVENT\r\n'
        'END:VCALENDAR';

    test('Parse formula 2025 file', () async {
      final file = File('test/resources/calendar-formula-2025.ics');
      final parser = CalendarParser();
      final calendar = parser.parseFromString(await file.readAsString());

      expect(calendar.prodid, 'RacingNews365 2025');
      expect(calendar.version, '2.0');
      expect(calendar.properties.length, 8);
      expect(calendar.timezones.length, 1);
      expect(calendar.events.length, 120);
    });

    test('Parsing calendar properties', () {
      final parser = CalendarParser();
      final calendar = parser.parseFromString(ics);

      expect(calendar.version, '2.0');
      expect(calendar.prodid, '-//hacksw/handcal//NONSGML v1.0//EN');
      expect(calendar.calscale, "GREGORIAN");
      expect(calendar.method, isNull);

      expect(calendar.value('VERSION'), '2.0');
      expect(calendar.properties['VERSION']?.first.property.value, '2.0');
    });

    test('Parsing event in calendar', () {
      final calendar = CalendarParser().parseFromString(ics);
      final event = calendar.events.first;
      expect(event.uid, '19970610T172345Z-AF23B2@example.com');
      expect(event.dtstamp, CalDateTime.utc(1997, 6, 10, 17, 23, 45));
      expect(event.dtstart, CalDateTime.utc(1997, 7, 14, 17));
      expect(event.dtend, CalDateTime.utc(1997, 7, 15, 4));
      expect(event.summary, 'Bastille Day Party');
    });
  });

  group('Component parsing', () {
    test('Parse VEVENT example 1', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:19970901T130000Z-123401@example.com\r\n'
        'DTSTAMP:19970901T130000Z\r\n'
        'DTSTART:19970903T163000Z\r\n'
        'DTEND:19970903T190000Z\r\n'
        'SUMMARY:Annual Employee Review\r\n'
        'CLASS:PRIVATE\r\n'
        'CATEGORIES:BUSINESS,HUMAN RESOURCES\r\n'
        'END:VEVENT',
      );

      expect(event.uid, '19970901T130000Z-123401@example.com');
      expect(event.dtstamp, CalDateTime.utc(1997, 9, 1, 13));
      expect(event.dtstart, CalDateTime.utc(1997, 9, 3, 16, 30));
      expect(event.dtend, CalDateTime.utc(1997, 9, 3, 19));
      expect(event.summary, 'Annual Employee Review');
      expect(event.classification, Classification.private);
      expect(event.categories, ['BUSINESS', 'HUMAN RESOURCES']);
    });

    test('Parse VEVENT example 2', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:19970901T130000Z-123402@example.com\r\n'
        'DTSTAMP:19970901T130000Z\r\n'
        'DTSTART:19970401T163000Z\r\n'
        'DTEND:19970402T010000Z\r\n'
        'SUMMARY:Laurel is in sensitivity awareness class.\r\n'
        'CLASS:PUBLIC\r\n'
        'CATEGORIES:BUSINESS,HUMAN RESOURCES\r\n'
        'TRANSP:TRANSPARENT\r\n'
        'END:VEVENT',
      );
      expect(event.uid, '19970901T130000Z-123402@example.com');
      expect(event.dtstamp, CalDateTime.utc(1997, 9, 1, 13));
      expect(event.dtstart, CalDateTime.utc(1997, 4, 1, 16, 30));
      expect(event.dtend, CalDateTime.utc(1997, 4, 2, 1));
      expect(event.summary, 'Laurel is in sensitivity awareness class.');
      expect(event.classification, Classification.public);
      expect(event.categories, ['BUSINESS', 'HUMAN RESOURCES']);
      expect(event.transp, TimeTransparency.transparent);
    });

    test('Parse VEVENT example 3', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:19970901T130000Z-123403@example.com\r\n'
        'DTSTAMP:19970901T130000Z\r\n'
        'DTSTART;VALUE=DATE:19971102\r\n'
        'SUMMARY:Our Blissful Anniversary\r\n'
        'TRANSP:TRANSPARENT\r\n'
        'CLASS:CONFIDENTIAL\r\n'
        'CATEGORIES:ANNIVERSARY,PERSONAL,SPECIAL OCCASION\r\n'
        'RRULE:FREQ=YEARLY\r\n'
        'END:VEVENT',
      );
      expect(event.uid, '19970901T130000Z-123403@example.com');
      expect(event.dtstamp, CalDateTime.utc(1997, 9, 1, 13));
      expect(event.dtstart, CalDateTime.date(1997, 11, 2));
      expect(event.summary, 'Our Blissful Anniversary');
      expect(event.transp, TimeTransparency.transparent);
      expect(event.classification, Classification.confidential);
      expect(event.categories, ['ANNIVERSARY', 'PERSONAL', 'SPECIAL OCCASION']);
      expect(event.rrule?.freq, RecurrenceFrequency.yearly);
    });

    test('Parse VEVENT example 4', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:20070423T123432Z-541111@example.com\r\n'
        'DTSTAMP:20070423T123432Z\r\n'
        'DTSTART;VALUE=DATE:20070628\r\n'
        'DTEND;VALUE=DATE:20070709\r\n'
        'SUMMARY:Festival International de Jazz de Montreal\r\n'
        'TRANSP:TRANSPARENT\r\n'
        'END:VEVENT',
      );

      expect(event.uid, '20070423T123432Z-541111@example.com');
      expect(event.dtstamp, CalDateTime.utc(2007, 4, 23, 12, 34, 32));
      expect(event.dtstart, CalDateTime.date(2007, 6, 28));
      expect(event.dtend, CalDateTime.date(2007, 7, 9));
      expect(event.summary, 'Festival International de Jazz de Montreal');
      expect(event.transp, TimeTransparency.transparent);
    });

    test('Parse VTODO example 1', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>(
        'BEGIN:VTODO\r\n'
        'UID:20070313T123432Z-456553@example.com\r\n'
        'DTSTAMP:20070313T123432Z\r\n'
        'DUE;VALUE=DATE:20070501\r\n'
        'SUMMARY:Submit Quebec Income Tax Return for 2006\r\n'
        'CLASS:CONFIDENTIAL\r\n'
        'CATEGORIES:FAMILY,FINANCE\r\n'
        'STATUS:NEEDS-ACTION\r\n'
        'END:VTODO',
      );
      expect(todo.uid, '20070313T123432Z-456553@example.com');
      expect(todo.dtstamp, CalDateTime.utc(2007, 3, 13, 12, 34, 32));
      expect(todo.due, CalDateTime.date(2007, 5, 1));
      expect(todo.summary, 'Submit Quebec Income Tax Return for 2006');
      expect(todo.classification, Classification.confidential);
      expect(todo.categories, ['FAMILY', 'FINANCE']);
      expect(todo.status, TodoStatus.needsAction);
    });

    test('Parse VTODO example 2', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>(
        'BEGIN:VTODO\r\n'
        'UID:20070514T103211Z-123404@example.com\r\n'
        'DTSTAMP:20070514T103211Z\r\n'
        'DTSTART:20070514T110000Z\r\n'
        'DUE:20070709T130000Z\r\n'
        'COMPLETED:20070707T100000Z\r\n'
        'SUMMARY:Submit Revised Internet-Draft\r\n'
        'PRIORITY:1\r\n'
        'STATUS:NEEDS-ACTION\r\n'
        'END:VTODO\r\n',
      );
      expect(todo.uid, '20070514T103211Z-123404@example.com');
      expect(todo.dtstamp, CalDateTime.utc(2007, 5, 14, 10, 32, 11));
      expect(todo.dtstart, CalDateTime.utc(2007, 5, 14, 11));
      expect(todo.due, CalDateTime.utc(2007, 7, 9, 13));
      expect(todo.completed, CalDateTime.utc(2007, 7, 7, 10));
      expect(todo.summary, 'Submit Revised Internet-Draft');
      expect(todo.priority, 1);
      expect(todo.status, TodoStatus.needsAction);
    });

    test('Parse VJOURNAL example', () {
      final parser = CalendarParser();
      final journal = parser.parseComponentFromString<JournalComponent>(
        'BEGIN:VJOURNAL\r\n'
        'UID:19970901T130000Z-123405@example.com\r\n'
        'DTSTAMP:19970901T130000Z\r\n'
        'DTSTART;VALUE=DATE:19970317\r\n'
        'SUMMARY:Staff meeting minutes\r\n'
        'DESCRIPTION:1. Staff meeting: Participants include Joe\\,\r\n'
        '  Lisa\\, and Bob. Aurora project plans were reviewed.\r\n'
        '  There is currently no budget reserves for this project.\r\n'
        '  Lisa will escalate to management. Next meeting on Tuesday.\\n\r\n'
        ' 2. Telephone Conference: ABC Corp. sales representative\r\n'
        '  called to discuss new printer. Promised to get us a demo by\r\n'
        '  Friday.\\n3. Henry Miller (Handsoff Insurance): Car was\r\n'
        '  totaled by tree. Is looking into a loaner car. 555-2323\r\n'
        '  (tel).\r\n'
        'END:VJOURNAL\r\n',
      );

      expect(journal.uid, '19970901T130000Z-123405@example.com');
      expect(journal.dtstamp, CalDateTime.utc(1997, 9, 1, 13));
      expect(journal.dtstart, CalDateTime.date(1997, 3, 17));
      expect(journal.summary, 'Staff meeting minutes');
      expect(
        journal.descriptions.first,
        '1. Staff meeting: Participants include Joe, Lisa, and Bob. Aurora project plans were reviewed. There is currently no budget reserves for this project. Lisa will escalate to management. Next meeting on Tuesday.\n'
        '2. Telephone Conference: ABC Corp. sales representative called to discuss new printer. Promised to get us a demo by Friday.\n'
        '3. Henry Miller (Handsoff Insurance): Car was totaled by tree. Is looking into a loaner car. 555-2323 (tel).',
      );
    });

    test('Parse VFREEBUSY example 1', () {
      final parser = CalendarParser();
      final freebusy = parser.parseComponentFromString<FreeBusyComponent>(
        'BEGIN:VFREEBUSY\r\n'
        'UID:19970901T082949Z-FA43EF@example.com\r\n'
        'ORGANIZER:mailto:jane_doe@example.com\r\n'
        'ATTENDEE:mailto:john_public@example.com\r\n'
        'DTSTART:19971015T050000Z\r\n'
        'DTEND:19971016T050000Z\r\n'
        'DTSTAMP:19970901T083000Z\r\n'
        'END:VFREEBUSY\r\n',
      );
      expect(freebusy.uid, '19970901T082949Z-FA43EF@example.com');
      expect(freebusy.organizer, isNotNull);
      expect(freebusy.organizer!.address, 'mailto:jane_doe@example.com');
      expect(freebusy.attendees, isNotEmpty);
      expect(
        freebusy.attendees.first.address,
        'mailto:john_public@example.com',
      );
      expect(freebusy.dtstart, CalDateTime.utc(1997, 10, 15, 5));
      expect(freebusy.dtend, CalDateTime.utc(1997, 10, 16, 5));
      expect(freebusy.dtstamp, CalDateTime.utc(1997, 9, 1, 8, 30));
    });

    test('Parse VFREEBUSY example 2', () {
      final parser = CalendarParser();
      final freebusy = parser.parseComponentFromString<FreeBusyComponent>(
        'BEGIN:VFREEBUSY\r\n'
        'UID:19970901T095957Z-76A912@example.com\r\n'
        'ORGANIZER:mailto:jane_doe@example.com\r\n'
        'ATTENDEE:mailto:john_public@example.com\r\n'
        'DTSTAMP:19970901T100000Z\r\n'
        'FREEBUSY:19971015T050000Z/PT8H30M,\r\n'
        ' 19971015T160000Z/PT5H30M,19971015T223000Z/PT6H30M\r\n'
        'URL:http://example.com/pub/busy/jpublic-01.ifb\r\n'
        'COMMENT:This iCalendar file contains busy time information for\r\n'
        '  the next three months.\r\n'
        'END:VFREEBUSY\r\n',
      );

      expect(freebusy.uid, '19970901T095957Z-76A912@example.com');
      expect(freebusy.organizer, isNotNull);
      expect(freebusy.organizer!.address, 'mailto:jane_doe@example.com');
      expect(freebusy.attendees, isNotEmpty);
      expect(
        freebusy.attendees.first.address,
        'mailto:john_public@example.com',
      );
      expect(freebusy.dtstamp, CalDateTime.utc(1997, 9, 1, 10));
      expect(freebusy.freebusy.map((f) => f.toString()), [
        '19971015T050000Z/PT8H30M',
        '19971015T160000Z/PT5H30M',
        '19971015T223000Z/PT6H30M',
      ]);
      expect(
        freebusy.url.toString(),
        'http://example.com/pub/busy/jpublic-01.ifb',
      );
      expect(freebusy.comments, [
        'This iCalendar file contains busy time information for the next three months.',
      ]);
    });

    test('Parse VFREEBUSY example 3', () {
      final parser = CalendarParser();
      final freebusy = parser.parseComponentFromString<FreeBusyComponent>(
        'BEGIN:VFREEBUSY\r\n'
        'UID:19970901T115957Z-76A912@example.com\r\n'
        'DTSTAMP:19970901T120000Z\r\n'
        'ORGANIZER:jsmith@example.com\r\n'
        'DTSTART:19980313T141711Z\r\n'
        'DTEND:19980410T141711Z\r\n'
        'FREEBUSY:19980314T233000Z/19980315T003000Z\r\n'
        'FREEBUSY:19980316T153000Z/19980316T163000Z\r\n'
        'FREEBUSY:19980318T030000Z/19980318T040000Z\r\n'
        'URL:http://www.example.com/calendar/busytime/jsmith.ifb\r\n'
        'END:VFREEBUSY\r\n',
      );

      expect(freebusy.uid, '19970901T115957Z-76A912@example.com');
      expect(freebusy.dtstamp, CalDateTime.utc(1997, 9, 1, 12));
      expect(freebusy.organizer, isNotNull);
      expect(freebusy.organizer!.address, 'jsmith@example.com');
      expect(freebusy.dtstart, CalDateTime.utc(1998, 3, 13, 14, 17, 11));
      expect(freebusy.dtend, CalDateTime.utc(1998, 4, 10, 14, 17, 11));
      expect(freebusy.freebusy.map((f) => f.toString()), [
        '19980314T233000Z/19980315T003000Z',
        '19980316T153000Z/19980316T163000Z',
        '19980318T030000Z/19980318T040000Z',
      ]);
      expect(
        freebusy.url.toString(),
        'http://www.example.com/calendar/busytime/jsmith.ifb',
      );
    });

    test('Parse VTIMEZONE example 1', () {
      final parser = CalendarParser();
      final timezone = parser.parseComponentFromString<TimeZoneComponent>(
        'BEGIN:VTIMEZONE\r\n'
        'TZID:America/New_York\r\n'
        'LAST-MODIFIED:20050809T050000Z\r\n'
        'BEGIN:DAYLIGHT\r\n'
        'DTSTART:19670430T020000\r\n'
        'RRULE:FREQ=YEARLY;BYMONTH=4;BYDAY=-1SU;UNTIL=19730429T070000Z\r\n'
        'TZOFFSETFROM:-0500\r\n'
        'TZOFFSETTO:-0400\r\n'
        'TZNAME:EDT\r\n'
        'END:DAYLIGHT\r\n'
        'BEGIN:STANDARD\r\n'
        'DTSTART:19671029T020000\r\n'
        'RRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU;UNTIL=20061029T060000Z\r\n'
        'TZOFFSETFROM:-0400\r\n'
        'TZOFFSETTO:-0500\r\n'
        'TZNAME:EST\r\n'
        'END:STANDARD\r\n'
        'BEGIN:DAYLIGHT\r\n'
        'DTSTART:19740106T020000\r\n'
        'RDATE:19750223T020000\r\n'
        'TZOFFSETFROM:-0500\r\n'
        'TZOFFSETTO:-0400\r\n'
        'TZNAME:EDT\r\n'
        'END:DAYLIGHT\r\n'
        'BEGIN:DAYLIGHT\r\n'
        'DTSTART:19760425T020000\r\n'
        'RRULE:FREQ=YEARLY;BYMONTH=4;BYDAY=-1SU;UNTIL=19860427T070000Z\r\n'
        'TZOFFSETFROM:-0500\r\n'
        'TZOFFSETTO:-0400\r\n'
        'TZNAME:EDT\r\n'
        'END:DAYLIGHT\r\n'
        'BEGIN:DAYLIGHT\r\n'
        'DTSTART:19870405T020000\r\n'
        'RRULE:FREQ=YEARLY;BYMONTH=4;BYDAY=1SU;UNTIL=20060402T070000Z\r\n'
        'TZOFFSETFROM:-0500\r\n'
        'TZOFFSETTO:-0400\r\n'
        'TZNAME:EDT\r\n'
        'END:DAYLIGHT\r\n'
        'BEGIN:DAYLIGHT\r\n'
        'DTSTART:20070311T020000\r\n'
        'RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=2SU\r\n'
        'TZOFFSETFROM:-0500\r\n'
        'TZOFFSETTO:-0400\r\n'
        'TZNAME:EDT\r\n'
        'END:DAYLIGHT\r\n'
        'BEGIN:STANDARD\r\n'
        'DTSTART:20071104T020000\r\n'
        'RRULE:FREQ=YEARLY;BYMONTH=11;BYDAY=1SU\r\n'
        'TZOFFSETFROM:-0400\r\n'
        'TZOFFSETTO:-0500\r\n'
        'TZNAME:EST\r\n'
        'END:STANDARD\r\n'
        'END:VTIMEZONE\r\n',
      );

      expect(timezone.tzid, 'America/New_York');
      expect(timezone.lastModified, CalDateTime.utc(2005, 8, 9, 5));
      expect(timezone.daylight.length, 5);
      expect(timezone.standard.length, 2);

      expect(timezone.daylight[0].dtstart, CalDateTime.local(1967, 4, 30, 2));
      expect(
        timezone.daylight[0].rrule,
        // FREQ=YEARLY;BYMONTH=4;BYDAY=-1SU;UNTIL=19730429T070000Z
        RecurrenceRule(
          freq: RecurrenceFrequency.yearly,
          byMonth: {4},
          byDay: {ByDay(Weekday.su, ordinal: -1)},
          until: CalDateTime.utc(1973, 4, 29, 7),
        ),
      );
      expect(
        timezone.daylight[0].tzoffsetFrom,
        UtcOffset(sign: Sign.negative, hours: 5, minutes: 0),
      );
      expect(
        timezone.daylight[0].tzoffsetTo,
        UtcOffset(sign: Sign.negative, hours: 4, minutes: 0),
      );
      expect(timezone.daylight[0].tznames, ['EDT']);
      expect(timezone.standard[0].dtstart, CalDateTime.local(1967, 10, 29, 2));
      expect(
        timezone.standard[0].rrule,
        // FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU;UNTIL=20061029T060000Z
        RecurrenceRule(
          freq: RecurrenceFrequency.yearly,
          byMonth: {10},
          byDay: {ByDay(Weekday.su, ordinal: -1)},
          until: CalDateTime.utc(2006, 10, 29, 6),
        ),
      );
      expect(
        timezone.standard[0].tzoffsetFrom,
        UtcOffset(sign: Sign.negative, hours: 4, minutes: 0),
      );
      expect(
        timezone.standard[0].tzoffsetTo,
        UtcOffset(sign: Sign.negative, hours: 5, minutes: 0),
      );
      expect(timezone.standard[0].tznames, ['EST']);
    });

    test('Parse VTIMEZONE example 2', () {
      final parser = CalendarParser();
      final timezone = parser.parseComponentFromString<TimeZoneComponent>(
        'BEGIN:VTIMEZONE\r\n'
        'TZID:America/New_York\r\n'
        'LAST-MODIFIED:20050809T050000Z\r\n'
        'BEGIN:STANDARD\r\n'
        'DTSTART:20071104T020000\r\n'
        'TZOFFSETFROM:-0400\r\n'
        'TZOFFSETTO:-0500\r\n'
        'TZNAME:EST\r\n'
        'END:STANDARD\r\n'
        'BEGIN:DAYLIGHT\r\n'
        'DTSTART:20070311T020000\r\n'
        'TZOFFSETFROM:-0500\r\n'
        'TZOFFSETTO:-0400\r\n'
        'TZNAME:EDT\r\n'
        'END:DAYLIGHT\r\n'
        'END:VTIMEZONE\r\n',
      );

      expect(timezone.tzid, 'America/New_York');
      expect(timezone.lastModified, CalDateTime.utc(2005, 8, 9, 5));
      expect(timezone.daylight.length, 1);
      expect(timezone.standard.length, 1);
      expect(timezone.daylight[0].dtstart, CalDateTime.local(2007, 3, 11, 2));
      expect(
        timezone.daylight[0].tzoffsetFrom,
        UtcOffset(sign: Sign.negative, hours: 5, minutes: 0),
      );
      expect(
        timezone.daylight[0].tzoffsetTo,
        UtcOffset(sign: Sign.negative, hours: 4, minutes: 0),
      );
      expect(timezone.daylight[0].tznames, ['EDT']);
      expect(timezone.standard[0].dtstart, CalDateTime.local(2007, 11, 4, 2));
      expect(
        timezone.standard[0].tzoffsetFrom,
        UtcOffset(sign: Sign.negative, hours: 4, minutes: 0),
      );
      expect(
        timezone.standard[0].tzoffsetTo,
        UtcOffset(sign: Sign.negative, hours: 5, minutes: 0),
      );
      expect(timezone.standard[0].tznames, ['EST']);
    });

    test('Parse VTIMEZONE example 3', () {
      final parser = CalendarParser();
      final timezone = parser.parseComponentFromString<TimeZoneComponent>(
        'BEGIN:VTIMEZONE\r\n'
        'TZID:America/New_York\r\n'
        'LAST-MODIFIED:20050809T050000Z\r\n'
        'TZURL:http://zones.example.com/tz/America-New_York.ics\r\n'
        'BEGIN:STANDARD\r\n'
        'DTSTART:20071104T020000\r\n'
        'RRULE:FREQ=YEARLY;BYMONTH=11;BYDAY=1SU\r\n'
        'TZOFFSETFROM:-0400\r\n'
        'TZOFFSETTO:-0500\r\n'
        'TZNAME:EST\r\n'
        'END:STANDARD\r\n'
        'BEGIN:DAYLIGHT\r\n'
        'DTSTART:20070311T020000\r\n'
        'RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=2SU\r\n'
        'TZOFFSETFROM:-0500\r\n'
        'TZOFFSETTO:-0400\r\n'
        'TZNAME:EDT\r\n'
        'END:DAYLIGHT\r\n'
        'END:VTIMEZONE\r\n',
      );

      expect(timezone.tzid, 'America/New_York');
      expect(timezone.lastModified, CalDateTime.utc(2005, 8, 9, 5));
      expect(
        timezone.tzurl.toString(),
        'http://zones.example.com/tz/America-New_York.ics',
      );
      expect(timezone.daylight.length, 1);
      expect(timezone.standard.length, 1);
      expect(timezone.daylight[0].dtstart, CalDateTime.local(2007, 3, 11, 2));
      expect(
        timezone.daylight[0].rrule,
        // FREQ=YEARLY;BYMONTH=3;BYDAY=2SU
        RecurrenceRule(
          freq: RecurrenceFrequency.yearly,
          byMonth: {3},
          byDay: {ByDay(Weekday.su, ordinal: 2)},
        ),
      );
      expect(
        timezone.daylight[0].tzoffsetFrom,
        UtcOffset(sign: Sign.negative, hours: 5, minutes: 0),
      );
      expect(
        timezone.daylight[0].tzoffsetTo,
        UtcOffset(sign: Sign.negative, hours: 4, minutes: 0),
      );
      expect(timezone.daylight[0].tznames, ['EDT']);
      expect(timezone.standard[0].dtstart, CalDateTime.local(2007, 11, 4, 2));
      expect(
        timezone.standard[0].rrule,
        // FREQ=YEARLY;BYMONTH=11;BYDAY=1SU
        RecurrenceRule(
          freq: RecurrenceFrequency.yearly,
          byMonth: {11},
          byDay: {ByDay(Weekday.su, ordinal: 1)},
        ),
      );
      expect(
        timezone.standard[0].tzoffsetFrom,
        UtcOffset(sign: Sign.negative, hours: 4, minutes: 0),
      );
      expect(
        timezone.standard[0].tzoffsetTo,
        UtcOffset(sign: Sign.negative, hours: 5, minutes: 0),
      );
      expect(timezone.standard[0].tznames, ['EST']);
    });

    test('Parse VTIMEZONE example 4', () {
      final parser = CalendarParser();
      final timezone = parser.parseComponentFromString<TimeZoneComponent>(
        'BEGIN:VTIMEZONE\r\n'
        'TZID:Fictitious\r\n'
        'LAST-MODIFIED:19870101T000000Z\r\n'
        'BEGIN:STANDARD\r\n'
        'DTSTART:19671029T020000\r\n'
        'RRULE:FREQ=YEARLY;BYDAY=-1SU;BYMONTH=10\r\n'
        'TZOFFSETFROM:-0400\r\n'
        'TZOFFSETTO:-0500\r\n'
        'TZNAME:EST\r\n'
        'END:STANDARD\r\n'
        'BEGIN:DAYLIGHT\r\n'
        'DTSTART:19870405T020000\r\n'
        'RRULE:FREQ=YEARLY;BYDAY=1SU;BYMONTH=4;UNTIL=19980404T070000Z\r\n'
        'TZOFFSETFROM:-0500\r\n'
        'TZOFFSETTO:-0400\r\n'
        'TZNAME:EDT\r\n'
        'END:DAYLIGHT\r\n'
        'END:VTIMEZONE\r\n',
      );

      expect(timezone.tzid, 'Fictitious');
      expect(timezone.lastModified, CalDateTime.utc(1987, 1, 1));
      expect(timezone.daylight.length, 1);
      expect(timezone.standard.length, 1);
      expect(timezone.daylight[0].dtstart, CalDateTime.local(1987, 4, 5, 2));
      expect(
        timezone.daylight[0].rrule,
        // FREQ=YEARLY;BYDAY=1SU;BYMONTH=4;UNTIL=19980404T070000Z
        RecurrenceRule(
          freq: RecurrenceFrequency.yearly,
          byMonth: {4},
          byDay: {ByDay(Weekday.su, ordinal: 1)},
          until: CalDateTime.utc(1998, 4, 4, 7),
        ),
      );
      expect(
        timezone.daylight[0].tzoffsetFrom,
        UtcOffset(sign: Sign.negative, hours: 5, minutes: 0),
      );
      expect(
        timezone.daylight[0].tzoffsetTo,
        UtcOffset(sign: Sign.negative, hours: 4, minutes: 0),
      );
      expect(timezone.daylight[0].tznames, ['EDT']);
      expect(timezone.standard[0].dtstart, CalDateTime.local(1967, 10, 29, 2));
      expect(
        timezone.standard[0].rrule,
        // FREQ=YEARLY;BYDAY=-1SU;BYMONTH=10
        RecurrenceRule(
          freq: RecurrenceFrequency.yearly,
          byMonth: {10},
          byDay: {ByDay(Weekday.su, ordinal: -1)},
        ),
      );
      expect(
        timezone.standard[0].tzoffsetFrom,
        UtcOffset(sign: Sign.negative, hours: 4, minutes: 0),
      );
      expect(
        timezone.standard[0].tzoffsetTo,
        UtcOffset(sign: Sign.negative, hours: 5, minutes: 0),
      );
      expect(timezone.standard[0].tznames, ['EST']);
    });

    test('Parse VTIMEZONE example 5', () {
      final parser = CalendarParser();
      final timezone = parser.parseComponentFromString<TimeZoneComponent>(
        'BEGIN:VTIMEZONE\r\n'
        'TZID:Fictitious\r\n'
        'LAST-MODIFIED:19870101T000000Z\r\n'
        'BEGIN:STANDARD\r\n'
        'DTSTART:19671029T020000\r\n'
        'RRULE:FREQ=YEARLY;BYDAY=-1SU;BYMONTH=10\r\n'
        'TZOFFSETFROM:-0400\r\n'
        'TZOFFSETTO:-0500\r\n'
        'TZNAME:EST\r\n'
        'END:STANDARD\r\n'
        'BEGIN:DAYLIGHT\r\n'
        'DTSTART:19870405T020000\r\n'
        'RRULE:FREQ=YEARLY;BYDAY=1SU;BYMONTH=4;UNTIL=19980404T070000Z\r\n'
        'TZOFFSETFROM:-0500\r\n'
        'TZOFFSETTO:-0400\r\n'
        'TZNAME:EDT\r\n'
        'END:DAYLIGHT\r\n'
        'BEGIN:DAYLIGHT\r\n'
        'DTSTART:19990424T020000\r\n'
        'RRULE:FREQ=YEARLY;BYDAY=-1SU;BYMONTH=4\r\n'
        'TZOFFSETFROM:-0500\r\n'
        'TZOFFSETTO:-0400\r\n'
        'TZNAME:EDT\r\n'
        'END:DAYLIGHT\r\n'
        'END:VTIMEZONE\r\n',
      );

      expect(timezone.tzid, 'Fictitious');
      expect(timezone.lastModified, CalDateTime.utc(1987, 1, 1));
      expect(timezone.daylight.length, 2);
      expect(timezone.standard.length, 1);
      expect(timezone.daylight[0].dtstart, CalDateTime.local(1987, 4, 5, 2));
      expect(
        timezone.daylight[0].rrule,
        // FREQ=YEARLY;BYDAY=1SU;BYMONTH=4;UNTIL=19980404T070000Z
        RecurrenceRule(
          freq: RecurrenceFrequency.yearly,
          byMonth: {4},
          byDay: {ByDay(Weekday.su, ordinal: 1)},
          until: CalDateTime.utc(1998, 4, 4, 7),
        ),
      );
      expect(
        timezone.daylight[0].tzoffsetFrom,
        UtcOffset(sign: Sign.negative, hours: 5, minutes: 0),
      );
      expect(
        timezone.daylight[0].tzoffsetTo,
        UtcOffset(sign: Sign.negative, hours: 4, minutes: 0),
      );
      expect(timezone.daylight[0].tznames, ['EDT']);
      expect(timezone.standard[0].dtstart, CalDateTime.local(1967, 10, 29, 2));
      expect(
        timezone.standard[0].rrule,
        // FREQ=YEARLY;BYDAY=-1SU;BYMONTH=10
        RecurrenceRule(
          freq: RecurrenceFrequency.yearly,
          byMonth: {10},
          byDay: {ByDay(Weekday.su, ordinal: -1)},
        ),
      );
      expect(
        timezone.standard[0].tzoffsetFrom,
        UtcOffset(sign: Sign.negative, hours: 4, minutes: 0),
      );
      expect(
        timezone.standard[0].tzoffsetTo,
        UtcOffset(sign: Sign.negative, hours: 5, minutes: 0),
      );
      expect(timezone.standard[0].tznames, ['EST']);
      expect(timezone.daylight[1].dtstart, CalDateTime.local(1999, 4, 24, 2));
      expect(
        timezone.daylight[1].rrule,
        //FREQ=YEARLY;BYDAY=-1SU;BYMONTH=4'
        RecurrenceRule(
          freq: RecurrenceFrequency.yearly,
          byMonth: {4},
          byDay: {ByDay(Weekday.su, ordinal: -1)},
        ),
      );
      expect(
        timezone.daylight[1].tzoffsetFrom,
        UtcOffset(sign: Sign.negative, hours: 5, minutes: 0),
      );
      expect(
        timezone.daylight[1].tzoffsetTo,
        UtcOffset(sign: Sign.negative, hours: 4, minutes: 0),
      );
      expect(timezone.daylight[1].tznames, ['EDT']);
    });

    test('Parse VALARM example 1', () {
      final parser = CalendarParser();
      final alarm = parser.parseComponentFromString<AlarmComponent>(
        'BEGIN:VALARM\r\n'
        'TRIGGER;VALUE=DATE-TIME:19970317T133000Z\r\n'
        'REPEAT:4\r\n'
        'DURATION:PT15M\r\n'
        'ACTION:AUDIO\r\n'
        'ATTACH;FMTTYPE=audio/basic:ftp://example.com/pub/\r\n'
        ' sounds/bell-01.aud\r\n'
        'END:VALARM\r\n',
      );

      expect(alarm.trigger.dateTime, CalDateTime.utc(1997, 3, 17, 13, 30));
      expect(alarm.repeat, 4);
      expect(alarm.duration, CalDuration(minutes: 15));
      expect(alarm.action, AlarmAction.audio);

      final attachment = alarm.attachments.firstOrNull as AttachmentUri?;
      expect(attachment, isNotNull);
      expect(attachment!.fmtType, 'audio/basic');
      expect(
        attachment.uri,
        Uri.parse('ftp://example.com/pub/sounds/bell-01.aud'),
      );
    });

    test('Parse VALARM example 2', () {
      final parser = CalendarParser();
      final alarm = parser.parseComponentFromString<AlarmComponent>(
        'BEGIN:VALARM\r\n'
        'TRIGGER:-PT30M\r\n'
        'REPEAT:2\r\n'
        'DURATION:PT15M\r\n'
        'ACTION:DISPLAY\r\n'
        'DESCRIPTION:Breakfast meeting with executive\n'
        '  team at 8:30 AM EST.\r\n'
        'END:VALARM\r\n',
      );
      expect(
        alarm.trigger.duration,
        CalDuration(sign: Sign.negative, minutes: 30),
      );
      expect(alarm.repeat, 2);
      expect(alarm.duration, CalDuration(minutes: 15));
      expect(alarm.action, AlarmAction.display);
      expect(
        alarm.description,
        'Breakfast meeting with executive team at 8:30 AM EST.',
      );
    });

    test('Parse VALARM example 3', () {
      final parser = CalendarParser();
      final alarm = parser.parseComponentFromString<AlarmComponent>(
        'BEGIN:VALARM\r\n'
        'TRIGGER;RELATED=END:-P2D\r\n'
        'ACTION:EMAIL\r\n'
        'ATTENDEE:mailto:john_doe@example.com\r\n'
        'SUMMARY:*** REMINDER: SEND AGENDA FOR WEEKLY STAFF MEETING ***\r\n'
        'DESCRIPTION:A draft agenda needs to be sent out to the attendees\r\n'
        '  to the weekly managers meeting (MGR-LIST). Attached is a\r\n'
        '  pointer the document template for the agenda file.\r\n'
        'ATTACH;FMTTYPE=application/msword:http://example.com/\r\n'
        ' templates/agenda.doc\r\n'
        'END:VALARM\r\n',
      );

      expect(alarm.trigger.duration, CalDuration(sign: Sign.negative, days: 2));
      expect(alarm.trigger.related, TriggerRelated.end);
      expect(alarm.trigger.relatedName, 'END');
      expect(alarm.action, AlarmAction.email);
      expect(alarm.attendees, isNotEmpty);
      expect(alarm.attendees.first.address, 'mailto:john_doe@example.com');
      expect(
        alarm.summary,
        '*** REMINDER: SEND AGENDA FOR WEEKLY STAFF MEETING ***',
      );
      expect(
        alarm.description,
        'A draft agenda needs to be sent out to the attendees to the weekly managers meeting (MGR-LIST). Attached is a pointer the document template for the agenda file.',
      );
      final attachment = alarm.attachments.firstOrNull as AttachmentUri?;
      expect(attachment, isNotNull);
      expect(attachment!.fmtType, 'application/msword');
      expect(
        attachment.uri,
        Uri.parse('http://example.com/templates/agenda.doc'),
      );
    });

    test('Parse multiple CATEGORIES in VEVENT', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:19970901T130000Z-123401@example.com\r\n'
        'DTSTAMP:19970901T130000Z\r\n'
        'DTSTART:19970903T163000Z\r\n'
        'CATEGORIES:BUSINESS,HUMAN RESOURCES\r\n'
        'CATEGORIES:VACATION,NOT IN OFFICE\r\n'
        'END:VEVENT\r\n',
      );

      expect(event.categories, [
        'BUSINESS',
        'HUMAN RESOURCES',
        'VACATION',
        'NOT IN OFFICE',
      ]);
    });
  });

  group('Calendar custom properties', () {
    test('Parsing calendar with required X-CUSTOM-INT rule', () {
      final parser = CalendarParser();
      parser.registerPropertyRule(
        componentName: 'VCALENDAR',
        propertyName: 'X-CUSTOM-INT',
        rule: PropertyRule(minOccurs: 1, parser: parseInteger),
      );
      final calendar = parser.parseFromString(
        'BEGIN:VCALENDAR\r\n'
        'VERSION:2.0\r\n'
        'PRODID:-//hacksw/handcal//NONSGML v1.0//EN\r\n'
        'X-CUSTOM-INT:42\r\n'
        'END:VCALENDAR',
      );

      expect(calendar.properties['X-CUSTOM-INT'], isNotNull);

      final customInt = calendar.value<int>('X-CUSTOM-INT');
      expect(customInt, 42);
    });

    test(
      'Parsing calendar with X-CUSTOM-INT rule that may occur multiple times',
      () {
        final parser = CalendarParser();
        parser.registerPropertyRule(
          componentName: 'VCALENDAR',
          propertyName: 'X-CUSTOM-INT',
          rule: PropertyRule(maxOccurs: -1, parser: parseInteger),
        );
        final calendar = parser.parseFromString(
          'BEGIN:VCALENDAR\r\n'
          'VERSION:2.0\r\n'
          'PRODID:-//hacksw/handcal//NONSGML v1.0//EN\r\n'
          'X-CUSTOM-INT:42\r\n'
          'X-CUSTOM-INT:43\r\n'
          'END:VCALENDAR',
        );

        expect(calendar.properties['X-CUSTOM-INT'], isNotNull);

        final customInts = calendar.values<int>('X-CUSTOM-INT');
        expect(customInts, [42, 43]);
      },
    );

    test(
      'Parsing calendar with required X-CUSTOM-INT rule that may occur multiple times',
      () {
        final parser = CalendarParser();
        parser.registerPropertyRule(
          componentName: 'VCALENDAR',
          propertyName: 'X-CUSTOM-INT',
          rule: PropertyRule(minOccurs: 1, maxOccurs: -1, parser: parseInteger),
        );
        final calendar = parser.parseFromString(
          'BEGIN:VCALENDAR\r\n'
          'VERSION:2.0\r\n'
          'PRODID:-//hacksw/handcal//NONSGML v1.0//EN\r\n'
          'X-CUSTOM-INT:42\r\n'
          'X-CUSTOM-INT:43\r\n'
          'END:VCALENDAR',
        );

        expect(calendar.properties['X-CUSTOM-INT'], isNotNull);

        final customInts = calendar.values<int>('X-CUSTOM-INT');
        expect(customInts, [42, 43]);
      },
    );

    test('Parsing calendar with VTODO X-CUSTOM-INT rule', () {
      final parser = CalendarParser();
      parser.registerPropertyRule(
        componentName: 'VTODO',
        propertyName: 'X-CUSTOM-INT',
        rule: PropertyRule(parser: parseInteger),
      );
      final calendar = parser.parseFromString(
        'BEGIN:VCALENDAR\r\n'
        'VERSION:2.0\r\n'
        'PRODID:-//hacksw/handcal//NONSGML v1.0//EN\r\n'
        'X-CUSTOM-INT:42\r\n'
        'BEGIN:VTODO\r\n'
        'UID:19970901T130000Z-123401@example.com\r\n'
        'DTSTAMP:19970901T130000Z\r\n'
        'X-CUSTOM-INT:42\r\n'
        'END:VTODO\r\n'
        'END:VCALENDAR\r\n',
      );

      // custom property rule not applied to VCALENDAR
      final calendarCustomInt = calendar.value<String>('X-CUSTOM-INT');
      expect(calendarCustomInt, "42");

      // custom property rule is applied to VTODO
      final eventCustomInt = calendar.todos.first.value<int>('X-CUSTOM-INT');
      expect(eventCustomInt, 42);
    });

    test('Parsing calendar with global X-CUSTOM-INT rule', () {
      final parser = CalendarParser();
      parser.registerPropertyRule(
        propertyName: 'X-CUSTOM-INT',
        rule: PropertyRule(parser: parseInteger),
      );
      final calendar = parser.parseFromString(
        'BEGIN:VCALENDAR\r\n'
        'VERSION:2.0\r\n'
        'PRODID:-//hacksw/handcal//NONSGML v1.0//EN\r\n'
        'X-CUSTOM-INT:42\r\n'
        'BEGIN:VTODO\r\n'
        'UID:19970901T130000Z-123401@example.com\r\n'
        'DTSTAMP:19970901T130000Z\r\n'
        'X-CUSTOM-INT:42\r\n'
        'END:VTODO\r\n'
        'END:VCALENDAR\r\n',
      );

      // custom property rule is applied to VCALENDAR
      final calendarCustomInt = calendar.value<int>('X-CUSTOM-INT');
      expect(calendarCustomInt, 42);

      // custom property rule is applied to VTODO
      final eventCustomInt = calendar.todos.first.value<int>('X-CUSTOM-INT');
      expect(eventCustomInt, 42);
    });

    test('Parsing calendar translate VERSION value', () {
      final parser = CalendarParser();
      parser.registerPropertyRule(
        componentName: 'VCALENDAR',
        propertyName: 'VERSION',
        rule: PropertyRule(
          parser: (property) {
            return '!! ${property.value}';
          },
        ),
      );
      final calendar = parser.parseFromString(
        'BEGIN:VCALENDAR\r\n'
        'VERSION:2.0\r\n'
        'PRODID:-//hacksw/handcal//NONSGML v1.0//EN\r\n'
        'END:VCALENDAR\r\n',
      );

      // custom property rule overrides default parser
      expect(calendar.version, '!! 2.0');
    });

    test('Parsing calendar make VERSION optional', () {
      final parser = CalendarParser();
      parser.registerPropertyRule(
        componentName: 'VCALENDAR',
        propertyName: 'VERSION',
        rule: PropertyRule(
          minOccurs: 0,
          parser: (property) {
            return parseString(property);
          },
        ),
      );
      final calendar = parser.parseFromString(
        'BEGIN:VCALENDAR\r\n'
        'PRODID:-//hacksw/handcal//NONSGML v1.0//EN\r\n'
        'END:VCALENDAR\r\n',
      );
      // VERSION is now optional
      expect(calendar.valueOrNull('VERSION'), isNull);

      // accessing non-nullable version should throw StateError
      expect(
        () => calendar.version,
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'No value for "VERSION"',
          ),
        ),
      );
    });

    test('Unknown VCALENDAR property may appear multiple times', () {
      final parser = CalendarParser();

      final calendar = parser.parseFromString(
        'BEGIN:VCALENDAR\r\n'
        'VERSION:2.0\r\n'
        'PRODID:-//hacksw/handcal//NONSGML v1.0//EN\r\n'
        'X-APPLE-CALENDAR-COLOR:#FF0000\r\n'
        'X-APPLE-CALENDAR-COLOR:#00FF00\r\n'
        'X-APPLE-CALENDAR-COLOR:#0000FF\r\n'
        'END:VCALENDAR\r\n',
      );

      // unknown property may appear multiple times
      // it doesn't make sens, but we allow it
      expect(calendar.values('X-APPLE-CALENDAR-COLOR'), [
        '#FF0000',
        '#00FF00',
        '#0000FF',
      ]);
    });

    test('Parsing calendar overriding built-in VERSION with invalid type', () {
      final parser = CalendarParser();
      parser.registerPropertyRule(
        componentName: 'VCALENDAR',
        propertyName: 'VERSION',
        rule: PropertyRule(
          parser: (property) {
            return 2;
          },
        ),
      );
      final calendar = parser.parseFromString(
        'BEGIN:VCALENDAR\r\n'
        'VERSION:2.0\r\n'
        'PRODID:-//hacksw/handcal//NONSGML v1.0//EN\r\n'
        'END:VCALENDAR\r\n',
      );

      // custom property rule overrides default parser
      expect(calendar.value<int>('VERSION'), 2);

      // access as string should throw
      expect(
        () => calendar.version,
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'Property "VERSION" has type int, expected String',
          ),
        ),
      );
    });

    test('Parsing calendar with invalid X-CUSTOM-INT value should throw', () {
      final parser = CalendarParser();
      parser.registerPropertyRule(
        componentName: 'VCALENDAR',
        propertyName: 'X-CUSTOM-INT',
        rule: PropertyRule(parser: parseInteger),
      );
      expect(
        () => parser.parseFromString(
          'BEGIN:VCALENDAR\r\n'
          'VERSION:2.0\r\n'
          'PRODID:-//hacksw/handcal//NONSGML v1.0//EN\r\n'
          'X-CUSTOM-INT:FOO\r\n'
          'END:VCALENDAR',
        ),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Invalid integer value "FOO" [Ln 4]',
          ),
        ),
      );
    });

    test(
      'Parsing calendar with missing required X-CUSTOM-INT property should throw',
      () {
        final parser = CalendarParser();
        parser.registerPropertyRule(
          componentName: 'VCALENDAR',
          propertyName: 'X-CUSTOM-INT',
          rule: PropertyRule(minOccurs: 1, parser: parseString),
        );
        expect(
          () => parser.parseFromString(
            'BEGIN:VCALENDAR\r\n'
            'VERSION:2.0\r\n'
            'PRODID:-//hacksw/handcal//NONSGML v1.0//EN\r\n'
            'END:VCALENDAR',
          ),
          throwsA(
            predicate(
              (e) =>
                  e.toString() ==
                  'ParseException: Property "X-CUSTOM-INT" must occur at least once [Ln 1]',
            ),
          ),
        );
      },
    );

    test(
      'Parsing calendar with multiple X-CUSTOM-INT properties should throw if not allowed',
      () {
        final parser = CalendarParser();
        parser.registerPropertyRule(
          componentName: 'VCALENDAR',
          propertyName: 'X-CUSTOM-INT',
          rule: PropertyRule(parser: parseString),
        );
        expect(
          () => parser.parseFromString(
            'BEGIN:VCALENDAR\r\n'
            'VERSION:2.0\r\n'
            'PRODID:-//hacksw/handcal//NONSGML v1.0//EN\r\n'
            'X-CUSTOM-INT:42\r\n'
            'X-CUSTOM-INT:43\r\n'
            'END:VCALENDAR',
          ),
          throwsA(
            predicate(
              (e) =>
                  e.toString() ==
                  'ParseException: Property "X-CUSTOM-INT" may not occur more than once [Ln 5]',
            ),
          ),
        );
      },
    );
  });

  group('Component parsing errors', () {
    test('Parsing event with invalid GEO property should throw', () {
      final parser = CalendarParser();

      expect(
        () => parser.parseComponentFromString(
          'BEGIN:VEVENT\r\n'
          'GEO:foo\r\n'
          'END:VEVENT',
        ),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: "foo" is not a valid GEO format [Ln 2]',
          ),
        ),
      );
    });
  });
}
