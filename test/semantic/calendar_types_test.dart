import 'dart:typed_data';
import 'package:firstfloor_calendar/firstfloor_calendar.dart';
import 'package:test/test.dart';

void main() {
  group('AttachmentBinary', () {
    test('Equality works correctly', () {
      final att1 = AttachmentBinary(
        fmtType: 'image/png',
        encoding: 'BASE64',
        value: 'aGVsbG8=',
      );
      final att2 = AttachmentBinary(
        fmtType: 'image/png',
        encoding: 'BASE64',
        value: 'aGVsbG8=',
      );
      final att3 = AttachmentBinary(
        fmtType: 'image/jpeg',
        encoding: 'BASE64',
        value: 'aGVsbG8=',
      );

      expect(att1, equals(att2));
      expect(att1, isNot(equals(att3)));
      expect(att1.hashCode, equals(att2.hashCode));
    });

    test('bytes decodes BASE64 correctly', () {
      final att = AttachmentBinary(
        encoding: 'BASE64',
        value: 'aGVsbG8=', // "hello" in base64
      );

      final bytes = att.bytes;
      expect(bytes, isA<Uint8List>());
      expect(String.fromCharCodes(bytes), 'hello');
    });

    test('bytes caches decoded value', () {
      final att = AttachmentBinary(encoding: 'BASE64', value: 'aGVsbG8=');

      final bytes1 = att.bytes;
      final bytes2 = att.bytes;
      expect(identical(bytes1, bytes2), isTrue);
    });

    test('bytes throws for unsupported encoding', () {
      final att = AttachmentBinary(encoding: 'UNKNOWN', value: 'data');

      expect(() => att.bytes, throwsUnsupportedError);
    });
  });

  group('AttachmentUri', () {
    test('Equality works correctly', () {
      final att1 = AttachmentUri(
        fmtType: 'image/png',
        uri: Uri.parse('https://example.com/image.png'),
      );
      final att2 = AttachmentUri(
        fmtType: 'image/png',
        uri: Uri.parse('https://example.com/image.png'),
      );
      final att3 = AttachmentUri(
        fmtType: 'image/png',
        uri: Uri.parse('https://example.com/other.png'),
      );

      expect(att1, equals(att2));
      expect(att1, isNot(equals(att3)));
      expect(att1.hashCode, equals(att2.hashCode));
    });

    test('toString returns URI string', () {
      final att = AttachmentUri(uri: Uri.parse('https://example.com/file.pdf'));

      expect(att.toString(), 'https://example.com/file.pdf');
    });
  });

  group('ByDay', () {
    test('Equality works correctly', () {
      final bd1 = ByDay(Weekday.mo, ordinal: 1);
      final bd2 = ByDay(Weekday.mo, ordinal: 1);
      final bd3 = ByDay(Weekday.mo, ordinal: 2);
      final bd4 = ByDay(Weekday.mo);

      expect(bd1, equals(bd2));
      expect(bd1, isNot(equals(bd3)));
      expect(bd1, isNot(equals(bd4)));
      expect(bd1.hashCode, equals(bd2.hashCode));
    });

    test('toString with ordinal', () {
      final bd = ByDay(Weekday.su, ordinal: -1);
      expect(bd.toString(), '-1SU');
    });

    test('toString without ordinal', () {
      final bd = ByDay(Weekday.fr);
      expect(bd.toString(), 'FR');
    });
  });

  group('CalDateTime', () {
    test('add throws StateError when adding time to DATE', () {
      final date = CalDateTime.date(2025, 1, 1);
      expect(
        () => date.add(hours: 1),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'Cannot add time part to a DATE value',
          ),
        ),
      );
    });

    test('copyWith throws StateError when setting time on DATE', () {
      final date = CalDateTime.date(2025, 1, 1);
      expect(
        () => date.copyWith(hour: 10),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'Cannot set time part on a DATE value',
          ),
        ),
      );
    });

    test('compareTo works correctly', () {
      final dt1 = CalDateTime.local(2025, 1, 1, 10, 0, 0);
      final dt2 = CalDateTime.local(2025, 1, 2, 10, 0, 0);
      final dt3 = CalDateTime.local(2025, 1, 1, 10, 0, 0);

      expect(dt1.compareTo(dt2), lessThan(0));
      expect(dt2.compareTo(dt1), greaterThan(0));
      expect(dt1.compareTo(dt3), equals(0));
    });
  });

  group('CalDuration', () {
    test('Equality works correctly', () {
      final dur1 = CalDuration(days: 1, hours: 2, minutes: 30);
      final dur2 = CalDuration(days: 1, hours: 2, minutes: 30);
      final dur3 = CalDuration(days: 1, hours: 3, minutes: 30);

      expect(dur1, equals(dur2));
      expect(dur1, isNot(equals(dur3)));
      expect(dur1.hashCode, equals(dur2.hashCode));
    });

    test('toString formats duration correctly', () {
      final dur1 = CalDuration(days: 1, hours: 2, minutes: 30, seconds: 45);
      expect(dur1.toString(), equals('P1DT2H30M45S'));
    });

    test('toString with weeks only', () {
      final dur = CalDuration(weeks: 2);
      expect(dur.toString(), equals('P2W'));
    });
  });

  group('CalTime', () {
    test('Equality works correctly', () {
      final t1 = CalTime.local(10, 30, 45);
      final t2 = CalTime.local(10, 30, 45);
      final t3 = CalTime.local(10, 30, 0);

      expect(t1, equals(t2));
      expect(t1, isNot(equals(t3)));
      expect(t1.hashCode, equals(t2.hashCode));
    });

    test('toString formats time correctly', () {
      final t = CalTime.local(9, 5, 3);
      expect(t.toString(), equals('090503'));
    });

    test('toString with UTC', () {
      final t = CalTime.utc(14, 30, 0);
      expect(t.toString(), equals('143000Z'));
    });

    test('isFloating returns true when no UTC or TZID', () {
      final t = CalTime.local(10, 30, 0);
      expect(t.isFloating, isTrue);
    });

    test('isFloating returns false with UTC', () {
      final t = CalTime.utc(10, 30, 0);
      expect(t.isFloating, isFalse);
    });

    test('isFloating returns false with TZID', () {
      final t = CalTime.local(10, 30, 0, tzid: 'America/New_York');
      expect(t.isFloating, isFalse);
    });
  });

  group('CalendarUserAddress', () {
    test('Equality works correctly', () {
      final addr1 = CalendarUserAddress(
        address: 'mailto:user@example.com',
        cn: 'John Doe',
      );
      final addr2 = CalendarUserAddress(
        address: 'mailto:user@example.com',
        cn: 'John Doe',
      );
      final addr3 = CalendarUserAddress(
        address: 'mailto:other@example.com',
        cn: 'John Doe',
      );

      expect(addr1, equals(addr2));
      expect(addr1, isNot(equals(addr3)));
      expect(addr1.hashCode, equals(addr2.hashCode));
    });
  });

  group('GeoCoordinate', () {
    test('Equality works correctly', () {
      final geo1 = GeoCoordinate(latitude: 51.5074, longitude: -0.1278);
      final geo2 = GeoCoordinate(latitude: 51.5074, longitude: -0.1278);
      final geo3 = GeoCoordinate(latitude: 40.7128, longitude: -74.0060);

      expect(geo1, equals(geo2));
      expect(geo1, isNot(equals(geo3)));
      expect(geo1.hashCode, equals(geo2.hashCode));
    });

    test('toString formats coordinates', () {
      final geo = GeoCoordinate(latitude: 51.5074, longitude: -0.1278);
      expect(geo.toString(), equals('51.5074;-0.1278'));
    });
  });

  group('Period', () {
    test('Equality works correctly', () {
      final start = CalDateTime.local(2025, 1, 1, 10, 0, 0);
      final end = CalDateTime.local(2025, 1, 1, 11, 0, 0);
      final duration = CalDuration(hours: 1);

      final p1 = Period.explicit(start: start, end: end);
      final p2 = Period.explicit(start: start, end: end);
      final p3 = Period.start(start: start, duration: duration);

      expect(p1, equals(p2));
      expect(p1, isNot(equals(p3)));
      expect(p1.hashCode, equals(p2.hashCode));
    });

    test('toString with end time', () {
      final start = CalDateTime.local(2025, 1, 1, 10, 0, 0);
      final end = CalDateTime.local(2025, 1, 1, 11, 0, 0);
      final period = Period.explicit(start: start, end: end);

      expect(period.toString(), equals('20250101T100000/20250101T110000'));
    });

    test('toString with duration', () {
      final start = CalDateTime.local(2025, 1, 1, 10, 0, 0);
      final duration = CalDuration(hours: 2);
      final period = Period.start(start: start, duration: duration);

      expect(period.toString(), equals('20250101T100000/PT2H'));
    });

    test('isExplicit returns true for explicit period', () {
      final start = CalDateTime.local(2025, 1, 1, 10, 0, 0);
      final end = CalDateTime.local(2025, 1, 1, 11, 0, 0);
      final period = Period.explicit(start: start, end: end);

      expect(period.isExplicit, isTrue);
      expect(period.isDuration, isFalse);
    });

    test('isDuration returns true for duration period', () {
      final start = CalDateTime.local(2025, 1, 1, 10, 0, 0);
      final duration = CalDuration(hours: 1);
      final period = Period.start(start: start, duration: duration);

      expect(period.isDuration, isTrue);
      expect(period.isExplicit, isFalse);
    });
  });

  group('RecurrenceDateTime', () {
    test('Equality works correctly', () {
      final dt1 = CalDateTime.local(2025, 1, 1, 10, 0, 0);
      final dt2 = CalDateTime.local(2025, 1, 2, 10, 0, 0);

      final rd1 = RecurrenceDateTime.dateTime(dt1);
      final rd2 = RecurrenceDateTime.dateTime(dt1);
      final rd3 = RecurrenceDateTime.dateTime(dt2);

      expect(rd1, equals(rd2));
      expect(rd1, isNot(equals(rd3)));
      expect(rd1.hashCode, equals(rd2.hashCode));
    });

    test('toString returns datetime string', () {
      final dt = CalDateTime.local(2025, 1, 15, 14, 30, 0);
      final rd = RecurrenceDateTime.dateTime(dt);

      expect(rd.toString(), equals('20250115T143000'));
    });

    test('isDateTime returns true for dateTime', () {
      final dt = CalDateTime.local(2025, 1, 1, 10, 0, 0);
      final rd = RecurrenceDateTime.dateTime(dt);

      expect(rd.isDateTime, isTrue);
      expect(rd.isPeriod, isFalse);
    });

    test('isPeriod returns true for period', () {
      final start = CalDateTime.utc(2025, 1, 1, 10, 0, 0);
      final end = CalDateTime.utc(2025, 1, 1, 11, 0, 0);
      final period = Period.explicit(start: start, end: end);
      final rd = RecurrenceDateTime.period(period);

      expect(rd.isPeriod, isTrue);
      expect(rd.isDateTime, isFalse);
    });

    test('toString returns period string', () {
      final start = CalDateTime.utc(2025, 1, 1, 10, 0, 0);
      final duration = CalDuration(hours: 1);
      final period = Period.start(start: start, duration: duration);
      final rd = RecurrenceDateTime.period(period);

      expect(rd.toString(), equals('20250101T100000Z/PT1H'));
    });
  });

  group('RecurrenceRule', () {
    test('hashCode works with collections', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.daily,
        count: 10,
        interval: 2,
        bySecond: {0, 30},
        byMinute: {0, 15, 30, 45},
        byHour: {9, 17},
        byDay: {ByDay(Weekday.mo), ByDay(Weekday.fr)},
        byMonthDay: {1, 15},
        byYearDay: {1, 100, 200},
        byWeekNo: {1, 26, 52},
        byMonth: {1, 6, 12},
        bySetPos: {1, -1},
        wkst: Weekday.mo,
      );

      expect(rrule.hashCode, isA<int>());

      // Test that equal rrules have equal hashCodes
      final rrule2 = RecurrenceRule(
        freq: RecurrenceFrequency.daily,
        count: 10,
        interval: 2,
        bySecond: {0, 30},
        byMinute: {0, 15, 30, 45},
        byHour: {9, 17},
        byDay: {ByDay(Weekday.mo), ByDay(Weekday.fr)},
        byMonthDay: {1, 15},
        byYearDay: {1, 100, 200},
        byWeekNo: {1, 26, 52},
        byMonth: {1, 6, 12},
        bySetPos: {1, -1},
        wkst: Weekday.mo,
      );

      expect(rrule.hashCode, equals(rrule2.hashCode));
    });

    test('toString formats complete RRULE', () {
      final rrule = RecurrenceRule(
        freq: RecurrenceFrequency.weekly,
        until: CalDateTime.utc(2025, 12, 31, 23, 59, 59),
        interval: 2,
        byDay: {ByDay(Weekday.mo), ByDay(Weekday.we), ByDay(Weekday.fr)},
        wkst: Weekday.su,
      );

      // Note: Cannot use exact string assertion because byDay uses Set<>,
      // which has undefined iteration order. Testing individual components instead.
      final str = rrule.toString();
      expect(str, startsWith('FREQ=WEEKLY;'));
      expect(str, contains('UNTIL=20251231T235959Z'));
      expect(str, contains('INTERVAL=2'));
      expect(str, contains('BYDAY='));
      expect(str, contains('WKST=SU'));
    });

    test('toString with COUNT', () {
      final rrule = RecurrenceRule(freq: RecurrenceFrequency.daily, count: 10);

      expect(rrule.toString(), equals('FREQ=DAILY;COUNT=10'));
    });
  });

  group('Trigger', () {
    test('toString with duration', () {
      final dur = CalDuration(hours: 1, minutes: 30);
      final trigger = Trigger.duration(dur);

      expect(trigger.toString(), equals('PT1H30M'));
    });

    test('toString with UTC dateTime', () {
      final dt = CalDateTime.utc(2025, 1, 1, 10, 0, 0);
      final trigger = Trigger.dateTime(dt);

      expect(trigger.toString(), equals('20250101T100000Z'));
    });

    test('stores RELATED parameter metadata', () {
      final trigger = Trigger.duration(
        CalDuration(minutes: 15),
        related: TriggerRelated.end,
        relatedName: 'END',
      );

      expect(trigger.related, TriggerRelated.end);
      expect(trigger.relatedName, 'END');
    });
  });

  group('UtcOffset', () {
    test('Equality works correctly', () {
      final off1 = UtcOffset(sign: Sign.positive, hours: 5, minutes: 30);
      final off2 = UtcOffset(sign: Sign.positive, hours: 5, minutes: 30);
      final off3 = UtcOffset(sign: Sign.negative, hours: 8, minutes: 0);

      expect(off1, equals(off2));
      expect(off1, isNot(equals(off3)));
      expect(off1.hashCode, equals(off2.hashCode));
    });

    test('toString formats positive offset', () {
      final off = UtcOffset(sign: Sign.positive, hours: 5, minutes: 30);
      expect(off.toString(), equals('+0530'));
    });

    test('toString formats negative offset', () {
      final off = UtcOffset(sign: Sign.negative, hours: 8, minutes: 0);
      expect(off.toString(), equals('-0800'));
    });

    test('toString with seconds', () {
      final off = UtcOffset(
        sign: Sign.positive,
        hours: 1,
        minutes: 0,
        seconds: 30,
      );
      expect(off.toString(), equals('+010030'));
    });
  });
}
