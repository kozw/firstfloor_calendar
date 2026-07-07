import 'package:firstfloor_calendar/firstfloor_calendar.dart';
import 'package:test/test.dart';

void main() {
  void testDuration(String input, CalDuration expected) =>
      test('Parse DURATION: $input', () {
        final property = DocumentParser.parseProperty('DURATION:$input');
        final duration = parseCalDuration(property);
        expect(duration, isA<CalDuration>());
        expect(duration, expected);
      });

  void testDurationError(String input, String errorMessage) =>
      test('Parse DURATION: $input should throw $errorMessage', () {
        final property = DocumentParser.parseProperty('DURATION:$input');

        expect(
          () => parseCalDuration(property),
          throwsA(
            predicate((e) => e.toString() == 'ParseException: $errorMessage'),
          ),
        );
      });

  void testUtcOffset(String input, UtcOffset expected) =>
      test('Parse UTC-OFFSET: $input', () {
        final property = DocumentParser.parseProperty('TZOFFSETTO:$input');
        final offset = parseUtcOffset(property);
        expect(offset, isA<UtcOffset>());
        expect(offset, expected);
      });

  void testUtcOffsetError(String input, String errorMessage) =>
      test('Parse UTC-OFFSET: $input should throw $errorMessage', () {
        final property = DocumentParser.parseProperty('TZOFFSETTO:$input');

        expect(
          () => parseUtcOffset(property),
          throwsA(
            predicate((e) => e.toString() == 'ParseException: $errorMessage'),
          ),
        );
      });

  group('Parse DURATION', () {
    testDuration('PT1H30M', CalDuration(hours: 1, minutes: 30));
    testDuration('-P0DT0H30M0S', CalDuration(sign: Sign.negative, minutes: 30));
    testDuration('P1D', CalDuration(days: 1));
    testDuration('P1W', CalDuration(weeks: 1));
    testDuration('P1W2D', CalDuration(weeks: 1, days: 2));
    testDuration('P1DT', CalDuration(days: 1)); // we allow empty time part
    testDuration('PT2H', CalDuration(hours: 2));
    testDuration('PT1H2M', CalDuration(hours: 1, minutes: 2));
    testDuration('PT1H2M3S', CalDuration(hours: 1, minutes: 2, seconds: 3));
    testDuration(
      'P1W4DT3H4M2S',
      CalDuration(weeks: 1, days: 4, hours: 3, minutes: 4, seconds: 2),
    );

    testDurationError(
      'PT1H2H30M',
      'Expected one of ["M", "S"], found "H" [Ln 0, Col 5]',
    );
    testDurationError('', 'Expected "P", found "<endOfLine>" [Ln 0, Col 0]');
    testDurationError('P', 'No DURATION components found in "P" [Ln 0, Col 2]');
    testDurationError('T', 'Expected "P", found "T" [Ln 0, Col 0]');
    testDurationError('FOO', 'Expected "P", found "F" [Ln 0, Col 0]');
    testDurationError(
      'PT',
      'No DURATION components found in "PT" [Ln 0, Col 3]',
    );
    testDurationError(
      '-PT',
      'No DURATION components found in "-PT" [Ln 0, Col 4]',
    );
    testDurationError(
      'P1D2D',
      'Expected "<endOfLine>", found "2" [Ln 0, Col 3]',
    );
    testDurationError(
      'P1W2W',
      'Expected one of ["D"], found "W" [Ln 0, Col 4]',
    );
    testDurationError(
      'P1W2H',
      'Expected one of ["D"], found "H" [Ln 0, Col 4]',
    );
    testDurationError(
      'P1D2W',
      'Expected "<endOfLine>", found "2" [Ln 0, Col 3]',
    );
    testDurationError(
      'P1D2M',
      'Expected "<endOfLine>", found "2" [Ln 0, Col 3]',
    );
    testDurationError(
      'P1D2Y',
      'Expected "<endOfLine>", found "2" [Ln 0, Col 3]',
    );
    testDurationError(
      'P1Y2M3D4H5M6S',
      'Expected one of ["W", "D"], found "Y" [Ln 0, Col 2]',
    );
  });

  group('Parse UTC-OFFSET', () {
    testUtcOffset(
      '+0000',
      UtcOffset(sign: Sign.positive, hours: 0, minutes: 0),
    );
    testUtcOffset(
      '+000000',
      UtcOffset(sign: Sign.positive, hours: 0, minutes: 0),
    );
    testUtcOffset(
      '+0100',
      UtcOffset(sign: Sign.positive, hours: 1, minutes: 0),
    );
    testUtcOffset(
      '+0201',
      UtcOffset(sign: Sign.positive, hours: 2, minutes: 1),
    );
    testUtcOffset(
      '+030100',
      UtcOffset(sign: Sign.positive, hours: 3, minutes: 1),
    );
    testUtcOffset(
      '+040101',
      UtcOffset(sign: Sign.positive, hours: 4, minutes: 1, seconds: 1),
    );
    testUtcOffset(
      '-0100',
      UtcOffset(sign: Sign.negative, hours: 1, minutes: 0),
    );
    testUtcOffset(
      '-0201',
      UtcOffset(sign: Sign.negative, hours: 2, minutes: 1),
    );
    testUtcOffset(
      '-030100',
      UtcOffset(sign: Sign.negative, hours: 3, minutes: 1),
    );
    testUtcOffset(
      '-040101',
      UtcOffset(sign: Sign.negative, hours: 4, minutes: 1, seconds: 1),
    );

    testUtcOffsetError(
      '',
      'Expected one of ["+", "-"], found "<endOfLine>" [Ln 0, Col 0]',
    );
    testUtcOffsetError(
      '10',
      'Expected one of ["+", "-"], found "1" [Ln 0, Col 0]',
    );
    testUtcOffsetError('+10', 'Expected 2 characters, found 0 [Ln 0, Col 3]');
    testUtcOffsetError('+100', 'Expected 2 characters, found 1 [Ln 0, Col 3]');
    testUtcOffsetError(
      '+10000',
      'Expected 2 characters, found 1 [Ln 0, Col 5]',
    );
    testUtcOffsetError(
      '+1000000',
      'Expected "<endOfLine>", found "0" [Ln 0, Col 7]',
    );
    testUtcOffsetError(
      '-0000',
      'Negative zero UTC offset is not allowed [Ln 0, Col 6]',
    );
    testUtcOffsetError(
      '-000000',
      'Negative zero UTC offset is not allowed [Ln 0, Col 8]',
    );
    testUtcOffsetError(
      '+2400',
      'Integer value 24 is out of bounds [0, 23] [Ln 0, Col 3]',
    );
    testUtcOffsetError(
      '+0060',
      'Integer value 60 is out of bounds [0, 59] [Ln 0, Col 5]',
    );
    testUtcOffsetError(
      '+000060',
      'Integer value 60 is out of bounds [0, 59] [Ln 0, Col 7]',
    );
    testUtcOffsetError('+00A', 'Expected 2 characters, found 0 [Ln 0, Col 3]');
  });

  group('Parse TEXT', () {
    test('Parse TEXT', () {
      final property = DocumentParser.parseProperty('TEXT:Sample text');
      final text = parseString(property);
      expect(text, isA<String>());
      expect(text, 'Sample text');
    });

    test('Parse TEXT with special characters', () {
      final property = DocumentParser.parseProperty('TEXT:Sample \\; text');
      final text = parseString(property);
      expect(text, isA<String>());
      expect(text, 'Sample ; text');
    });

    test('Parse TEXT with escaped characters', () {
      final property = DocumentParser.parseProperty('TEXT:Sample \\n text');
      final text = parseString(property);
      expect(text, isA<String>());
      expect(text, 'Sample \n text');
    });
  });

  group('Parse ATTACH', () {
    test('Parse ATTACH with URI', () {
      final property = DocumentParser.parseProperty(
        'ATTACH:https://example.com/file.pdf',
      );
      final attachment = parseAttachment(property);
      expect(attachment, isA<AttachmentUri>());
      expect(
        (attachment as AttachmentUri).uri.toString(),
        'https://example.com/file.pdf',
      );
    });

    test('Parse ATTACH with binary', () {
      final property = DocumentParser.parseProperty(
        'ATTACH;VALUE=BINARY;ENCODING=BASE64:SGVsbG8gV29ybGQ=',
      );
      final attachment = parseAttachment(property);
      expect(attachment, isA<AttachmentBinary>());
      expect((attachment as AttachmentBinary).value, 'SGVsbG8gV29ybGQ=');
    });

    test('Parse ATTACH with invalid VALUE type throws', () {
      final property = DocumentParser.parseProperty(
        'ATTACH;VALUE=TEXT:invalid',
      );
      expect(
        () => parseAttachment(property),
        throwsA(
          isA<ParseException>().having(
            (e) => e.message,
            'message',
            'Invalid value type "TEXT" for property "ATTACH"',
          ),
        ),
      );
    });
  });

  group('Parse date-time with TZID validation', () {
    test('parseCalDateTimeLocal throws when TZID parameter present', () {
      final property = DocumentParser.parseProperty(
        'DTSTART;TZID=America/New_York:20250101T100000',
      );
      expect(
        () => parseCalDateTimeLocal(property),
        throwsA(
          isA<ParseException>().having(
            (e) => e.message,
            'message',
            'Expected local date-time without TZID for property "DTSTART"',
          ),
        ),
      );
    });

    test('parseCalDateTimeLocalValue throws when UTC format used', () {
      expect(
        () => parseCalDateTimeLocalValue('20250101T100000Z'),
        throwsA(
          isA<ParseException>().having(
            (e) => e.message,
            'message',
            'Expected local date-time for value "20250101T100000Z"',
          ),
        ),
      );
    });

    test('parseCalDateTimeUtcValue throws when local format used', () {
      expect(
        () => parseCalDateTimeUtcValue('20250101T100000'),
        throwsA(
          isA<ParseException>().having(
            (e) => e.message,
            'message',
            'Expected UTC date-time for value "20250101T100000"',
          ),
        ),
      );
    });
  });

  group('Parse date-or-datetime validation', () {
    test('parseCalDateOrDateTime with invalid VALUE type throws', () {
      final property = DocumentParser.parseProperty(
        'DTSTART;VALUE=TEXT:invalid',
      );
      expect(
        () => parseCalDateOrDateTime(property),
        throwsA(
          isA<ParseException>().having(
            (e) => e.message,
            'message',
            'Invalid value type "TEXT" for property "DTSTART"',
          ),
        ),
      );
    });

    test('parseCalDateOrDateTimeList with invalid VALUE type throws', () {
      final property = DocumentParser.parseProperty(
        'EXDATE;VALUE=TEXT:invalid',
      );
      expect(
        () => parseCalDateOrDateTimeList(property),
        throwsA(
          isA<ParseException>().having(
            (e) => e.message,
            'message',
            'Invalid value type "TEXT" for property "EXDATE"',
          ),
        ),
      );
    });
  });

  group('Parse GEO', () {
    test('Parse GEO with valid coordinates', () {
      final property = DocumentParser.parseProperty(
        'GEO:37.386013;-122.082932',
      );
      final geo = parseGeoCoordinate(property);
      expect(geo.latitude, 37.386013);
      expect(geo.longitude, -122.082932);
    });

    test('Parse GEO with invalid format throws', () {
      final property = DocumentParser.parseProperty('GEO:invalid');
      expect(
        () => parseGeoCoordinate(property),
        throwsA(
          isA<ParseException>().having(
            (e) => e.message,
            'message',
            '"invalid" is not a valid GEO format',
          ),
        ),
      );
    });

    test('Parse GEO with non-numeric values throws', () {
      final property = DocumentParser.parseProperty('GEO:abc;def');
      expect(
        () => parseGeoCoordinate(property),
        throwsA(
          isA<ParseException>().having(
            (e) => e.message,
            'message',
            '"abc;def" is not a valid GEO format',
          ),
        ),
      );
    });
  });

  group('Parse CALADDRESS', () {
    test('Parse CALADDRESS with all parameters', () {
      final property = DocumentParser.parseProperty(
        'ATTENDEE;CN=John Doe;CUTYPE=INDIVIDUAL;ROLE=REQ-PARTICIPANT;'
        'PARTSTAT=ACCEPTED;RSVP=TRUE;MEMBER="mailto:group@example.com";'
        'DELEGATED-TO="mailto:jane@example.com";'
        'DELEGATED-FROM="mailto:boss@example.com":mailto:john@example.com',
      );
      final calAddress = parseCalAddress(property);
      expect(calAddress.address, 'mailto:john@example.com');
      expect(calAddress.cn, 'John Doe');
      expect(calAddress.rsvp, isTrue);
    });

    test('Parse CALADDRESS with minimal parameters', () {
      final property = DocumentParser.parseProperty(
        'ATTENDEE:mailto:simple@example.com',
      );
      final calAddress = parseCalAddress(property);
      expect(calAddress.address, 'mailto:simple@example.com');
      expect(calAddress.cn, isNull);
      expect(calAddress.rsvp, isFalse);
    });
  });

  group('Parse INTEGER', () {
    test('Parse INTEGER with valid value', () {
      final property = DocumentParser.parseProperty('PRIORITY:5');
      final value = parseInteger(property);
      expect(value, 5);
    });

    test('Parse INTEGER with invalid value throws', () {
      final property = DocumentParser.parseProperty('PRIORITY:invalid');
      expect(
        () => parseInteger(property),
        throwsA(
          isA<ParseException>().having(
            (e) => e.message,
            'message',
            'Invalid integer value "invalid"',
          ),
        ),
      );
    });
  });

  group('Parse PERIOD', () {
    test('Parse PERIOD with start and end', () {
      final property = DocumentParser.parseProperty(
        'FREEBUSY:19980101T120000Z/19980101T130000Z',
      );
      final period = parsePeriod(property);
      expect(period.start, CalDateTime.utc(1998, 1, 1, 12, 0, 0));
      expect(period.end, CalDateTime.utc(1998, 1, 1, 13, 0, 0));
    });

    test('Parse PERIOD with start and duration', () {
      final property = DocumentParser.parseProperty(
        'FREEBUSY:19980101T120000Z/PT1H',
      );
      final period = parsePeriod(property);
      expect(period.start, CalDateTime.utc(1998, 1, 1, 12, 0, 0));
      expect(period.duration, CalDuration(hours: 1));
    });

    test('Parse PERIOD with invalid format throws', () {
      expect(
        () => parsePeriodValue('invalid'),
        throwsA(
          isA<ParseException>().having(
            (e) => e.message,
            'message',
            '"invalid" is not a valid PERIOD format',
          ),
        ),
      );
    });

    test('Parse PERIOD with non-UTC start throws', () {
      expect(
        () => parsePeriodValue('19980101T120000/19980101T130000Z'),
        throwsA(
          isA<ParseException>().having(
            (e) => e.message,
            'message',
            'Start date-time in PERIOD must be UTC',
          ),
        ),
      );
    });

    test('Parse PERIOD with non-UTC end throws', () {
      expect(
        () => parsePeriodValue('19980101T120000Z/19980101T130000'),
        throwsA(
          isA<ParseException>().having(
            (e) => e.message,
            'message',
            'End date-time in PERIOD must be UTC',
          ),
        ),
      );
    });
  });

  group('Parse RECURRENCE-ID', () {
    test('Parse RECURRENCE-ID with DATE value', () {
      final property = DocumentParser.parseProperty(
        'RECURRENCE-ID;VALUE=DATE:20250101',
      );
      final recur = parseRecurrenceDateTime(property);
      expect(recur.dateTime, CalDateTime.date(2025, 1, 1));
    });

    test('Parse RECURRENCE-ID with DATE-TIME value', () {
      final property = DocumentParser.parseProperty(
        'RECURRENCE-ID:20250101T100000Z',
      );
      final recur = parseRecurrenceDateTime(property);
      expect(recur.dateTime, CalDateTime.utc(2025, 1, 1, 10, 0, 0));
    });

    test('Parse RECURRENCE-ID with PERIOD value', () {
      final property = DocumentParser.parseProperty(
        'RECURRENCE-ID;VALUE=PERIOD:19980101T120000Z/19980101T130000Z',
      );
      final recur = parseRecurrenceDateTime(property);
      expect(recur.period, isNotNull);
      expect(recur.period!.start, CalDateTime.utc(1998, 1, 1, 12, 0, 0));
    });

    test('Parse RECURRENCE-ID with invalid VALUE type throws', () {
      final property = DocumentParser.parseProperty(
        'RECURRENCE-ID;VALUE=TEXT:invalid',
      );
      expect(
        () => parseRecurrenceDateTime(property),
        throwsA(
          isA<ParseException>().having(
            (e) => e.message,
            'message',
            'Invalid value type "TEXT" for property "RECURRENCE-ID"',
          ),
        ),
      );
    });
  });

  group('Parse TRIGGER', () {
    test('Parse TRIGGER with duration', () {
      final property = DocumentParser.parseProperty('TRIGGER:-PT15M');
      final trigger = parseTrigger(property);
      expect(trigger.duration, CalDuration(sign: Sign.negative, minutes: 15));
    });

    test('Parse TRIGGER with date-time', () {
      final property = DocumentParser.parseProperty(
        'TRIGGER;VALUE=DATE-TIME:19980101T120000Z',
      );
      final trigger = parseTrigger(property);
      expect(trigger.dateTime, CalDateTime.utc(1998, 1, 1, 12, 0, 0));
    });

    test('Parse TRIGGER with RELATED=END', () {
      final property = DocumentParser.parseProperty(
        'TRIGGER;RELATED=END:-PT15M',
      );
      final trigger = parseTrigger(property);
      expect(trigger.duration, CalDuration(sign: Sign.negative, minutes: 15));
      expect(trigger.related, TriggerRelated.end);
      expect(trigger.relatedName, 'END');
    });

    test('Parse TRIGGER with invalid RELATED value throws', () {
      final property = DocumentParser.parseProperty(
        'TRIGGER;RELATED=INVALID:-PT15M',
      );
      expect(
        () => parseTrigger(property),
        throwsA(
          isA<ParseException>().having(
            (e) => e.message,
            'message',
            'Invalid RELATED value "INVALID" for property "TRIGGER"',
          ),
        ),
      );
    });

    test('Parse TRIGGER with RELATED and DATE-TIME throws', () {
      final property = DocumentParser.parseProperty(
        'TRIGGER;RELATED=END;VALUE=DATE-TIME:19980101T120000Z',
      );
      expect(
        () => parseTrigger(property),
        throwsA(
          isA<ParseException>().having(
            (e) => e.message,
            'message',
            'RELATED parameter is only valid for DURATION trigger values',
          ),
        ),
      );
    });

    test('Parse TRIGGER with multiple VALUE parameters throws', () {
      final property = CalendarProperty(
        name: 'TRIGGER',
        value: '-PT15M',
        parameters: {
          'VALUE': ['DURATION', 'DATE-TIME'],
        },
        lineNumber: 1,
      );
      expect(
        () => parseTrigger(property),
        throwsA(
          isA<ParseException>().having(
            (e) => e.message,
            'message',
            'Multiple VALUE parameters found for property "TRIGGER"',
          ),
        ),
      );
    });

    test('Parse TRIGGER with multiple RELATED parameters throws', () {
      final property = CalendarProperty(
        name: 'TRIGGER',
        value: '-PT15M',
        parameters: {
          'RELATED': ['START', 'END'],
        },
        lineNumber: 1,
      );
      expect(
        () => parseTrigger(property),
        throwsA(
          isA<ParseException>().having(
            (e) => e.message,
            'message',
            'Multiple RELATED parameters found for property "TRIGGER"',
          ),
        ),
      );
    });

    test('Parse TRIGGER with invalid VALUE type throws', () {
      final property = DocumentParser.parseProperty(
        'TRIGGER;VALUE=TEXT:invalid',
      );
      expect(
        () => parseTrigger(property),
        throwsA(
          isA<ParseException>().having(
            (e) => e.message,
            'message',
            'Invalid value type "TEXT" for property "TRIGGER"',
          ),
        ),
      );
    });
  });

  group('Parse URI', () {
    test('Parse URI with valid value', () {
      final property = DocumentParser.parseProperty('URL:https://example.com');
      final uri = parseUri(property);
      expect(uri.toString(), 'https://example.com');
    });

    test('Parse URI with invalid value throws', () {
      final property = DocumentParser.parseProperty('URL:ht!tp://invalid');
      expect(
        () => parseUri(property),
        throwsA(
          isA<ParseException>().having(
            (e) => e.message,
            'message',
            'Invalid URI value "ht!tp://invalid"',
          ),
        ),
      );
    });
  });

  group('Parse TZID parameter validation', () {
    test('Multiple TZID parameters throws', () {
      final property = CalendarProperty(
        name: 'DTSTART',
        value: '20250101T100000',
        parameters: {
          'TZID': ['America/New_York', 'Europe/London'],
        },
        lineNumber: 1,
      );
      expect(
        () => parseCalDateTime(property),
        throwsA(
          isA<ParseException>().having(
            (e) => e.message,
            'message',
            'Multiple TZID parameters found for property "DTSTART"',
          ),
        ),
      );
    });
  });

  group('Parse TEXT string escaping', () {
    test('Parse TEXT with backslash escape', () {
      final property = DocumentParser.parseProperty('TEXT:test\\\\value');
      final text = parseString(property);
      expect(text, 'test\\value');
    });

    test('Parse TEXT with comma escape', () {
      final property = DocumentParser.parseProperty('TEXT:test\\,value');
      final text = parseString(property);
      expect(text, 'test,value');
    });

    test('Parse TEXT with unknown escape sequence', () {
      final property = DocumentParser.parseProperty('TEXT:test\\xvalue');
      final text = parseString(property);
      expect(text, 'test\\xvalue');
    });

    test('Parse TEXT list with comma separation', () {
      final property = DocumentParser.parseProperty(
        'CATEGORIES:CAT1,CAT2,CAT3',
      );
      final list = parseStringList(property);
      expect(list, ['CAT1', 'CAT2', 'CAT3']);
    });

    test('Parse TEXT list with escaped comma', () {
      final property = DocumentParser.parseProperty('CATEGORIES:CAT1\\,A,CAT2');
      final list = parseStringList(property);
      expect(list, ['CAT1,A', 'CAT2']);
    });
  });

  group('Parse TIME', () {
    test('Parse TIME with UTC', () {
      final value = parseCalTimeValue('120000Z');
      expect(value.hour, 12);
      expect(value.minute, 0);
      expect(value.second, 0);
      expect(value.isUtc, isTrue);
    });

    test('Parse TIME with local', () {
      final value = parseCalTimeValue('120000');
      expect(value.hour, 12);
      expect(value.minute, 0);
      expect(value.second, 0);
      expect(value.isUtc, isFalse);
    });

    test('Parse TIME with TZID and Z throws', () {
      expect(
        () => parseCalTimeValue('120000Z', tzid: 'America/New_York'),
        throwsA(
          isA<ParseException>().having(
            (e) => e.message,
            'message',
            'Cannot specify TZID for UTC date-time value "120000Z"',
          ),
        ),
      );
    });
  });

  group('Parse DATE-TIME', () {
    test('Parse DATE-TIME with TZID and Z throws', () {
      expect(
        () =>
            parseCalDateTimeValue('20250101T120000Z', tzid: 'America/New_York'),
        throwsA(
          isA<ParseException>().having(
            (e) => e.message,
            'message',
            'Cannot specify TZID for UTC date-time value "20250101T120000Z"',
          ),
        ),
      );
    });
  });

  group('Parse RRULE validation', () {
    test('Parse RRULE with duplicate key throws', () {
      expect(
        () => parseRecurrenceRuleValue('FREQ=DAILY;FREQ=WEEKLY'),
        throwsA(
          isA<ParseException>().having(
            (e) => e.message,
            'message',
            'Duplicate key "FREQ" in RRULE',
          ),
        ),
      );
    });

    test('Parse RRULE with invalid FREQ value throws', () {
      expect(
        () => parseRecurrenceRuleValue('FREQ=INVALID'),
        throwsA(
          isA<ParseException>().having(
            (e) => e.message,
            'message',
            'Invalid FREQ value "INVALID" in RRULE',
          ),
        ),
      );
    });

    test('Parse RRULE with invalid WKST value throws', () {
      expect(
        () => parseRecurrenceRuleValue('FREQ=DAILY;WKST=XX'),
        throwsA(
          isA<ParseException>().having(
            (e) => e.message,
            'message',
            'Invalid WKST value "XX" in RRULE',
          ),
        ),
      );
    });

    test('Parse RRULE with unknown key throws', () {
      expect(
        () => parseRecurrenceRuleValue('FREQ=DAILY;UNKNOWN=VALUE'),
        throwsA(
          isA<ParseException>().having(
            (e) => e.message,
            'message',
            'Unknown key "UNKNOWN" in RRULE',
          ),
        ),
      );
    });

    test('Parse RRULE without FREQ throws', () {
      expect(
        () => parseRecurrenceRuleValue('COUNT=10'),
        throwsA(
          isA<ParseException>().having(
            (e) => e.message,
            'message',
            'Missing required FREQ in RRULE',
          ),
        ),
      );
    });

    test('Parse RRULE with zero in BYMONTHDAY throws', () {
      expect(
        () => parseRecurrenceRuleValue('FREQ=DAILY;BYMONTHDAY=0'),
        throwsA(
          isA<ParseException>().having(
            (e) => e.message,
            'message',
            'Invalid integer "0" in BYMONTHDAY',
          ),
        ),
      );
    });

    test('Parse RRULE with duplicate integer in BYSECOND throws', () {
      expect(
        () => parseRecurrenceRuleValue('FREQ=DAILY;BYSECOND=30,30'),
        throwsA(
          isA<ParseException>().having(
            (e) => e.message,
            'message',
            'Duplicate integer "30" in BYSECOND',
          ),
        ),
      );
    });

    test('Parse RRULE with invalid weekday in BYDAY throws', () {
      expect(
        () => parseRecurrenceRuleValue('FREQ=DAILY;BYDAY=XX'),
        throwsA(
          isA<ParseException>().having(
            (e) => e.message,
            'message',
            'Invalid weekday "XX" in BYDAY',
          ),
        ),
      );
    });

    test('Parse RRULE with duplicate weekday in BYDAY throws', () {
      expect(
        () => parseRecurrenceRuleValue('FREQ=DAILY;BYDAY=MO,MO'),
        throwsA(
          isA<ParseException>().having(
            (e) => e.message,
            'message',
            'Duplicate weekday "MO" in BYDAY',
          ),
        ),
      );
    });

    test('Parse RRULE with BYDAY ordinal', () {
      final rrule = parseRecurrenceRuleValue('FREQ=MONTHLY;BYDAY=2MO');
      expect(rrule.byDay, isNotNull);
      expect(rrule.byDay!.first.weekday, Weekday.mo);
      expect(rrule.byDay!.first.ordinal, 2);
    });

    test('Parse RRULE with negative BYDAY ordinal', () {
      final rrule = parseRecurrenceRuleValue('FREQ=MONTHLY;BYDAY=-1FR');
      expect(rrule.byDay, isNotNull);
      expect(rrule.byDay!.first.weekday, Weekday.fr);
      expect(rrule.byDay!.first.ordinal, -1);
    });

    test('Parse RRULE with UNTIL as date', () {
      final rrule = parseRecurrenceRuleValue('FREQ=DAILY;UNTIL=20251231');
      expect(rrule.until, CalDateTime.date(2025, 12, 31));
    });

    test('Parse RRULE with UNTIL as date-time', () {
      final rrule = parseRecurrenceRuleValue(
        'FREQ=DAILY;UNTIL=20251231T235959Z',
      );
      expect(rrule.until, CalDateTime.utc(2025, 12, 31, 23, 59, 59));
    });

    test('Parse RRULE with invalid comma in integer list throws', () {
      expect(
        () => parseRecurrenceRuleValue('FREQ=DAILY;BYSECOND=30,'),
        throwsA(isA<ParseException>()),
      );
    });

    test('Parse RRULE with invalid comma in day list throws', () {
      expect(
        () => parseRecurrenceRuleValue('FREQ=DAILY;BYDAY=MO,'),
        throwsA(isA<ParseException>()),
      );
    });
  });

  group('Parse date/time lists', () {
    test('Parse EXDATE with DATE list', () {
      final property = DocumentParser.parseProperty(
        'EXDATE;VALUE=DATE:20250101,20250102,20250103',
      );
      final dates = parseCalDateOrDateTimeList(property);
      expect(dates.length, 3);
      expect(dates[0], CalDateTime.date(2025, 1, 1));
      expect(dates[1], CalDateTime.date(2025, 1, 2));
      expect(dates[2], CalDateTime.date(2025, 1, 3));
    });

    test('Parse EXDATE with DATE-TIME list', () {
      final property = DocumentParser.parseProperty(
        'EXDATE:20250101T100000Z,20250102T100000Z',
      );
      final dates = parseCalDateOrDateTimeList(property);
      expect(dates.length, 2);
      expect(dates[0], CalDateTime.utc(2025, 1, 1, 10, 0, 0));
      expect(dates[1], CalDateTime.utc(2025, 1, 2, 10, 0, 0));
    });
  });

  group('Parse TIME with property', () {
    test('Parse TIME property', () {
      final property = DocumentParser.parseProperty('TIME:120000');
      final time = parseCalTime(property);
      expect(time.hour, 12);
      expect(time.minute, 0);
      expect(time.second, 0);
    });

    test('Parse TIME property with TZID', () {
      final property = DocumentParser.parseProperty(
        'TIME;TZID=America/New_York:120000',
      );
      final time = parseCalTime(property);
      expect(time.hour, 12);
      expect(time.tzid, 'America/New_York');
    });
  });

  group('Parse BOOLEAN', () {
    test('Parse TRUE (uppercase)', () {
      final property = DocumentParser.parseProperty('X-TEST:TRUE');
      final value = parseBoolean(property);
      expect(value, isTrue);
    });

    test('Parse FALSE (uppercase)', () {
      final property = DocumentParser.parseProperty('X-TEST:FALSE');
      final value = parseBoolean(property);
      expect(value, isFalse);
    });

    test('Parse true (lowercase)', () {
      final property = DocumentParser.parseProperty('X-TEST:true');
      final value = parseBoolean(property);
      expect(value, isTrue);
    });

    test('Parse false (lowercase)', () {
      final property = DocumentParser.parseProperty('X-TEST:false');
      final value = parseBoolean(property);
      expect(value, isFalse);
    });

    test('Parse True (mixed case)', () {
      final property = DocumentParser.parseProperty('X-TEST:True');
      final value = parseBoolean(property);
      expect(value, isTrue);
    });

    test('Parse False (mixed case)', () {
      final property = DocumentParser.parseProperty('X-TEST:False');
      final value = parseBoolean(property);
      expect(value, isFalse);
    });

    test('Parse invalid boolean value throws ParseException', () {
      final property = DocumentParser.parseProperty('X-TEST:INVALID');
      expect(
        () => parseBoolean(property),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Invalid boolean value "INVALID" for property "X-TEST" [Ln 0]',
          ),
        ),
      );
    });

    test('Parse empty boolean value throws ParseException', () {
      final property = DocumentParser.parseProperty('X-TEST:');
      expect(
        () => parseBoolean(property),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Invalid boolean value "" for property "X-TEST" [Ln 0]',
          ),
        ),
      );
    });

    test('Parse numeric value throws ParseException', () {
      final property = DocumentParser.parseProperty('X-TEST:1');
      expect(
        () => parseBoolean(property),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Invalid boolean value "1" for property "X-TEST" [Ln 0]',
          ),
        ),
      );
    });

    test('Parse YES value throws ParseException', () {
      final property = DocumentParser.parseProperty('X-TEST:YES');
      expect(
        () => parseBoolean(property),
        throwsA(
          predicate(
            (e) =>
                e.toString() ==
                'ParseException: Invalid boolean value "YES" for property "X-TEST" [Ln 0]',
          ),
        ),
      );
    });
  });
}
