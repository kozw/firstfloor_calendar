# firstfloor_calendar

[![Pub Package](https://img.shields.io/pub/v/firstfloor_calendar.svg)](https://pub.dev/packages/firstfloor_calendar)
[![codecov](https://codecov.io/github/firstfloorsoftware/firstfloor_calendar/graph/badge.svg?token=W97YVE1EI6)](https://codecov.io/github/firstfloorsoftware/firstfloor_calendar)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Dart library for parsing and working with iCalendar (.ics) files. Built with RFC 5545 compliance in mind, firstfloor_calendar provides a two-layer architecture that offers both low-level document access for custom processing and a high-level semantic API for type-safe calendar operations. Whether you're building a calendar app, processing meeting invites, or managing recurring events, this library gives you the tools to work with iCalendar data efficiently and correctly.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Choose a Parsing Approach](#choose-a-parsing-approach)
- [Core Usage Patterns](#core-usage-patterns)
  - [Basic Parsing](#basic-parsing)
  - [Serializing Back to iCalendar](#serializing-back-to-icalendar)
  - [Working with Events](#working-with-events)
  - [Working with Timezones](#working-with-timezones)
  - [Recurring Events](#recurring-events)
  - [Filtering Events by Date Range](#filtering-events-by-date-range)
  - [Getting All Occurrences](#getting-all-occurrences)
  - [Chronological Ordering Across Multiple Events](#chronological-ordering-across-multiple-events)
- [Advanced Usage](#advanced-usage)
  - [Streaming Large Files](#streaming-large-files)
  - [Conditional Parsing with Stream Parser](#conditional-parsing-with-stream-parser)
  - [Custom Property Parsers](#custom-property-parsers)
- [Common Gotchas](#common-gotchas)
- [Architecture](#architecture)
  - [Document Layer](#document-layer)
  - [Semantic Layer](#semantic-layer)
  - [Layer Interaction](#layer-interaction)
- [API Reference](#api-reference)
- [Contributing](#contributing)
- [Release Policy](#release-policy)
- [License](#license)

## Features

- Parse iCalendar files into strongly typed models
- Support for events, todos, journals, and timezones
- Full RRULE recurrence expansion
- Memory-efficient streaming for large files
- Extensible with custom property parsers

## Installation

```yaml
dependencies:
  firstfloor_calendar: ^1.0.13
```

## Quick Start

Use the semantic parser for most apps:

```dart
import 'package:firstfloor_calendar/firstfloor_calendar.dart';

final calendar = CalendarParser().parseFromString('''
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Example//EN
BEGIN:VEVENT
UID:event-123@example.com
DTSTAMP:20240315T090000Z
DTSTART:20240315T100000Z
SUMMARY:Team Meeting
END:VEVENT
END:VCALENDAR''');

print(calendar.events.first.summary); // Team Meeting
```

## Choose a Parsing Approach

| Use case | Recommended API |
| --- | --- |
| Parse complete calendars into typed models | `CalendarParser().parseFromString(...)` |
| Parse one semantic component from raw text | `CalendarParser().parseComponentFromString<T>(...)` |
| Work with raw properties/components | `DocumentParser().parse(...)` |
| Process very large files incrementally | `DocumentStreamParser().parseComponents(...)` |
| Query date-range occurrences across many events/todos | `calendar.events.occurrences(...)`, `calendar.todos.occurrences(...)` |

## Core Usage Patterns

### Basic Parsing

Parse iCalendar text into a strongly typed `Calendar` object. The parser handles all RFC 5545 components including events, todos, journals, and timezones.

```dart
import 'package:firstfloor_calendar/firstfloor_calendar.dart';

final ics = '''
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Example//EN
BEGIN:VEVENT
UID:event-123@example.com
DTSTAMP:20240315T090000Z
DTSTART:20240315T100000Z
DTEND:20240315T110000Z
SUMMARY:Team Meeting
END:VEVENT
END:VCALENDAR''';

final parser = CalendarParser();
final calendar = parser.parseFromString(ics);

for (final event in calendar.events) {
  print('${event.summary}: ${event.dtstart}');
}
```

### Serializing Back to iCalendar

You can serialize both document-layer and semantic components back to iCalendar
text using `toIcsString()`. The serializer emits CRLF line endings and
applies RFC 5545 line folding by default.

```dart
final event = CalendarParser().parseComponentFromString<EventComponent>(
  '''
BEGIN:VEVENT
UID:evt-1
DTSTAMP:20250703T120000Z
DTSTART:20250703T130000Z
SUMMARY:Serialized event
END:VEVENT''',
);

final ics = event.toIcsString();
print(ics);
```

### Working with Events

Access event properties with full type safety. Required properties like `uid` and `dtstart` are non-nullable, while optional properties return nullable values.

```dart
final event = calendar.events.first;

// Required properties
print('UID: ${event.uid}');
print('Start: ${event.dtstart}');

// Optional properties
print('Summary: ${event.summary ?? "Untitled"}');
print('Location: ${event.location ?? "No location"}');
print('Description: ${event.description ?? ""}');

// Extension properties
print('Is recurring: ${event.isRecurring}');
print('Is all-day: ${event.isAllDay}');
print('Is multi-day: ${event.isMultiDay}');
print('Duration: ${event.effectiveDuration}');

// Attendees
for (final attendee in event.attendees) {
  print('Attendee: ${attendee.address}');
}
```

### Working with Timezones

Handle timezone-aware dates using the `timezone` package. Initialize timezones before parsing calendars with timezone identifiers.

```dart
import 'package:timezone/data/latest.dart' as tz;

// Initialize timezone database (call once at app startup)
tz.initializeTimeZones();

final ics = '''
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Example//EN
BEGIN:VEVENT
UID:tz-event@example.com
DTSTAMP:20240315T120000Z
DTSTART;TZID=America/New_York:20240315T090000
DTEND;TZID=America/New_York:20240315T100000
SUMMARY:Morning Meeting
END:VEVENT
END:VCALENDAR''';

final parser = CalendarParser();
final calendar = parser.parseFromString(ics);
final event = calendar.events.first;

// Access timezone-aware datetime
print('Start: ${event.dtstart}');
print('Timezone: ${event.dtstart?.time?.tzid}');

// Convert to different timezone (if native is TZDateTime)
if (event.dtstart?.native is tz.TZDateTime) {
  final tzDateTime = event.dtstart!.native as tz.TZDateTime;
  final berlinTime = tz.TZDateTime.from(tzDateTime, tz.getLocation('Europe/Berlin'));
  print('Berlin time: $berlinTime');
}
```

### Recurring Events

Generate occurrences from recurrence rules (RRULE). The `occurrences()`
method returns a lazy iterable that handles both recurring and
non-recurring events gracefully.

```dart
final event = calendar.events.first;

// Get first 10 occurrences
for (final occurrence in event.occurrences().take(10)) {
  print('Occurrence: $occurrence');
}
```

### Filtering Events by Date Range

Use the `occurrences` extension to filter events that occur within a specific date range. This works correctly with multi-day events, all-day events, and recurring events. Results are always returned in chronological order, regardless of the order in the source file.

```dart
final start = CalDateTime.date(2024, 3, 1);
final end = CalDateTime.date(2024, 3, 31);

// Get all event occurrences in March 2024
final occurrencesInMarch = calendar.events.occurrences(
  start: start,
  end: end,
);

for (final result in occurrencesInMarch) {
  print('${result.event.summary}: ${result.occurrence}');
}

// Works with todos and journals too
final todoOccurrences = calendar.todos.occurrences(
  start: start,
  end: end,
);
```

### Getting All Occurrences

When you need all occurrences across multiple components without filtering by date range, simply call `occurrences()` without parameters. Use `.take()` to limit results when working with recurring events that could generate infinite occurrences.

```dart
// Get all occurrences without date filtering
final allOccurrences = calendar.events.occurrences();

for (final result in allOccurrences.take(20)) {
  print('${result.event.summary}: ${result.occurrence}');
}
```

### Chronological Ordering Across Multiple Events

The `occurrences` extension automatically sorts event occurrences chronologically, regardless of the order they appear in the source iCalendar file.

```dart
final ics = '''
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Example//EN
BEGIN:VEVENT
UID:event3@example.com
DTSTAMP:20240301T000000Z
DTSTART:20240315T140000
SUMMARY:Afternoon Meeting
END:VEVENT
BEGIN:VEVENT
UID:event1@example.com
DTSTAMP:20240301T000000Z
DTSTART:20240310T090000
SUMMARY:Early Meeting
END:VEVENT
BEGIN:VEVENT
UID:event2@example.com
DTSTAMP:20240301T000000Z
DTSTART:20240312T100000
SUMMARY:Mid-Month Standup
END:VEVENT
END:VCALENDAR''';

final parser = CalendarParser();
final calendar = parser.parseFromString(ics);

// Events are automatically ordered chronologically
final start = CalDateTime.date(2024, 3, 1);
final end = CalDateTime.date(2024, 3, 31);

for (final result in calendar.events.occurrences(
  start: start,
  end: end,
)) {
  print('${result.occurrence}: ${result.event.summary}');
}

// Output (chronologically sorted despite unordered source):
// 2024-03-10 09:00:00: Early Meeting
// 2024-03-12 10:00:00: Mid-Month Standup
// 2024-03-15 14:00:00: Afternoon Meeting
```

## Advanced Usage

### Streaming Large Files

Parse large iCalendar files efficiently using the streaming parser. Components are processed one at a time without loading the entire file into memory.

```dart
import 'dart:io';

final file = File('large-calendar.ics');
final streamParser = DocumentStreamParser();

await for (final component in streamParser.parseComponents(file.openRead())) {
  if (component.name == 'VEVENT') {
    final summary = component.properties
        .where((p) => p.name == 'SUMMARY')
        .firstOrNull
        ?.value;
    print('Event: ${summary ?? "Untitled"}');
  }
}
```

### Conditional Parsing with Stream Parser

Process large files and selectively convert components to typed models based on specific criteria.

```dart
import 'dart:io';

final file = File('large-calendar.ics');
final streamParser = DocumentStreamParser();
final events = <EventComponent>[];

await for (final component in streamParser.parseComponents(file.openRead())) {
  if (component.name == 'VEVENT') {
    // Check for a specific condition before parsing
    final status = component.properties
        .where((p) => p.name == 'STATUS')
        .firstOrNull
        ?.value;

    // Only convert confirmed events to typed models
    if (status == 'CONFIRMED') {
      final event = component.toEvent();
      events.add(event);
    }
  }
}

print('Found ${events.length} confirmed events');
for (final event in events) {
  print('${event.summary}: ${event.dtstart}');
}
```

### Custom Property Parsers

Extend the parser with custom property handlers for vendor-specific or experimental properties. Register custom parsers before parsing your calendar data.

```dart
final parser = CalendarParser();

parser.registerPropertyRule(
  componentName: 'VEVENT',
  propertyName: 'X-CUSTOM-PRIORITY',
  rule: PropertyRule(
    parser: (property) {
      final value = int.tryParse(property.value);
      if (value == null || value < 1 || value > 10) {
        throw ParseException(
          'X-CUSTOM-PRIORITY must be between 1-10',
          lineNumber: property.lineNumber,
        );
      }
      return value;
    },
  ),
);

final calendar = parser.parseFromString(ics);
final priority = calendar.events.first.value<int>('X-CUSTOM-PRIORITY');
```

## Common Gotchas

- Initialize timezone data before parsing timezone-aware calendars:
  `tz.initializeTimeZones()`.
- Recurrence expansion is lazy; for potentially unbounded rules, use
  `.take(n)` or pass an `end` boundary.
- `CalDateTime.date(...)` is a DATE value (all-day), while
  `CalDateTime.local(...)` / `CalDateTime.utc(...)` are DATE-TIME values.
- Prefer `DocumentStreamParser` over full in-memory parsing when reading
  very large `.ics` files.

## Architecture

The library uses a two-layer architecture that separates parsing concerns and provides flexibility for different use cases:

### Document Layer

The **Document Layer** (`DocumentParser` and `DocumentStreamParser`) handles the low-level parsing of iCalendar text. It:

- Parses .ics files into an untyped tree structure (`CalendarDocument`)
- Handles line unfolding, property parsing, and component nesting
- Provides streaming capabilities for large files via `DocumentStreamParser`
- Performs no semantic validation - just structural parsing
- Returns raw components (`CalendarDocumentComponent`) and properties (`CalendarProperty`)

Use the Document Layer when you need:
- Low-level access to raw iCalendar data
- Custom validation or transformation logic
- Memory-efficient streaming of large files
- Access to non-standard or vendor-specific properties

### Semantic Layer

The **Semantic Layer** (`CalendarParser`) builds on top of the Document Layer to provide type-safe models. It:

- Converts document components into strongly typed models (`EventComponent`, `TodoComponent`, etc.)
- Validates property values according to RFC 5545
- Provides type-safe access to properties with proper nullability
- Supports custom property parsers via `registerPropertyRule`
- Handles recurrence rule expansion and date calculations

Use the Semantic Layer when you need:
- Type-safe business logic and calendar operations
- RFC 5545 validation and compliance checking
- Convenient access to common properties
- Recurrence rule processing and occurrence generation

### Layer Interaction

The layers work together seamlessly:

```dart
// Parse at document level
final document = DocumentParser().parse(ics);

// Optionally inspect/transform document
// ... custom logic ...

// Convert to semantic models
final calendar = CalendarParser().parse(document);

// Or go directly to semantic layer
final calendar = CalendarParser().parseFromString(ics);
```

You can also bridge from document to semantic selectively using extension methods like `toEvent()`, `toTodo()`, etc.

## API Reference

- Package docs: <https://pub.dev/documentation/firstfloor_calendar/latest/>
- Library entry point:
  <https://pub.dev/documentation/firstfloor_calendar/latest/firstfloor_calendar/>

## Contributing

Run these checks before opening a PR:

```bash
dart format --set-exit-if-changed .
dart analyze --fatal-infos
dart test
```

## Release Policy

For maintainers, the release checklist and policy are documented in
[`RELEASE.md`](RELEASE.md).

## License

MIT License - see [LICENSE](LICENSE) file for details.
