import 'package:collection/collection.dart';

import '../semantic.dart';

/// Represents a single event occurrence.
typedef EventOccurrence = ({CalDateTime occurrence, EventComponent event});

/// Query extensions for [Iterable]<[EventComponent]> to enhance functionality.
extension EventIterableQuery on Iterable<EventComponent> {
  /// Finds all event occurrences within the specified optional date range.
  ///
  /// Returns occurrences in chronological order across all events.
  ///
  /// [start] and [end] should be [CalDateTime] values that define the
  /// inclusive date range. Use [CalDateTime.date] for all-day boundaries
  /// or [CalDateTime] with time components for precise time ranges.
  ///
  /// For recurring events without an end date, occurrences are generated
  /// up to [end] only.
  ///
  /// Example with date-only boundaries:
  /// ```dart
  /// final start = CalDateTime.date(2025, 1, 1);
  /// final end = CalDateTime.date(2025, 1, 31);
  ///
  /// for (final result in calendar.events.occurrences(
  ///   start: start,
  ///   end: end,
  /// )) {
  ///   print('${result.event.summary}: ${result.occurrence}');
  /// }
  /// ```
  ///
  /// Example with date-time boundaries:
  /// ```dart
  /// final start = CalDateTime(2025, 1, 1, 9, 0, 0);
  /// final end = CalDateTime(2025, 1, 31, 17, 0, 0);
  ///
  /// for (final result in calendar.events.occurrences(
  ///   start: start,
  ///   end: end,
  /// )) {
  ///   print('${result.event.summary}: ${result.occurrence}');
  /// }
  /// ```
  Iterable<EventOccurrence> occurrences({
    CalDateTime? start,
    CalDateTime? end,
  }) {
    return _OccurrenceIterator.occurrences<EventComponent>(
      components: this,
      ignore: (event) => event.dtstart == null,
      occurrences: (event) => event.occurrences(start: start, end: end),
    ).map((e) => (occurrence: e.occurrence, event: e.component));
  }
}

/// Represents a single todo occurrence.
typedef TodoOccurrence = ({CalDateTime occurrence, TodoComponent todo});

/// Query extensions for [Iterable]<[TodoComponent]> to enhance functionality.
extension TodoIterableQuery on Iterable<TodoComponent> {
  /// Finds all todo occurrences within the specified date range.
  ///
  /// Returns occurrences in chronological order across all todos.
  ///
  /// [start] and [end] should be [CalDateTime] values that define the
  /// inclusive date range. Use [CalDateTime.date] for all-day boundaries
  /// or [CalDateTime] with time components for precise time ranges.
  ///
  /// For recurring todos without an end date, occurrences are generated
  /// up to [end] only.
  ///
  /// Example with date-only boundaries:
  /// ```dart
  /// final start = CalDateTime.date(2025, 1, 1);
  /// final end = CalDateTime.date(2025, 1, 31);
  ///
  /// for (final result in calendar.todos.occurrences(
  ///   start: start,
  ///   end: end,
  /// )) {
  ///   print('${result.todo.summary}: ${result.occurrence}');
  /// }
  /// ```
  ///
  /// Example with date-time boundaries:
  /// ```dart
  /// final start = CalDateTime(2025, 1, 1, 9, 0, 0);
  /// final end = CalDateTime(2025, 1, 31, 17, 0, 0);
  ///
  /// for (final result in calendar.todos.occurrences(
  ///   start: start,
  ///   end: end,
  /// )) {
  ///   print('${result.todo.summary}: ${result.occurrence}');
  /// }
  /// ```
  Iterable<TodoOccurrence> occurrences({CalDateTime? start, CalDateTime? end}) {
    return _OccurrenceIterator.occurrences<TodoComponent>(
      components: this,
      ignore: (todo) => todo.dtstart == null && todo.due == null,
      occurrences: (todo) => todo.occurrences(start: start, end: end),
    ).map((e) => (occurrence: e.occurrence, todo: e.component));
  }
}

/// Represents a single journal occurrence.
typedef JournalOccurrence = ({
  CalDateTime occurrence,
  JournalComponent journal,
});

