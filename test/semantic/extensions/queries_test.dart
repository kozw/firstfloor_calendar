import 'package:firstfloor_calendar/firstfloor_calendar.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
  });
  group('EventIterableQuery.occurrences', () {
    test('returns single non-recurring event within range', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test1
DTSTAMP:20250101T000000Z
DTSTART:20250115T100000
DTEND:20250115T110000
SUMMARY:Test Event
END:VEVENT''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [event].occurrences(start: start, end: end).toList();

      expect(results.length, 1);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 15, 10, 0, 0));
      expect(results[0].event.summary, 'Test Event');
    });

    test('excludes single event before range', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test2
DTSTAMP:20250101T000000Z
DTSTART:20241215T100000
DTEND:20241215T110000
SUMMARY:Past Event
END:VEVENT''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [event].occurrences(start: start, end: end).toList();

      expect(results.length, 0);
    });

    test('excludes single event after range', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test3
DTSTAMP:20250101T000000Z
DTSTART:20250215T100000
DTEND:20250215T110000
SUMMARY:Future Event
END:VEVENT''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [event].occurrences(start: start, end: end).toList();

      expect(results.length, 0);
    });

    test('includes event exactly at range start', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test4
DTSTAMP:20250101T000000Z
DTSTART:20250101T000000
DTEND:20250101T010000
SUMMARY:Start Event
END:VEVENT''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [event].occurrences(start: start, end: end).toList();

      expect(results.length, 1);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 1));
    });

    test('includes event exactly at range end', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test5
DTSTAMP:20250101T000000Z
DTSTART:20250131T235959
DTEND:20250131T235959
SUMMARY:End Event
END:VEVENT''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [event].occurrences(start: start, end: end).toList();

      expect(results.length, 1);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 31, 23, 59, 59));
    });

    test('filters multiple events correctly', () {
      final parser = CalendarParser();
      final events = [
        parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test6
DTSTAMP:20250101T000000Z
DTSTART:20241215T100000
SUMMARY:Before Range
END:VEVENT'''),
        parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test7
DTSTAMP:20250101T000000Z
DTSTART:20250110T100000
SUMMARY:In Range 1
END:VEVENT'''),
        parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test8
DTSTAMP:20250101T000000Z
DTSTART:20250120T100000
SUMMARY:In Range 2
END:VEVENT'''),
        parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test9
DTSTAMP:20250101T000000Z
DTSTART:20250215T100000
SUMMARY:After Range
END:VEVENT'''),
      ];

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = events.occurrences(start: start, end: end).toList();

      expect(results.length, 2);
      expect(results[0].event.summary, 'In Range 1');
      expect(results[1].event.summary, 'In Range 2');
    });

    test('handles recurring event with COUNT', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test10
DTSTAMP:20250101T000000Z
DTSTART:20250105T100000
DTEND:20250105T110000
SUMMARY:Weekly Meeting
RRULE:FREQ=WEEKLY;COUNT=4
END:VEVENT''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [event].occurrences(start: start, end: end).toList();

      expect(results.length, 4);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 5, 10, 0, 0));
      expect(results[1].occurrence, CalDateTime.local(2025, 1, 12, 10, 0, 0));
      expect(results[2].occurrence, CalDateTime.local(2025, 1, 19, 10, 0, 0));
      expect(results[3].occurrence, CalDateTime.local(2025, 1, 26, 10, 0, 0));
    });

    test('handles recurring event with UNTIL', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test11
DTSTAMP:20250101T000000Z
DTSTART:20250105T100000
DTEND:20250105T110000
SUMMARY:Daily Standup
RRULE:FREQ=DAILY;UNTIL=20250110T100000
END:VEVENT''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [event].occurrences(start: start, end: end).toList();

      expect(results.length, 6); // Jan 5-10
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 5, 10, 0, 0));
      expect(results[5].occurrence, CalDateTime.local(2025, 1, 10, 10, 0, 0));
    });

    test('handles recurring event partially in range (starts before)', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test12
DTSTAMP:20250101T000000Z
DTSTART:20241220T100000
DTEND:20241220T110000
SUMMARY:Weekly Team Sync
RRULE:FREQ=WEEKLY;COUNT=5
END:VEVENT''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [event].occurrences(start: start, end: end).toList();

      // Starts Dec 20, 27, Jan 3, 10, 17 - only Jan occurrences
      expect(results.length, 3);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 3, 10, 0, 0));
      expect(results[1].occurrence, CalDateTime.local(2025, 1, 10, 10, 0, 0));
      expect(results[2].occurrence, CalDateTime.local(2025, 1, 17, 10, 0, 0));
    });

    test('handles recurring event partially in range (ends after)', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test13
DTSTAMP:20250101T000000Z
DTSTART:20250120T100000
DTEND:20250120T110000
SUMMARY:Weekly Review
RRULE:FREQ=WEEKLY;COUNT=5
END:VEVENT''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [event].occurrences(start: start, end: end).toList();

      // Jan 20, 27, Feb 3, 10, 17 - only Jan occurrences
      expect(results.length, 2);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 20, 10, 0, 0));
      expect(results[1].occurrence, CalDateTime.local(2025, 1, 27, 10, 0, 0));
    });

    test('handles infinite recurring event (stops at range end)', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test14
DTSTAMP:20250101T000000Z
DTSTART:20250101T100000
DTEND:20250101T110000
SUMMARY:Forever Event
RRULE:FREQ=WEEKLY
END:VEVENT''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [event].occurrences(start: start, end: end).toList();

      // Should stop at range end, not continue forever
      expect(results.length, 5); // Jan 1, 8, 15, 22, 29
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 1, 10, 0, 0));
      expect(results[4].occurrence, CalDateTime.local(2025, 1, 29, 10, 0, 0));
    });

    test('handles event with RDATE', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test15
DTSTAMP:20250101T000000Z
DTSTART:20250105T100000
DTEND:20250105T110000
SUMMARY:Special Dates
RDATE:20250112T100000
RDATE:20250119T100000
RDATE:20250226T100000
END:VEVENT''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [event].occurrences(start: start, end: end).toList();

      // DTSTART + 2 RDATEs in January (26th is in Feb)
      expect(results.length, 3);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 5, 10, 0, 0));
      expect(results[1].occurrence, CalDateTime.local(2025, 1, 12, 10, 0, 0));
      expect(results[2].occurrence, CalDateTime.local(2025, 1, 19, 10, 0, 0));
    });

    test('handles event with EXDATE', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test16
DTSTAMP:20250101T000000Z
DTSTART:20250105T100000
DTEND:20250105T110000
SUMMARY:Weekly with Exceptions
RRULE:FREQ=WEEKLY;COUNT=4
EXDATE:20250112T100000
EXDATE:20250126T100000
END:VEVENT''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [event].occurrences(start: start, end: end).toList();

      // 4 occurrences minus 2 exceptions = 2
      expect(results.length, 2);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 5, 10, 0, 0));
      expect(results[1].occurrence, CalDateTime.local(2025, 1, 19, 10, 0, 0));
    });

    test('handles all-day events with date-only range', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test17
DTSTAMP:20250101T000000Z
DTSTART;VALUE=DATE:20250115
SUMMARY:All Day Event
END:VEVENT''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [event].occurrences(start: start, end: end).toList();

      expect(results.length, 1);
      expect(results[0].occurrence, CalDateTime.date(2025, 1, 15));
    });

    test('handles all-day recurring events', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test18
DTSTAMP:20250101T000000Z
DTSTART;VALUE=DATE:20250101
SUMMARY:Daily All-Day
RRULE:FREQ=DAILY;COUNT=10
END:VEVENT''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [event].occurrences(start: start, end: end).toList();

      expect(results.length, 10);
      expect(results[0].occurrence, CalDateTime.date(2025, 1, 1));
      expect(results[9].occurrence, CalDateTime.date(2025, 1, 10));
    });

    test('handles empty event list', () {
      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = <EventComponent>[]
          .occurrences(start: start, end: end)
          .toList();

      expect(results.length, 0);
    });

    test('handles events without DTSTART', () {
      // Create an event component directly without DTSTART
      // (simulating a malformed or partially constructed event)
      final event = EventComponent(properties: {}, components: []);

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [event].occurrences(start: start, end: end).toList();

      expect(results.length, 0);
    });

    test('throws ArgumentError when start is after end', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test20
DTSTAMP:20250101T000000Z
DTSTART:20250115T100000
SUMMARY:Test Event
END:VEVENT''');

      final start = CalDateTime.date(2025, 1, 31);
      final end = CalDateTime.date(2025, 1, 1);

      expect(
        () => [event].occurrences(start: start, end: end).toList(),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('handles same start and end (single moment)', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test21
DTSTAMP:20250101T000000Z
DTSTART:20250115T120000
SUMMARY:Exact Time Event
END:VEVENT''');

      final moment = CalDateTime.local(2025, 1, 15, 12, 0, 0);
      final results = [event].occurrences(start: moment, end: moment).toList();

      expect(results.length, 1);
      expect(results[0].occurrence, moment);
    });

    test('handles complex recurring rule (monthly on specific day)', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test22
DTSTAMP:20250101T000000Z
DTSTART:20250101T100000
SUMMARY:First Monday
RRULE:FREQ=MONTHLY;BYDAY=1MO;COUNT=6
END:VEVENT''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 6, 30);
      final results = [event].occurrences(start: start, end: end).toList();

      expect(results.length, 6);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 6, 10, 0, 0));
      expect(results[1].occurrence, CalDateTime.local(2025, 2, 3, 10, 0, 0));
      expect(results[2].occurrence, CalDateTime.local(2025, 3, 3, 10, 0, 0));
    });

    test('handles mixed recurring and non-recurring events', () {
      final parser = CalendarParser();
      final events = [
        parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test23
DTSTAMP:20250101T000000Z
DTSTART:20250105T100000
SUMMARY:One-time Event
END:VEVENT'''),
        parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test24
DTSTAMP:20250101T000000Z
DTSTART:20250110T100000
SUMMARY:Weekly Event
RRULE:FREQ=WEEKLY;COUNT=3
END:VEVENT'''),
      ];

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = events.occurrences(start: start, end: end).toList();

      expect(results.length, 4); // 1 one-time + 3 recurring
      expect(results[0].event.summary, 'One-time Event');
      expect(results[1].event.summary, 'Weekly Event');
      expect(results[2].event.summary, 'Weekly Event');
      expect(results[3].event.summary, 'Weekly Event');
    });

    test('handles events across timezone boundaries', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test25
DTSTAMP:20250101T000000Z
DTSTART:20250115T100000Z
DTEND:20250115T110000Z
SUMMARY:UTC Event
END:VEVENT''');

      final start = CalDateTime.utc(2025, 1, 15, 9, 0, 0);
      final end = CalDateTime.utc(2025, 1, 15, 12, 0, 0);
      final results = [event].occurrences(start: start, end: end).toList();

      expect(results.length, 1);
      expect(results[0].occurrence, CalDateTime.utc(2025, 1, 15, 10, 0, 0));
    });

    test('preserves event reference in results', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test26
DTSTAMP:20250101T000000Z
DTSTART:20250115T100000
SUMMARY:Test Event
DESCRIPTION:Important meeting
LOCATION:Conference Room A
END:VEVENT''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [event].occurrences(start: start, end: end).toList();

      expect(results.length, 1);
      expect(results[0].event, same(event));
      expect(results[0].event.description, 'Important meeting');
      expect(results[0].event.location, 'Conference Room A');
    });

    test('handles large date range efficiently', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test27
DTSTAMP:20250101T000000Z
DTSTART:20250615T100000
SUMMARY:Mid-year Event
END:VEVENT''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 12, 31);
      final results = [event].occurrences(start: start, end: end).toList();

      expect(results.length, 1);
      expect(results[0].occurrence, CalDateTime.local(2025, 6, 15, 10, 0, 0));
    });

    test('works with filtered event list', () {
      final parser = CalendarParser();
      final events = [
        parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test28
DTSTAMP:20250101T000000Z
DTSTART:20250110T100000
SUMMARY:Work Meeting
CATEGORIES:WORK
END:VEVENT'''),
        parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test29
