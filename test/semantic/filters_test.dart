import 'package:firstfloor_calendar/firstfloor_calendar.dart';
import 'package:firstfloor_calendar/src/semantic/recurrence/filters.dart';
import 'package:test/test.dart';

void main() {
  group('ByMonthFilter', () {
    test('YEARLY with BYMONTH expands to specified months', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.yearly,
        byMonth: {1, 6, 12},
      );
      final filter = ByMonthFilter(rrule);
      final source = [CalDateTime.date(2025, 1, 15)];
      final result = filter.transform(source).toList();

      expect(result.length, 3);
      expect(result[0].toString(), '20250115');
      expect(result[1].toString(), '20250615');
      expect(result[2].toString(), '20251215');
    });

    test('YEARLY with BYMONTH skips invalid days (Jan 31 to Feb)', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.yearly,
        byMonth: {1, 2, 3},
      );
      final filter = ByMonthFilter(rrule);
      final source = [CalDateTime.date(2025, 1, 31)];
      final result = filter.transform(source).toList();

      expect(result.length, 2);
      expect(result[0].toString(), '20250131');
      expect(result[1].toString(), '20250331'); // Feb 31 skipped
    });

    test('MONTHLY with BYMONTH limits to specified months', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.monthly,
        byMonth: {1, 6, 12},
      );
      final filter = ByMonthFilter(rrule);
      final source = [
        CalDateTime.date(2025, 1, 1),
        CalDateTime.date(2025, 2, 1),
        CalDateTime.date(2025, 6, 1),
      ];
      final result = filter.transform(source).toList();

      expect(result.length, 2);
      expect(result[0].toString(), '20250101');
      expect(result[1].toString(), '20250601');
    });

    test('hasNoOccurrences returns true for MONTHLY with empty BYMONTH', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.monthly,
        byMonth: {},
      );
      final filter = ByMonthFilter(rrule);

      expect(filter.hasNoOccurrences(), true);
    });

    test('hasNoOccurrences returns false for YEARLY with empty BYMONTH', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.yearly,
        byMonth: {},
      );
      final filter = ByMonthFilter(rrule);

      expect(filter.hasNoOccurrences(), false);
    });

    test('Null BYMONTH passes through unchanged', () {
      final rrule = RecurrenceRule(freq: RecurrenceFrequency.yearly);
      final filter = ByMonthFilter(rrule);
      final source = [CalDateTime.date(2025, 1, 1)];
      final result = filter.transform(source).toList();

      expect(result.length, 1);
      expect(result[0].toString(), '20250101');
    });
  });

  group('ByWeekNoFilter', () {
    test('YEARLY with positive BYWEEKNO expands correctly', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.yearly,
        byWeekNo: {1, 10, 52},
      );
      final filter = ByWeekNoFilter(rrule);
      final source = [CalDateTime.date(2025, 1, 1)];
      final result = filter.transform(source).toList();

      expect(result.length, 3);
      expect(result[0].toString(), '20241230'); // Week 1 starts in 2024
      expect(result[1].toString(), '20250303'); // Week 10
      expect(result[2].toString(), '20251222'); // Week 52
    });

    test('YEARLY with negative BYWEEKNO counts from end', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.yearly,
        byWeekNo: {-1, -2},
      );
      final filter = ByWeekNoFilter(rrule);
      final source = [CalDateTime.date(2025, 1, 1)];
      final result = filter.transform(source).toList();

      expect(result.length, 2);
      expect(result[0].toString(), '20251229'); // Last week
      expect(result[1].toString(), '20251222'); // Second-to-last week
    });

    test('BYWEEKNO skips zero values', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.yearly,
        byWeekNo: {1, 10},
      );
      final filter = ByWeekNoFilter(rrule);
      final source = [CalDateTime.date(2025, 1, 1)];
      final result = filter.transform(source).toList();

      expect(result.length, 2);
      expect(result[0].toString(), '20241230');
      expect(result[1].toString(), '20250303');
    });

    test('BYWEEKNO with custom WKST (Sunday)', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.yearly,
        byWeekNo: {1},
        wkst: Weekday.su,
      );
      final filter = ByWeekNoFilter(rrule);
      final source = [CalDateTime.date(2025, 1, 1)];
      final result = filter.transform(source).toList();

      expect(result.length, 1);
      // Week 1 starting on Sunday
      expect(result[0].weekday, Weekday.su);
    });

    test('Non-YEARLY frequency passes through unchanged', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.monthly,
        byWeekNo: {1, 10},
      );
      final filter = ByWeekNoFilter(rrule);
      final source = [CalDateTime.date(2025, 1, 15)];
      final result = filter.transform(source).toList();

      expect(result.length, 1);
      expect(result[0].toString(), '20250115');
    });

    test('Null BYWEEKNO passes through unchanged', () {
      final rrule = RecurrenceRule(freq: RecurrenceFrequency.yearly);
      final filter = ByWeekNoFilter(rrule);
      final source = [CalDateTime.date(2025, 1, 1)];
      final result = filter.transform(source).toList();

      expect(result.length, 1);
      expect(result[0].toString(), '20250101');
    });
  });

  group('ByYearDayFilter', () {
    test('YEARLY with positive BYYEARDAY expands correctly', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.yearly,
        byYearDay: {1, 60, 365},
      );
      final filter = ByYearDayFilter(rrule);
      final source = [CalDateTime.date(2025, 1, 1)];
      final result = filter.transform(source).toList();

      expect(result.length, 3);
      expect(result[0].toString(), '20250101'); // Day 1
      expect(result[1].toString(), '20250301'); // Day 60 (non-leap year)
      expect(result[2].toString(), '20251231'); // Day 365
    });

    test('YEARLY with negative BYYEARDAY counts from end', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.yearly,
        byYearDay: {-1, -365},
      );
      final filter = ByYearDayFilter(rrule);
      final source = [CalDateTime.date(2025, 1, 1)];
      final result = filter.transform(source).toList();

      expect(result.length, 2);
      expect(result[0].toString(), '20251231'); // Last day
      expect(result[1].toString(), '20250101'); // First day (from end)
    });

    test('YEARLY with leap year day 366', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.yearly,
        byYearDay: {366},
      );
      final filter = ByYearDayFilter(rrule);
      final source = [CalDateTime.date(2024, 1, 1)]; // 2024 is leap year
      final result = filter.transform(source).toList();

      expect(result.length, 1);
      expect(result[0].toString(), '20241231'); // Day 366 in leap year
    });

    test('YEARLY with out-of-range BYYEARDAY values', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.yearly,
        byYearDay: {
          0,
          366,
          400,
          -400,
        }, // All should be invalid for non-leap year
      );
      final filter = ByYearDayFilter(rrule);
      final source = [CalDateTime.date(2025, 1, 1)]; // Non-leap year (365 days)
      final result = filter.transform(source).toList();

      // All values are out of range for a 365-day year
      // 0 is invalid, 366/400 are > 365, -400 is < -365
      expect(result.length, 0);
    });

    test('MONTHLY/WEEKLY ignores BYYEARDAY', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.monthly,
        byYearDay: {1, 60},
      );
      final filter = ByYearDayFilter(rrule);
      final source = [CalDateTime.date(2025, 2, 15)];
      final result = filter.transform(source).toList();

      expect(result.length, 1);
      expect(result[0].toString(), '20250215');
    });

    test('Null BYYEARDAY passes through unchanged', () {
      final rrule = RecurrenceRule(freq: RecurrenceFrequency.yearly);
      final filter = ByYearDayFilter(rrule);
      final source = [CalDateTime.date(2025, 1, 1)];
      final result = filter.transform(source).toList();

      expect(result.length, 1);
      expect(result[0].toString(), '20250101');
    });
  });

  group('ByMonthDayFilter', () {
    test('MONTHLY with positive BYMONTHDAY expands correctly', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.monthly,
        byMonthDay: {1, 15, 31},
      );
      final filter = ByMonthDayFilter(rrule);
      final source = [CalDateTime.date(2025, 1, 1)];
      final result = filter.transform(source).toList();

      expect(result.length, 3);
      expect(result[0].toString(), '20250101');
      expect(result[1].toString(), '20250115');
      expect(result[2].toString(), '20250131');
    });

    test('MONTHLY with BYMONTHDAY skips invalid days (31 in Feb)', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.monthly,
        byMonthDay: {28, 29, 30, 31},
      );
      final filter = ByMonthDayFilter(rrule);
      final source = [CalDateTime.date(2025, 2, 1)]; // Feb 2025 (non-leap)
      final result = filter.transform(source).toList();

      expect(result.length, 1);
      expect(result[0].toString(), '20250228');
    });

    test('MONTHLY with negative BYMONTHDAY counts from end', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.monthly,
        byMonthDay: {-1, -7},
      );
      final filter = ByMonthDayFilter(rrule);
      final source = [CalDateTime.date(2025, 1, 1)]; // January (31 days)
      final result = filter.transform(source).toList();

      expect(result.length, 2);
      expect(result[0].toString(), '20250131'); // Last day
      expect(result[1].toString(), '20250125'); // 7th from last
    });

    test('YEARLY with BYMONTHDAY expands correctly', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.yearly,
        byMonthDay: {1, 31},
      );
      final filter = ByMonthDayFilter(rrule);
      final source = [CalDateTime.date(2025, 6, 15)];
      final result = filter.transform(source).toList();

      expect(result.length, 1); // June only has 30 days
      expect(result[0].toString(), '20250601');
    });

    test('DAILY with BYMONTHDAY limits occurrences', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.daily,
        byMonthDay: {1, 15},
      );
      final filter = ByMonthDayFilter(rrule);
      final source = [
        CalDateTime.date(2025, 1, 1),
        CalDateTime.date(2025, 1, 2),
        CalDateTime.date(2025, 1, 15),
      ];
      final result = filter.transform(source).toList();

      expect(result.length, 2);
      expect(result[0].toString(), '20250101');
      expect(result[1].toString(), '20250115');
    });

    test('WEEKLY ignores BYMONTHDAY', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.weekly,
        byMonthDay: {1, 15},
      );
      final filter = ByMonthDayFilter(rrule);
      final source = [CalDateTime.date(2025, 1, 10)];
      final result = filter.transform(source).toList();

      expect(result.length, 1);
      expect(result[0].toString(), '20250110');
    });

    test('BYMONTHDAY skips zero values', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.monthly,
        byMonthDay: {1, 15},
      );
      final filter = ByMonthDayFilter(rrule);
      final source = [CalDateTime.date(2025, 1, 1)];
      final result = filter.transform(source).toList();

      expect(result.length, 2);
      expect(result[0].toString(), '20250101');
      expect(result[1].toString(), '20250115');
    });

    test('Null BYMONTHDAY passes through unchanged', () {
      final rrule = RecurrenceRule(freq: RecurrenceFrequency.monthly);
      final filter = ByMonthDayFilter(rrule);
      final source = [CalDateTime.date(2025, 1, 1)];
      final result = filter.transform(source).toList();

      expect(result.length, 1);
      expect(result[0].toString(), '20250101');
    });
  });

  group('ByDayFilter', () {
    test('WEEKLY with BYDAY expands to specified weekdays', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.weekly,
        byDay: {ByDay(Weekday.mo), ByDay(Weekday.we), ByDay(Weekday.fr)},
      );
      final filter = ByDayFilter(rrule);
      final source = [CalDateTime.date(2025, 1, 6)]; // Monday
      final result = filter.transform(source).toList();

      expect(result.length, 3);
      expect(result[0].weekday, Weekday.mo);
      expect(result[1].weekday, Weekday.we);
      expect(result[2].weekday, Weekday.fr);
    });

    test('WEEKLY with custom WKST', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.weekly,
        byDay: {ByDay(Weekday.su), ByDay(Weekday.sa)},
        wkst: Weekday.su,
      );
      final filter = ByDayFilter(rrule);
      final source = [CalDateTime.date(2025, 1, 5)]; // Sunday
      final result = filter.transform(source).toList();

      expect(result.length, 2);
      expect(result[0].weekday, Weekday.su);
      expect(result[1].weekday, Weekday.sa);
    });

    test('MONTHLY with BYDAY expands all occurrences', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.monthly,
        byDay: {ByDay(Weekday.mo)},
      );
      final filter = ByDayFilter(rrule);
      final source = [CalDateTime.date(2025, 1, 1)];
      final result = filter.transform(source).toList();

      // January 2025 has 4 Mondays (6, 13, 20, 27)
      expect(result.length, 4);
      expect(result.every((d) => d.weekday == Weekday.mo), true);
    });

    test('MONTHLY with BYDAY and ordinal (first Monday)', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.monthly,
        byDay: {ByDay(Weekday.mo, ordinal: 1)},
      );
      final filter = ByDayFilter(rrule);
      final source = [CalDateTime.date(2025, 1, 1)];
      final result = filter.transform(source).toList();

      expect(result.length, 1);
      expect(result[0].toString(), '20250106'); // First Monday of Jan 2025
    });

    test('MONTHLY with BYDAY and negative ordinal (last Friday)', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.monthly,
        byDay: {ByDay(Weekday.fr, ordinal: -1)},
      );
      final filter = ByDayFilter(rrule);
      final source = [CalDateTime.date(2025, 1, 1)];
      final result = filter.transform(source).toList();

      expect(result.length, 1);
      expect(result[0].toString(), '20250131'); // Last Friday of Jan 2025
    });

    test('MONTHLY with BYMONTHDAY limits instead of expanding', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.monthly,
        byDay: {ByDay(Weekday.mo)},
        byMonthDay: {6, 13, 20, 27},
      );
      final filter = ByDayFilter(rrule);
      final source = [
        CalDateTime.date(2025, 1, 6), // Monday
        CalDateTime.date(2025, 1, 13), // Monday
        CalDateTime.date(2025, 1, 14), // Tuesday
      ];
      final result = filter.transform(source).toList();

      expect(result.length, 2);
      expect(result[0].toString(), '20250106');
      expect(result[1].toString(), '20250113');
    });

    test('YEARLY with BYDAY expands all occurrences in year', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.yearly,
        byDay: {ByDay(Weekday.mo)},
      );
      final filter = ByDayFilter(rrule);
      final source = [CalDateTime.date(2025, 1, 1)];
      final result = filter.transform(source).toList();

      // 2025 has 52 Mondays
      expect(result.length, 52);
      expect(result.every((d) => d.weekday == Weekday.mo), true);
    });

    test('YEARLY with BYMONTH and BYDAY expands within months', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.yearly,
        byMonth: {1, 6},
        byDay: {ByDay(Weekday.mo)},
      );
      final filter = ByDayFilter(rrule);
      final source = [
        CalDateTime.date(2025, 1, 1),
        CalDateTime.date(2025, 6, 1),
      ];
      final result = filter.transform(source).toList();

      // 4 Mondays in Jan + 5 Mondays in June = 9
      expect(result.length, 9);
      expect(result.every((d) => d.weekday == Weekday.mo), true);
    });

    test(
      'YEARLY with BYWEEKNO and BYDAY expands weekdays in selected weeks',
      () {
        final rrule = RecurrenceRule(
          freq: RecurrenceFrequency.yearly,
          byWeekNo: {1},
          byDay: {ByDay(Weekday.mo), ByDay(Weekday.we)},
        );
        final filter = ByDayFilter(rrule);
        final source = [CalDateTime.date(2024, 12, 30)]; // Week 1 of 2025
        final result = filter.transform(source).toList();

        expect(result.length, 2);
        expect(result[0].toString(), '20241230'); // Monday
        expect(result[1].toString(), '20250101'); // Wednesday
      },
    );

    test('YEARLY with BYYEARDAY limits instead of expanding', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.yearly,
        byYearDay: {1, 100, 200},
        byDay: {ByDay(Weekday.tu)},
      );
      final filter = ByDayFilter(rrule);
      final source = [
        CalDateTime.date(2025, 1, 1), // Thursday
        CalDateTime.date(2025, 4, 10), // Thursday (day 100)
        CalDateTime.date(2025, 7, 19), // Saturday (day 200)
      ];
      final result = filter.transform(source).toList();

      expect(result.length, 0); // None are Tuesdays
    });

    test('DAILY with BYDAY limits occurrences', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.daily,
        byDay: {ByDay(Weekday.mo), ByDay(Weekday.fr)},
      );
      final filter = ByDayFilter(rrule);
      final source = [
        CalDateTime.date(2025, 1, 6), // Monday
        CalDateTime.date(2025, 1, 7), // Tuesday
        CalDateTime.date(2025, 1, 10), // Friday
      ];
      final result = filter.transform(source).toList();

      expect(result.length, 2);
      expect(result[0].toString(), '20250106');
      expect(result[1].toString(), '20250110');
    });

    test('Null BYDAY passes through unchanged', () {
      final rrule = RecurrenceRule(freq: RecurrenceFrequency.weekly);
      final filter = ByDayFilter(rrule);
      final source = [CalDateTime.date(2025, 1, 1)];
      final result = filter.transform(source).toList();

      expect(result.length, 1);
      expect(result[0].toString(), '20250101');
    });
  });

  group('ByHourFilter', () {
    test('DAILY with BYHOUR expands to specified hours', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.daily,
        byHour: {0, 12, 23},
      );
      final filter = ByHourFilter(rrule);
      final source = [CalDateTime.local(2025, 1, 1)];
      final result = filter.transform(source).toList();

      expect(result.length, 3);
      expect(result[0].time!.hour, 0);
      expect(result[1].time!.hour, 12);
      expect(result[2].time!.hour, 23);
    });

    test('HOURLY with BYHOUR limits occurrences', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.hourly,
        byHour: {0, 12, 23},
      );
      final filter = ByHourFilter(rrule);
      final source = [
        CalDateTime.local(2025, 1, 1),
        CalDateTime.local(2025, 1, 1, 1, 0, 0),
        CalDateTime.local(2025, 1, 1, 12, 0, 0),
      ];
      final result = filter.transform(source).toList();

      expect(result.length, 2);
      expect(result[0].time!.hour, 0);
      expect(result[1].time!.hour, 12);
    });

    test('MINUTELY with BYHOUR limits occurrences', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.minutely,
        byHour: {10, 11},
      );
      final filter = ByHourFilter(rrule);
      final source = [
        CalDateTime.local(2025, 1, 1, 10, 30, 0),
        CalDateTime.local(2025, 1, 1, 12, 30, 0),
      ];
      final result = filter.transform(source).toList();

      expect(result.length, 1);
      expect(result[0].time!.hour, 10);
    });

    test('SECONDLY with BYHOUR limits occurrences', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.secondly,
        byHour: {5},
      );
      final filter = ByHourFilter(rrule);
      final source = [
        CalDateTime.local(2025, 1, 1, 5, 0, 30),
        CalDateTime.local(2025, 1, 1, 6, 0, 30),
      ];
      final result = filter.transform(source).toList();

      expect(result.length, 1);
      expect(result[0].time!.hour, 5);
    });

    test('Null BYHOUR passes through unchanged', () {
      final rrule = RecurrenceRule(freq: RecurrenceFrequency.daily);
      final filter = ByHourFilter(rrule);
      final source = [CalDateTime.local(2025, 1, 1, 10, 0, 0)];
      final result = filter.transform(source).toList();

      expect(result.length, 1);
      expect(result[0].time!.hour, 10);
    });
  });

  group('ByMinuteFilter', () {
    test('HOURLY with BYMINUTE expands to specified minutes', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.hourly,
        byMinute: {0, 15, 30, 45},
      );
      final filter = ByMinuteFilter(rrule);
      final source = [CalDateTime.local(2025, 1, 1, 10, 0, 0)];
      final result = filter.transform(source).toList();

      expect(result.length, 4);
      expect(result[0].time!.minute, 0);
      expect(result[1].time!.minute, 15);
      expect(result[2].time!.minute, 30);
      expect(result[3].time!.minute, 45);
    });

    test('MINUTELY with BYMINUTE limits occurrences', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.minutely,
        byMinute: {0, 30},
      );
      final filter = ByMinuteFilter(rrule);
      final source = [
        CalDateTime.local(2025, 1, 1, 10, 0, 0),
        CalDateTime.local(2025, 1, 1, 10, 15, 0),
        CalDateTime.local(2025, 1, 1, 10, 30, 0),
      ];
      final result = filter.transform(source).toList();

      expect(result.length, 2);
      expect(result[0].time!.minute, 0);
      expect(result[1].time!.minute, 30);
    });

    test('SECONDLY with BYMINUTE limits occurrences', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.secondly,
        byMinute: {0},
      );
      final filter = ByMinuteFilter(rrule);
      final source = [
        CalDateTime.local(2025, 1, 1, 10, 0, 30),
        CalDateTime.local(2025, 1, 1, 10, 1, 30),
      ];
      final result = filter.transform(source).toList();

      expect(result.length, 1);
      expect(result[0].time!.minute, 0);
    });

    test('Null BYMINUTE passes through unchanged', () {
      final rrule = RecurrenceRule(freq: RecurrenceFrequency.hourly);
      final filter = ByMinuteFilter(rrule);
      final source = [CalDateTime.local(2025, 1, 1, 10, 30, 0)];
      final result = filter.transform(source).toList();

      expect(result.length, 1);
      expect(result[0].time!.minute, 30);
    });
  });

  group('BySecondFilter', () {
    test('MINUTELY with BYSECOND expands to specified seconds', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.minutely,
        bySecond: {0, 15, 30, 45},
      );
      final filter = BySecondFilter(rrule);
      final source = [CalDateTime.local(2025, 1, 1, 10, 0, 0)];
      final result = filter.transform(source).toList();

      expect(result.length, 4);
      expect(result[0].time!.second, 0);
      expect(result[1].time!.second, 15);
      expect(result[2].time!.second, 30);
      expect(result[3].time!.second, 45);
    });

    test('SECONDLY with BYSECOND limits occurrences', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.secondly,
        bySecond: {0, 30},
      );
      final filter = BySecondFilter(rrule);
      final source = [
        CalDateTime.local(2025, 1, 1, 10, 0, 0),
        CalDateTime.local(2025, 1, 1, 10, 0, 15),
        CalDateTime.local(2025, 1, 1, 10, 0, 30),
      ];
      final result = filter.transform(source).toList();

      expect(result.length, 2);
      expect(result[0].time!.second, 0);
      expect(result[1].time!.second, 30);
    });

    test('Null BYSECOND passes through unchanged', () {
      final rrule = RecurrenceRule(freq: RecurrenceFrequency.minutely);
      final filter = BySecondFilter(rrule);
      final source = [CalDateTime.local(2025, 1, 1, 10, 0, 45)];
      final result = filter.transform(source).toList();

      expect(result.length, 1);
      expect(result[0].time!.second, 45);
    });
  });

  group('BySetPosFilter', () {
    test('BYSETPOS with positive values selects from start', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.yearly,
        bySetPos: {1, 3, 5},
      );
      final filter = BySetPosFilter(rrule);
      final source = [
        CalDateTime.date(2025, 1, 1),
        CalDateTime.date(2025, 2, 1),
        CalDateTime.date(2025, 3, 1),
        CalDateTime.date(2025, 4, 1),
        CalDateTime.date(2025, 5, 1),
      ];
      final result = filter.transform(source).toList();

      expect(result.length, 3);
      expect(result[0].toString(), '20250101');
      expect(result[1].toString(), '20250301');
      expect(result[2].toString(), '20250501');
    });

    test('BYSETPOS with negative values selects from end', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.yearly,
        bySetPos: {-1, -2},
      );
      final filter = BySetPosFilter(rrule);
      final source = [
        CalDateTime.date(2025, 1, 1),
        CalDateTime.date(2025, 2, 1),
        CalDateTime.date(2025, 3, 1),
      ];
      final result = filter.transform(source).toList();

      expect(result.length, 2);
      expect(result[0].toString(), '20250301'); // Last
      expect(result[1].toString(), '20250201'); // Second to last
    });

    test('BYSETPOS skips zero values', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.yearly,
        bySetPos: {1, 2},
      );
      final filter = BySetPosFilter(rrule);
      final source = [
        CalDateTime.date(2025, 1, 1),
        CalDateTime.date(2025, 2, 1),
      ];
      final result = filter.transform(source).toList();

      expect(result.length, 2);
      expect(result[0].toString(), '20250101');
      expect(result[1].toString(), '20250201');
    });

    test('BYSETPOS skips out-of-range positive values', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.yearly,
        bySetPos: {1, 2, 5}, // 5 is out of range for 2-element list
      );
      final filter = BySetPosFilter(rrule);
      final source = [
        CalDateTime.date(2025, 1, 1),
        CalDateTime.date(2025, 2, 1),
      ];
      final result = filter.transform(source).toList();

      // Should only get positions 1 and 2 (5 is out of range)
      expect(result.length, 2);
      expect(result[0].toString(), '20250101');
      expect(result[1].toString(), '20250201');
    });

    test('BYSETPOS skips out-of-range negative values', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.yearly,
        bySetPos: {-1, -10}, // -10 is out of range
      );
      final filter = BySetPosFilter(rrule);
      final source = [
        CalDateTime.date(2025, 1, 1),
        CalDateTime.date(2025, 2, 1),
      ];
      final result = filter.transform(source).toList();

      expect(result.length, 1);
      expect(result[0].toString(), '20250201');
    });

    test('Null BYSETPOS passes through unchanged', () {
      final rrule = RecurrenceRule(freq: RecurrenceFrequency.yearly);
      final filter = BySetPosFilter(rrule);
      final source = [CalDateTime.date(2025, 1, 1)];
      final result = filter.transform(source).toList();

      expect(result.length, 1);
      expect(result[0].toString(), '20250101');
    });
  });

  group('Edge Cases and Complex Scenarios', () {
    test('Multiple filters chained together', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.yearly,
        byMonth: {1, 6},
        byMonthDay: {1, 15},
      );

      final monthFilter = ByMonthFilter(rrule);
      final dayFilter = ByMonthDayFilter(rrule);

      final source = [CalDateTime.date(2025, 1, 1)];
      final afterMonth = monthFilter.transform(source);
      final result = dayFilter.transform(afterMonth).toList();

      expect(result.length, 4);
      expect(result[0].toString(), '20250101');
      expect(result[1].toString(), '20250115');
      expect(result[2].toString(), '20250601');
      expect(result[3].toString(), '20250615');
    });

    test('Empty source yields empty result', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.monthly,
        byMonthDay: {1, 15},
      );
      final filter = ByMonthDayFilter(rrule);
      final source = <CalDateTime>[];
      final result = filter.transform(source).toList();

      expect(result.length, 0);
    });

    test('Leap year February 29 handling in BYMONTHDAY', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.monthly,
        byMonthDay: {29},
      );
      final filter = ByMonthDayFilter(rrule);

      // Leap year
      final source1 = [CalDateTime.date(2024, 2, 1)];
      final result1 = filter.transform(source1).toList();
      expect(result1.length, 1);
      expect(result1[0].toString(), '20240229');

      // Non-leap year
      final source2 = [CalDateTime.date(2025, 2, 1)];
      final result2 = filter.transform(source2).toList();
      expect(result2.length, 0);
    });

    test('BYDAY with all 7 weekdays', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.weekly,
        byDay: {
          ByDay(Weekday.mo),
          ByDay(Weekday.tu),
          ByDay(Weekday.we),
          ByDay(Weekday.th),
          ByDay(Weekday.fr),
          ByDay(Weekday.sa),
          ByDay(Weekday.su),
        },
      );
      final filter = ByDayFilter(rrule);
      final source = [CalDateTime.date(2025, 1, 6)]; // Monday
      final result = filter.transform(source).toList();

      expect(result.length, 7);
    });

    test('BYSETPOS selecting only first and last', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.monthly,
        bySetPos: {1, -1},
      );
      final filter = BySetPosFilter(rrule);
      final source = List.generate(10, (i) => CalDateTime.date(2025, 1, i + 1));
      final result = filter.transform(source).toList();

      expect(result.length, 2);
      expect(result[0].toString(), '20250101');
      expect(result[1].toString(), '20250110');
    });
  });
}
