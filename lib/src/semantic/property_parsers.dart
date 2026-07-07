import '../document/document.dart';
import '../document/parser.dart';
import 'builders.dart';
import 'semantic.dart';

/// Parses a [CalendarProperty] into a uri or binary attachment.
Attachment parseAttachment(CalendarProperty property) {
  final valueType = property.parameters['VALUE']?.first ?? ValueTypeNames.uri;
  final fmtType =
      property.parameters['FMTTYPE']?.firstOrNull ?? 'application/octet-stream';
  if (valueType == ValueTypeNames.uri) {
    return AttachmentUri(fmtType: fmtType, uri: Uri.parse(property.value));
  }
  if (valueType == ValueTypeNames.binary) {
    return AttachmentBinary(
      fmtType: fmtType,
      encoding: property.parameters['ENCODING']?.firstOrNull,
      value: property.value,
    );
  }
  throw ParseException(
    'Invalid value type "$valueType" for property "${property.name}"',
    lineNumber: property.lineNumber,
  );
}

/// Parses a [CalendarProperty] into a boolean value.
bool parseBoolean(CalendarProperty property) {
  final value = property.value.toUpperCase();
  if (value == 'TRUE') return true;
  if (value == 'FALSE') return false;
  throw ParseException(
    'Invalid boolean value "${property.value}" for property "${property.name}"',
    lineNumber: property.lineNumber,
  );
}

/// Parses a [CalendarProperty] into a calendar user address value.
CalendarUserAddress parseCalAddress(CalendarProperty property) {
  final cutypeName = property.parameters['CUTYPE']?.firstOrNull;
  final roleName = property.parameters['ROLE']?.firstOrNull;
  final partstatName = property.parameters['PARTSTAT']?.firstOrNull;

  return CalendarUserAddress(
    address: property.value,
    cn: property.parameters['CN']?.firstOrNull,
    dir: property.parameters['DIR']?.firstOrNull,
    sentby: property.parameters['SENT-BY']?.firstOrNull,
    language: property.parameters['LANGUAGE']?.firstOrNull,
    cutype: cutypeName != null
        ? CalendarUserTypeNames.tryParse(cutypeName)
        : null,
    cutypeName: cutypeName,
    members: property.parameters.containsKey('MEMBER')
        ? List.unmodifiable(property.parameters['MEMBER']!)
        : null,
    role: roleName != null ? ParticipationRoleNames.tryParse(roleName) : null,
    roleName: roleName,
    partstat: partstatName != null
        ? ParticipationStatusNames.tryParse(partstatName)
        : null,
    partstatName: partstatName,
    rsvp: property.parameters['RSVP']?.firstOrNull == 'TRUE',
    delegatedto: property.parameters.containsKey('DELEGATED-TO')
        ? List.unmodifiable(property.parameters['DELEGATED-TO']!)
        : null,
    delegatedfrom: property.parameters.containsKey('DELEGATED-FROM')
        ? List.unmodifiable(property.parameters['DELEGATED-FROM']!)
        : null,
  );
}

/// Parses a [CalendarProperty] into a CalDate value.
CalDateTime parseCalDate(CalendarProperty property) =>
    parseCalDateValue(property.value, lineNumber: property.lineNumber);

/// Parses a date string in the format YYYYMMDD into a CalDate value.
CalDateTime parseCalDateValue(String value, {int lineNumber = 0}) {
  final parser = _CalDateParser(value, lineNumber: lineNumber);
  return parser.parse();
}

/// Parses a [CalendarProperty] into a CalDateTime value.
CalDateTime parseCalDateTime(CalendarProperty property) =>
    parseCalDateTimeValue(
      property.value,
      tzid: _tryParseTzidParameter(property),
      lineNumber: property.lineNumber,
    );

/// Parses a date-time string in the format YYYYMMDDTHHMMSS[Z] into a CalDateTime value.
CalDateTime parseCalDateTimeValue(
  String value, {
  String? tzid,
  int lineNumber = 0,
}) {
  final parser = _CalDateTimeParser(value, tzid: tzid, lineNumber: lineNumber);
  return parser.parse();
}