DTSTAMP:20250101T000000Z
DTSTART:20250115T100000
SUMMARY:Personal Appointment
CATEGORIES:PERSONAL
END:VEVENT'''),
        parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test30
DTSTAMP:20250101T000000Z
DTSTART:20250120T100000
SUMMARY:Team Standup
CATEGORIES:WORK
END:VEVENT'''),
      ];

      // Filter for work events first, then find in range
      final workEvents = events.where(
        (e) => e.categories.any((c) => c == 'WORK'),
      );

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = workEvents.occurrences(start: start, end: end).toList();

      expect(results.length, 2);
      expect(results[0].event.summary, 'Work Meeting');
      expect(results[1].event.summary, 'Team Standup');
    });

    test('returns all occurrences with no date range', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test31
DTSTAMP:20250101T000000Z
DTSTART:20250105T100000
DTEND:20250105T110000
SUMMARY:Daily Meeting
RRULE:FREQ=DAILY;COUNT=5
END:VEVENT''');

      final results = [event].occurrences().toList();

      expect(results.length, 5);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 5, 10, 0, 0));
      expect(results[1].occurrence, CalDateTime.local(2025, 1, 6, 10, 0, 0));
      expect(results[2].occurrence, CalDateTime.local(2025, 1, 7, 10, 0, 0));
      expect(results[3].occurrence, CalDateTime.local(2025, 1, 8, 10, 0, 0));
      expect(results[4].occurrence, CalDateTime.local(2025, 1, 9, 10, 0, 0));
    });

    test('returns occurrences from start date onwards', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test32
DTSTAMP:20250101T000000Z
DTSTART:20250105T100000
DTEND:20250105T110000
SUMMARY:Daily Meeting
RRULE:FREQ=DAILY;COUNT=10
END:VEVENT''');

      final start = CalDateTime.date(2025, 1, 8);
      final results = [event].occurrences(start: start).toList();

      // Should get occurrences from Jan 8 onwards (8, 9, 10, 11, 12, 13, 14)
      expect(results.length, 7);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 8, 10, 0, 0));
      expect(results[1].occurrence, CalDateTime.local(2025, 1, 9, 10, 0, 0));
      expect(results[6].occurrence, CalDateTime.local(2025, 1, 14, 10, 0, 0));
    });

    test('returns occurrences up to end date', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test33
DTSTAMP:20250101T000000Z
DTSTART:20250105T100000
DTEND:20250105T110000
SUMMARY:Daily Meeting
RRULE:FREQ=DAILY;COUNT=10
END:VEVENT''');

      final end = CalDateTime.date(2025, 1, 8);
      final results = [event].occurrences(end: end).toList();

      // Should get occurrences up to Jan 8 (5, 6, 7, 8)
      expect(results.length, 4);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 5, 10, 0, 0));
      expect(results[1].occurrence, CalDateTime.local(2025, 1, 6, 10, 0, 0));
      expect(results[2].occurrence, CalDateTime.local(2025, 1, 7, 10, 0, 0));
      expect(results[3].occurrence, CalDateTime.local(2025, 1, 8, 10, 0, 0));
    });
  });

  group('TodoIterableQuery.occurrences', () {
    test('includes single todo within range', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:test1
DTSTAMP:20250101T000000Z
DTSTART:20250115T100000
SUMMARY:Test Todo
END:VTODO''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [todo].occurrences(start: start, end: end).toList();

      expect(results.length, 1);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 15, 10, 0, 0));
      expect(results[0].todo.summary, 'Test Todo');
    });

    test('excludes single todo before range', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:test2
DTSTAMP:20250101T000000Z
DTSTART:20241215T100000
SUMMARY:Past Todo
END:VTODO''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [todo].occurrences(start: start, end: end).toList();

      expect(results.length, 0);
    });

    test('excludes single todo after range', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:test3
DTSTAMP:20250101T000000Z
DTSTART:20250215T100000
SUMMARY:Future Todo
END:VTODO''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [todo].occurrences(start: start, end: end).toList();

      expect(results.length, 0);
    });

    test('includes todo exactly at range start', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:test4
DTSTAMP:20250101T000000Z
DTSTART:20250101T000000
SUMMARY:Start Todo
END:VTODO''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [todo].occurrences(start: start, end: end).toList();

      expect(results.length, 1);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 1));
    });

    test('includes todo exactly at range end', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:test5
DTSTAMP:20250101T000000Z
DTSTART:20250131T235959
SUMMARY:End Todo
END:VTODO''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [todo].occurrences(start: start, end: end).toList();

      expect(results.length, 1);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 31, 23, 59, 59));
    });

    test('includes multiple single todos in range', () {
      final parser = CalendarParser();
      final todos = [
        parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:test6a
DTSTAMP:20250101T000000Z
DTSTART:20250105T090000
SUMMARY:Todo A
END:VTODO'''),
        parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:test6b
