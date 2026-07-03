import '../../document/document.dart';
import '../semantic.dart';

/// Helper function to determine if a component spans multiple days.
///
/// [duration] is the effective duration of the component.
/// [startDate] is the start date/time of the component.
/// [endDate] is the end date/time of the component.
///
/// Returns true if the component appears on more than one calendar day.
bool _isMultiDay({
  required CalDuration? duration,
  required CalDateTime? startDate,
  required CalDateTime? endDate,
}) {
  if (duration == null) return false;

  // For negative durations, consider it not multi-day
  if (duration.sign == Sign.negative) return false;

  // For all-day items (DATE values), check if duration is MORE than 1 day
  final isAllDay = startDate?.isDate ?? false;
  if (isAllDay) {
    return duration.days > 1;
  }

  // For timed items, check if duration is at least 1 day
  // or if it crosses midnight
  if (duration.days > 0) return true;

  // For items with only hours/minutes/seconds, check if it crosses midnight
  if (endDate != null && startDate != null) {
    return startDate.day != endDate.day ||
        startDate.month != endDate.month ||
        startDate.year != endDate.year;
  }

  return false;
}

/// Extensions for [EventComponent] to enhance functionality.
extension EventComponentExtensions on EventComponent {
  /// Determines if the event is recurring based on the presence of
  /// a recurrence rule (RRULE) or recurrence dates (RDATE).
  bool get isRecurring => rrule != null || rdates.isNotEmpty;

  /// Returns true if this event is an all-day event
  bool get isAllDay => dtstart?.isDate ?? false;

  /// Returns true if this event spans multiple days.
  ///
  /// An event is considered multi-day if it appears on more than one calendar day.
  /// For all-day events, this means the duration is more than 1 day.
  /// For timed events, this means it crosses midnight to a different day.
  /// Returns false if the event has no end time or duration.
  bool get isMultiDay => _isMultiDay(
    duration: effectiveDuration,
    startDate: dtstart,
    endDate: effectiveEnd,
  );

  /// Returns the effective end time (dtend or dtstart + duration)
  CalDateTime? get effectiveEnd {
    if (dtend != null) return dtend;
    if (duration != null && dtstart != null) {
      return dtstart!.addDuration(duration!);
    }
    return null;
  }

  /// Returns the effective duration of the event.
  ///
  /// If [duration] is specified, returns it directly.
  /// Otherwise, calculates duration from [effectiveEnd] - [dtstart].
  /// Returns null if the event has no duration or end time.
  CalDuration? get effectiveDuration {
    if (duration != null) return duration;

    final end = effectiveEnd;
    if (end != null && dtstart != null && end != dtstart) {
      final diff = end.native.difference(dtstart!.native);
      final isNegative = diff.isNegative;
      final absDiff = diff.abs();

      return CalDuration(
        sign: isNegative ? Sign.negative : Sign.positive,
        days: absDiff.inDays,
        hours: absDiff.inHours % 24,
        minutes: absDiff.inMinutes % 60,
        seconds: absDiff.inSeconds % 60,
      );
    }

    return null;
  }

  /// Generates all occurrences of the event based on its recurrence
  /// rules, exclusions (EXDATE), and additional dates (RDATE).
  ///
  /// [start] and [end] can be provided to limit the occurrences.
  ///
  /// Returns an empty iterable if the event has no start date.
  Iterable<CalDateTime> occurrences({CalDateTime? start, CalDateTime? end}) {
    if (dtstart == null) return const Iterable<CalDateTime>.empty();

    final iterator = RecurrenceIterator(
      dtstart: dtstart!,
      rrule: rrule,
      exdates: exdates,
      rdates: rdates,
    );
    return iterator.occurrences(
      start: start,
      end: end,
      duration: effectiveDuration,
    );
  }
}

/// Extensions for [TodoComponent] to enhance functionality.
extension TodoComponentExtensions on TodoComponent {
  /// Determines if the todo is recurring based on the presence of
  /// a recurrence rule (RRULE) or recurrence dates (RDATE).
  bool get isRecurring => rrule != null || rdates.isNotEmpty;

  /// Returns true if this todo spans multiple days.
  ///
  /// A todo is considered multi-day if it appears on more than one calendar day.
  /// This is determined by the duration from [dtstart] to [due].
  /// Returns false if the todo has no due date or duration.
  bool get isMultiDay => _isMultiDay(
    duration: effectiveDuration,
    startDate: dtstart,
    endDate: due,
  );

  /// Returns the effective duration of the todo.
  ///
  /// If [duration] is specified, returns it directly.
  /// Otherwise, calculates duration from [due] - [dtstart].
  /// Returns null if the todo has no duration or due date.
  CalDuration? get effectiveDuration {
    if (duration != null) return duration;

    if (due != null && dtstart != null && due != dtstart) {
      final diff = due!.native.difference(dtstart!.native);
      final isNegative = diff.isNegative;
      final absDiff = diff.abs();

      return CalDuration(
        sign: isNegative ? Sign.negative : Sign.positive,
        days: absDiff.inDays,
        hours: absDiff.inHours % 24,
        minutes: absDiff.inMinutes % 60,
        seconds: absDiff.inSeconds % 60,
      );
    }

    return null;
  }