/// Parses a [CalendarProperty] into a CalDateTime value.
/// This is used for properties that must be in local format without timezone identifier.
CalDateTime parseCalDateTimeLocal(CalendarProperty property) {
  if (property.parameters.containsKey('TZID')) {
    throw ParseException(
      'Expected local date-time without TZID for property "${property.name}"',
      lineNumber: property.lineNumber,
    );
  }
  return parseCalDateTimeLocalValue(
    property.value,
    lineNumber: property.lineNumber,
  );
}

/// Parses a date-time string in the format YYYYMMDDTHHMMSS into a CalDateTime value.
CalDateTime parseCalDateTimeLocalValue(String value, {int lineNumber = 0}) {
  final result = parseCalDateTimeValue(value, lineNumber: lineNumber);
  if (result.time!.isUtc) {
    throw ParseException(
      'Expected local date-time for value "$value"',
      lineNumber: lineNumber,
    );
  }
  return result;
}

/// Parses a [CalendarProperty] into a CalDateTime value.
/// This is used for properties that must be in UTC format.
CalDateTime parseCalDateTimeUtc(CalendarProperty property) =>
    parseCalDateTimeUtcValue(property.value, lineNumber: property.lineNumber);

/// Parses a date-time string in the format YYYYMMDDTHHMMSSZ into a CalDateTime value.
CalDateTime parseCalDateTimeUtcValue(String value, {int lineNumber = 0}) {
  final result = parseCalDateTimeValue(value, lineNumber: lineNumber);
  if (!result.time!.isUtc) {
    throw ParseException(
      'Expected UTC date-time for value "$value"',
      lineNumber: lineNumber,
    );
  }
  return result;
}

/// Parses a [CalendarProperty] into a date or datetime value.
/// This will determine if the value is a date or datetime based on the parameters.
CalDateTime parseCalDateOrDateTime(CalendarProperty property) {
  final valueType =
      property.parameters['VALUE']?.first ?? ValueTypeNames.dateTime;
  if (valueType == ValueTypeNames.date) return parseCalDate(property);
  if (valueType == ValueTypeNames.dateTime) return parseCalDateTime(property);
  throw ParseException(
    'Invalid value type "$valueType" for property "${property.name}"',
    lineNumber: property.lineNumber,
  );
}

/// Parses a [CalendarProperty] into a list of date or datetime values.
List<CalDateTime> parseCalDateOrDateTimeList(CalendarProperty property) {
  final valueType =
      property.parameters['VALUE']?.first ?? ValueTypeNames.dateTime;
  final tzid = _tryParseTzidParameter(property);
  final parts = property.value.split(',');

  if (valueType == ValueTypeNames.date) {
    return List.unmodifiable(
      parts.map((p) => parseCalDateValue(p, lineNumber: property.lineNumber)),
    );
  }
  if (valueType == ValueTypeNames.dateTime) {
    return List.unmodifiable(
      parts.map(
        (p) => parseCalDateTimeValue(
          p,
          tzid: tzid,
          lineNumber: property.lineNumber,
        ),
      ),
    );
  }

  throw ParseException(
    'Invalid value type "$valueType" for property "${property.name}"',
    lineNumber: property.lineNumber,
  );
}

/// Parses a [CalendarProperty] into a CalDuration value.
CalDuration parseCalDuration(CalendarProperty property) {
  final parser = _CalDurationParser(
    property.value,
    lineNumber: property.lineNumber,
  );
  return parser.parse();
}

/// Parses a [CalendarProperty] into a geo coordinate value.
GeoCoordinate parseGeoCoordinate(CalendarProperty property) {
  final parts = property.value.split(';');
  if (parts.length != 2) {
    throw ParseException(
      '"${property.value}" is not a valid GEO format',
      lineNumber: property.lineNumber,
    );
  }
  final latitude = double.tryParse(parts[0]);
  final longitude = double.tryParse(parts[1]);
  if (latitude == null || longitude == null) {
    throw ParseException(
      '"${property.value}" is not a valid GEO format',
      lineNumber: property.lineNumber,
    );
  }
  return GeoCoordinate(latitude: latitude, longitude: longitude);
}