/// Query extensions for [Iterable]<[JournalComponent]> to enhance functionality.
extension JournalIterableQuery on Iterable<JournalComponent> {
  /// Finds all journal occurrences within the specified date range.
  ///
  /// Returns occurrences in chronological order across all journals.
  ///
  /// [start] and [end] should be [CalDateTime] values that define the
  /// inclusive date range. Use [CalDateTime.date] for all-day boundaries
  /// or [CalDateTime] with time components for precise time ranges.
  ///
  /// For recurring journals without an end date, occurrences are generated
  /// up to [end] only.
  ///
  /// Example with date-only boundaries:
  /// ```dart
  /// final start = CalDateTime.date(2025, 1, 1);
  /// final end = CalDateTime.date(2025, 1, 31);
  ///
  /// for (final result in calendar.journals.occurrences(
  ///   start: start,
  ///   end: end,
  /// )) {
  ///   print('${result.journal.summary}: ${result.occurrence}');
  /// }
  /// ```
  ///
  /// Example with date-time boundaries:
  /// ```dart
  /// final start = CalDateTime(2025, 1, 1, 9, 0, 0);
  /// final end = CalDateTime(2025, 1, 31, 17, 0, 0);
  ///
  /// for (final result in calendar.journals.occurrences(
  ///   start: start,
  ///   end: end,
  /// )) {
  ///   print('${result.journal.summary}: ${result.occurrence}');
  /// }
  /// ```
  Iterable<JournalOccurrence> occurrences({
    CalDateTime? start,
    CalDateTime? end,
  }) {
    return _OccurrenceIterator.occurrences<JournalComponent>(
      components: this,
      ignore: (journal) => journal.dtstart == null,
      occurrences: (journal) => journal.occurrences(start: start, end: end),
    ).map((e) => (occurrence: e.occurrence, journal: e.component));
  }
}

/// Represents a single timezone occurrence.
typedef TimeZoneOccurrence = ({
  CalDateTime occurrence,
  TimeZoneSubComponent timezone,
});

/// Query extensions for [Iterable]<[TimeZoneSubComponent]> to enhance functionality.
extension TimeZoneIterableQuery on Iterable<TimeZoneSubComponent> {
  /// Finds all timezone occurrences within the specified date range.
  ///
  /// Returns occurrences in chronological order across all timezones.
  ///
  /// [start] and [end] should be [CalDateTime] values that define the
  /// inclusive date range. Use [CalDateTime.date] for all-day boundaries
  /// or [CalDateTime] with time components for precise time ranges.
  ///
  /// For recurring timezone rules without an end date, occurrences are generated
  /// up to [end] only.
  ///
  /// Example with date-only boundaries:
  /// ```dart
  /// final start = CalDateTime.date(2025, 1, 1);
  /// final end = CalDateTime.date(2025, 1, 31);
  ///
  /// for (final result in timezoneComponents.occurrences(
  ///   start: start,
  ///   end: end,
  /// )) {
  ///   print('${result.timezone.tzoffsetTo}: ${result.occurrence}');
  /// }
  /// ```
  ///
  /// Example with date-time boundaries:
  /// ```dart
  /// final start = CalDateTime(2025, 1, 1, 9, 0, 0);
  /// final end = CalDateTime(2025, 1, 31, 17, 0, 0);
  ///
  /// for (final result in timezoneComponents.occurrences(
  ///   start: start,
  ///   end: end,
  /// )) {
  ///   print('${result.timezone.tzoffsetTo}: ${result.occurrence}');
  /// }
  /// ```
  Iterable<TimeZoneOccurrence> occurrences({
    CalDateTime? start,
    CalDateTime? end,
  }) {
    return _OccurrenceIterator.occurrences<TimeZoneSubComponent>(
      components: this,
      ignore: (timezone) => false, // No timezones to ignore
      occurrences: (timezone) => timezone.occurrences(start: start, end: end),
    ).map((e) => (occurrence: e.occurrence, timezone: e.component));
  }
}

/// Helper class to track a generic occurrence iterator.
class _OccurrenceIterator<T> implements Comparable<_OccurrenceIterator<T>> {
  final T component;
  final Iterator<CalDateTime> iterator;
  final int sequence;

  _OccurrenceIterator(this.component, this.iterator, this.sequence);

  @override
  int compareTo(_OccurrenceIterator<T> other) {
    final timeCompare = iterator.current.compareTo(other.iterator.current);
    if (timeCompare != 0) return timeCompare;
    // If same time, preserve insertion order (stable sort)
    return sequence.compareTo(other.sequence);
  }

  /// Returns occurrences in chronological order across all components.
  static Iterable<({CalDateTime occurrence, T component})> occurrences<T>({
    required Iterable<T> components,
    required bool Function(T component) ignore,
    required Iterable<CalDateTime> Function(T component) occurrences,
  }) sync* {
    // Use a priority queue to efficiently get the earliest occurrence.
    // Use sequence number for stable sorting when occurrences are at the same time.
    var sequence = 0;
    final queue = PriorityQueue<_OccurrenceIterator<T>>();

    // setup iterators for each component and add to queue
    for (final component in components) {
      // skip ignored components
      if (ignore(component)) continue;

      final entry = _OccurrenceIterator<T>(
        component,
        occurrences(component).iterator,
        sequence++,
      );

      // add to queue if it has at least one occurrence
      if (entry.iterator.moveNext()) {
        queue.add(entry);
      }
    }

    // Process occurrences in chronological order using the queue
    while (queue.isNotEmpty) {
      final entry = queue.removeFirst();
      yield (occurrence: entry.iterator.current, component: entry.component);

      if (entry.iterator.moveNext()) {
        queue.add(entry); // Re-insert if it has more occurrences
      }
    }
  }
}