DTSTAMP:20250101T000000Z
DTSTART:20250115T140000
SUMMARY:Todo B
END:VTODO'''),
        parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:test6c
DTSTAMP:20250101T000000Z
DTSTART:20250125T160000
SUMMARY:Todo C
END:VTODO'''),
      ];

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = todos.occurrences(start: start, end: end).toList();

      expect(results.length, 3);
      expect(results[0].todo.summary, 'Todo A');
      expect(results[1].todo.summary, 'Todo B');
      expect(results[2].todo.summary, 'Todo C');
    });

    test(
      'includes only occurrences within range for recurring todo with COUNT',
      () {
        final parser = CalendarParser();
        final todo = parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:test7
DTSTAMP:20250101T000000Z
DTSTART:20250105T100000
SUMMARY:Weekly Recurring Todo
RRULE:FREQ=WEEKLY;COUNT=10
END:VTODO''');

        final start = CalDateTime.date(2025, 1, 10);
        final end = CalDateTime.date(2025, 1, 31);
        final results = [todo].occurrences(start: start, end: end).toList();

        // Should get occurrences on Jan 12, 19, 26 (3 total)
        expect(results.length, 3);
        expect(results[0].occurrence, CalDateTime.local(2025, 1, 12, 10, 0, 0));
        expect(results[1].occurrence, CalDateTime.local(2025, 1, 19, 10, 0, 0));
        expect(results[2].occurrence, CalDateTime.local(2025, 1, 26, 10, 0, 0));
      },
    );

    test(
      'includes only occurrences within range for recurring todo with UNTIL',
      () {
        final parser = CalendarParser();
        final todo = parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:test8
DTSTAMP:20250101T000000Z
DTSTART:20250101T090000
SUMMARY:Daily Todo
RRULE:FREQ=DAILY;UNTIL=20250115T090000
END:VTODO''');

        final start = CalDateTime.date(2025, 1, 10);
        final end = CalDateTime.date(2025, 1, 20);
        final results = [todo].occurrences(start: start, end: end).toList();

        // Should get occurrences from Jan 10-15 (6 days)
        expect(results.length, 6);
        expect(results[0].occurrence, CalDateTime.local(2025, 1, 10, 9, 0, 0));
        expect(results[5].occurrence, CalDateTime.local(2025, 1, 15, 9, 0, 0));
      },
    );

    test('stops generating at range end for infinite recurring todo', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:test9
DTSTAMP:20250101T000000Z
DTSTART:20250101T100000
SUMMARY:Weekly Forever
RRULE:FREQ=WEEKLY
END:VTODO''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [todo].occurrences(start: start, end: end).toList();

      // Should get 5 occurrences (Jan 1, 8, 15, 22, 29)
      expect(results.length, 5);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 1, 10, 0, 0));
      expect(results[4].occurrence, CalDateTime.local(2025, 1, 29, 10, 0, 0));
    });

    test('handles recurring todo starting before range', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:test10
DTSTAMP:20241201T000000Z
DTSTART:20241220T100000
SUMMARY:Started Earlier
RRULE:FREQ=WEEKLY;COUNT=8
END:VTODO''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [todo].occurrences(start: start, end: end).toList();

      // Started Dec 20, 2024, weekly for 8 occurrences
      // Occurrences in Jan 2025: Jan 3, 10, 17, 24, 31
      expect(results.length, 5);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 3, 10, 0, 0));
      expect(results[4].occurrence, CalDateTime.local(2025, 1, 31, 10, 0, 0));
    });

    test('handles recurring todo with EXDATE exclusions', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:test11
DTSTAMP:20250101T000000Z
DTSTART:20250101T100000
SUMMARY:Daily with Exclusions
RRULE:FREQ=DAILY;COUNT=10
EXDATE:20250103T100000
EXDATE:20250105T100000
EXDATE:20250107T100000
END:VTODO''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 10);
      final results = [todo].occurrences(start: start, end: end).toList();

      // 10 days minus 3 excluded days = 7 occurrences
      expect(results.length, 7);
      final occurrenceDates = results.map((r) => r.occurrence.day).toList();
      expect(occurrenceDates, isNot(contains(3)));
      expect(occurrenceDates, isNot(contains(5)));
      expect(occurrenceDates, isNot(contains(7)));
    });

    test('handles recurring todo with RDATE additions', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:test12
DTSTAMP:20250101T000000Z
DTSTART:20250101T100000
SUMMARY:With Extra Dates
RRULE:FREQ=WEEKLY;COUNT=2
RDATE:20250115T100000
RDATE:20250120T100000
END:VTODO''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [todo].occurrences(start: start, end: end).toList();

      // 2 weekly occurrences (Jan 1, 8) + 2 RDATE (Jan 15, 20) = 4
      expect(results.length, 4);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 1, 10, 0, 0));
      expect(results[1].occurrence, CalDateTime.local(2025, 1, 8, 10, 0, 0));
      expect(results[2].occurrence, CalDateTime.local(2025, 1, 15, 10, 0, 0));
      expect(results[3].occurrence, CalDateTime.local(2025, 1, 20, 10, 0, 0));
    });

    test('returns empty list when no todos in range', () {
      final parser = CalendarParser();
      final todos = [
        parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:test13a
DTSTAMP:20250101T000000Z
DTSTART:20240615T100000
SUMMARY:Past Todo
END:VTODO'''),
        parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:test13b
DTSTAMP:20250101T000000Z
DTSTART:20260215T100000
SUMMARY:Future Todo
END:VTODO'''),
      ];

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = todos.occurrences(start: start, end: end).toList();

      expect(results.length, 0);
    });

    test('returns empty list for empty todo list', () {
      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = <TodoComponent>[]
          .occurrences(start: start, end: end)
          .toList();

      expect(results.length, 0);
    });

    test('throws ArgumentError when start is after end', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:test14
DTSTAMP:20250101T000000Z
DTSTART:20250115T100000
SUMMARY:Test Todo
END:VTODO''');

      final start = CalDateTime.date(2025, 1, 31);
      final end = CalDateTime.date(2025, 1, 1);

      expect(
        () => [todo].occurrences(start: start, end: end).toList(),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('handles todos with date-only boundaries', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:test15
DTSTAMP:20250101T000000Z
DTSTART;VALUE=DATE:20250115
SUMMARY:All Day Todo
END:VTODO''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [todo].occurrences(start: start, end: end).toList();

      expect(results.length, 1);
      expect(results[0].occurrence, CalDateTime.date(2025, 1, 15));
    });

    test('handles recurring todo with interval', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:test16
DTSTAMP:20250101T000000Z
DTSTART:20250101T100000
SUMMARY:Every Other Day
RRULE:FREQ=DAILY;INTERVAL=2;COUNT=10
END:VTODO''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 20);
      final results = [todo].occurrences(start: start, end: end).toList();

      // Every 2 days: Jan 1, 3, 5, 7, 9, 11, 13, 15, 17, 19
      expect(results.length, 10);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 1, 10, 0, 0));
      expect(results[1].occurrence, CalDateTime.local(2025, 1, 3, 10, 0, 0));
      expect(results[9].occurrence, CalDateTime.local(2025, 1, 19, 10, 0, 0));
    });

    test('handles monthly recurring todo', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:test17
DTSTAMP:20250101T000000Z
DTSTART:20250115T100000
SUMMARY:Monthly Review
RRULE:FREQ=MONTHLY;COUNT=6
END:VTODO''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 12, 31);
      final results = [todo].occurrences(start: start, end: end).toList();

      // Monthly on 15th for 6 months
      expect(results.length, 6);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 15, 10, 0, 0));
      expect(results[1].occurrence, CalDateTime.local(2025, 2, 15, 10, 0, 0));
      expect(results[5].occurrence, CalDateTime.local(2025, 6, 15, 10, 0, 0));
    });

    test('preserves todo reference in results', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:test18
DTSTAMP:20250101T000000Z
DTSTART:20250115T100000
SUMMARY:Important Task
DESCRIPTION:Critical deadline
PRIORITY:1
END:VTODO''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [todo].occurrences(start: start, end: end).toList();

      expect(results.length, 1);
      expect(results[0].todo, same(todo));
      expect(results[0].todo.description, 'Critical deadline');
      expect(results[0].todo.priority, 1);
    });

    test('handles large date range efficiently', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:test19
DTSTAMP:20250101T000000Z
DTSTART:20250615T100000
SUMMARY:Mid-year Task
END:VTODO''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 12, 31);
      final results = [todo].occurrences(start: start, end: end).toList();

      expect(results.length, 1);
      expect(results[0].occurrence, CalDateTime.local(2025, 6, 15, 10, 0, 0));
    });

    test('works with filtered todo list', () {
      final parser = CalendarParser();
      final todos = [
        parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:test20a
DTSTAMP:20250101T000000Z
DTSTART:20250110T100000
SUMMARY:High Priority Task
PRIORITY:1
END:VTODO'''),
        parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:test20b