/// Parses a [CalendarProperty] into an integer value.
int parseInteger(CalendarProperty property) {
  return int.tryParse(property.value) ??
      (throw ParseException(
        'Invalid integer value "${property.value}"',
        lineNumber: property.lineNumber,
      ));
}

/// Parses a [CalendarProperty] into a list of integer values.
Period parsePeriod(CalendarProperty property) =>
    parsePeriodValue(property.value, lineNumber: property.lineNumber);

/// Parses a list of PERIOD values from a [CalendarProperty].
List<Period> parsePeriodList(CalendarProperty property) {
  final parts = property.value.split(',');
  return List.unmodifiable(
    parts.map((p) => parsePeriodValue(p, lineNumber: property.lineNumber)),
  );
}

/// Parses a period string in the format "start/end" or "start/duration".
Period parsePeriodValue(String value, {int lineNumber = 0}) {
  final parts = value.split('/');
  if (parts.length != 2) {
    throw ParseException(
      '"$value" is not a valid PERIOD format',
      lineNumber: lineNumber,
    );
  }
  final start = _CalDateTimeParser(parts[0], lineNumber: lineNumber).parse();
  if (!start.time!.isUtc) {
    throw ParseException(
      'Start date-time in PERIOD must be UTC',
      lineNumber: lineNumber,
    );
  }

  // determine if the second part is a date-time or a duration
  if (parts[1].startsWith('P')) {
    // duration
    final duration = _CalDurationParser(
      parts[1],
      lineNumber: lineNumber,
    ).parse();
    return Period.start(start: start, duration: duration);
  }

  final end = _CalDateTimeParser(parts[1], lineNumber: lineNumber).parse();
  if (!end.time!.isUtc) {
    throw ParseException(
      'End date-time in PERIOD must be UTC',
      lineNumber: lineNumber,
    );
  }
  return Period.explicit(start: start, end: end);
}

/// Parses a [CalendarProperty] into a raw string representation.
/// This is used for properties that do not require any special parsing.
String parseRaw(CalendarProperty property) {
  // return the raw value as a string
  return property.value;
}

/// Parses a [CalendarProperty] into a recurrence date-time value.
RecurrenceDateTime parseRecurrenceDateTime(CalendarProperty property) {
  final valueType =
      property.parameters['VALUE']?.first ?? ValueTypeNames.dateTime;
  if (valueType == ValueTypeNames.date) {
    final date = parseCalDate(property);
    return RecurrenceDateTime.dateTime(date);
  }
  if (valueType == ValueTypeNames.dateTime) {
    final dateTime = parseCalDateTime(property);
    return RecurrenceDateTime.dateTime(dateTime);
  }
  if (valueType == ValueTypeNames.period) {
    final period = parsePeriod(property);
    return RecurrenceDateTime.period(period);
  }
  throw ParseException(
    'Invalid value type "$valueType" for property "${property.name}"',
    lineNumber: property.lineNumber,
  );
}

/// Parses a [CalendarProperty] into a recurrence rule instance.
RecurrenceRule parseRecurrenceRule(CalendarProperty property) =>
    parseRecurrenceRuleValue(property.value, lineNumber: property.lineNumber);

/// Parses a recurrence rule string in the format defined by RFC 5545 into a RecurrenceRule instance.
RecurrenceRule parseRecurrenceRuleValue(String value, {int lineNumber = 0}) {
  final parser = _RecurrenceRuleParser(value, lineNumber: lineNumber);
  return parser.parse();
}

/// Parses a [CalendarProperty] into a text representation.
/// This is the default parser for text properties.
String parseString(CalendarProperty property) =>
    _parseTextString(property.value);

/// Parses a [CalendarProperty] into a list of text values.
/// This is used for properties that can have multiple values separated by commas.
List<String> parseStringList(CalendarProperty property) {
  // Split by comma not escaped by backslash
  final parts = property.value.split(RegExp(r'(?<!\\),'));
  return List.unmodifiable(parts.map((p) => _parseTextString(p)));
}

/// Parses a [CalendarProperty] into a CalTime value.
CalTime parseCalTime(CalendarProperty property) => parseCalTimeValue(
  property.value,
  tzid: _tryParseTzidParameter(property),
  lineNumber: property.lineNumber,
);