  /// Generates all occurrences of the todo based on its recurrence
  /// rules, exclusions (EXDATE), and additional dates (RDATE).
  ///
  /// [start] and [end] can be provided to limit the occurrences.
  ///
  /// Returns an empty iterable if the todo has neither start nor due date.
  Iterable<CalDateTime> occurrences({CalDateTime? start, CalDateTime? end}) {
    final startDate = dtstart ?? due;
    if (startDate == null) return const Iterable<CalDateTime>.empty();

    final iterator = RecurrenceIterator(
      dtstart: startDate,
      rrule: rrule,
      exdates: exdates,
      rdates: rdates,
    );
    return iterator.occurrences(
      start: start,
      end: end,
      duration: effectiveDuration,
    );
  }
}

/// Extensions for [JournalComponent] to enhance functionality.
extension JournalComponentExtensions on JournalComponent {
  /// Determines if the journal is recurring based on the presence of
  /// a recurrence rule (RRULE) or recurrence dates (RDATE).
  bool get isRecurring => rrule != null || rdates.isNotEmpty;

  /// Generates all occurrences of the journal based on its recurrence
  /// rules, exclusions (EXDATE), and additional dates (RDATE).
  ///
  /// [start] and [end] can be provided to limit the occurrences.
  ///
  /// Returns an empty iterable if the journal has no start date.
  Iterable<CalDateTime> occurrences({CalDateTime? start, CalDateTime? end}) {
    if (dtstart == null) return const Iterable<CalDateTime>.empty();

    final iterator = RecurrenceIterator(
      dtstart: dtstart!,
      rrule: rrule,
      exdates: exdates,
      rdates: rdates,
    );
    return iterator.occurrences(start: start, end: end);
  }
}

/// Extensions for [TimeZoneSubComponent] to enhance functionality.
extension TimeZoneSubComponentExtensions on TimeZoneSubComponent {
  /// Determines if the timezone component is recurring based on the presence of
  /// a recurrence rule (RRULE) or recurrence dates (RDATE).
  bool get isRecurring => rrule != null || rdates.isNotEmpty;

  /// Generates all occurrences of the timezone component based on its recurrence
  /// rules, exclusions (EXDATE), and additional dates (RDATE).
  ///
  /// [start] and [end] can be provided to limit the occurrences.
  Iterable<CalDateTime> occurrences({CalDateTime? start, CalDateTime? end}) {
    final iterator = RecurrenceIterator(
      dtstart: dtstart,
      rrule: rrule,
      rdates: rdates,
    );
    return iterator.occurrences(start: start, end: end);
  }
}

/// Extensions for [CalendarDocumentComponent] to enhance functionality.
extension CalendarDocumentComponentExtensions on CalendarDocumentComponent {
  /// Determines if this component is an event (VEVENT).
  bool get isEvent => name == 'VEVENT';

  /// Determines if this component is a todo (VTODO).
  bool get isTodo => name == 'VTODO';

  /// Determines if this component is a journal (VJOURNAL).
  bool get isJournal => name == 'VJOURNAL';

  /// Determines if this component is a free/busy (VFREEBUSY).
  bool get isFreeBusy => name == 'VFREEBUSY';

  /// Determines if this component is a timezone (VTIMEZONE).
  bool get isTimezone => name == 'VTIMEZONE';

  /// Determines if this component is an alarm (VALARM).
  bool get isAlarm => name == 'VALARM';

  /// Converts this raw component into a typed component using the given parser.
  EventComponent toEvent({CalendarParser? parser}) {
    if (!isEvent) throw Exception('Not an event component');
    parser ??= CalendarParser();
    return parser.parseComponent(this);
  }

  /// Converts this raw component into a typed todo component using the given parser.
  TodoComponent toTodo({CalendarParser? parser}) {
    if (!isTodo) throw Exception('Not a todo component');
    parser ??= CalendarParser();
    return parser.parseComponent(this);
  }

  /// Converts this raw component into a typed journal component using the given parser.
  JournalComponent toJournal({CalendarParser? parser}) {
    if (!isJournal) throw Exception('Not a journal component');
    parser ??= CalendarParser();
    return parser.parseComponent(this);
  }

  /// Converts this raw component into a typed free/busy component using the given parser.
  FreeBusyComponent toFreeBusy({CalendarParser? parser}) {
    if (!isFreeBusy) throw Exception('Not a free/busy component');
    parser ??= CalendarParser();
    return parser.parseComponent(this);
  }

  /// Converts this raw component into a typed timezone component using the given parser.
  TimeZoneComponent toTimeZone({CalendarParser? parser}) {
    if (!isTimezone) throw Exception('Not a timezone component');
    parser ??= CalendarParser();
    return parser.parseComponent(this);
  }

  /// Converts this raw component into a typed alarm component using the given parser.
  AlarmComponent toAlarm({CalendarParser? parser}) {
    if (!isAlarm) throw Exception('Not an alarm component');
    parser ??= CalendarParser();
    return parser.parseComponent(this);
  }
}
