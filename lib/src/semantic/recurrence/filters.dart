import '../semantic.dart';

/// Base class for BYxxx rule filters that transform a stream of dates
/// according to the specific BYxxx rule logic.
abstract class ByRuleFilter {
  final RecurrenceRule rrule;

  const ByRuleFilter(this.rrule);

  bool hasNoOccurrences() {
    return false;
  }

  Iterable<CalDateTime> transform(Iterable<CalDateTime> source);
}

class ByMonthFilter extends ByRuleFilter {
  const ByMonthFilter(super.rrule);

  @override
  bool hasNoOccurrences() {
    // if BYMONTH is empty and FREQ is MONTHLY, no occurrences possible
    return rrule.byMonth?.isEmpty == true &&
        rrule.freq == RecurrenceFrequency.monthly;
  }

  @override
  Iterable<CalDateTime> transform(Iterable<CalDateTime> source) sync* {
    // no BYMONTH, just pass through
    if (rrule.byMonth == null) {
      yield* source;
      return;
    }

    if (rrule.freq == RecurrenceFrequency.yearly) {
      // expand to all months in BYMONTH
      for (final dt in source) {
        for (final month in rrule.byMonth!) {
          final candidate = dt.copyWith(month: month);
          // ensure day is valid for month
          if (candidate.day != dt.day) continue;
          yield candidate;
        }
      }
    } else {
      // limit
      for (final dt in source) {
        if (rrule.byMonth!.contains(dt.month)) {
          yield dt;
        }
      }
    }
  }
}

class ByWeekNoFilter extends ByRuleFilter {
  const ByWeekNoFilter(super.rrule);

  @override
  Iterable<CalDateTime> transform(Iterable<CalDateTime> source) sync* {
    // no BYWEEKNO, just pass through
    if (rrule.byWeekNo == null) {
      yield* source;
      return;
    }

    if (rrule.freq == RecurrenceFrequency.yearly) {
      final weekDayStart = rrule.wkst ?? Weekday.mo;

      // expand to all weeknos in BYWEEKNO
      for (final dt in source) {
        final startOfYear = dt.copyWith(month: 1, day: 1);
        var startOfFirstWeek = DateUtils.startOfWeek(startOfYear, weekDayStart);
        // first week of year contains at least four (4) days in that calendar year.
        if (startOfFirstWeek.day <= 28 && startOfFirstWeek.month == 12) {
          startOfFirstWeek = startOfFirstWeek.add(days: 7);
        }

        for (var week in rrule.byWeekNo!) {
          // positive values indicate counting from start of year
          if (week > 0) {
            yield startOfFirstWeek.add(days: (week - 1) * 7);
          }
          // negative values indicate counting from end of year
          else if (week < 0) {
            final startOfLastWeek = DateUtils.startOfWeek(
              dt.copyWith(month: 12, day: 31),
              weekDayStart,
            );
            yield startOfLastWeek.add(days: (week + 1) * 7);
          }
        }
      }
    } else {
      // N/A, ignore
      yield* source;
    }
  }
}

class ByYearDayFilter extends ByRuleFilter {
  const ByYearDayFilter(super.rrule);

  @override
  Iterable<CalDateTime> transform(Iterable<CalDateTime> source) sync* {
    // no BYYEARDAY, just pass through
    if (rrule.byYearDay == null) {
      yield* source;
      return;
    }

    if (rrule.freq == RecurrenceFrequency.yearly) {
      // expand to all yeardays in BYYEARDAY
      for (final dt in source) {
        final startOfYear = dt.copyWith(month: 1, day: 1);
        final daysInYear = DateUtils.totalDaysInYear(startOfYear.year);

        for (final day in rrule.byYearDay!) {
          // positive values indicate counting from start of year
          if (day > 0 && day <= daysInYear) {
            yield startOfYear.add(days: day - 1);
          }
          // negative values indicate counting from end of year
          else if (day < 0 && -day <= daysInYear) {
            yield startOfYear.add(days: daysInYear + day);
          }
        }
      }
    } else if (rrule.freq == RecurrenceFrequency.monthly ||
        rrule.freq == RecurrenceFrequency.weekly ||
        rrule.freq == RecurrenceFrequency.daily) {
      // N/A, ignore
      yield* source;
    } else {
      // limit
      for (final dt in source) {
        final dayOfYear = dt.dayOfYear;
        final daysInYear = DateUtils.totalDaysInYear(dt.year);
        for (final day in rrule.byYearDay!) {
          // positive values indicate counting from start of year
          if (day > 0 && dayOfYear == day) {
            yield dt;
          }
          // negative values indicate counting from end of year
          else if (day < 0 && dayOfYear == daysInYear + day + 1) {
            yield dt;
          }
        }
      }
    }
  }
}

