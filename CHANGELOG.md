# Changelog

All notable changes to this project will be documented in this file.

## [1.0.13] - 2026-07-07

### Added
- Added first-class support for `TRIGGER;RELATED` metadata through `Trigger.related` and `Trigger.relatedName`.

### Fixed
- Enforced stricter TRIGGER parameter validation for duplicate `VALUE` and invalid `RELATED` usage with `DATE-TIME`.

## [1.0.12] - 2026-07-05

### Improved
- Updated dependency constraints to support the latest `timezone` package release.

### Fixed
- Kept timezone-aware date-time parsing resilient when TZID aliases are unavailable in canonical timezone datasets.

## [1.0.11] - 2026-07-03

### Added
- Added first-class iCalendar serialization API for document and semantic components via `toIcsString()`.

### Improved
- Added broader date-time serialization test coverage (UTC, floating local, TZID, and VALUE=DATE).

## [1.0.10] - 2026-07-03

### Fixed
- Added support for `RDATE;VALUE=PERIOD` in recurrence iteration.
- Expanded `BYDAY` correctly when `BYWEEKNO` is present in yearly recurrence rules.

## [1.0.9] - 2026-07-03

### Fixed
- Include due-only VTODO items in occurrence queries by using DUE when DTSTART is missing.

## [1.0.8] - 2025-11-17

### Added
- `parseBoolean` property parser for consistent boolean value parsing

### Improved
- Simplified occurrence iterator implementation with better code reuse across component types

## [1.0.7] - 2025-11-10

### Fixes
- Invalid pubspec.yaml package description

## [1.0.6] - 2025-11-10

### Fixed
- All README code examples verified to compile and run correctly

### Improved
- Enhanced pubspec.yaml with topics and metadata for improved pub.dev visibility

## [1.0.5] - 2025-11-07

### Changed
- **BREAKING**: Renamed `inRange()` extension methods to `occurrences()` for consistency
  - All component iterable extensions (EventIterableQuery, TodoIterableQuery, JournalIterableQuery, TimeZoneIterableQuery) now use `occurrences()`
  - Parameters are now optional: `occurrences({CalDateTime? start, CalDateTime? end})`
  - Call without parameters to get all occurrences, or provide `start`/`end` to filter
- Updated `RecurrenceIterator.occurrences()` to accept optional `start`, `end`, and `duration` parameters
- Removed `RecurrenceIteratorQuery` extension - logic consolidated into `RecurrenceIterator` class

## [1.0.4] - 2025-11-07

### Added
- `isMultiDay` extension property on EventComponent and TodoComponent

### Fixed
- `inRange()` extensions now guarantee chronological ordering across all components
- Date-only end boundary handling in `inRange()`

## [1.0.3] - 2025-11-06

### Added
- `addDuration` extension method on CalDateTime
- `isAllDay` extension property on EventComponent
- `effectiveEnd` extension property on EventComponent
- `effectiveDuration` extension property on Event and Todo components
- `inRange()` extension method on Iterable<EventComponent>, Iterable<TodoComponent>, Iterable<JournalComponent>, and Iterable<TimeZoneSubComponent>

### Fixed
- Ordering of occurrences when combining RRULE and RDATE values
- TodoComponent.dtstart is now nullable (was incorrectly required)
- JournalComponent.dtstart is now nullable (was incorrectly required)
- Documentation comments for several component properties

### Improved
- Refactored RecurrenceIterator for better separation of concerns
- Reorganized extensions into dedicated directory structure
- Major test coverage increase

## [1.0.2] - 2025-11-05

### Fixed
- Fixed `resources` property type from `List<CalendarUserAddress>` to `List<String>` and use `valuesUnion()` for RFC 5545 compliance

### Improved
- Significantly increased test coverage

## [1.0.1] - 2025-10-26

### Fixed
- Updated README examples to use correct API methods (`parseComponents` instead of deprecated `streamComponents`)
- Added missing required `DTSTAMP` properties in README examples for RFC 5545 compliance

### Improved
- Enhanced documentation comments across public APIs for better clarity and consistency

## [1.0.0] - 2025-10-15

### Added
- RFC 5545 compliant iCalendar parser
- Support for VEVENT, VTODO, VJOURNAL, VTIMEZONE components
- Full RRULE recurrence expansion
- Streaming parser for large files
- Custom property parser registration
- Timezone-aware date/time handling
- Two-layer architecture (document + semantic)

[1.0.13]: https://github.com/firstfloorsoftware/firstfloor_calendar/releases/tag/v1.0.13
[1.0.12]: https://github.com/firstfloorsoftware/firstfloor_calendar/releases/tag/v1.0.12
[1.0.11]: https://github.com/firstfloorsoftware/firstfloor_calendar/releases/tag/v1.0.11
[1.0.10]: https://github.com/firstfloorsoftware/firstfloor_calendar/releases/tag/v1.0.10
[1.0.9]: https://github.com/firstfloorsoftware/firstfloor_calendar/releases/tag/v1.0.9
[1.0.8]: https://github.com/firstfloorsoftware/firstfloor_calendar/releases/tag/v1.0.8
[1.0.7]: https://github.com/firstfloorsoftware/firstfloor_calendar/releases/tag/v1.0.7
[1.0.6]: https://github.com/firstfloorsoftware/firstfloor_calendar/releases/tag/v1.0.6
[1.0.5]: https://github.com/firstfloorsoftware/firstfloor_calendar/releases/tag/v1.0.5
[1.0.4]: https://github.com/firstfloorsoftware/firstfloor_calendar/releases/tag/v1.0.4
[1.0.3]: https://github.com/firstfloorsoftware/firstfloor_calendar/releases/tag/v1.0.3
[1.0.2]: https://github.com/firstfloorsoftware/firstfloor_calendar/releases/tag/v1.0.2
[1.0.1]: https://github.com/firstfloorsoftware/firstfloor_calendar/releases/tag/v1.0.1
[1.0.0]: https://github.com/firstfloorsoftware/firstfloor_calendar/releases/tag/v1.0.0