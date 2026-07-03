import 'package:firstfloor_calendar/firstfloor_calendar.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
  });
  group('EventComponentExtensions', () {
    test('isRecurring returns true when rrule is present', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:test-1\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250101T100000\r\n'
        'RRULE:FREQ=DAILY;COUNT=5\r\n'
        'END:VEVENT',
      );

      expect(event.isRecurring, isTrue);
    });

    test('isRecurring returns false when no recurrence', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:test-2\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250101T100000\r\n'
        'END:VEVENT',
      );

      expect(event.isRecurring, isFalse);
    });

    test('isAllDay returns true for date-only DTSTART', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:test-allday-1\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART;VALUE=DATE:20250115\r\n'
        'END:VEVENT',
      );

      expect(event.isAllDay, isTrue);
    });

    test('isAllDay returns false for datetime DTSTART', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:test-allday-2\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250115T100000\r\n'
        'END:VEVENT',
      );

      expect(event.isAllDay, isFalse);
    });

    test('isAllDay returns false when DTSTART is null', () {
      // Create an event without DTSTART property
      final event = EventComponent(properties: {}, components: []);

      expect(event.isAllDay, isFalse);
    });

    test('isAllDay returns true for date-only DTSTART with timezone', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:test-allday-3\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART;VALUE=DATE;TZID=America/New_York:20250115\r\n'
        'END:VEVENT',
      );

      expect(event.isAllDay, isTrue);
    });

    test('isAllDay returns false for UTC datetime', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:test-allday-4\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250115T100000Z\r\n'
        'END:VEVENT',
      );

      expect(event.isAllDay, isFalse);
    });

    test('isMultiDay returns true for event with duration >= 1 day', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:test-multiday-1\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250115T100000\r\n'
        'DURATION:P2D\r\n'
        'END:VEVENT',
      );

      expect(event.isMultiDay, isTrue);
    });

    test('isMultiDay returns true for event crossing midnight', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:test-multiday-2\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250115T230000\r\n'
        'DTEND:20250116T010000\r\n'
        'END:VEVENT',
      );

      expect(event.isMultiDay, isTrue);
    });

    test('isMultiDay returns false for single-day event', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:test-multiday-3\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250115T100000\r\n'
        'DTEND:20250115T110000\r\n'
        'END:VEVENT',
      );

      expect(event.isMultiDay, isFalse);
    });

    test('isMultiDay returns false when no duration or end time', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:test-multiday-4\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250115T100000\r\n'
        'END:VEVENT',
      );

      expect(event.isMultiDay, isFalse);
    });

    test(
      'isMultiDay returns true for all-day event spanning multiple days',
      () {
        final parser = CalendarParser();
        final event = parser.parseComponentFromString<EventComponent>(
          'BEGIN:VEVENT\r\n'
          'UID:test-multiday-5\r\n'
          'DTSTAMP:20250101T000000Z\r\n'
          'DTSTART;VALUE=DATE:20250115\r\n'
          'DTEND;VALUE=DATE:20250117\r\n'
          'END:VEVENT',
        );

        expect(event.isMultiDay, isTrue);
      },
    );

    test('isMultiDay returns false for single all-day event', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:test-multiday-6\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART;VALUE=DATE:20250115\r\n'
        'DTEND;VALUE=DATE:20250116\r\n'
        'END:VEVENT',
      );

      // All-day event from Jan 15 to Jan 16 (exclusive) is a single day
      expect(event.isMultiDay, isFalse);
    });

    test('isMultiDay returns false for single all-day event without end', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:test-multiday-7\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART;VALUE=DATE:20250115\r\n'
        'END:VEVENT',
      );

      // Single all-day event with no end date is not multi-day
      expect(event.isMultiDay, isFalse);
    });

    test('effectiveEnd returns dtend when present', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:test-end-1\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250115T100000\r\n'
        'DTEND:20250115T110000\r\n'
        'END:VEVENT',
      );

      expect(event.effectiveEnd, CalDateTime.local(2025, 1, 15, 11, 0, 0));
    });

    test('effectiveEnd calculates from dtstart + duration when no dtend', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:test-end-2\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250115T100000\r\n'
        'DURATION:PT2H30M\r\n'
        'END:VEVENT',
      );

      expect(event.effectiveEnd, CalDateTime.local(2025, 1, 15, 12, 30, 0));
    });

    test('effectiveEnd prefers dtend over duration when both present', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:test-end-3\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250115T100000\r\n'
        'DTEND:20250115T120000\r\n'
        'DURATION:PT1H\r\n'
        'END:VEVENT',
      );

      expect(event.effectiveEnd, CalDateTime.local(2025, 1, 15, 12, 0, 0));
    });

    test('effectiveEnd returns null when no dtend or duration', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:test-end-4\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250115T100000\r\n'
        'END:VEVENT',
      );

      expect(event.effectiveEnd, isNull);
    });

    test(
      'effectiveEnd returns null when dtstart is null but duration present',
      () {
        // Create an event without DTSTART property
        final event = EventComponent(properties: {}, components: []);

        expect(event.effectiveEnd, isNull);
      },
    );

    test('effectiveEnd handles multi-day duration', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:test-end-6\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250115T100000\r\n'
        'DURATION:P2DT5H\r\n'
        'END:VEVENT',
      );

      expect(event.effectiveEnd, CalDateTime.local(2025, 1, 17, 15, 0, 0));
    });

    test('effectiveEnd handles negative duration', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:test-end-7\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250115T100000\r\n'
        'DURATION:-PT1H\r\n'
        'END:VEVENT',
      );

      expect(event.effectiveEnd, CalDateTime.local(2025, 1, 15, 9, 0, 0));
    });

    test('effectiveDuration returns duration when present', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:test-duration-1\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250115T100000\r\n'
        'DURATION:PT2H30M\r\n'
        'END:VEVENT',
      );

      expect(event.effectiveDuration, isNotNull);
      expect(event.effectiveDuration!.hours, 2);
      expect(event.effectiveDuration!.minutes, 30);
    });

    test('effectiveDuration calculates from dtend when no duration', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:test-duration-2\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250115T100000\r\n'
        'DTEND:20250115T130000\r\n'
        'END:VEVENT',
      );

      expect(event.effectiveDuration, isNotNull);
      expect(event.effectiveDuration!.hours, 3);
      expect(event.effectiveDuration!.minutes, 0);
    });

    test('effectiveDuration prefers duration over dtend when both present', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:test-duration-3\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250115T100000\r\n'
        'DTEND:20250115T120000\r\n'
        'DURATION:PT1H\r\n'
        'END:VEVENT',
      );

      expect(event.effectiveDuration, isNotNull);
      expect(event.effectiveDuration!.hours, 1);
      expect(event.effectiveDuration!.minutes, 0);
    });

    test('effectiveDuration returns null when no duration or dtend', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:test-duration-4\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250115T100000\r\n'
        'END:VEVENT',
      );

      expect(event.effectiveDuration, isNull);
    });

    test('effectiveDuration returns null when dtstart is null', () {
      final event = EventComponent(properties: {}, components: []);
      expect(event.effectiveDuration, isNull);
    });

    test('effectiveDuration handles multi-day duration', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:test-duration-5\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250115T100000\r\n'
        'DURATION:P2DT5H\r\n'
        'END:VEVENT',
      );

      expect(event.effectiveDuration, isNotNull);
      expect(event.effectiveDuration!.days, 2);
      expect(event.effectiveDuration!.hours, 5);
    });

    test('effectiveDuration calculates from multi-day dtend', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:test-duration-6\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250115T100000\r\n'
        'DTEND:20250117T150000\r\n'
        'END:VEVENT',
      );

      expect(event.effectiveDuration, isNotNull);
      expect(event.effectiveDuration!.days, 2);
      expect(event.effectiveDuration!.hours, 5);
    });

    test('effectiveDuration handles negative duration', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:test-duration-7\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250115T100000\r\n'
        'DURATION:-PT1H\r\n'
        'END:VEVENT',
      );

      expect(event.effectiveDuration, isNotNull);
      expect(event.effectiveDuration!.sign, Sign.negative);
      expect(event.effectiveDuration!.hours, 1);
    });

    test('effectiveDuration calculates negative from dtend before dtstart', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:test-duration-8\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250115T100000\r\n'
        'DTEND:20250115T090000\r\n'
        'END:VEVENT',
      );

      expect(event.effectiveDuration, isNotNull);
      expect(event.effectiveDuration!.sign, Sign.negative);
      expect(event.effectiveDuration!.hours, 1);
    });

    test('occurrences generates correct occurrences', () {
      final parser = CalendarParser();
      final event = parser.parseComponentFromString<EventComponent>(
        'BEGIN:VEVENT\r\n'
        'UID:test-3\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250101T100000\r\n'
        'RRULE:FREQ=DAILY;COUNT=3\r\n'
        'END:VEVENT',
      );

      final occurrences = event.occurrences().toList();
      expect(occurrences.length, 3);
      expect(occurrences[0], CalDateTime.local(2025, 1, 1, 10, 0, 0));
      expect(occurrences[1], CalDateTime.local(2025, 1, 2, 10, 0, 0));
      expect(occurrences[2], CalDateTime.local(2025, 1, 3, 10, 0, 0));
    });

    test('occurrences returns empty iterable when DTSTART is null', () {
      // Create an event without DTSTART property
      final event = EventComponent(properties: {}, components: []);

      final occurrences = event.occurrences().toList();
      expect(occurrences, isEmpty);
    });
  });

  group('TodoComponentExtensions', () {
    test('isRecurring returns true when rrule is present', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>(
        'BEGIN:VTODO\r\n'
        'UID:test-todo-1\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250101T100000\r\n'
        'RRULE:FREQ=WEEKLY;COUNT=4\r\n'
        'END:VTODO',
      );

      expect(todo.isRecurring, isTrue);
    });

    test('isRecurring returns false when no recurrence', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>(
        'BEGIN:VTODO\r\n'
        'UID:test-todo-2\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250101T100000\r\n'
        'END:VTODO',
      );

      expect(todo.isRecurring, isFalse);
    });

    test('occurrences generates correct occurrences', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>(
        'BEGIN:VTODO\r\n'
        'UID:test-todo-3\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250101T100000\r\n'
        'RRULE:FREQ=DAILY;COUNT=2\r\n'
        'END:VTODO',
      );

      final occurrences = todo.occurrences().toList();
      expect(occurrences.length, 2);
      expect(occurrences[0], CalDateTime.local(2025, 1, 1, 10, 0, 0));
      expect(occurrences[1], CalDateTime.local(2025, 1, 2, 10, 0, 0));
    });

    test(
      'occurrences returns empty iterable when DTSTART and DUE are null',
      () {
        final todo = TodoComponent(properties: {}, components: []);

        final occurrences = todo.occurrences().toList();
        expect(occurrences, isEmpty);
      },
    );

    test('occurrences uses DUE when DTSTART is null', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>(
        'BEGIN:VTODO\r\n'
        'UID:test-todo-due-fallback\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DUE:20250115T140000\r\n'
        'END:VTODO',
      );

      final occurrences = todo.occurrences().toList();
      expect(occurrences.length, 1);
      expect(occurrences[0], CalDateTime.local(2025, 1, 15, 14, 0, 0));
    });

    test('effectiveDuration returns duration when present', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>(
        'BEGIN:VTODO\r\n'
        'UID:test-todo-duration-1\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250115T100000\r\n'
        'DURATION:PT3H\r\n'
        'END:VTODO',
      );

      expect(todo.effectiveDuration, isNotNull);
      expect(todo.effectiveDuration!.hours, 3);
    });

    test('effectiveDuration calculates from due when no duration', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>(
        'BEGIN:VTODO\r\n'
        'UID:test-todo-duration-2\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250115T100000\r\n'
        'DUE:20250115T140000\r\n'
        'END:VTODO',
      );

      expect(todo.effectiveDuration, isNotNull);
      expect(todo.effectiveDuration!.hours, 4);
    });

    test('effectiveDuration prefers duration over due when both present', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>(
        'BEGIN:VTODO\r\n'
        'UID:test-todo-duration-3\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250115T100000\r\n'
        'DUE:20250115T130000\r\n'
        'DURATION:PT2H\r\n'
        'END:VTODO',
      );

      expect(todo.effectiveDuration, isNotNull);
      expect(todo.effectiveDuration!.hours, 2);
    });

    test('effectiveDuration returns null when no duration or due', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>(
        'BEGIN:VTODO\r\n'
        'UID:test-todo-duration-4\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250115T100000\r\n'
        'END:VTODO',
      );

      expect(todo.effectiveDuration, isNull);
    });

    test('effectiveDuration returns null when dtstart is null', () {
      final todo = TodoComponent(properties: {}, components: []);
      expect(todo.effectiveDuration, isNull);
    });

    test('effectiveDuration handles multi-day duration', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>(
        'BEGIN:VTODO\r\n'
        'UID:test-todo-duration-5\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250115T100000\r\n'
        'DURATION:P3DT2H30M\r\n'
        'END:VTODO',
      );

      expect(todo.effectiveDuration, isNotNull);
      expect(todo.effectiveDuration!.days, 3);
      expect(todo.effectiveDuration!.hours, 2);
      expect(todo.effectiveDuration!.minutes, 30);
    });

    test('effectiveDuration calculates from multi-day due', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>(
        'BEGIN:VTODO\r\n'
        'UID:test-todo-duration-6\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250115T100000\r\n'
        'DUE:20250118T123000\r\n'
        'END:VTODO',
      );

      expect(todo.effectiveDuration, isNotNull);
      expect(todo.effectiveDuration!.days, 3);
      expect(todo.effectiveDuration!.hours, 2);
      expect(todo.effectiveDuration!.minutes, 30);
    });

    test('effectiveDuration returns null when due before dtstart', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>(
        'BEGIN:VTODO\r\n'
        'UID:test-todo-duration-7\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250115T100000\r\n'
        'DUE:20250115T090000\r\n'
        'END:VTODO',
      );

      expect(todo.effectiveDuration, isNotNull);
      expect(todo.effectiveDuration!.sign, Sign.negative);
      expect(todo.effectiveDuration!.hours, 1);
    });

    test('isMultiDay returns true for todo with duration >= 1 day', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>(
        'BEGIN:VTODO\r\n'
        'UID:test-multiday-todo-1\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250115T100000\r\n'
        'DURATION:P2D\r\n'
        'END:VTODO',
      );

      expect(todo.isMultiDay, isTrue);
    });

    test('isMultiDay returns true for todo crossing midnight', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>(
        'BEGIN:VTODO\r\n'
        'UID:test-multiday-todo-2\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250115T230000\r\n'
        'DUE:20250116T010000\r\n'
        'END:VTODO',
      );

      expect(todo.isMultiDay, isTrue);
    });

    test('isMultiDay returns false for single-day todo', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>(
        'BEGIN:VTODO\r\n'
        'UID:test-multiday-todo-3\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250115T100000\r\n'
        'DUE:20250115T140000\r\n'
        'END:VTODO',
      );

      expect(todo.isMultiDay, isFalse);
    });

    test('isMultiDay returns false when no duration or due date', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>(
        'BEGIN:VTODO\r\n'
        'UID:test-multiday-todo-4\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250115T100000\r\n'
        'END:VTODO',
      );

      expect(todo.isMultiDay, isFalse);
    });

    test('isMultiDay returns true for all-day todo spanning multiple days', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>(
        'BEGIN:VTODO\r\n'
        'UID:test-multiday-todo-5\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART;VALUE=DATE:20250115\r\n'
        'DUE;VALUE=DATE:20250118\r\n'
        'END:VTODO',
      );

      expect(todo.isMultiDay, isTrue);
    });

    test('isMultiDay returns false for single all-day todo', () {
      final parser = CalendarParser();
      final todo = parser.parseComponentFromString<TodoComponent>(
        'BEGIN:VTODO\r\n'
        'UID:test-multiday-todo-6\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART;VALUE=DATE:20250115\r\n'
        'DUE;VALUE=DATE:20250116\r\n'
        'END:VTODO',
      );

      // All-day todo from Jan 15 to Jan 16 (exclusive) is a single day
      expect(todo.isMultiDay, isFalse);
    });
  });

  group('JournalComponentExtensions', () {
    test('isRecurring returns true when rrule is present', () {
      final parser = CalendarParser();
      final journal = parser.parseComponentFromString<JournalComponent>(
        'BEGIN:VJOURNAL\r\n'
        'UID:test-journal-1\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250101T100000\r\n'
        'RRULE:FREQ=DAILY;COUNT=2\r\n'
        'END:VJOURNAL',
      );

      expect(journal.isRecurring, isTrue);
    });

    test('isRecurring returns false when no recurrence', () {
      final parser = CalendarParser();
      final journal = parser.parseComponentFromString<JournalComponent>(
        'BEGIN:VJOURNAL\r\n'
        'UID:test-journal-2\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250101T100000\r\n'
        'END:VJOURNAL',
      );

      expect(journal.isRecurring, isFalse);
    });

    test('occurrences generates correct occurrences', () {
      final parser = CalendarParser();
      final journal = parser.parseComponentFromString<JournalComponent>(
        'BEGIN:VJOURNAL\r\n'
        'UID:test-journal-3\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250101T100000\r\n'
        'RRULE:FREQ=DAILY;COUNT=2\r\n'
        'END:VJOURNAL',
      );

      final occurrences = journal.occurrences().toList();
      expect(occurrences.length, 2);
      expect(occurrences[0], CalDateTime.local(2025, 1, 1, 10, 0, 0));
      expect(occurrences[1], CalDateTime.local(2025, 1, 2, 10, 0, 0));
    });

    test('occurrences returns empty iterable when DTSTART is null', () {
      // Create a journal without DTSTART property
      final journal = JournalComponent(properties: {}, components: []);

      final occurrences = journal.occurrences().toList();
      expect(occurrences, isEmpty);
    });
  });

  group('CalendarDocumentComponentExtensions', () {
    test('isEvent returns true for VEVENT', () {
      final component = CalendarDocumentComponent(
        name: 'VEVENT',
        properties: [],
        components: [],
      );

      expect(component.isEvent, isTrue);
      expect(component.isTodo, isFalse);
      expect(component.isJournal, isFalse);
      expect(component.isFreeBusy, isFalse);
      expect(component.isTimezone, isFalse);
      expect(component.isAlarm, isFalse);
    });

    test('isTodo returns true for VTODO', () {
      final component = CalendarDocumentComponent(
        name: 'VTODO',
        properties: [],
        components: [],
      );

      expect(component.isTodo, isTrue);
      expect(component.isEvent, isFalse);
    });

    test('isJournal returns true for VJOURNAL', () {
      final component = CalendarDocumentComponent(
        name: 'VJOURNAL',
        properties: [],
        components: [],
      );

      expect(component.isJournal, isTrue);
      expect(component.isEvent, isFalse);
    });

    test('isFreeBusy returns true for VFREEBUSY', () {
      final component = CalendarDocumentComponent(
        name: 'VFREEBUSY',
        properties: [],
        components: [],
      );

      expect(component.isFreeBusy, isTrue);
      expect(component.isEvent, isFalse);
    });

    test('isTimezone returns true for VTIMEZONE', () {
      final component = CalendarDocumentComponent(
        name: 'VTIMEZONE',
        properties: [],
        components: [],
      );

      expect(component.isTimezone, isTrue);
      expect(component.isEvent, isFalse);
    });

    test('isAlarm returns true for VALARM', () {
      final component = CalendarDocumentComponent(
        name: 'VALARM',
        properties: [],
        components: [],
      );

      expect(component.isAlarm, isTrue);
      expect(component.isEvent, isFalse);
    });

    test('toEvent converts VEVENT to EventComponent', () {
      final parser = DocumentParser();
      final component = parser.parseComponent(
        'BEGIN:VEVENT\r\n'
        'UID:test-5\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250101T100000\r\n'
        'SUMMARY:Test Event\r\n'
        'END:VEVENT',
      );

      final event = component.toEvent();
      expect(event, isA<EventComponent>());
      expect(event.summary, 'Test Event');
    });

    test('toEvent throws exception for non-event component', () {
      final component = CalendarDocumentComponent(
        name: 'VTODO',
        properties: [],
        components: [],
      );

      expect(() => component.toEvent(), throwsException);
    });

    test('toTodo converts VTODO to TodoComponent', () {
      final parser = DocumentParser();
      final component = parser.parseComponent(
        'BEGIN:VTODO\r\n'
        'UID:test-todo\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'SUMMARY:Test Todo\r\n'
        'END:VTODO',
      );

      final todo = component.toTodo();
      expect(todo, isA<TodoComponent>());
      expect(todo.summary, 'Test Todo');
    });

    test('toTodo throws exception for non-todo component', () {
      final component = CalendarDocumentComponent(
        name: 'VEVENT',
        properties: [],
        components: [],
      );

      expect(() => component.toTodo(), throwsException);
    });

    test('toJournal converts VJOURNAL to JournalComponent', () {
      final parser = DocumentParser();
      final component = parser.parseComponent(
        'BEGIN:VJOURNAL\r\n'
        'UID:test-journal\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'SUMMARY:Test Journal\r\n'
        'END:VJOURNAL',
      );

      final journal = component.toJournal();
      expect(journal, isA<JournalComponent>());
      expect(journal.summary, 'Test Journal');
    });

    test('toJournal throws exception for non-journal component', () {
      final component = CalendarDocumentComponent(
        name: 'VEVENT',
        properties: [],
        components: [],
      );

      expect(() => component.toJournal(), throwsException);
    });

    test('toFreeBusy converts VFREEBUSY to FreeBusyComponent', () {
      final parser = DocumentParser();
      final component = parser.parseComponent(
        'BEGIN:VFREEBUSY\r\n'
        'UID:test-freebusy\r\n'
        'DTSTAMP:20250101T000000Z\r\n'
        'DTSTART:20250101T080000Z\r\n'
        'DTEND:20250101T180000Z\r\n'
        'END:VFREEBUSY',
      );

      final freebusy = component.toFreeBusy();
      expect(freebusy, isA<FreeBusyComponent>());
      expect(freebusy.uid, 'test-freebusy');
    });

    test('toFreeBusy throws exception for non-freebusy component', () {
      final component = CalendarDocumentComponent(
        name: 'VEVENT',
        properties: [],
        components: [],
      );

      expect(() => component.toFreeBusy(), throwsException);
    });

    test('toTimeZone converts VTIMEZONE to TimeZoneComponent', () {
      final parser = DocumentParser();
      final component = parser.parseComponent(
        'BEGIN:VTIMEZONE\r\n'
        'TZID:America/New_York\r\n'
        'END:VTIMEZONE',
      );

      final timezone = component.toTimeZone();
      expect(timezone, isA<TimeZoneComponent>());
      expect(timezone.tzid, 'America/New_York');
    });

    test('toTimeZone throws exception for non-timezone component', () {
      final component = CalendarDocumentComponent(
        name: 'VEVENT',
        properties: [],
        components: [],
      );

      expect(() => component.toTimeZone(), throwsException);
    });

    test('toAlarm converts VALARM to AlarmComponent', () {
      final parser = DocumentParser();
      final component = parser.parseComponent(
        'BEGIN:VALARM\r\n'
        'ACTION:DISPLAY\r\n'
        'TRIGGER:-PT15M\r\n'
        'END:VALARM',
      );

      final alarm = component.toAlarm();
      expect(alarm, isA<AlarmComponent>());
      expect(alarm.actionName, 'DISPLAY');
    });

    test('toAlarm throws exception for non-alarm component', () {
      final component = CalendarDocumentComponent(
        name: 'VEVENT',
        properties: [],
        components: [],
      );

      expect(() => component.toAlarm(), throwsException);
    });
  });

  group('TimeZoneSubComponentExtensions', () {
    test('isRecurring returns true with RRULE', () {
      final ics = '''BEGIN:STANDARD
DTSTART:20250101T000000
TZOFFSETFROM:+0000
TZOFFSETTO:+0100
RRULE:FREQ=YEARLY
END:STANDARD''';
      final parser = CalendarParser();
      final component = parser.parseComponentFromString<TimeZoneSubComponent>(
        ics,
      );

      expect(component.isRecurring, isTrue);
    });

    test('isRecurring returns true with RDATE', () {
      final ics = '''BEGIN:STANDARD
DTSTART:20250101T000000
TZOFFSETFROM:+0000
TZOFFSETTO:+0100
RDATE:20260101T000000
END:STANDARD''';
      final parser = CalendarParser();
      final component = parser.parseComponentFromString<TimeZoneSubComponent>(
        ics,
      );

      expect(component.isRecurring, isTrue);
    });

    test('isRecurring returns false without RRULE or RDATE', () {
      final ics = '''BEGIN:STANDARD
DTSTART:20250101T000000
TZOFFSETFROM:+0000
TZOFFSETTO:+0100
END:STANDARD''';
      final parser = CalendarParser();
      final component = parser.parseComponentFromString<TimeZoneSubComponent>(
        ics,
      );

      expect(component.isRecurring, isFalse);
    });

    test('occurrences returns iterator results', () {
      final ics = '''BEGIN:STANDARD
DTSTART:20250101T000000
TZOFFSETFROM:+0000
TZOFFSETTO:+0100
RRULE:FREQ=YEARLY;COUNT=3
END:STANDARD''';
      final parser = CalendarParser();
      final component = parser.parseComponentFromString<TimeZoneSubComponent>(
        ics,
      );

      final occurrences = component.occurrences().toList();
      expect(occurrences.length, 3);
      expect(occurrences[0], CalDateTime.local(2025, 1, 1));
      expect(occurrences[1], CalDateTime.local(2026, 1, 1));
      expect(occurrences[2], CalDateTime.local(2027, 1, 1));
    });
  });
}
