# Copilot Instructions for firstfloor_calendar

## Project Overview

RFC 5545 compliant iCalendar (.ics) parser for Dart. Uses a **two-layer architecture**:

1. **Document Layer** (`lib/src/document/`) - Low-level parsing into untyped tree structure
2. **Semantic Layer** (`lib/src/semantic/`) - Type-safe models with RFC 5545 validation

## Architecture

### Data Flow
```
.ics string → DocumentParser → CalendarDocument (untyped) → CalendarParser → Calendar (typed)
```

### Key Classes
- `CalendarDocument` / `CalendarDocumentComponent` - Raw document structure with properties
- `Calendar` - Typed model with `events`, `todos`, `journals`, `timezones`
- `EventComponent`, `TodoComponent`, `JournalComponent` - Typed component models
- `CalendarParser` - Converts documents to semantic models, supports custom property rules
- `RecurrenceIterator` - Lazy occurrence generation from RRULE/RDATE

### Extension Pattern
Extensions in `lib/src/semantic/extensions/` add computed properties and queries:
- `components.dart` - `isRecurring`, `isAllDay`, `isMultiDay`, `effectiveDuration`, `occurrences()`
- `queries.dart` - `calendar.events.occurrences(start:, end:)` with chronological ordering

## Conventions

### Property Access Pattern
Typed components use `value<T>()` and `valueOrNull<T>()` for property access:
```dart
String get uid => value('UID');           // Required, throws if missing
String? get summary => valueOrNull('SUMMARY');  // Optional, returns null
List<String> get categories => valuesUnion('CATEGORIES');  // Multi-value with flattening
```

### Property Rules
Custom property parsers use `registerPropertyRule()` before parsing:
```dart
parser.registerPropertyRule(
  componentName: 'VEVENT',
  propertyName: 'X-CUSTOM',
  rule: PropertyRule(parser: parseString),
);
```

Built-in rules are defined in `CalendarParser.builtinPropertyRules`.

### Date/Time Types
- `CalDateTime` - Wrapper supporting DATE, DATE-TIME (local/UTC/TZ-aware)
- Use `CalDateTime.date()`, `CalDateTime.utc()`, `CalDateTime.local()` constructors
- Access `isDate` to distinguish all-day from timed events
- Call `tz.initializeTimeZones()` before parsing timezone-aware calendars

## Development

### Commands
```bash
dart pub get              # Install dependencies
dart test                 # Run all tests
dart test test/semantic/  # Run semantic layer tests only
dart format .             # Format code
dart analyze --fatal-infos  # Static analysis (CI fails on any info/warning)
```

### CI Requirements (`.github/workflows/dart.yml`)
All PRs to `main` must pass:
1. **Formatting** - `dart format --set-exit-if-changed .` (no manual formatting)
2. **Analysis** - `dart analyze --fatal-infos` (zero warnings/infos allowed)
3. **Tests with coverage** - Uses `coverage:test_with_coverage`, uploaded to Codecov

### Publishing
Releases to pub.dev are triggered by version tags (e.g., `1.0.8`). Update `pubspec.yaml` version before tagging.

### Branching Strategy
- Develop on feature branches
- Merge to `main` when complete (PRs must pass CI)
- Tag `main` with version number to publish to pub.dev

### Test Patterns
Tests are organized by layer matching `lib/src/`:
- `test/document/` - Document parsing tests
- `test/semantic/` - Semantic model and extension tests
- `test/resources/` - Sample .ics files for integration tests

Test helper pattern (inline ICS strings with CRLF):
```dart
final ics = 
    'BEGIN:VCALENDAR\r\n'
    'VERSION:2.0\r\n'
    ...
    'END:VCALENDAR';
final calendar = CalendarParser().parseFromString(ics);
```

### Dependencies
- `timezone` - TZ database for TZID support
- `collection` - List utilities (`firstWhereOrNull`, etc.)

## Important Implementation Details

- **Streaming**: Use `DocumentStreamParser` for large files to avoid memory issues
- **Recurrence**: `RecurrenceIterator` has `maxIterations` safeguard (default 10000) for infinite rules
- **Lazy evaluation**: `occurrences()` returns `Iterable` (lazy) - use `.take()` to limit infinite series
- **Chronological ordering**: Query extensions auto-sort results regardless of source order