/// Parses a time string in the format HHMMSS[Z] into a CalTime value.
CalTime parseCalTimeValue(String value, {String? tzid, int lineNumber = 0}) {
  final parser = _CalTimeParser(value, tzid: tzid, lineNumber: lineNumber);
  return parser.parse();
}

/// Parses a [CalendarProperty] into a trigger value.
Trigger parseTrigger(CalendarProperty property) {
  final relatedName = _tryParseSingleParameterValue(
    property,
    parameterName: 'RELATED',
  );
  final related = relatedName != null
      ? TriggerRelatedNames.tryParse(relatedName) ??
            (throw ParseException(
              'Invalid RELATED value "$relatedName" for property "${property.name}"',
              lineNumber: property.lineNumber,
            ))
      : null;

  final valueType =
      property.parameters['VALUE']?.first ?? ValueTypeNames.duration;
  if (valueType == ValueTypeNames.duration) {
    final duration = parseCalDuration(property);
    return Trigger.duration(
      duration,
      related: related,
      relatedName: relatedName,
    );
  } else if (valueType == ValueTypeNames.dateTime) {
    final dateTime = parseCalDateTimeUtc(property);
    return Trigger.dateTime(
      dateTime,
      related: related,
      relatedName: relatedName,
    );
  }
  throw ParseException(
    'Invalid value type "$valueType" for property "${property.name}"',
    lineNumber: property.lineNumber,
  );
}

/// Parses a [CalendarProperty] into a URI value.
Uri parseUri(CalendarProperty property) {
  final uri = Uri.tryParse(property.value);
  if (uri == null) {
    throw ParseException(
      'Invalid URI value "${property.value}"',
      lineNumber: property.lineNumber,
    );
  }
  return uri;
}

/// Parses a [CalendarProperty] into a UTC offset value.
UtcOffset parseUtcOffset(CalendarProperty property) {
  final parser = _UtcOffsetParser(
    property.value,
    lineNumber: property.lineNumber,
  );
  return parser.parse();
}

String? _tryParseTzidParameter(CalendarProperty property) {
  return _tryParseSingleParameterValue(property, parameterName: 'TZID');
}

String? _tryParseSingleParameterValue(
  CalendarProperty property, {
  required String parameterName,
}) {
  final values = property.parameters[parameterName];
  if (values != null && values.length > 1) {
    throw ParseException(
      'Multiple $parameterName parameters found for property "${property.name}"',
      lineNumber: property.lineNumber,
    );
  }
  return values?.firstOrNull;
}

String _parseTextString(String value) {
  // Early return if no backslashes
  if (!value.contains('\\')) {
    return value;
  }

  final buffer = StringBuffer();
  final length = value.length;

  for (int i = 0; i < length; i++) {
    if (value[i] == '\\' && i + 1 < length) {
      final next = value[i + 1];
      switch (next) {
        case '\\':
          buffer.write('\\');
          i++; // Skip next character
          break;
        case 'N':
        case 'n':
          buffer.write('\n');
          i++; // Skip next character
          break;
        case ';':
          buffer.write(';');
          i++; // Skip next character
          break;
        case ',':
          buffer.write(',');
          i++; // Skip next character
          break;
        default:
          // Not an escape sequence, write the backslash as-is
          buffer.write('\\');
      }
    } else {
      buffer.write(value[i]);
    }
  }

  return buffer.toString();
}

class _CalDurationParser extends Parser {
  _CalDurationParser(super.value, {super.lineNumber});

  /// Parses the duration from the line.
  CalDuration parse() {
    reset();

    final values = <int, int>{};
    final first = lookahead();
    var sign = $plus;
    if (first == $plus || first == $minus) {
      sign = consume();
    }
    matchOne($P);
    final next = lookahead();

    if (next == $T) {
      _parseTime(values);
    } else {
      _parseWeekAndDay(values);
      if (lookahead() == $T) {
        _parseTime(values);
      }
    }
    // make sure we reached the end of the line
    matchOne(Parser.endOfLine);

    // make sure we have at least one value
    if (values.isEmpty) {
      throw ParseException(
        'No DURATION components found in "$source"',
        lineNumber: lineNumber,
        column: column,
      );
    }

    return CalDuration(
      sign: sign == $minus ? Sign.negative : Sign.positive,
      weeks: values[$W] ?? 0,
      days: values[$D] ?? 0,
      hours: values[$H] ?? 0,
      minutes: values[$M] ?? 0,
      seconds: values[$S] ?? 0,
    );
  }

