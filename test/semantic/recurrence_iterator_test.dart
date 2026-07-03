import 'package:firstfloor_calendar/firstfloor_calendar.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart' as tz;

/// Helper to convert iterator occurrences to string list for easy comparison
List<String> occurrences(RecurrenceIterator iterator) {
  return iterator.occurrences().map((e) => e.toString()).toList();
}

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
  });

  group('RecurrenceIterator - Basic Frequency', () {
    test('SECONDLY with count', () {
      final dtstart = CalDateTime.local(2025, 1, 1, 10, 0, 0);
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.secondly,
        count: 5,
      );
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, [
        '20250101T100000',
        '20250101T100001',
        '20250101T100002',
        '20250101T100003',
        '20250101T100004',
      ]);
    });

    test('SECONDLY with interval', () {
      final dtstart = CalDateTime.local(2025, 1, 1, 10, 0, 0);
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.secondly,
        interval: 10,
        count: 3,
      );
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, ['20250101T100000', '20250101T100010', '20250101T100020']);
    });

    test('MINUTELY with count', () {
      final dtstart = CalDateTime.local(2025, 1, 1, 10, 0, 0);
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.minutely,
        count: 4,
      );
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, [
        '20250101T100000',
        '20250101T100100',
        '20250101T100200',
        '20250101T100300',
      ]);
    });

    test('MINUTELY with interval', () {
      final dtstart = CalDateTime.local(2025, 1, 1, 10, 0, 0);
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.minutely,
        interval: 15,
        count: 3,
      );
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, ['20250101T100000', '20250101T101500', '20250101T103000']);
    });

    test('HOURLY with count', () {
      final dtstart = CalDateTime.local(2025, 1, 1, 10, 0, 0);
      final rrule = RecurrenceRule(freq: RecurrenceFrequency.hourly, count: 3);
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, ['20250101T100000', '20250101T110000', '20250101T120000']);
    });

    test('HOURLY with interval', () {
      final dtstart = CalDateTime.local(2025, 1, 1, 10, 0, 0);
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.hourly,
        interval: 3,
        count: 4,
      );
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, [
        '20250101T100000',
        '20250101T130000',
        '20250101T160000',
        '20250101T190000',
      ]);
    });

    test('DAILY with count', () {
      final dtstart = CalDateTime.local(2025, 1, 1, 10, 0, 0);
      final rrule = RecurrenceRule(freq: RecurrenceFrequency.daily, count: 3);
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, ['20250101T100000', '20250102T100000', '20250103T100000']);
    });

    test('DAILY with interval', () {
      final dtstart = CalDateTime.date(2025, 1, 1);
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.daily,
        interval: 2,
        count: 3,
      );
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, ['20250101', '20250103', '20250105']);
    });

    test('WEEKLY with count', () {
      final dtstart = CalDateTime.date(2025, 1, 6); // Monday
      final rrule = RecurrenceRule(freq: RecurrenceFrequency.weekly, count: 3);
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, ['20250106', '20250113', '20250120']);
    });

    test('WEEKLY with interval', () {
      final dtstart = CalDateTime.date(2025, 1, 6); // Monday
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.weekly,
        interval: 2,
        count: 3,
      );
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, ['20250106', '20250120', '20250203']);
    });

    test('MONTHLY with count', () {
      final dtstart = CalDateTime.date(2025, 1, 15);
      final rrule = RecurrenceRule(freq: RecurrenceFrequency.monthly, count: 3);
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, ['20250115', '20250215', '20250315']);
    });

    test('MONTHLY with interval', () {
      final dtstart = CalDateTime.date(2025, 1, 15);
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.monthly,
        interval: 2,
        count: 3,
      );
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, ['20250115', '20250315', '20250515']);
    });

    test('YEARLY with count', () {
      final dtstart = CalDateTime.date(2025, 1, 15);
      final rrule = RecurrenceRule(freq: RecurrenceFrequency.yearly, count: 3);
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, ['20250115', '20260115', '20270115']);
    });

    test('YEARLY with interval', () {
      final dtstart = CalDateTime.date(2025, 1, 15);
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.yearly,
        interval: 2,
        count: 3,
      );
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, ['20250115', '20270115', '20290115']);
    });
  });

  group('RecurrenceIterator - UNTIL', () {
    test('DAILY with UNTIL date', () {
      final dtstart = CalDateTime.date(2025, 1, 1);
      final until = CalDateTime.date(2025, 1, 5);
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.daily,
        until: until,
      );
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, [
        '20250101',
        '20250102',
        '20250103',
        '20250104',
        '20250105',
      ]);
    });

    test('WEEKLY with UNTIL', () {
      final dtstart = CalDateTime.date(2025, 1, 6); // Monday
      final until = CalDateTime.date(2025, 2, 3); // 4 weeks later
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.weekly,
        until: until,
      );
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, [
        '20250106',
        '20250113',
        '20250120',
        '20250127',
        '20250203',
      ]);
    });

    test('UNTIL before dtstart returns only dtstart', () {
      final dtstart = CalDateTime.date(2025, 1, 10);
      final until = CalDateTime.date(2025, 1, 5);
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.daily,
        until: until,
      );
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, ['20250110']);
    });
  });

  group('RecurrenceIterator - BYMONTH', () {
    test('YEARLY with BYMONTH expands', () {
      final dtstart = CalDateTime.date(2025, 1, 15);
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.yearly,
        byMonth: {3, 6, 9},
        count: 6,
      );
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, [
        '20250315',
        '20250615',
        '20250915',
        '20260315',
        '20260615',
        '20260915',
      ]);
    });

    test('MONTHLY with BYMONTH limits', () {
      final dtstart = CalDateTime.date(2025, 1, 15);
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.monthly,
        byMonth: {3, 6},
        count: 4,
      );
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, ['20250315', '20250615', '20260315', '20260615']);
    });
  });

  group('RecurrenceIterator - BYMONTHDAY', () {
    test('MONTHLY with BYMONTHDAY positive', () {
      final dtstart = CalDateTime.date(2025, 1, 1);
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.monthly,
        byMonthDay: {15},
        count: 3,
      );
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, ['20250115', '20250215', '20250315']);
    });

    test('MONTHLY with BYMONTHDAY negative (last day)', () {
      final dtstart = CalDateTime.date(2025, 1, 1);
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.monthly,
        byMonthDay: {-1},
        count: 3,
      );
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, ['20250131', '20250228', '20250331']);
    });

    test('MONTHLY with multiple BYMONTHDAY values', () {
      final dtstart = CalDateTime.date(2025, 1, 1);
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.monthly,
        byMonthDay: {10, 20},
        count: 4,
      );
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, ['20250110', '20250120', '20250210', '20250220']);
    });
  });

  group('RecurrenceIterator - BYDAY', () {
    test('WEEKLY with BYDAY single weekday', () {
      final dtstart = CalDateTime.date(2025, 1, 6); // Monday
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.weekly,
        byDay: {ByDay(Weekday.mo)},
        count: 3,
      );
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, [
        '20250106', // Mon
        '20250113', // Mon
        '20250120', // Mon
      ]);
    });

    test('WEEKLY with BYDAY multiple weekdays', () {
      final dtstart = CalDateTime.date(2025, 1, 6); // Monday
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.weekly,
        byDay: {ByDay(Weekday.mo), ByDay(Weekday.we), ByDay(Weekday.fr)},
        count: 6,
      );
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, [
        '20250106', // Mon
        '20250108', // Wed
        '20250110', // Fri
        '20250113', // Mon
        '20250115', // Wed
        '20250117', // Fri
      ]);
    });

    test('MONTHLY with BYDAY and ordinal (first Monday)', () {
      final dtstart = CalDateTime.date(2025, 1, 1);
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.monthly,
        byDay: {ByDay(Weekday.mo, ordinal: 1)},
        count: 3,
      );
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, [
        '20250106', // First Monday of Jan
        '20250203', // First Monday of Feb
        '20250303', // First Monday of Mar
      ]);
    });

    test('MONTHLY with BYDAY and negative ordinal (last Friday)', () {
      final dtstart = CalDateTime.date(2025, 1, 1);
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.monthly,
        byDay: {ByDay(Weekday.fr, ordinal: -1)},
        count: 3,
      );
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, [
        '20250131', // Last Friday of Jan
        '20250228', // Last Friday of Feb
        '20250328', // Last Friday of Mar
      ]);
    });
  });

  group('RecurrenceIterator - BYYEARDAY', () {
    test('YEARLY with BYYEARDAY positive', () {
      final dtstart = CalDateTime.date(2025, 1, 1);
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.yearly,
        byYearDay: {1, 100, 200},
        count: 6,
      );
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, [
        '20250101', // Day 1
        '20250410', // Day 100
        '20250719', // Day 200
        '20260101', // Day 1
        '20260410', // Day 100
        '20260719', // Day 200
      ]);
    });

    test('YEARLY with BYYEARDAY negative (last day)', () {
      final dtstart = CalDateTime.date(2025, 1, 1);
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.yearly,
        byYearDay: {-1},
        count: 3,
      );
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, ['20251231', '20261231', '20271231']);
    });
  });

  group('RecurrenceIterator - BYWEEKNO', () {
    test('YEARLY with BYWEEKNO', () {
      final dtstart = CalDateTime.date(2025, 1, 1);
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.yearly,
        byWeekNo: {1, 20},
        byDay: {ByDay(Weekday.mo)},
        count: 4,
      );
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, [
        // Week 1 of 2025: Mon Dec 30, 2024 is before dtstart, so skipped
        '20250512', // Monday of week 20, 2025
        '20251229', // Monday of week 1, 2026
        '20260511', // Monday of week 20, 2026
        '20270104', // Monday of week 1, 2027
      ]);
    });

    test('YEARLY with BYWEEKNO and multiple BYDAY values', () {
      final dtstart = CalDateTime.date(2025, 1, 1);
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.yearly,
        byWeekNo: {1},
        byDay: {ByDay(Weekday.mo), ByDay(Weekday.we)},
        count: 4,
      );
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, [
        '20250101', // Wednesday of week 1, 2025
        '20251229', // Monday of week 1, 2026
        '20251231', // Wednesday of week 1, 2026
        '20270104', // Monday of week 1, 2027
      ]);
    });
  });

  group('RecurrenceIterator - BYHOUR/BYMINUTE/BYSECOND', () {
    test('DAILY with BYHOUR', () {
      final dtstart = CalDateTime.local(2025, 1, 1, 10, 0, 0);
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.daily,
        byHour: {9, 12, 15},
        count: 6,
      );
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, [
        '20250101T120000', // Jan 1, 12:00 (9:00 already passed)
        '20250101T150000', // Jan 1, 15:00
        '20250102T090000', // Jan 2, 09:00
        '20250102T120000', // Jan 2, 12:00
        '20250102T150000', // Jan 2, 15:00
        '20250103T090000', // Jan 3, 09:00
      ]);
    });

    test('HOURLY with BYMINUTE', () {
      final dtstart = CalDateTime.local(2025, 1, 1, 10, 0, 0);
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.hourly,
        byMinute: {0, 30},
        count: 4,
      );
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, [
        '20250101T100000',
        '20250101T103000',
        '20250101T110000',
        '20250101T113000',
      ]);
    });

    test('MINUTELY with BYSECOND', () {
      final dtstart = CalDateTime.local(2025, 1, 1, 10, 0, 0);
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.minutely,
        bySecond: {0, 15, 30, 45},
        count: 8,
      );
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, [
        '20250101T100000',
        '20250101T100015',
        '20250101T100030',
        '20250101T100045',
        '20250101T100100',
        '20250101T100115',
        '20250101T100130',
        '20250101T100145',
      ]);
    });
  });

  group('RecurrenceIterator - BYSETPOS', () {
    test('MONTHLY with BYSETPOS selecting first and last', () {
      final dtstart = CalDateTime.date(2025, 1, 1);
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.monthly,
        byDay: {ByDay(Weekday.mo)},
        bySetPos: {1, -1},
        count: 4,
      );
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, [
        '20250106', // First Monday of Jan
        '20250127', // Last Monday of Jan
        '20250203', // First Monday of Feb
        '20250224', // Last Monday of Feb
      ]);
    });

    test('YEARLY with BYSETPOS selecting middle occurrence', () {
      final dtstart = CalDateTime.date(2025, 1, 1);
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.yearly,
        byMonth: {1, 6},
        bySetPos: {1},
        count: 2,
      );
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, [
        '20250101', // First occurrence (Jan)
        '20260101', // First occurrence (Jan next year)
      ]);
    });
  });

  group('RecurrenceIterator - Combined Rules', () {
    test('MONTHLY with BYMONTH and BYDAY', () {
      final dtstart = CalDateTime.date(2025, 1, 1);
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.monthly,
        byMonth: {3},
        byDay: {ByDay(Weekday.th)},
        count: 5,
      );
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, [
        '20250306', // Thu Mar 6
        '20250313', // Thu Mar 13
        '20250320', // Thu Mar 20
        '20250327', // Thu Mar 27
        '20260305', // Thu Mar 5, 2026
      ]);
    });

    test('WEEKLY with BYDAY and BYHOUR', () {
      final dtstart = CalDateTime.local(2025, 1, 6, 10, 0, 0);
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.weekly,
        byDay: {ByDay(Weekday.mo), ByDay(Weekday.we)},
        byHour: {9, 15},
        count: 8,
      );
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, [
        '20250106T150000', // Mon 15:00 (9:00 passed)
        '20250108T090000', // Wed 09:00
        '20250108T150000', // Wed 15:00
        '20250113T090000', // Mon 09:00
        '20250113T150000', // Mon 15:00
        '20250115T090000', // Wed 09:00
        '20250115T150000', // Wed 15:00
        '20250120T090000', // Mon 09:00
      ]);
    });

    test('YEARLY with multiple BY rules', () {
      final dtstart = CalDateTime.date(2025, 1, 1);
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.yearly,
        byMonth: {6},
        byMonthDay: {15},
        count: 3,
      );
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, ['20250615', '20260615', '20270615']);
    });
  });

  group('RecurrenceIterator - EXDATE', () {
    test('DAILY with EXDATE removes specific dates', () {
      final dtstart = CalDateTime.date(2025, 1, 1);
      final rrule = RecurrenceRule(freq: RecurrenceFrequency.daily, count: 5);
      final exdates = [
        CalDateTime.date(2025, 1, 2),
        CalDateTime.date(2025, 1, 4),
      ];
      final iterator = RecurrenceIterator(
        dtstart: dtstart,
        rrule: rrule,
        exdates: exdates,
      );

      final actual = occurrences(iterator);
      expect(actual, ['20250101', '20250103', '20250105']);
    });
  });

  group('RecurrenceIterator - RDATE', () {
    test('RDATE adds additional occurrences', () {
      final dtstart = CalDateTime.date(2025, 1, 1);
      final rdates = [
        RecurrenceDateTime.dateTime(CalDateTime.date(2025, 1, 15)),
        RecurrenceDateTime.dateTime(CalDateTime.date(2025, 1, 20)),
      ];
      final iterator = RecurrenceIterator(dtstart: dtstart, rdates: rdates);

      final actual = occurrences(iterator);
      expect(actual, ['20250101', '20250115', '20250120']);
    });

    test('RDATE with RRULE combines occurrences', () {
      final dtstart = CalDateTime.date(2025, 1, 1);
      final rrule = RecurrenceRule(freq: RecurrenceFrequency.weekly, count: 2);
      final rdates = [
        RecurrenceDateTime.dateTime(CalDateTime.date(2025, 1, 5)),
      ];
      final iterator = RecurrenceIterator(
        dtstart: dtstart,
        rrule: rrule,
        rdates: rdates,
      );

      // Occurrences are chronologically sorted (RRULE and RDATE merged)
      final actual = occurrences(iterator);

      expect(actual, ['20250101', '20250105', '20250108']);
    });

    test(
      'RDATE occurrences are sorted chronologically even when out of order',
      () {
        final dtstart = CalDateTime.date(2025, 1, 1);
        final rrule = RecurrenceRule(
          freq: RecurrenceFrequency.weekly,
          count: 2,
        );

        // RDATEs are intentionally out of chronological order
        final rdates = [
          RecurrenceDateTime.dateTime(CalDateTime.date(2025, 1, 15)), // Later
          RecurrenceDateTime.dateTime(CalDateTime.date(2025, 1, 5)), // Earlier
          RecurrenceDateTime.dateTime(CalDateTime.date(2025, 1, 20)), // Latest
        ];

        final iterator = RecurrenceIterator(
          dtstart: dtstart,
          rrule: rrule,
          rdates: rdates,
        );

        final actual = occurrences(iterator);

        expect(actual, [
          '20250101', // RRULE
          '20250105', // RDATE (earlier)
          '20250108', // RRULE
          '20250115', // RDATE (middle)
          '20250120', // RDATE (later)
        ]);
      },
    );

    test('RDATE with PERIOD explicit end is supported', () {
      final dtstart = CalDateTime.local(2025, 1, 1, 10, 0, 0);
      final rdates = [
        RecurrenceDateTime.period(
          Period.explicit(
            start: CalDateTime.local(2025, 1, 6, 9, 0, 0),
            end: CalDateTime.local(2025, 1, 6, 11, 0, 0),
          ),
        ),
      ];
      final iterator = RecurrenceIterator(dtstart: dtstart, rdates: rdates);

      final actual = occurrences(iterator);
      expect(actual, ['20250101T100000', '20250106T090000']);
    });

    test('RDATE with PERIOD duration is supported', () {
      final dtstart = CalDateTime.local(2025, 1, 1, 10, 0, 0);
      final rdates = [
        RecurrenceDateTime.period(
          Period.start(
            start: CalDateTime.local(2025, 1, 5, 8, 0, 0),
            duration: CalDuration(hours: 2),
          ),
        ),
      ];
      final iterator = RecurrenceIterator(dtstart: dtstart, rdates: rdates);

      final actual = occurrences(iterator);
      expect(actual, ['20250101T100000', '20250105T080000']);
    });

    test('RDATE PERIOD overlap uses period end for range filtering', () {
      final dtstart = CalDateTime.local(2025, 1, 1, 10, 0, 0);
      final rdates = [
        RecurrenceDateTime.period(
          Period.start(
            start: CalDateTime.local(2025, 1, 5, 8, 0, 0),
            duration: CalDuration(hours: 3),
          ),
        ),
      ];
      final iterator = RecurrenceIterator(dtstart: dtstart, rdates: rdates);

      final actual = iterator
          .occurrences(start: CalDateTime.local(2025, 1, 5, 10, 0, 0))
          .map((e) => e.toString())
          .toList();

      expect(actual, ['20250105T080000']);
    });
  });

  group('RecurrenceIterator - Edge Cases', () {
    test('MONTHLY on 31st skips months without 31 days', () {
      final dtstart = CalDateTime.date(2025, 1, 31);
      final rrule = RecurrenceRule(freq: RecurrenceFrequency.monthly, count: 5);
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, [
        '20250131', // Jan 31
        '20250331', // Mar 31 (Feb skipped)
        '20250531', // May 31 (Apr skipped)
        '20250731', // Jul 31 (Jun skipped)
        '20250831', // Aug 31
      ]);
    });

    test('Leap year February 29', () {
      final dtstart = CalDateTime.date(2024, 2, 29);
      final rrule = RecurrenceRule(freq: RecurrenceFrequency.yearly, count: 3);
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, [
        '20240229', // 2024 is leap year
        '20280229', // 2028 is leap year
        '20320229', // 2032 is leap year
      ]);
    });

    test('COUNT of 0 returns empty', () {
      final dtstart = CalDateTime.date(2025, 1, 1);
      final rrule = RecurrenceRule(freq: RecurrenceFrequency.daily, count: 0);
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, []);
    });

    test('No RRULE returns only DTSTART', () {
      final dtstart = CalDateTime.date(2025, 1, 1);
      final iterator = RecurrenceIterator(dtstart: dtstart);

      final actual = occurrences(iterator);
      expect(actual, ['20250101']);
    });

    test('Empty BYMONTH with MONTHLY frequency returns no occurrences', () {
      final dtstart = CalDateTime.date(2025, 1, 1);
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.monthly,
        byMonth: {},
        count: 10,
      );
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final actual = occurrences(iterator);
      expect(actual, []);
    });
  });

  group('RecurrenceIterator - Timezone', () {
    test('Timezone is preserved in occurrences', () {
      final dtstart = CalDateTime.local(
        2025,
        1,
        1,
        9,
        0,
        0,
        'America/New_York',
      );
      final rrule = RecurrenceRule(freq: RecurrenceFrequency.daily, count: 3);
      final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

      final result = occurrences(iterator);
      expect(result, [
        '20250101T090000 [America/New_York]',
        '20250102T090000 [America/New_York]',
        '20250103T090000 [America/New_York]',
      ]);

      // Verify all occurrences preserve timezone
      final actual = iterator.occurrences().toList();
      for (final occ in actual) {
        expect(occ.time!.tzid, 'America/New_York');
      }
    });
  });

  group('RecurrenceIterator - Chronological Ordering', () {
    test('Interleaved RRULE and RDATE occurrences maintain strict order', () {
      final dtstart = CalDateTime.date(2025, 1, 1);
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.daily,
        interval: 3,
        count: 5,
      );

      // RDATEs that fall between RRULE occurrences
      final rdates = [
        RecurrenceDateTime.dateTime(
          CalDateTime.date(2025, 1, 2),
        ), // Between 1 and 4
        RecurrenceDateTime.dateTime(
          CalDateTime.date(2025, 1, 5),
        ), // Between 4 and 7
        RecurrenceDateTime.dateTime(
          CalDateTime.date(2025, 1, 9),
        ), // Between 7 and 10
        RecurrenceDateTime.dateTime(CalDateTime.date(2025, 1, 15)), // After 13
      ];

      final iterator = RecurrenceIterator(
        dtstart: dtstart,
        rrule: rrule,
        rdates: rdates,
      );

      final actual = occurrences(iterator);

      // Verify strict chronological order with mixed sources
      expect(actual, [
        '20250101', // RRULE (dtstart)
        '20250102', // RDATE
        '20250104', // RRULE
        '20250105', // RDATE
        '20250107', // RRULE
        '20250109', // RDATE
        '20250110', // RRULE
        '20250113', // RRULE
        '20250115', // RDATE
      ]);
    });

    test('Large RDATE list with RRULE maintains chronological order', () {
      final dtstart = CalDateTime.date(2025, 1, 1);
      final rrule = RecurrenceRule(freq: RecurrenceFrequency.weekly, count: 10);

      // RRULE generates: 1/1, 1/8, 1/15, 1/22, 1/29, 2/5, 2/12, 2/19, 2/26, 3/5
      // Create RDATEs scattered throughout (avoiding RRULE dates)
      final rdates = <RecurrenceDateTime>[
        RecurrenceDateTime.dateTime(CalDateTime.date(2025, 1, 3)),
        RecurrenceDateTime.dateTime(CalDateTime.date(2025, 1, 5)),
        RecurrenceDateTime.dateTime(CalDateTime.date(2025, 1, 10)),
        RecurrenceDateTime.dateTime(CalDateTime.date(2025, 1, 12)),
        RecurrenceDateTime.dateTime(CalDateTime.date(2025, 1, 17)),
        RecurrenceDateTime.dateTime(CalDateTime.date(2025, 1, 20)),
        RecurrenceDateTime.dateTime(CalDateTime.date(2025, 1, 24)),
        RecurrenceDateTime.dateTime(CalDateTime.date(2025, 1, 27)),
        RecurrenceDateTime.dateTime(CalDateTime.date(2025, 1, 31)),
        RecurrenceDateTime.dateTime(CalDateTime.date(2025, 2, 3)),
        RecurrenceDateTime.dateTime(CalDateTime.date(2025, 2, 7)),
        RecurrenceDateTime.dateTime(CalDateTime.date(2025, 2, 10)),
        RecurrenceDateTime.dateTime(CalDateTime.date(2025, 2, 14)),
        RecurrenceDateTime.dateTime(CalDateTime.date(2025, 2, 17)),
        RecurrenceDateTime.dateTime(CalDateTime.date(2025, 2, 21)),
        RecurrenceDateTime.dateTime(CalDateTime.date(2025, 2, 24)),
        RecurrenceDateTime.dateTime(CalDateTime.date(2025, 2, 28)),
        RecurrenceDateTime.dateTime(CalDateTime.date(2025, 3, 3)),
        RecurrenceDateTime.dateTime(CalDateTime.date(2025, 3, 7)),
        RecurrenceDateTime.dateTime(CalDateTime.date(2025, 3, 10)),
      ];

      final iterator = RecurrenceIterator(
        dtstart: dtstart,
        rrule: rrule,
        rdates: rdates,
      );

      final allOccurrences = iterator.occurrences().toList();

      // Verify we have all occurrences (10 RRULE + 20 RDATE = 30)
      expect(allOccurrences.length, 30);

      // Verify strict chronological ordering throughout entire sequence
      for (var i = 0; i < allOccurrences.length - 1; i++) {
        expect(
          allOccurrences[i].isBefore(allOccurrences[i + 1]),
          isTrue,
          reason:
              'Occurrence $i (${allOccurrences[i]}) should be before ${i + 1} (${allOccurrences[i + 1]})',
        );
      }
    });

    test('Ordering maintained with time components (not just dates)', () {
      final dtstart = CalDateTime.local(2025, 1, 1, 10, 0, 0);
      final rrule = RecurrenceRule(freq: RecurrenceFrequency.daily, count: 3);

      // RDATEs on same days but different times
      final rdates = [
        RecurrenceDateTime.dateTime(
          CalDateTime.local(2025, 1, 1, 8, 0, 0),
        ), // Before dtstart time
        RecurrenceDateTime.dateTime(
          CalDateTime.local(2025, 1, 1, 12, 0, 0),
        ), // After dtstart time
        RecurrenceDateTime.dateTime(
          CalDateTime.local(2025, 1, 2, 9, 0, 0),
        ), // Between day 2 RRULE times
        RecurrenceDateTime.dateTime(CalDateTime.local(2025, 1, 2, 11, 0, 0)),
      ];

      final iterator = RecurrenceIterator(
        dtstart: dtstart,
        rrule: rrule,
        rdates: rdates,
      );

      final actual = occurrences(iterator);

      // Verify chronological order with time precision
      expect(actual, [
        '20250101T080000', // RDATE 8am
        '20250101T100000', // RRULE 10am (dtstart)
        '20250101T120000', // RDATE 12pm
        '20250102T090000', // RDATE 9am
        '20250102T100000', // RRULE 10am
        '20250102T110000', // RDATE 11am
        '20250103T100000', // RRULE 10am
      ]);
    });
  });

  group('RecurrenceIterator - Real World Examples', () {
    test(
      'Dutch air raid siren (luchtalarm) - first Monday of every month at 12:00',
      () {
        // The Dutch air raid siren test occurs on the first Monday of every month at 12:00
        final dtstart = CalDateTime.local(2025, 1, 1, 12, 0, 0);
        final rrule = RecurrenceRule(
          freq: RecurrenceFrequency.monthly,
          byDay: {const ByDay(Weekday.mo, ordinal: 1)},
          count: 12, // One year of tests
        );

        final iterator = RecurrenceIterator(dtstart: dtstart, rrule: rrule);

        final actual = occurrences(iterator);
        expect(actual, [
          '20250106T120000', // January 6, 2025 (Monday)
          '20250203T120000', // February 3, 2025 (Monday)
          '20250303T120000', // March 3, 2025 (Monday)
          '20250407T120000', // April 7, 2025 (Monday)
          '20250505T120000', // May 5, 2025 (Monday)
          '20250602T120000', // June 2, 2025 (Monday)
          '20250707T120000', // July 7, 2025 (Monday)
          '20250804T120000', // August 4, 2025 (Monday)
          '20250901T120000', // September 1, 2025 (Monday)
          '20251006T120000', // October 6, 2025 (Monday)
          '20251103T120000', // November 3, 2025 (Monday)
          '20251201T120000', // December 1, 2025 (Monday)
        ]);

        // Verify that all occurrences are indeed the first Monday
        for (final occ in iterator.occurrences()) {
          expect(occ.weekday, Weekday.mo, reason: 'Should be Monday');
          expect(
            occ.day,
            lessThanOrEqualTo(7),
            reason: 'Should be in first week',
          );
          expect(occ.time!.hour, 12, reason: 'Should be at 12:00');
          expect(occ.time!.minute, 0, reason: 'Should be at 12:00');
        }
      },
    );
  });
}