class ByMonthDayFilter extends ByRuleFilter {
  const ByMonthDayFilter(super.rrule);

  @override
  Iterable<CalDateTime> transform(Iterable<CalDateTime> source) sync* {
    // no BYMONTHDAY, just pass through
    if (rrule.byMonthDay == null) {
      yield* source;
      return;
    }

    if (rrule.freq == RecurrenceFrequency.monthly ||
        rrule.freq == RecurrenceFrequency.yearly) {
      // expand to all monthdays in BYMONTHDAY
      for (final dt in source) {
        final daysInMonth = DateUtils.totalDaysInMonth(dt.year, dt.month);

        for (final day in rrule.byMonthDay!) {
          // positive values indicate counting from start of month
          if (day > 0 && day <= daysInMonth) {
            yield dt.copyWith(day: day);
            continue;
          }
          // negative values indicate counting from end of month
          else if (day < 0 && -day <= daysInMonth) {
            // negative values indicate counting from end of month
            yield dt.copyWith(day: daysInMonth + day + 1);
          }
        }
      }
    } else if (rrule.freq == RecurrenceFrequency.weekly) {
      // N/A, ignore
      yield* source;
    } else {
      // limit
      for (final dt in source) {
        final daysInMonth = DateUtils.totalDaysInMonth(dt.year, dt.month);

        for (final day in rrule.byMonthDay!) {
          // positive values indicate counting from start of month
          if (day > 0 && dt.day == day) {
            yield dt;
          }
          // negative values indicate counting from end of month
          else if (day < 0 && dt.day == daysInMonth + day + 1) {
            yield dt;
          }
        }
      }
    }
  }
}

class ByDayFilter extends ByRuleFilter {
  const ByDayFilter(super.rrule);

  @override
  Iterable<CalDateTime> transform(Iterable<CalDateTime> source) sync* {
    // no BYDAY, just pass through
    if (rrule.byDay == null) {
      yield* source;
      return;
    }

    if (rrule.freq == RecurrenceFrequency.yearly) {
      // Limit if BYYEARDAY or BYMONTHDAY is present
      if (rrule.byYearDay != null || rrule.byMonthDay != null) {
        for (final dt in source) {
          if (rrule.byDay!.any((d) => d.weekday == dt.weekday)) {
            yield dt;
          }
        }
      } else if (rrule.byWeekNo != null) {
        // otherwise, special expand for WEEKLY if BYWEEKNO is present.
        yield* _expandWeekly(source);
      } else if (rrule.byMonth != null) {
        // otherwise, special expand for MONTHLY if BYMONTH is present.
        yield* _expandMonthly(source);
      } else {
        // otherwise, special expand for YEARLY.
        yield* _expandYearly(source);
      }
    } else if (rrule.freq == RecurrenceFrequency.monthly) {
      // Limit if BYMONTHDAY is present
      if (rrule.byMonthDay != null) {
        for (final dt in source) {
          if (rrule.byDay!.any((d) => d.weekday == dt.weekday)) {
            yield dt;
          }
        }
      } else {
        // otherwise, special expand for MONTHLY.
        yield* _expandMonthly(source);
      }
    } else if (rrule.freq == RecurrenceFrequency.weekly) {
      yield* _expandWeekly(source);
    } else {
      // limit only
      for (final dt in source) {
        if (rrule.byDay!.any((d) => d.weekday == dt.weekday)) {
          yield dt;
        }
      }
    }
  }

  Iterable<CalDateTime> _expandMonthly(Iterable<CalDateTime> source) sync* {
    for (final dt in source) {
      final firstOfMonth = dt.copyWith(day: 1);
      final daysInMonth = DateUtils.totalDaysInMonth(dt.year, dt.month);

      for (var i = 0; i < daysInMonth; i++) {
        final candidate = firstOfMonth.add(days: i);

        if (_include(
          candidate,
          ordinal: () => (i / 7).floor() + 1,
          occcurences: (day) => DateUtils.numberOfWeekdaysInMonth(
            firstOfMonth.year,
            firstOfMonth.month,
            day,
          ),
        )) {
          yield candidate;
        }
      }
    }
  }

  Iterable<CalDateTime> _expandWeekly(Iterable<CalDateTime> source) sync* {
    final weekDayStart = rrule.wkst ?? Weekday.mo;
    // sort BYDAY by weekday index where startOfWeek weekday is the first day
    final byDay = rrule.byDay!.toList()
      ..sort((a, b) {
        // adjust index to startOfWeek
        // eg. if week starts on Wed, Wed=0, Thu=1, Fri=2, Sat=3, Sun=4, Mon=5, Tue=6
        final aIndex = (a.weekday.index - weekDayStart.index) % 7;
        final bIndex = (b.weekday.index - weekDayStart.index) % 7;
        return aIndex.compareTo(bIndex);
      });

    // expand to matching weekdays
    for (final dt in source) {
      final startOfWeek = DateUtils.startOfWeek(dt, weekDayStart);

      for (final day in byDay) {
        final index = (day.weekday.index - weekDayStart.index) % 7;
        yield startOfWeek.add(days: index);
      }
    }
  }