  void _parseWeekAndDay(Map<int, int> values) {
    for (final value in matchValues([$W, $D])) {
      values[value.$1] = value.$2;
    }
  }

  void _parseTime(Map<int, int> values) {
    matchOne($T);
    for (final value in matchValues([$H, $M, $S])) {
      values[value.$1] = value.$2;
    }
  }

  Iterable<(int designator, int value)> matchValues(
    List<int> designators,
  ) sync* {
    while (designators.isNotEmpty && !isEndOfLine() && lookahead() != $T) {
      final integer = matchInteger();
      final designator = matchOneOf(designators);

      yield (designator, integer);

      // Remove designator and its predecessors from the list
      // So if we have W, D, H, M, S and we match H, we want to remove W, D and H from the list
      final index = designators.indexOf(designator);
      designators.removeRange(0, index + 1);
    }
  }
}

class _UtcOffsetParser extends Parser {
  _UtcOffsetParser(super.value, {super.lineNumber});

  /// Parses the UTC offset from the line.
  UtcOffset parse() {
    reset();

    final signChar = matchOneOf([$plus, $minus]);
    final sign = signChar == $minus ? Sign.negative : Sign.positive;
    final hours = matchInteger(minOccurs: 2, maxOccurs: 2, maxValue: 23);
    final minutes = matchInteger(minOccurs: 2, maxOccurs: 2, maxValue: 59);
    final seconds = !isEndOfLine()
        ? matchInteger(minOccurs: 2, maxOccurs: 2, maxValue: 59)
        : 0;

    // make sure we reached the end of the line
    matchOne(Parser.endOfLine);

    // -0000 and -000000 are not allowed
    if (sign == Sign.negative && hours == 0 && minutes == 0 && seconds == 0) {
      throw ParseException(
        'Negative zero UTC offset is not allowed',
        lineNumber: lineNumber,
        column: column,
      );
    }

    return UtcOffset(
      sign: sign,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    );
  }
}

/// Parser for iCalendar DATE values in the format YYYYMMDD
class _CalDateParser extends Parser {
  _CalDateParser(super.value, {super.lineNumber});

  CalDateTime parse() {
    reset();
    final year = matchInteger(minOccurs: 4, maxOccurs: 4);
    final month = matchInteger(
      minOccurs: 2,
      maxOccurs: 2,
      minValue: 1,
      maxValue: 12,
    );
    final day = matchInteger(
      minOccurs: 2,
      maxOccurs: 2,
      minValue: 1,
      maxValue: 31,
    );

    // make sure we reached the end of the line
    matchOne(Parser.endOfLine);

    return CalDateTime.date(year, month, day);
  }
}

/// Parser for iCalendar DATE-TIME values in the format YYYYMMDDTHHMMSS[Z]
class _CalDateTimeParser extends Parser {
  final String? tzid;
  _CalDateTimeParser(super.value, {this.tzid, super.lineNumber});

  CalDateTime parse() {
    reset();
    final year = matchInteger(minOccurs: 4, maxOccurs: 4);
    final month = matchInteger(
      minOccurs: 2,
      maxOccurs: 2,
      minValue: 1,
      maxValue: 12,
    );
    final day = matchInteger(
      minOccurs: 2,
      maxOccurs: 2,
      minValue: 1,
      maxValue: 31,
    );
    matchOne($T);
    final hour = matchInteger(minOccurs: 2, maxOccurs: 2, maxValue: 23);
    final minute = matchInteger(minOccurs: 2, maxOccurs: 2, maxValue: 59);
    final second = matchInteger(minOccurs: 2, maxOccurs: 2, maxValue: 60);

    CalDateTime result;
    if (lookahead() == $Z) {
      // if 'Z' is present, the time must not have a TZID parameter
      if (tzid != null) {
        throw ParseException(
          'Cannot specify TZID for UTC date-time value "$source"',
          lineNumber: lineNumber,
        );
      }

      consume(); // consume the 'Z'
      result = CalDateTime.utc(year, month, day, hour, minute, second);
    } else {
      result = CalDateTime.local(year, month, day, hour, minute, second, tzid);
    }
    // make sure we reached the end of the line
    matchOne(Parser.endOfLine);

    return result;
  }
}