DTSTAMP:20250101T000000Z
DTSTART:20250115T100000
SUMMARY:Low Priority Task
PRIORITY:9
END:VTODO'''),
        parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:test20c
DTSTAMP:20250101T000000Z
DTSTART:20250120T100000
SUMMARY:Another High Priority
PRIORITY:1
END:VTODO'''),
      ];

      // Filter for high priority todos first, then find in range
      final highPriorityTodos = todos.where((t) => t.priority == 1);

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = highPriorityTodos
          .occurrences(start: start, end: end)
          .toList();

      expect(results.length, 2);
      expect(results[0].todo.summary, 'High Priority Task');
      expect(results[1].todo.summary, 'Another High Priority');
    });
  });

  group('JournalIterableQuery.occurrences', () {
    test('includes single journal within range', () {
      final parser = CalendarParser();
      final journal = parser.parseComponentFromString<JournalComponent>('''
BEGIN:VJOURNAL
UID:test1
DTSTAMP:20250101T000000Z
DTSTART:20250115T100000
SUMMARY:Test Journal
END:VJOURNAL''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [journal].occurrences(start: start, end: end).toList();

      expect(results.length, 1);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 15, 10, 0, 0));
      expect(results[0].journal.summary, 'Test Journal');
    });

    test('excludes single journal before range', () {
      final parser = CalendarParser();
      final journal = parser.parseComponentFromString<JournalComponent>('''
BEGIN:VJOURNAL
UID:test2
DTSTAMP:20250101T000000Z
DTSTART:20241215T100000
SUMMARY:Past Journal
END:VJOURNAL''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [journal].occurrences(start: start, end: end).toList();

      expect(results.length, 0);
    });

    test('excludes single journal after range', () {
      final parser = CalendarParser();
      final journal = parser.parseComponentFromString<JournalComponent>('''
BEGIN:VJOURNAL
UID:test3
DTSTAMP:20250101T000000Z
DTSTART:20250215T100000
SUMMARY:Future Journal
END:VJOURNAL''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [journal].occurrences(start: start, end: end).toList();

      expect(results.length, 0);
    });

    test('includes journal exactly at range start', () {
      final parser = CalendarParser();
      final journal = parser.parseComponentFromString<JournalComponent>('''
BEGIN:VJOURNAL
UID:test4
DTSTAMP:20250101T000000Z
DTSTART:20250101T000000
SUMMARY:Start Journal
END:VJOURNAL''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [journal].occurrences(start: start, end: end).toList();

      expect(results.length, 1);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 1));
    });

    test('includes journal exactly at range end', () {
      final parser = CalendarParser();
      final journal = parser.parseComponentFromString<JournalComponent>('''
BEGIN:VJOURNAL
UID:test5
DTSTAMP:20250101T000000Z
DTSTART:20250131T235959
SUMMARY:End Journal
END:VJOURNAL''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [journal].occurrences(start: start, end: end).toList();

      expect(results.length, 1);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 31, 23, 59, 59));
    });

    test('includes multiple single journals in range', () {
      final parser = CalendarParser();
      final journals = [
        parser.parseComponentFromString<JournalComponent>('''
BEGIN:VJOURNAL
UID:test6a
DTSTAMP:20250101T000000Z
DTSTART:20250105T090000
SUMMARY:Journal A
END:VJOURNAL'''),
        parser.parseComponentFromString<JournalComponent>('''
BEGIN:VJOURNAL
UID:test6b
DTSTAMP:20250101T000000Z
DTSTART:20250115T140000
SUMMARY:Journal B
END:VJOURNAL'''),
        parser.parseComponentFromString<JournalComponent>('''
BEGIN:VJOURNAL
UID:test6c
DTSTAMP:20250101T000000Z
DTSTART:20250125T160000
SUMMARY:Journal C
END:VJOURNAL'''),
      ];

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = journals.occurrences(start: start, end: end).toList();

      expect(results.length, 3);
      expect(results[0].journal.summary, 'Journal A');
      expect(results[1].journal.summary, 'Journal B');
      expect(results[2].journal.summary, 'Journal C');
    });

    test(
      'includes only occurrences within range for recurring journal with COUNT',
      () {
        final parser = CalendarParser();
        final journal = parser.parseComponentFromString<JournalComponent>('''
BEGIN:VJOURNAL
UID:test7
DTSTAMP:20250101T000000Z
DTSTART:20250105T100000
SUMMARY:Weekly Recurring Journal
RRULE:FREQ=WEEKLY;COUNT=10
END:VJOURNAL''');

        final start = CalDateTime.date(2025, 1, 10);
        final end = CalDateTime.date(2025, 1, 31);
        final results = [journal].occurrences(start: start, end: end).toList();

        // Should get occurrences on Jan 12, 19, 26 (3 total)
        expect(results.length, 3);
        expect(results[0].occurrence, CalDateTime.local(2025, 1, 12, 10, 0, 0));
        expect(results[1].occurrence, CalDateTime.local(2025, 1, 19, 10, 0, 0));
        expect(results[2].occurrence, CalDateTime.local(2025, 1, 26, 10, 0, 0));
      },
    );

    test(
      'includes only occurrences within range for recurring journal with UNTIL',
      () {
        final parser = CalendarParser();
        final journal = parser.parseComponentFromString<JournalComponent>('''
BEGIN:VJOURNAL
UID:test8
DTSTAMP:20250101T000000Z
DTSTART:20250101T090000
SUMMARY:Daily Journal
RRULE:FREQ=DAILY;UNTIL=20250115T090000
END:VJOURNAL''');

        final start = CalDateTime.date(2025, 1, 10);
        final end = CalDateTime.date(2025, 1, 20);
        final results = [journal].occurrences(start: start, end: end).toList();

        // Should get occurrences from Jan 10-15 (6 days)
        expect(results.length, 6);
        expect(results[0].occurrence, CalDateTime.local(2025, 1, 10, 9, 0, 0));
        expect(results[5].occurrence, CalDateTime.local(2025, 1, 15, 9, 0, 0));
      },
    );

    test('stops generating at range end for infinite recurring journal', () {
      final parser = CalendarParser();
      final journal = parser.parseComponentFromString<JournalComponent>('''
BEGIN:VJOURNAL
UID:test9
DTSTAMP:20250101T000000Z
DTSTART:20250101T100000
SUMMARY:Weekly Forever
RRULE:FREQ=WEEKLY
END:VJOURNAL''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [journal].occurrences(start: start, end: end).toList();

      // Should get 5 occurrences (Jan 1, 8, 15, 22, 29)
      expect(results.length, 5);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 1, 10, 0, 0));
      expect(results[4].occurrence, CalDateTime.local(2025, 1, 29, 10, 0, 0));
    });

    test('handles recurring journal starting before range', () {
      final parser = CalendarParser();
      final journal = parser.parseComponentFromString<JournalComponent>('''
BEGIN:VJOURNAL
UID:test10
DTSTAMP:20241201T000000Z
DTSTART:20241220T100000
SUMMARY:Started Earlier
RRULE:FREQ=WEEKLY;COUNT=8
END:VJOURNAL''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [journal].occurrences(start: start, end: end).toList();

      // Started Dec 20, 2024, weekly for 8 occurrences
      // Occurrences in Jan 2025: Jan 3, 10, 17, 24, 31
      expect(results.length, 5);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 3, 10, 0, 0));
      expect(results[4].occurrence, CalDateTime.local(2025, 1, 31, 10, 0, 0));
    });

    test('handles recurring journal with EXDATE exclusions', () {
      final parser = CalendarParser();
      final journal = parser.parseComponentFromString<JournalComponent>('''
BEGIN:VJOURNAL
UID:test11
DTSTAMP:20250101T000000Z
DTSTART:20250101T100000
SUMMARY:Daily with Exclusions
RRULE:FREQ=DAILY;COUNT=10
EXDATE:20250103T100000
EXDATE:20250105T100000
EXDATE:20250107T100000
END:VJOURNAL''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 10);
      final results = [journal].occurrences(start: start, end: end).toList();

      // 10 days minus 3 excluded days = 7 occurrences
      expect(results.length, 7);
      final occurrenceDates = results.map((r) => r.occurrence.day).toList();
      expect(occurrenceDates, isNot(contains(3)));
      expect(occurrenceDates, isNot(contains(5)));
      expect(occurrenceDates, isNot(contains(7)));
    });

    test('handles recurring journal with RDATE additions', () {
      final parser = CalendarParser();
      final journal = parser.parseComponentFromString<JournalComponent>('''
BEGIN:VJOURNAL
UID:test12
DTSTAMP:20250101T000000Z
DTSTART:20250101T100000
SUMMARY:With Extra Dates
RRULE:FREQ=WEEKLY;COUNT=2
RDATE:20250115T100000
RDATE:20250120T100000
END:VJOURNAL''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [journal].occurrences(start: start, end: end).toList();

      // 2 weekly occurrences (Jan 1, 8) + 2 RDATE (Jan 15, 20) = 4
      expect(results.length, 4);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 1, 10, 0, 0));
      expect(results[1].occurrence, CalDateTime.local(2025, 1, 8, 10, 0, 0));
      expect(results[2].occurrence, CalDateTime.local(2025, 1, 15, 10, 0, 0));
      expect(results[3].occurrence, CalDateTime.local(2025, 1, 20, 10, 0, 0));
    });

    test('returns empty list when no journals in range', () {
      final parser = CalendarParser();
      final journals = [
        parser.parseComponentFromString<JournalComponent>('''
BEGIN:VJOURNAL
UID:test13a
DTSTAMP:20250101T000000Z
DTSTART:20240615T100000
SUMMARY:Past Journal
END:VJOURNAL'''),
        parser.parseComponentFromString<JournalComponent>('''
BEGIN:VJOURNAL
UID:test13b
DTSTAMP:20250101T000000Z
DTSTART:20260215T100000
SUMMARY:Future Journal
END:VJOURNAL'''),
      ];

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = journals.occurrences(start: start, end: end).toList();

      expect(results.length, 0);
    });

    test('returns empty list for empty journal list', () {
      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = <JournalComponent>[]
          .occurrences(start: start, end: end)
          .toList();

      expect(results.length, 0);
    });

    test('throws ArgumentError when start is after end', () {
      final parser = CalendarParser();
      final journal = parser.parseComponentFromString<JournalComponent>('''
BEGIN:VJOURNAL
UID:test14
DTSTAMP:20250101T000000Z
DTSTART:20250115T100000
SUMMARY:Test Journal
END:VJOURNAL''');

      final start = CalDateTime.date(2025, 1, 31);
      final end = CalDateTime.date(2025, 1, 1);

      expect(
        () => [journal].occurrences(start: start, end: end).toList(),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('handles journals with date-only boundaries', () {
      final parser = CalendarParser();
      final journal = parser.parseComponentFromString<JournalComponent>('''
BEGIN:VJOURNAL
UID:test15
DTSTAMP:20250101T000000Z
DTSTART;VALUE=DATE:20250115
SUMMARY:All Day Journal
END:VJOURNAL''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [journal].occurrences(start: start, end: end).toList();

      expect(results.length, 1);
      expect(results[0].occurrence, CalDateTime.date(2025, 1, 15));
    });

    test('handles recurring journal with interval', () {
      final parser = CalendarParser();
      final journal = parser.parseComponentFromString<JournalComponent>('''
BEGIN:VJOURNAL
UID:test16
DTSTAMP:20250101T000000Z
DTSTART:20250101T100000
SUMMARY:Every Other Day
RRULE:FREQ=DAILY;INTERVAL=2;COUNT=10
END:VJOURNAL''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 20);
      final results = [journal].occurrences(start: start, end: end).toList();

      // Every 2 days: Jan 1, 3, 5, 7, 9, 11, 13, 15, 17, 19
      expect(results.length, 10);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 1, 10, 0, 0));
      expect(results[1].occurrence, CalDateTime.local(2025, 1, 3, 10, 0, 0));
      expect(results[9].occurrence, CalDateTime.local(2025, 1, 19, 10, 0, 0));
    });

    test('handles monthly recurring journal', () {
      final parser = CalendarParser();
      final journal = parser.parseComponentFromString<JournalComponent>('''
BEGIN:VJOURNAL
UID:test17
DTSTAMP:20250101T000000Z
DTSTART:20250115T100000
SUMMARY:Monthly Review
RRULE:FREQ=MONTHLY;COUNT=6
END:VJOURNAL''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 12, 31);
      final results = [journal].occurrences(start: start, end: end).toList();

      // Monthly on 15th for 6 months
      expect(results.length, 6);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 15, 10, 0, 0));
      expect(results[1].occurrence, CalDateTime.local(2025, 2, 15, 10, 0, 0));
      expect(results[5].occurrence, CalDateTime.local(2025, 6, 15, 10, 0, 0));
    });

    test('preserves journal reference in results', () {
      final parser = CalendarParser();
      final journal = parser.parseComponentFromString<JournalComponent>('''
BEGIN:VJOURNAL
UID:test18
DTSTAMP:20250101T000000Z
DTSTART:20250115T100000
SUMMARY:Important Entry
END:VJOURNAL''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [journal].occurrences(start: start, end: end).toList();

      expect(results.length, 1);
      expect(results[0].journal, same(journal));
      expect(results[0].journal.summary, 'Important Entry');
    });

    test('handles large date range efficiently', () {
      final parser = CalendarParser();
      final journal = parser.parseComponentFromString<JournalComponent>('''
BEGIN:VJOURNAL
UID:test19
DTSTAMP:20250101T000000Z
DTSTART:20250615T100000
SUMMARY:Mid-year Entry
END:VJOURNAL''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 12, 31);
      final results = [journal].occurrences(start: start, end: end).toList();

      expect(results.length, 1);
      expect(results[0].occurrence, CalDateTime.local(2025, 6, 15, 10, 0, 0));
    });

    test('works with filtered journal list', () {
      final parser = CalendarParser();
      final journals = [
        parser.parseComponentFromString<JournalComponent>('''
BEGIN:VJOURNAL
UID:test20a
DTSTAMP:20250101T000000Z
DTSTART:20250110T100000
SUMMARY:Work Journal
CATEGORIES:WORK
END:VJOURNAL'''),
        parser.parseComponentFromString<JournalComponent>('''
BEGIN:VJOURNAL
UID:test20b
DTSTAMP:20250101T000000Z
DTSTART:20250115T100000
SUMMARY:Personal Journal
CATEGORIES:PERSONAL
END:VJOURNAL'''),
        parser.parseComponentFromString<JournalComponent>('''
BEGIN:VJOURNAL
UID:test20c
DTSTAMP:20250101T000000Z
DTSTART:20250120T100000
SUMMARY:Work Notes
CATEGORIES:WORK
END:VJOURNAL'''),
      ];

      // Filter for work journals first, then find in range
      final workJournals = journals.where(
        (j) => j.categories.any((c) => c == 'WORK'),
      );

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = workJournals.occurrences(start: start, end: end).toList();

      expect(results.length, 2);
      expect(results[0].journal.summary, 'Work Journal');
      expect(results[1].journal.summary, 'Work Notes');
    });
  });

  group('TimeZoneIterableQuery.occurrences', () {
    test('Includes single timezone within range', () {
      final parser = CalendarParser();
      final timezone = parser.parseComponentFromString<TimeZoneSubComponent>('''
BEGIN:STANDARD
DTSTART:20250115T020000
TZOFFSETFROM:+0100
TZOFFSETTO:+0000
END:STANDARD''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [timezone].occurrences(start: start, end: end).toList();

      expect(results.length, 1);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 15, 2, 0, 0));
      expect(results[0].timezone.tzoffsetTo.toString(), '+0000');
    });

    test('Excludes single timezone before range', () {
      final parser = CalendarParser();
      final timezone = parser.parseComponentFromString<TimeZoneSubComponent>('''
BEGIN:STANDARD
DTSTART:20241215T020000
TZOFFSETFROM:+0100
TZOFFSETTO:+0000
END:STANDARD''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [timezone].occurrences(start: start, end: end).toList();

      expect(results.length, 0);
    });

    test('Excludes single timezone after range', () {
      final parser = CalendarParser();
      final timezone = parser.parseComponentFromString<TimeZoneSubComponent>('''
BEGIN:STANDARD
DTSTART:20250215T020000
TZOFFSETFROM:+0100
TZOFFSETTO:+0000
END:STANDARD''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [timezone].occurrences(start: start, end: end).toList();

      expect(results.length, 0);
    });

    test('Includes timezone exactly at range start', () {
      final parser = CalendarParser();
      final timezone = parser.parseComponentFromString<TimeZoneSubComponent>('''
BEGIN:STANDARD
DTSTART:20250101T000000
TZOFFSETFROM:+0100
TZOFFSETTO:+0000
END:STANDARD''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [timezone].occurrences(start: start, end: end).toList();

      expect(results.length, 1);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 1));
    });

    test('Includes timezone exactly at range end', () {
      final parser = CalendarParser();
      final timezone = parser.parseComponentFromString<TimeZoneSubComponent>('''
BEGIN:STANDARD
DTSTART:20250131T235959
TZOFFSETFROM:+0100
TZOFFSETTO:+0000
END:STANDARD''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [timezone].occurrences(start: start, end: end).toList();

      expect(results.length, 1);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 31, 23, 59, 59));
    });

    test('Includes multiple single timezones in range', () {
      final parser = CalendarParser();
      final timezones = [
        parser.parseComponentFromString<TimeZoneSubComponent>('''
BEGIN:STANDARD
DTSTART:20250105T020000
TZOFFSETFROM:+0100
TZOFFSETTO:+0000
END:STANDARD'''),
        parser.parseComponentFromString<TimeZoneSubComponent>('''
BEGIN:DAYLIGHT
DTSTART:20250315T020000
TZOFFSETFROM:+0000
TZOFFSETTO:+0100
END:DAYLIGHT'''),
        parser.parseComponentFromString<TimeZoneSubComponent>('''
BEGIN:STANDARD
DTSTART:20251025T020000
TZOFFSETFROM:+0100
TZOFFSETTO:+0000
END:STANDARD'''),
      ];

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 12, 31);
      final results = timezones.occurrences(start: start, end: end).toList();

      expect(results.length, 3);
      expect(results[0].timezone.name, 'STANDARD');
      expect(results[1].timezone.name, 'DAYLIGHT');
      expect(results[2].timezone.name, 'STANDARD');
    });

    test(
      'Includes only occurrences within range for recurring timezone with COUNT',
      () {
        final parser = CalendarParser();
        final timezone = parser.parseComponentFromString<TimeZoneSubComponent>(
          '''
BEGIN:STANDARD
DTSTART:20250105T020000
TZOFFSETFROM:+0100
TZOFFSETTO:+0000
RRULE:FREQ=WEEKLY;COUNT=10
END:STANDARD''',
        );

        final start = CalDateTime.date(2025, 1, 10);
        final end = CalDateTime.date(2025, 1, 31);
        final results = [timezone].occurrences(start: start, end: end).toList();

        // Should get occurrences on Jan 12, 19, 26 (3 total)
        expect(results.length, 3);
        expect(results[0].occurrence, CalDateTime.local(2025, 1, 12, 2, 0, 0));
        expect(results[1].occurrence, CalDateTime.local(2025, 1, 19, 2, 0, 0));
        expect(results[2].occurrence, CalDateTime.local(2025, 1, 26, 2, 0, 0));
      },
    );

    test(
      'Includes only occurrences within range for recurring timezone with UNTIL',
      () {
        final parser = CalendarParser();
        final timezone = parser.parseComponentFromString<TimeZoneSubComponent>(
          '''
BEGIN:STANDARD
DTSTART:20250101T020000
TZOFFSETFROM:+0100
TZOFFSETTO:+0000
RRULE:FREQ=DAILY;UNTIL=20250115T020000
END:STANDARD''',
        );

        final start = CalDateTime.local(2025, 1, 10);
        final end = CalDateTime.local(2025, 1, 20);
        final results = [timezone].occurrences(start: start, end: end).toList();

        // Should get occurrences from Jan 10-15 (6 days)
        expect(results.length, 6);
        expect(results[0].occurrence, CalDateTime.local(2025, 1, 10, 2, 0, 0));
        expect(results[5].occurrence, CalDateTime.local(2025, 1, 15, 2, 0, 0));
      },
    );

    test('Stops generating at range end for infinite recurring timezone', () {
      final parser = CalendarParser();
      final timezone = parser.parseComponentFromString<TimeZoneSubComponent>('''
BEGIN:STANDARD
DTSTART:20250101T020000
TZOFFSETFROM:+0100
TZOFFSETTO:+0000
RRULE:FREQ=WEEKLY
END:STANDARD''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [timezone].occurrences(start: start, end: end).toList();

      // Should get 5 occurrences (Jan 1, 8, 15, 22, 29)
      expect(results.length, 5);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 1, 2, 0, 0));
      expect(results[4].occurrence, CalDateTime.local(2025, 1, 29, 2, 0, 0));
    });

    test('Handles recurring timezone starting before range', () {
      final parser = CalendarParser();
      final timezone = parser.parseComponentFromString<TimeZoneSubComponent>('''
BEGIN:STANDARD
DTSTART:20241220T020000
TZOFFSETFROM:+0100
TZOFFSETTO:+0000
RRULE:FREQ=WEEKLY;COUNT=8
END:STANDARD''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [timezone].occurrences(start: start, end: end).toList();

      // Started Dec 20, 2024, weekly for 8 occurrences
      // Occurrences in Jan 2025: Jan 3, 10, 17, 24, 31
      expect(results.length, 5);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 3, 2, 0, 0));
      expect(results[4].occurrence, CalDateTime.local(2025, 1, 31, 2, 0, 0));
    });

    test('Handles recurring timezone with RDATE additions', () {
      final parser = CalendarParser();
      final timezone = parser.parseComponentFromString<TimeZoneSubComponent>('''
BEGIN:STANDARD
DTSTART:20250101T020000
TZOFFSETFROM:+0100
TZOFFSETTO:+0000
RRULE:FREQ=WEEKLY;COUNT=2
RDATE:20250115T020000
RDATE:20250120T020000
END:STANDARD''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [timezone].occurrences(start: start, end: end).toList();

      // 2 weekly occurrences (Jan 1, 8) + 2 RDATE (Jan 15, 20) = 4
      expect(results.length, 4);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 1, 2, 0, 0));
      expect(results[1].occurrence, CalDateTime.local(2025, 1, 8, 2, 0, 0));
      expect(results[2].occurrence, CalDateTime.local(2025, 1, 15, 2, 0, 0));
      expect(results[3].occurrence, CalDateTime.local(2025, 1, 20, 2, 0, 0));
    });

    test('Returns empty list when no timezones in range', () {
      final parser = CalendarParser();
      final timezones = [
        parser.parseComponentFromString<TimeZoneSubComponent>('''
BEGIN:STANDARD
DTSTART:20240615T020000
TZOFFSETFROM:+0100
TZOFFSETTO:+0000
END:STANDARD'''),
        parser.parseComponentFromString<TimeZoneSubComponent>('''
BEGIN:STANDARD
DTSTART:20260215T020000
TZOFFSETFROM:+0100
TZOFFSETTO:+0000
END:STANDARD'''),
      ];

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = timezones.occurrences(start: start, end: end).toList();

      expect(results.length, 0);
    });

    test('Returns empty list for empty timezone list', () {
      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = <TimeZoneSubComponent>[]
          .occurrences(start: start, end: end)
          .toList();

      expect(results.length, 0);
    });

    test('Throws ArgumentError when start is after end', () {
      final parser = CalendarParser();
      final timezone = parser.parseComponentFromString<TimeZoneSubComponent>('''
BEGIN:STANDARD
DTSTART:20250115T020000
TZOFFSETFROM:+0100
TZOFFSETTO:+0000
END:STANDARD''');

      final start = CalDateTime.date(2025, 1, 31);
      final end = CalDateTime.date(2025, 1, 1);

      expect(
        () => [timezone].occurrences(start: start, end: end).toList(),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Handles date-only range boundaries', () {
      final parser = CalendarParser();
      final timezone = parser.parseComponentFromString<TimeZoneSubComponent>('''
BEGIN:STANDARD
DTSTART:20250115T000000
TZOFFSETFROM:+0100
TZOFFSETTO:+0000
END:STANDARD''');

      // Use date-only boundaries for the range
      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [timezone].occurrences(start: start, end: end).toList();

      expect(results.length, 1);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 15));
    });

    test('Handles yearly recurring timezone', () {
      final parser = CalendarParser();
      final timezone = parser.parseComponentFromString<TimeZoneSubComponent>('''
BEGIN:STANDARD
DTSTART:20250315T020000
TZOFFSETFROM:+0100
TZOFFSETTO:+0000
RRULE:FREQ=YEARLY;COUNT=5
END:STANDARD''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2029, 12, 31);
      final results = [timezone].occurrences(start: start, end: end).toList();

      // Yearly on March 15 for 5 years
      expect(results.length, 5);
      expect(results[0].occurrence, CalDateTime.local(2025, 3, 15, 2, 0, 0));
      expect(results[1].occurrence, CalDateTime.local(2026, 3, 15, 2, 0, 0));
      expect(results[4].occurrence, CalDateTime.local(2029, 3, 15, 2, 0, 0));
    });

    test('Preserves timezone reference in results', () {
      final parser = CalendarParser();
      final timezone = parser.parseComponentFromString<TimeZoneSubComponent>('''
BEGIN:STANDARD
DTSTART:20250115T020000
TZOFFSETFROM:+0100
TZOFFSETTO:+0000
TZNAME:EST
END:STANDARD''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [timezone].occurrences(start: start, end: end).toList();

      expect(results.length, 1);
      expect(results[0].timezone, same(timezone));
      expect(results[0].timezone.tznames, contains('EST'));
    });

    test('Handles large date range efficiently', () {
      final parser = CalendarParser();
      final timezone = parser.parseComponentFromString<TimeZoneSubComponent>('''
BEGIN:STANDARD
DTSTART:20250615T020000
TZOFFSETFROM:+0100
TZOFFSETTO:+0000
END:STANDARD''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 12, 31);
      final results = [timezone].occurrences(start: start, end: end).toList();

      expect(results.length, 1);
      expect(results[0].occurrence, CalDateTime.local(2025, 6, 15, 2, 0, 0));
    });

    test('Works with filtered timezone list', () {
      final parser = CalendarParser();
      final timezones = [
        parser.parseComponentFromString<TimeZoneSubComponent>('''
BEGIN:STANDARD
DTSTART:20251025T020000
TZOFFSETFROM:+0100
TZOFFSETTO:+0000
END:STANDARD'''),
        parser.parseComponentFromString<TimeZoneSubComponent>('''
BEGIN:DAYLIGHT
DTSTART:20250329T020000
TZOFFSETFROM:+0000
TZOFFSETTO:+0100
END:DAYLIGHT'''),
        parser.parseComponentFromString<TimeZoneSubComponent>('''
BEGIN:STANDARD
DTSTART:20250105T020000
TZOFFSETFROM:+0100
TZOFFSETTO:+0000
END:STANDARD'''),
      ];

      // Filter for STANDARD components first, then find in range
      final standardTimezones = timezones.where((tz) => tz.name == 'STANDARD');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 12, 31);
      final results = standardTimezones
          .occurrences(start: start, end: end)
          .toList();

      expect(results.length, 2);
      expect(results[0].timezone.name, 'STANDARD');
      expect(results[1].timezone.name, 'STANDARD');
    });
  });
  group('Multi-day event overlap', () {
    test('Includes event that starts before range but ends during', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test-multiday-1
DTSTAMP:20250101T000000Z
DTSTART:20241228T100000
DTEND:20250105T110000
SUMMARY:Spans Into Range
END:VEVENT''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [event].occurrences(start: start, end: end).toList();

      expect(results.length, 1);
      expect(results[0].occurrence, CalDateTime.local(2024, 12, 28, 10, 0, 0));
    });

    test('Includes event that starts during range but ends after', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test-multiday-2
DTSTAMP:20250101T000000Z
DTSTART:20250125T100000
DTEND:20250205T110000
SUMMARY:Spans Out Of Range
END:VEVENT''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [event].occurrences(start: start, end: end).toList();

      expect(results.length, 1);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 25, 10, 0, 0));
    });

    test('Includes event that fully contains range', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test-multiday-3
DTSTAMP:20250101T000000Z
DTSTART:20241215T100000
DTEND:20250215T110000
SUMMARY:Fully Contains Range
END:VEVENT''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [event].occurrences(start: start, end: end).toList();

      expect(results.length, 1);
      expect(results[0].occurrence, CalDateTime.local(2024, 12, 15, 10, 0, 0));
    });

    test('Excludes event that ends before range starts', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test-multiday-4
DTSTAMP:20250101T000000Z
DTSTART:20241215T100000
DTEND:20241225T110000
SUMMARY:Ends Before Range
END:VEVENT''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [event].occurrences(start: start, end: end).toList();

      expect(results.length, 0);
    });

    test('Includes recurring multi-day events with overlap', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test-multiday-recurring
DTSTAMP:20250101T000000Z
DTSTART:20241228T100000
DTEND:20250102T110000
RRULE:FREQ=WEEKLY;COUNT=4
SUMMARY:Recurring Multi-Day
END:VEVENT''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [event].occurrences(start: start, end: end).toList();

      // First occurrence: Dec 28 - Jan 2 (overlaps with range start)
      // Second occurrence: Jan 4 - Jan 9 (fully in range)
      // Third occurrence: Jan 11 - Jan 16 (fully in range)
      // Fourth occurrence: Jan 18 - Jan 23 (fully in range)
      expect(results.length, 4);
      expect(results[0].occurrence, CalDateTime.local(2024, 12, 28, 10, 0, 0));
      expect(results[1].occurrence, CalDateTime.local(2025, 1, 4, 10, 0, 0));
      expect(results[2].occurrence, CalDateTime.local(2025, 1, 11, 10, 0, 0));
      expect(results[3].occurrence, CalDateTime.local(2025, 1, 18, 10, 0, 0));
    });

    test('Handles DURATION instead of DTEND', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test-multiday-duration
DTSTAMP:20250101T000000Z
DTSTART:20241228T100000
DURATION:P5D
SUMMARY:With Duration
END:VEVENT''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [event].occurrences(start: start, end: end).toList();

      // Event: Dec 28 10:00 + 5 days = Jan 2 10:00 (overlaps with range)
      expect(results.length, 1);
      expect(results[0].occurrence, CalDateTime.local(2024, 12, 28, 10, 0, 0));
    });
  });

  group('Recurring events with duration', () {
    test('Daily recurring event with 2-hour duration', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test-daily-duration
DTSTAMP:20250101T000000Z
DTSTART:20250115T100000
DURATION:PT2H
RRULE:FREQ=DAILY;COUNT=5
SUMMARY:Daily 2hr Meeting
END:VEVENT''');

      final start = CalDateTime.local(2025, 1, 15, 11, 0, 0);
      final end = CalDateTime.local(2025, 1, 17, 11, 0, 0);
      final results = [event].occurrences(start: start, end: end).toList();

      // Jan 15 10:00-12:00 (overlaps, starts before range but ends after range start)
      // Jan 16 10:00-12:00 (fully in range)
      // Jan 17 10:00-12:00 (starts in range)
      expect(results.length, 3);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 15, 10, 0, 0));
      expect(results[1].occurrence, CalDateTime.local(2025, 1, 16, 10, 0, 0));
      expect(results[2].occurrence, CalDateTime.local(2025, 1, 17, 10, 0, 0));
    });

    test('Weekly recurring event with multi-day duration', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test-weekly-multiday
DTSTAMP:20250101T000000Z
DTSTART:20250105T140000
DURATION:P2DT4H
RRULE:FREQ=WEEKLY;COUNT=4
SUMMARY:Weekend Workshop
END:VEVENT''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [event].occurrences(start: start, end: end).toList();

      // Jan 5 14:00 + 2d4h = Jan 7 18:00
      // Jan 12 14:00 + 2d4h = Jan 14 18:00
      // Jan 19 14:00 + 2d4h = Jan 21 18:00
      // Jan 26 14:00 + 2d4h = Jan 28 18:00
      expect(results.length, 4);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 5, 14, 0, 0));
      expect(results[1].occurrence, CalDateTime.local(2025, 1, 12, 14, 0, 0));
      expect(results[2].occurrence, CalDateTime.local(2025, 1, 19, 14, 0, 0));
      expect(results[3].occurrence, CalDateTime.local(2025, 1, 26, 14, 0, 0));
    });

    test('Monthly recurring event with duration spanning month boundary', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test-monthly-duration
DTSTAMP:20250101T000000Z
DTSTART:20250128T200000
DURATION:P3D
RRULE:FREQ=MONTHLY;COUNT=3
SUMMARY:End of Month Event
END:VEVENT''');

      final start = CalDateTime.date(2025, 1, 15);
      final end = CalDateTime.date(2025, 3, 31);
      final results = [event].occurrences(start: start, end: end).toList();

      // Jan 28 20:00 + 3d = Jan 31 20:00 (in range)
      // Feb 28 20:00 + 3d = Mar 3 20:00 (in range)
      // Mar 28 20:00 + 3d = Mar 31 20:00 (in range)
      expect(results.length, 3);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 28, 20, 0, 0));
      expect(results[1].occurrence, CalDateTime.local(2025, 2, 28, 20, 0, 0));
      expect(results[2].occurrence, CalDateTime.local(2025, 3, 28, 20, 0, 0));
    });

    test('Excludes recurring events when duration ends before range', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test-exclude-duration
DTSTAMP:20250101T000000Z
DTSTART:20250110T100000
DURATION:PT1H
RRULE:FREQ=DAILY;COUNT=10
SUMMARY:Daily 1hr Event
END:VEVENT''');

      final start = CalDateTime.local(2025, 1, 20, 12, 0, 0);
      final end = CalDateTime.date(2025, 1, 25);
      final results = [event].occurrences(start: start, end: end).toList();

      // Jan 10-19 all end at 11:00, range starts at Jan 20 12:00
      // No events should match
      expect(results.length, 0);
    });

    test('Recurring event with DTEND instead of DURATION', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:test-dtend-recur
DTSTAMP:20250101T000000Z
DTSTART:20250115T090000
DTEND:20250115T173000
RRULE:FREQ=DAILY;COUNT=5
SUMMARY:Work Day
END:VEVENT''');

      final start = CalDateTime.local(2025, 1, 16, 16, 0, 0);
      final end = CalDateTime.local(2025, 1, 18, 10, 0, 0);
      final results = [event].occurrences(start: start, end: end).toList();

      // Jan 15 09:00-17:30 (ends before range)
      // Jan 16 09:00-17:30 (overlaps with range start at 16:00)
      // Jan 17 09:00-17:30 (fully overlaps)
      // Jan 18 09:00-17:30 (starts before range end at 10:00)
      expect(results.length, 3);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 16, 9, 0, 0));
      expect(results[1].occurrence, CalDateTime.local(2025, 1, 17, 9, 0, 0));
      expect(results[2].occurrence, CalDateTime.local(2025, 1, 18, 9, 0, 0));
    });
  });

  group('Recurring todos with duration', () {
    test('Daily recurring todo with 3-hour duration', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:test-daily-todo
DTSTAMP:20250101T000000Z
DTSTART:20250115T140000
DURATION:PT3H
RRULE:FREQ=DAILY;COUNT=5
SUMMARY:Daily Task
END:VTODO''');

      final start = CalDateTime.date(2025, 1, 16);
      final end = CalDateTime.date(2025, 1, 17);
      final results = [todo].occurrences(start: start, end: end).toList();

      // Jan 15 14:00-17:00 (ends before range)
      // Jan 16 14:00-17:00 (in range)
      // Jan 17 14:00-17:00 (in range)
      expect(results.length, 2);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 16, 14, 0, 0));
      expect(results[1].occurrence, CalDateTime.local(2025, 1, 17, 14, 0, 0));
    });

    test('Weekly recurring todo with multi-day duration', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:test-weekly-todo-multiday
DTSTAMP:20250101T000000Z
DTSTART:20250106T080000
DURATION:P4D
RRULE:FREQ=WEEKLY;COUNT=3
SUMMARY:Weekly Project
END:VTODO''');

      final start = CalDateTime.date(2025, 1, 10);
      final end = CalDateTime.date(2025, 1, 25);
      final results = [todo].occurrences(start: start, end: end).toList();

      // Jan 6 08:00 + 4d = Jan 10 08:00 (overlaps range start)
      // Jan 13 08:00 + 4d = Jan 17 08:00 (in range)
      // Jan 20 08:00 + 4d = Jan 24 08:00 (in range)
      expect(results.length, 3);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 6, 8, 0, 0));
      expect(results[1].occurrence, CalDateTime.local(2025, 1, 13, 8, 0, 0));
      expect(results[2].occurrence, CalDateTime.local(2025, 1, 20, 8, 0, 0));
    });

    test('Recurring todo with DUE instead of DURATION', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:test-todo-due
DTSTAMP:20250101T000000Z
DTSTART:20250115T090000
DUE:20250115T180000
RRULE:FREQ=DAILY;COUNT=4
SUMMARY:Daily Work Task
END:VTODO''');

      final start = CalDateTime.local(2025, 1, 16, 12, 0, 0);
      final end = CalDateTime.local(2025, 1, 17, 15, 0, 0);
      final results = [todo].occurrences(start: start, end: end).toList();

      // Jan 15 09:00-18:00 (ends before range)
      // Jan 16 09:00-18:00 (overlaps range)
      // Jan 17 09:00-18:00 (starts before range end at 15:00)
      expect(results.length, 2);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 16, 9, 0, 0));
      expect(results[1].occurrence, CalDateTime.local(2025, 1, 17, 9, 0, 0));
    });

    test('Monthly recurring todo with long duration', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:test-monthly-todo-long
DTSTAMP:20250101T000000Z
DTSTART:20250101T000000
DURATION:P15D
RRULE:FREQ=MONTHLY;COUNT=3
SUMMARY:Monthly Project Phase
END:VTODO''');

      final start = CalDateTime.date(2025, 1, 10);
      final end = CalDateTime.date(2025, 2, 10);
      final results = [todo].occurrences(start: start, end: end).toList();

      // Jan 1 00:00 + 15d = Jan 16 00:00 (overlaps range start)
      // Feb 1 00:00 + 15d = Feb 16 00:00 (overlaps range)
      expect(results.length, 2);
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 1));
      expect(results[1].occurrence, CalDateTime.local(2025, 2, 1));
    });
  });

  group('Chronological Ordering', () {
    test('Multiple events with different frequencies in chronological order', () {
      final parser = CalendarParser();

      // Daily event starting Jan 5 at 9am
      final dailyEvent = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:daily-event
DTSTAMP:20250101T000000Z
DTSTART:20250105T090000
DTEND:20250105T100000
SUMMARY:Daily Standup
RRULE:FREQ=DAILY
END:VEVENT''');

      // Hourly event starting Jan 10 at 8am
      final hourlyEvent = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:hourly-event