  Iterable<CalDateTime> _expandYearly(Iterable<CalDateTime> source) sync* {
    for (final dt in source) {
      final firstOfYear = dt.copyWith(month: 1, day: 1);
      final daysInYear = DateUtils.totalDaysInYear(dt.year);

      for (var i = 0; i < daysInYear; i++) {
        final candidate = firstOfYear.add(days: i);

        if (_include(
          candidate,
          ordinal: () => (i / 7).floor() + 1,
          occcurences: (day) =>
              DateUtils.numberOfWeekdaysInYear(firstOfYear.year, day),
        )) {
          yield candidate;
        }
      }
    }
  }

  bool _include(
    CalDateTime candidate, {
    required int Function() ordinal,
    required int Function(Weekday day) occcurences,
  }) {
    // check all BYDAY rules, must match at least one
    for (final byDay in rrule.byDay!) {
      // check weekday match
      if (byDay.weekday != candidate.weekday) {
        continue;
      }

      // no ordinal number, just match the weekday
      if (byDay.ordinal == null) {
        return true;
      }

      // positive ordinal number
      if (byDay.ordinal! > 0 && ordinal() == byDay.ordinal!) {
        return true;
      }

      // negative ordinal number
      if (byDay.ordinal! < 0 &&
          ordinal() - 1 == occcurences(byDay.weekday) + byDay.ordinal!) {
        return true;
      }
    }
    return false;
  }
}

class ByHourFilter extends ByRuleFilter {
  const ByHourFilter(super.rrule);

  @override
  Iterable<CalDateTime> transform(Iterable<CalDateTime> source) sync* {
    // no BYHOUR, just pass through
    if (rrule.byHour == null) {
      yield* source;
      return;
    }

    if (rrule.freq == RecurrenceFrequency.secondly ||
        rrule.freq == RecurrenceFrequency.minutely ||
        rrule.freq == RecurrenceFrequency.hourly) {
      // limit
      for (final dt in source) {
        if (rrule.byHour!.contains(dt.time!.hour)) {
          yield dt;
        }
      }
    } else {
      // expand to all hours in BYHOUR
      for (final dt in source) {
        for (final hour in rrule.byHour!) {
          yield dt.copyWith(hour: hour);
        }
      }
    }
  }
}

class ByMinuteFilter extends ByRuleFilter {
  const ByMinuteFilter(super.rrule);

  @override
  Iterable<CalDateTime> transform(Iterable<CalDateTime> source) sync* {
    // no BYMINUTE, just pass through
    if (rrule.byMinute == null) {
      yield* source;
      return;
    }

    if (rrule.freq == RecurrenceFrequency.secondly ||
        rrule.freq == RecurrenceFrequency.minutely) {
      // limit
      for (final dt in source) {
        if (rrule.byMinute!.contains(dt.time!.minute)) {
          yield dt;
        }
      }
    } else {
      // expand to all minutes in BYMINUTE
      for (final dt in source) {
        for (final minute in rrule.byMinute!) {
          yield dt.copyWith(minute: minute);
        }
      }
    }
  }
}

class BySecondFilter extends ByRuleFilter {
  const BySecondFilter(super.rrule);

  @override
  Iterable<CalDateTime> transform(Iterable<CalDateTime> source) sync* {
    // no BYSECOND, just pass through
    if (rrule.bySecond == null) {
      yield* source;
      return;
    }

    if (rrule.freq == RecurrenceFrequency.secondly) {
      // limit
      for (final dt in source) {
        if (rrule.bySecond!.contains(dt.time!.second)) {
          yield dt;
        }
      }
    } else {
      // expand to all seconds in BYSECOND
      for (final dt in source) {
        for (final second in rrule.bySecond!) {
          yield dt.copyWith(second: second);
        }
      }
    }
  }
}

class BySetPosFilter extends ByRuleFilter {
  const BySetPosFilter(super.rrule);

  @override
  Iterable<CalDateTime> transform(Iterable<CalDateTime> source) sync* {
    // no BYSETPOS, just pass through
    if (rrule.bySetPos == null) {
      yield* source;
      return;
    }

    final list = source.toList();
    for (final pos in rrule.bySetPos!) {
      // positive values indicate counting from start of list
      if (pos > 0 && pos <= list.length) {
        yield list[pos - 1];
      }
      // negative values indicate counting from end of list
      else if (pos < 0 && -pos <= list.length) {
        yield list[list.length + pos];
      }
    }
  }
}