/// Parser for iCalendar TIME values in the format HHMMSS[Z]
class _CalTimeParser extends Parser {
  final String? tzid;
  _CalTimeParser(super.value, {this.tzid, super.lineNumber});

  CalTime parse() {
    reset();
    final hour = matchInteger(minOccurs: 2, maxOccurs: 2, maxValue: 23);
    final minute = matchInteger(minOccurs: 2, maxOccurs: 2, maxValue: 59);

    // seconds are optional and 60 is allowed for leap seconds
    final second = matchInteger(minOccurs: 2, maxOccurs: 2, maxValue: 60);

    CalTime result;
    if (lookahead() == $Z) {
      // if 'Z' is present, the time must not have a TZID parameter
      if (tzid != null) {
        throw ParseException(
          'Cannot specify TZID for UTC date-time value "$source"',
          lineNumber: lineNumber,
        );
      }

      consume(); // consume the 'Z'
      result = CalTime.utc(hour, minute, second);
    } else {
      result = CalTime.local(hour, minute, second, tzid: tzid);
    }
    // make sure we reached the end of the line
    matchOne(Parser.endOfLine);

    return result;
  }
}

class _RecurrenceRuleParser extends Parser {
  RecurrenceRuleBuilder builder = RecurrenceRuleBuilder();

  _RecurrenceRuleParser(super.value, {super.lineNumber});

  @override
  void reset() {
    super.reset();
    builder.clear();
  }

  RecurrenceRule parse() {
    reset();

    final Set<String> keysSeen = {};

    // parse key=value pairs separated by semicolons
    while (!isEndOfLine()) {
      final key = match((c) => c >= $A && c <= $Z, minOccurs: 1).toUpperCase();

      if (keysSeen.contains(key)) {
        throw ParseException(
          'Duplicate key "$key" in RRULE',
          lineNumber: lineNumber,
        );
      }
      keysSeen.add(key);

      matchOne($equals);

      if (key == 'FREQ') {
        final value = matchValue();
        final freq =
            RecurrenceFrequencyNames.tryParse(value) ??
            (throw ParseException(
              'Invalid FREQ value "$value" in RRULE',
              lineNumber: lineNumber,
            ));
        builder.setFreq(freq);
      } else if (key == 'UNTIL') {
        final value = matchValue();

        // determine if it's a date or date-time
        if (value.length == 8) {
          final until = _CalDateParser(value, lineNumber: lineNumber).parse();
          builder.setUntil(until);
        } else {
          final until = _CalDateTimeParser(
            value,
            lineNumber: lineNumber,
          ).parse();
          builder.setUntil(until);
        }
      } else if (key == 'COUNT') {
        final count = matchInteger(minValue: 1);
        builder.setCount(count);
      } else if (key == 'INTERVAL') {
        final interval = matchInteger(minValue: 1);
        builder.setInterval(interval);
      } else if (key == 'BYSECOND') {
        final bySecond = matchIntegerSet(0, 60, 'BYSECOND');
        builder.setBySecond(bySecond);
      } else if (key == 'BYMINUTE') {
        final byMinute = matchIntegerSet(0, 59, 'BYMINUTE');
        builder.setByMinute(byMinute);
      } else if (key == 'BYHOUR') {
        final byHour = matchIntegerSet(0, 23, 'BYHOUR');
        builder.setByHour(byHour);
      } else if (key == 'BYDAY') {
        final days = matchDaySet();
        builder.setByDay(days);
      } else if (key == 'BYMONTHDAY') {
        final byMonthDay = matchIntegerSet(
          -31,
          31,
          'BYMONTHDAY',
          excludeZero: true,
        );
        builder.setByMonthDay(byMonthDay);
      } else if (key == 'BYYEARDAY') {
        final byYearDay = matchIntegerSet(
          -366,
          366,
          'BYYEARDAY',
          excludeZero: true,
        );
        builder.setByYearDay(byYearDay);
      } else if (key == 'BYWEEKNO') {
        final byWeekNo = matchIntegerSet(
          -53,
          53,
          'BYWEEKNO',
          excludeZero: true,
        );
        builder.setByWeekNo(byWeekNo);
      } else if (key == 'BYMONTH') {
        final byMonth = matchIntegerSet(1, 12, 'BYMONTH');
        builder.setByMonth(byMonth);
      } else if (key == 'BYSETPOS') {
        final bySetPos = matchIntegerSet(
          -366,
          366,
          'BYSETPOS',
          excludeZero: true,
        );
        builder.setBySetPos(bySetPos);
      } else if (key == 'WKST') {
        final value = matchValue();
        final wkst =
            WeekdayNames.tryParse(value) ??
            (throw ParseException(
              'Invalid WKST value "$value" in RRULE',
              lineNumber: lineNumber,
            ));
        builder.setWkst(wkst);
      } else {
        throw ParseException(
          'Unknown key "$key" in RRULE',
          lineNumber: lineNumber,
        );
      }

      if (lookahead() == $semicolon) {
        consume(); // consume the semicolon
      } else {
        break; // no more key-value pairs
      }
    }

    // make sure we reached the end of the line
    matchOne(Parser.endOfLine);

    // FREQ is required
    if (!keysSeen.contains('FREQ')) {
      throw ParseException(
        'Missing required FREQ in RRULE',
        lineNumber: lineNumber,
      );
    }
    return builder.build();
  }