DTSTAMP:20250101T000000Z
DTSTART:20250110T080000
DTEND:20250110T083000
SUMMARY:Hourly Check
RRULE:FREQ=HOURLY
END:VEVENT''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [
        dailyEvent,
        hourlyEvent,
      ].occurrences(start: start, end: end).toList();

      // First 10 should be in chronological order
      expect(results[0].event.summary, 'Daily Standup');
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 5, 9, 0, 0));

      expect(results[1].event.summary, 'Daily Standup');
      expect(results[1].occurrence, CalDateTime.local(2025, 1, 6, 9, 0, 0));

      expect(results[2].event.summary, 'Daily Standup');
      expect(results[2].occurrence, CalDateTime.local(2025, 1, 7, 9, 0, 0));

      expect(results[3].event.summary, 'Daily Standup');
      expect(results[3].occurrence, CalDateTime.local(2025, 1, 8, 9, 0, 0));

      expect(results[4].event.summary, 'Daily Standup');
      expect(results[4].occurrence, CalDateTime.local(2025, 1, 9, 9, 0, 0));

      // Then hourly event starts on Jan 10 at 8am (before daily at 9am)
      expect(results[5].event.summary, 'Hourly Check');
      expect(results[5].occurrence, CalDateTime.local(2025, 1, 10, 8, 0, 0));

      // Both daily and hourly occur at 9am on Jan 10
      expect(results[6].event.summary, 'Daily Standup');
      expect(results[6].occurrence, CalDateTime.local(2025, 1, 10, 9, 0, 0));

      expect(results[7].event.summary, 'Hourly Check');
      expect(results[7].occurrence, CalDateTime.local(2025, 1, 10, 9, 0, 0));

      expect(results[8].event.summary, 'Hourly Check');
      expect(results[8].occurrence, CalDateTime.local(2025, 1, 10, 10, 0, 0));

      expect(results[9].event.summary, 'Hourly Check');
      expect(results[9].occurrence, CalDateTime.local(2025, 1, 10, 11, 0, 0));

      // Verify total counts: 27 daily (Jan 5-31) + 520 hourly (Jan 10-31, 22 hours/day)
      final dailyCount = results
          .where((r) => r.event.summary == 'Daily Standup')
          .length;
      final hourlyCount = results
          .where((r) => r.event.summary == 'Hourly Check')
          .length;

      expect(dailyCount, 27);

      // Jan 10: 8am-11pm = 16 hours
      // Jan 11-30: 20 days × 24 hours = 480
      // Jan 31: 12am-11pm = 24
      // Total = 16 + 480 + 24 = 520
      expect(hourlyCount, 520);
    });

    test('Simultaneous occurrences maintain stable order', () {
      final parser = CalendarParser();

      // Three events all starting at exactly 10am on Jan 15
      final event1 = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:event-1
DTSTAMP:20250101T000000Z
DTSTART:20250115T100000
DTEND:20250115T110000
SUMMARY:Event One
END:VEVENT''');

      final event2 = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:event-2
DTSTAMP:20250101T000000Z
DTSTART:20250115T100000
DTEND:20250115T110000
SUMMARY:Event Two
END:VEVENT''');

      final event3 = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:event-3
DTSTAMP:20250101T000000Z
DTSTART:20250115T100000
DTEND:20250115T110000
SUMMARY:Event Three
END:VEVENT''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [
        event1,
        event2,
        event3,
      ].occurrences(start: start, end: end).toList();

      expect(results.length, 3);
      // Should maintain insertion order when times are identical
      expect(results[0].event.summary, 'Event One');
      expect(results[1].event.summary, 'Event Two');
      expect(results[2].event.summary, 'Event Three');
    });

    test('Mixed recurring and non-recurring events in order', () {
      final parser = CalendarParser();

      // Non-recurring event on Jan 10 at 2pm
      final singleEvent = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:single-event
DTSTAMP:20250101T000000Z
DTSTART:20250110T140000
DTEND:20250110T150000
SUMMARY:Single Meeting
END:VEVENT''');

      // Daily event starting Jan 8 at 9am
      final dailyEvent = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:daily-event
DTSTAMP:20250101T000000Z
DTSTART:20250108T090000
DTEND:20250108T100000
SUMMARY:Daily Standup
RRULE:FREQ=DAILY;COUNT=5
END:VEVENT''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [
        singleEvent,
        dailyEvent,
      ].occurrences(start: start, end: end).toList();

      expect(results.length, 6);

      // Jan 8, 9 daily standups first
      expect(results[0].event.summary, 'Daily Standup');
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 8, 9, 0, 0));

      expect(results[1].event.summary, 'Daily Standup');
      expect(results[1].occurrence, CalDateTime.local(2025, 1, 9, 9, 0, 0));

      // Jan 10 daily at 9am, then single at 2pm
      expect(results[2].event.summary, 'Daily Standup');
      expect(results[2].occurrence, CalDateTime.local(2025, 1, 10, 9, 0, 0));

      expect(results[3].event.summary, 'Single Meeting');
      expect(results[3].occurrence, CalDateTime.local(2025, 1, 10, 14, 0, 0));

      // Jan 11, 12 daily standups
      expect(results[4].event.summary, 'Daily Standup');
      expect(results[4].occurrence, CalDateTime.local(2025, 1, 11, 9, 0, 0));

      expect(results[5].event.summary, 'Daily Standup');
      expect(results[5].occurrence, CalDateTime.local(2025, 1, 12, 9, 0, 0));
    });

    test('Todos with different frequencies in chronological order', () {
      final parser = CalendarParser();

      // Weekly todo starting Jan 1
      final weeklyTodo = parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:weekly-todo
DTSTAMP:20250101T000000Z
DTSTART:20250101T100000
DURATION:PT2H
SUMMARY:Weekly Review
RRULE:FREQ=WEEKLY;COUNT=4
END:VTODO''');

      // Daily todo starting Jan 5
      final dailyTodo = parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:daily-todo
DTSTAMP:20250101T000000Z
DTSTART:20250105T090000
DURATION:PT1H
SUMMARY:Daily Task
RRULE:FREQ=DAILY;COUNT=10
END:VTODO''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [
        weeklyTodo,
        dailyTodo,
      ].occurrences(start: start, end: end).toList();

      expect(results.length, 14); // 4 weekly + 10 daily

      // First should be weekly on Jan 1 at 10am
      expect(results[0].todo.summary, 'Weekly Review');
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 1, 10, 0, 0));

      // Then daily tasks start Jan 5 at 9am
      expect(results[1].todo.summary, 'Daily Task');
      expect(results[1].occurrence, CalDateTime.local(2025, 1, 5, 9, 0, 0));

      // Jan 6, 7 dailies
      expect(results[2].todo.summary, 'Daily Task');
      expect(results[3].todo.summary, 'Daily Task');

      // Jan 8 daily at 9am, then weekly at 10am
      expect(results[4].todo.summary, 'Daily Task');
      expect(results[4].occurrence, CalDateTime.local(2025, 1, 8, 9, 0, 0));

      expect(results[5].todo.summary, 'Weekly Review');
      expect(results[5].occurrence, CalDateTime.local(2025, 1, 8, 10, 0, 0));

      // Verify chronological order
      for (var i = 1; i < results.length; i++) {
        expect(
          results[i].occurrence.compareTo(results[i - 1].occurrence) >= 0,
          isTrue,
          reason:
              'Occurrence at index $i should be >= occurrence at index ${i - 1}',
        );
      }
    });

    test('Journals with overlapping occurrences in order', () {
      final parser = CalendarParser();

      // Journal every 2 hours starting Jan 10 at midnight
      final frequentJournal = parser.parseComponentFromString<JournalComponent>(
        '''
BEGIN:VJOURNAL
UID:frequent-journal
DTSTAMP:20250101T000000Z
DTSTART:20250110T000000
SUMMARY:Frequent Log
RRULE:FREQ=HOURLY;INTERVAL=2;COUNT=12
END:VJOURNAL''',
      );

      // Journal daily at 3am starting Jan 9
      final dailyJournal = parser.parseComponentFromString<JournalComponent>('''
BEGIN:VJOURNAL
UID:daily-journal
DTSTAMP:20250101T000000Z
DTSTART:20250109T030000
SUMMARY:Daily Reflection
RRULE:FREQ=DAILY;COUNT=5
END:VJOURNAL''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [
        frequentJournal,
        dailyJournal,
      ].occurrences(start: start, end: end).toList();

      expect(results.length, 17); // 12 frequent + 5 daily

      // First should be daily on Jan 9 at 3am
      expect(results[0].journal.summary, 'Daily Reflection');
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 9, 3, 0, 0));

      // Then frequent starts Jan 10 at midnight
      expect(results[1].journal.summary, 'Frequent Log');
      expect(results[1].occurrence, CalDateTime.local(2025, 1, 10));

      // Daily at 3am Jan 10
      expect(results[3].journal.summary, 'Daily Reflection');
      expect(results[3].occurrence, CalDateTime.local(2025, 1, 10, 3, 0, 0));

      // Verify all in chronological order
      for (var i = 1; i < results.length; i++) {
        expect(
          results[i].occurrence.compareTo(results[i - 1].occurrence) >= 0,
          isTrue,
          reason: 'Journal at index $i should be >= journal at index ${i - 1}',
        );
      }
    });

    test('Timezones with multiple transitions in chronological order', () {
      final parser = CalendarParser();

      // Parse a complete timezone with both standard and daylight rules
      final timezone = parser.parseComponentFromString<TimeZoneComponent>('''
BEGIN:VTIMEZONE
TZID:Test/Zone
BEGIN:STANDARD
DTSTART:20251102T020000
TZOFFSETFROM:-0400
TZOFFSETTO:-0500
RRULE:FREQ=YEARLY;BYMONTH=11;BYDAY=1SU
END:STANDARD
BEGIN:DAYLIGHT
DTSTART:20250309T020000
TZOFFSETFROM:-0500
TZOFFSETTO:-0400
RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=2SU
END:DAYLIGHT
END:VTIMEZONE''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 12, 31);

      // Combine both standard and daylight sub-components
      final allRules = [...timezone.standard, ...timezone.daylight];

      final results = allRules.occurrences(start: start, end: end).toList();

      expect(results.length, 2);

      // Daylight starts in March (offset to -4 hours)
      expect(results[0].timezone.tzoffsetTo.hours, 4);
      expect(results[0].timezone.tzoffsetTo.sign, Sign.negative);
      expect(results[0].occurrence, CalDateTime.local(2025, 3, 9, 2, 0, 0));

      // Standard starts in November (offset to -5 hours)
      expect(results[1].timezone.tzoffsetTo.hours, 5);
      expect(results[1].timezone.tzoffsetTo.sign, Sign.negative);
      expect(results[1].occurrence, CalDateTime.local(2025, 11, 2, 2, 0, 0));
    });

    test('Empty components list returns empty results', () {
      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);

      final events = <EventComponent>[]
          .occurrences(start: start, end: end)
          .toList();
      final todos = <TodoComponent>[]
          .occurrences(start: start, end: end)
          .toList();
      final journals = <JournalComponent>[]
          .occurrences(start: start, end: end)
          .toList();
      final timezones = <TimeZoneSubComponent>[]
          .occurrences(start: start, end: end)
          .toList();

      expect(events.length, 0);
      expect(todos.length, 0);
      expect(journals.length, 0);
      expect(timezones.length, 0);
    });

    test('Todos without DTSTART use DUE for occurrences', () {
      final parser = CalendarParser();

      // Todo without DTSTART (use DUE instead)
      final noDtstartTodo = parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:no-dtstart
DTSTAMP:20250101T000000Z
DUE:20250115T100000
SUMMARY:No Start Time
END:VTODO''');

      // Valid todo with DTSTART
      final validTodo = parser.parseComponentFromString<TodoComponent>('''
BEGIN:VTODO
UID:valid-todo
DTSTAMP:20250101T000000Z
DTSTART:20250115T100000
DURATION:PT1H
SUMMARY:Valid Todo
END:VTODO''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [
        noDtstartTodo,
        validTodo,
      ].occurrences(start: start, end: end).toList();

      expect(results.length, 2);
      expect(results[0].todo.summary, 'No Start Time');
      expect(results[0].occurrence, CalDateTime.local(2025, 1, 15, 10, 0, 0));
      expect(results[1].todo.summary, 'Valid Todo');
      expect(results[1].occurrence, CalDateTime.local(2025, 1, 15, 10, 0, 0));
    });

    test('Large number of components maintains order efficiently', () {
      final parser = CalendarParser();
      final events = <EventComponent>[];

      // Create 50 events with different start dates (days in Jan and Feb)
      for (var i = 1; i <= 50; i++) {
        final day = i <= 31 ? i : i - 31;
        final month = i <= 31 ? 1 : 2;
        final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:event-$i
DTSTAMP:20250101T000000Z
DTSTART:2025${month.toString().padLeft(2, '0')}${day.toString().padLeft(2, '0')}T100000
DTEND:2025${month.toString().padLeft(2, '0')}${day.toString().padLeft(2, '0')}T110000
SUMMARY:Event $i
END:VEVENT''');
        events.add(event);
      }

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 3, 31);
      final results = events.occurrences(start: start, end: end).toList();

      expect(results.length, 50);

      // Verify chronological order
      for (var i = 1; i < results.length; i++) {
        expect(
          results[i].occurrence.compareTo(results[i - 1].occurrence) >= 0,
          isTrue,
          reason: 'Event $i should occur at or after event ${i - 1}',
        );
      }
    });

    test('Recurring events with exceptions maintain order', () {
      final parser = CalendarParser();

      // Daily event with some exceptions
      final eventWithExceptions = parser
          .parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:event-with-exdates
DTSTAMP:20250101T000000Z
DTSTART:20250105T090000
DTEND:20250105T100000
SUMMARY:Daily Standup
RRULE:FREQ=DAILY;COUNT=10
EXDATE:20250107T090000,20250109T090000
END:VEVENT''');

      // Another daily event
      final normalEvent = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:normal-event
DTSTAMP:20250101T000000Z
DTSTART:20250107T140000
DTEND:20250107T150000
SUMMARY:Afternoon Meeting
RRULE:FREQ=DAILY;COUNT=3
END:VEVENT''');

      final start = CalDateTime.date(2025, 1, 1);
      final end = CalDateTime.date(2025, 1, 31);
      final results = [
        eventWithExceptions,
        normalEvent,
      ].occurrences(start: start, end: end).toList();

      // Should have 8 standups (10 - 2 excluded) + 3 meetings = 11
      expect(results.length, 11);

      // Verify no excluded dates appear
      final standupOccurrences = results
          .where((r) => r.event.summary == 'Daily Standup')
          .map((r) => r.occurrence)
          .toList();

      expect(
        standupOccurrences.contains(CalDateTime.local(2025, 1, 7, 9, 0, 0)),
        isFalse,
      );
      expect(
        standupOccurrences.contains(CalDateTime.local(2025, 1, 9, 9, 0, 0)),
        isFalse,
      );

      // Verify chronological order
      for (var i = 1; i < results.length; i++) {
        expect(
          results[i].occurrence.compareTo(results[i - 1].occurrence) >= 0,
          isTrue,
        );
      }
    });

    test(
      'Single event with time component on boundary date is included when using date-only boundary',
      () {
        final parser = CalendarParser();
        final event = parser.parseComponentFromString<EventComponent>('''
BEGIN:VEVENT
UID:event1@example.com
DTSTAMP:20250101T000000Z
DTSTART:20250131T150000
DTEND:20250131T160000
SUMMARY:End of Month Event
END:VEVENT''');

        final startDate = CalDateTime.date(2025, 1, 1);
        final endDate = CalDateTime.date(2025, 1, 31);

        final results = [
          event,
        ].occurrences(start: startDate, end: endDate).toList();

        // CalDateTime.date(2025, 1, 31) is treated as the entire day (00:00:00 to 23:59:59)
        // so the event at 15:00:00 on Jan 31 should be included
        expect(results.length, equals(1));
        expect(
          results[0].occurrence,
          equals(CalDateTime.local(2025, 1, 31, 15, 0, 0)),
        );
        expect(results[0].event.summary, equals('End of Month Event'));
      },
    );
  });
}