  String matchValue() {
    return match(
      (c) => c != $semicolon && c != Parser.endOfLine,
      minOccurs: 1,
    ).toUpperCase();
  }

  Set<int> matchIntegerSet(
    int minValue,
    int maxValue,
    String name, {
    bool excludeZero = false,
  }) {
    final result = <int>{};
    while (true) {
      final integer = matchInteger(minValue: minValue, maxValue: maxValue);
      if (excludeZero && integer == 0) {
        throw ParseException(
          'Invalid integer "0" in $name',
          lineNumber: lineNumber,
          column: column,
        );
      }
      if (!result.add(integer)) {
        throw ParseException(
          'Duplicate integer "$integer" in $name',
          lineNumber: lineNumber,
          column: column,
        );
      }

      final la = lookahead();
      if (la == Parser.endOfLine || la == $semicolon) {
        break; // no more integers
      }
      if (la != $comma) {
        throw ParseException(
          'Expected comma or end of line after integer in $name',
          lineNumber: lineNumber,
          column: column,
        );
      }
      consume(); // consume the comma
    }

    return result;
  }

  Set<ByDay> matchDaySet() {
    final result = <ByDay>{};
    while (true) {
      int? ordinal;
      int sign = $plus;
      if (lookahead() == $plus || lookahead() == $minus) {
        sign = consume();
      }
      final next = lookahead();
      if (next >= $0 && next <= $9) {
        ordinal = matchInteger(minOccurs: 1, maxOccurs: 2);
        if (sign == $minus) {
          ordinal = -ordinal;
        }
      }
      final dayStr = match(
        (c) => c >= $A && c <= $Z,
        minOccurs: 2,
        maxOccurs: 2,
      ).toUpperCase();
      final weekday =
          WeekdayNames.tryParse(dayStr) ??
          (throw ParseException(
            'Invalid weekday "$dayStr" in BYDAY',
            lineNumber: lineNumber,
          ));
      if (!result.add(ByDay(weekday, ordinal: ordinal))) {
        throw ParseException(
          'Duplicate weekday "$dayStr" in BYDAY',
          lineNumber: lineNumber,
          column: column,
        );
      }

      final la = lookahead();
      if (la == Parser.endOfLine || la == $semicolon) {
        break; // no more days
      }
      if (la != $comma) {
        throw ParseException(
          'Expected comma or end of line after weekday in BYDAY',
          lineNumber: lineNumber,
          column: column,
        );
      }
      consume(); // consume the comma
    }

    return result;
  }
}
