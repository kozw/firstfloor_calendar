import 'dart:convert';
import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:timezone/timezone.dart' as tz;

import 'semantic.dart';

/// Represents an ATTACH property, which can be either a URI or binary data.
abstract class Attachment {
  /// The MIME type of the attachment, defaults to 'application/octet-stream'.
  final String fmtType;

  const Attachment({this.fmtType = 'application/octet-stream'});
}

/// Attachment with binary data, typically encoded in BASE64.
class AttachmentBinary extends Attachment {
  /// The encoding type of the attachment, if any.
  final String? encoding; // expect 'BASE64'
  /// The raw value of the attachment, typically a base64 string.
  final String value; // raw base64
  Uint8List? _cache;

  /// Creates a new binary attachment with the given format type, encoding, and value.
  AttachmentBinary({super.fmtType, this.encoding, required this.value});

  /// The decoded bytes of the attachment.
  Uint8List get bytes {
    if (encoding?.toUpperCase() == 'BASE64') {
      return _cache ??= base64.decode(value);
    }

    throw UnsupportedError('Unsupported encoding: $encoding');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AttachmentBinary &&
        other.fmtType == fmtType &&
        other.encoding == encoding &&
        other.value == value;
  }

  @override
  int get hashCode => Object.hash(fmtType, encoding, value);
}

/// Attachment with a URI reference.
class AttachmentUri extends Attachment {
  /// The URI of the attachment.
  final Uri uri;

  /// Creates a new URI attachment with the given format type and URI.
  const AttachmentUri({super.fmtType, required this.uri});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AttachmentUri &&
        other.fmtType == fmtType &&
        other.uri == uri;
  }

  @override
  int get hashCode => Object.hash(fmtType, uri);

  @override
  String toString() => uri.toString();
}

/// BYDAY entry like -1SU or 3MO. ordinal may be null for plain weekday (e.g., SU).
class ByDay {
  /// The weekday (MO, TU, WE, TH, FR, SA, SU).
  final Weekday weekday;

  /// The optional ordinal, e.g., -1 for last, 1 for first, etc.
  final int? ordinal; // -53..-1 or 1..53 per RFC
  /// Creates a new BYDAY entry with the given weekday and optional ordinal.
  const ByDay(this.weekday, {this.ordinal});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ByDay &&
        other.weekday == weekday &&
        other.ordinal == ordinal;
  }

  @override
  int get hashCode => Object.hash(weekday, ordinal);

  @override
  String toString() {
    return ordinal != null ? '$ordinal${weekday.toName()}' : weekday.toName();
  }
}

/// Represents a DATE or a DATE-TIME.
/// If time is null, it's a DATE; otherwise, it's a DATE-TIME.
class CalDateTime implements Comparable<CalDateTime> {
  /// The year, month, and day components.
  final int year, month, day;

  /// The time component, or null for DATE values.
  final CalTime? time;

  // cached native DateTime representation
  final DateTime _native;

  CalDateTime._(this.year, this.month, this.day, this.time, this._native)
    : assert(year >= 1, 'Year must be positive'),
      assert(month >= 1 && month <= 12, 'Month must be in 1..12'),
      assert(day >= 1 && day <= 31, 'Day must be in 1..31');

  /// Creates a DATE value (no time part).
  CalDateTime.date(int year, [int month = 1, int day = 1])
    : this._(year, month, day, null, DateTime(year, month, day));

  /// Creates a DATE-TIME value with local time (no 'Z'), optionally with TZID.
  CalDateTime.local(
    int year, [
    int month = 1,
    int day = 1,
    int hour = 0,
    int minute = 0,
    int second = 0,
    String? tzid,
  ]) : this._(
         year,
         month,
         day,
         CalTime.local(hour, minute, second, tzid: tzid),
         _buildNativeLocalDateTime(
           year,
           month,
           day,
           hour,
           minute,
           second,
           tzid: tzid,
         ),
       );

  /// Creates a DATE-TIME value with UTC time ('Z').
  CalDateTime.utc(
    int year, [
    int month = 1,
    int day = 1,
    int hour = 0,
    int minute = 0,
    int second = 0,
  ]) : this._(
         year,
         month,
         day,
         CalTime.utc(hour, minute, second),
         DateTime.utc(year, month, day, hour, minute, second),
       );

  /// True if this is a DATE value (no time part).
  bool get isDate => time == null;

  /// True if this is a DATE-TIME value (has time part).
  bool get isDateTime => time != null;

  /// Returns the native Dart DateTime representation.
  DateTime get native => _native;

  /// Adds the specified duration to this date/time and returns a new instance.
  CalDateTime add({
    int years = 0,
    int months = 0,
    int weeks = 0,
    int days = 0,
    int hours = 0,
    int minutes = 0,
    int seconds = 0,
  }) {
    if (isDate && (hours != 0 || minutes != 0 || seconds != 0)) {
      throw StateError('Cannot add time part to a DATE value');
    }
    return copyWith(
      year: year + years,
      month: month + months,
      day: day + days + weeks * 7,
      hour: time == null ? null : (time!.hour + hours),
      minute: time == null ? null : (time!.minute + minutes),
      second: time == null ? null : (time!.second + seconds),
    );
  }

  /// Creates a copy of this date/time with the specified fields replaced.
  CalDateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    bool? isUtc,
    String? tzid,
  }) {
    if (isDate && (hour != null || minute != null || second != null)) {
      throw StateError('Cannot set time part on a DATE value');
    }

    final newYear = year ?? this.year;
    final newMonth = month ?? this.month;
    final newDay = day ?? this.day;

    if (isDate) {
      // native DateTime will handle month/day overflow
      final native = DateTime(newYear, newMonth, newDay);
      return CalDateTime._(native.year, native.month, native.day, null, native);
    }

    final newHour = hour ?? time!.hour;
    final newMinute = minute ?? time!.minute;
    final newSecond = second ?? time!.second;
    final newIsUtc = isUtc ?? time!.isUtc;
    final newTzid = tzid ?? time!.tzid;

    // preserve the timezone information
    final result = _buildNativeLocalDateTime(
      newYear,
      newMonth,
      newDay,
      newHour,
      newMinute,
      newSecond,
      tzid: newTzid,
      fallback: native,
    );

    return CalDateTime._(
      result.year,
      result.month,
      result.day,
      time != null
          ? CalTime._(
              result.hour,
              result.minute,
              result.second,
              isUtc: newIsUtc,
              tzid: newTzid,
            )
          : null,
      result,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CalDateTime &&
        other.year == year &&
        other.month == month &&
        other.day == day &&
        other.time == time;
  }

  @override
  int get hashCode => Object.hash(year, month, day, time);

  /// Compares this date/time to another, returning a negative value if this is before,
  /// zero if they are equal, or a positive value if this is after the other.
  @override
  int compareTo(CalDateTime other) {
    return _native.compareTo(other._native);
  }

  @override
  String toString() {
    final date =
        '${year.toString().padLeft(4, '0')}'
        '${month.toString().padLeft(2, '0')}'
        '${day.toString().padLeft(2, '0')}';

    return time != null ? '${date}T${time.toString()}' : date;
  }

  static DateTime _buildNativeLocalDateTime(
    int year,
    int month,
    int day,
    int hour,
    int minute,
    int second, {
    String? tzid,
    DateTime? fallback,
  }) {
    if (tzid == null) {
      if (fallback == null) {
        return DateTime(year, month, day, hour, minute, second);
      }
      return fallback.copyWith(
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute,
        second: second,
      );
    }

    try {
      return tz.TZDateTime(
        tz.getLocation(tzid),
        year,
        month,
        day,
        hour,
        minute,
        second,
      );
    } on tz.LocationNotFoundException {
      if (fallback == null) {
        return DateTime(year, month, day, hour, minute, second);
      }
      return fallback.copyWith(
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute,
        second: second,
      );
    }
  }
}

/// Represents a DURATION value.
class CalDuration {
  /// The sign of the duration, positive or negative.
  final Sign sign;

  /// The number of weeks in the duration.
  final int weeks;

  /// The number of days in the duration.
  final int days;

  /// The number of hours in the duration.
  final int hours;

  /// The number of minutes in the duration.
  final int minutes;

  /// The number of seconds in the duration.
  final int seconds;

  /// Creates a new duration with the given sign and components.
  const CalDuration({
    this.sign = Sign.positive,
    this.weeks = 0,
    this.days = 0,
    this.hours = 0,
    this.minutes = 0,
    this.seconds = 0,
  }) : assert(weeks >= 0, 'Weeks must be non-negative'),
       assert(days >= 0, 'Days must be non-negative'),
       assert(hours >= 0, 'Hours must be non-negative'),
       assert(minutes >= 0, 'Minutes must be non-negative'),
       assert(seconds >= 0, 'Seconds must be non-negative');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalDuration &&
        other.sign == sign &&
        other.weeks == weeks &&
        other.days == days &&
        other.hours == hours &&
        other.minutes == minutes &&
        other.seconds == seconds;
  }

  @override
  int get hashCode => Object.hash(sign, weeks, days, hours, minutes, seconds);

  @override
  String toString() {
    final signStr = sign == Sign.positive ? '' : '-';
    final weeksStr = weeks != 0 ? '${weeks}W' : '';
    final daysStr = days != 0 ? '${days}D' : '';
    final hoursStr = hours != 0 ? '${hours}H' : '';
    final minutesStr = minutes != 0 ? '${minutes}M' : '';
    final secondsStr = seconds != 0 ? '${seconds}S' : '';
    return '${signStr}P$weeksStr$daysStr'
        '${(hours != 0 || minutes != 0 || seconds != 0) ? 'T' : ''}'
        '$hoursStr$minutesStr$secondsStr';
  }
}

/// Represents a TIME.
class CalTime {
  /// The hour, minute, and second components.
  final int hour, minute, second;

  /// True if the time is in UTC ('Z').
  final bool isUtc;

  /// The optional timezone identifier (TZID).
  final String? tzid;

  const CalTime._(
    this.hour,
    this.minute,
    this.second, {
    required this.isUtc,
    this.tzid,
  }) : assert(hour >= 0 && hour < 24, 'Hour must be in 0..23'),
       assert(minute >= 0 && minute < 60, 'Minute must be in 0..59'),
       assert(second >= 0 && second < 61, 'Second must be in 0..60');

  /// Creates a TIME value with local time (no 'Z'), optionally with TZID.
  const CalTime.local(int hour, int minute, int second, {String? tzid})
    : this._(hour, minute, second, isUtc: false, tzid: tzid);

  /// Creates a TIME value with UTC time ('Z').
  const CalTime.utc(int hour, int minute, int second)
    : this._(hour, minute, second, isUtc: true);

  /// True if neither UTC nor TZID is set, meaning floating time.
  bool get isFloating => !isUtc && tzid == null;

  @override
  operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CalTime &&
        other.hour == hour &&
        other.minute == minute &&
        other.second == second &&
        other.isUtc == isUtc &&
        other.tzid == tzid;
  }

  @override
  int get hashCode => Object.hash(hour, minute, second, isUtc, tzid);
  @override
  String toString() {
    final timePart =
        '${hour.toString().padLeft(2, '0')}'
        '${minute.toString().padLeft(2, '0')}'
        '${second.toString().padLeft(2, '0')}';
    final tzPart = isUtc ? 'Z' : (tzid != null ? ' [$tzid]' : '');
    return '$timePart$tzPart';
  }
}

/// Represents a calendar user address (CUA) with various parameters.
class CalendarUserAddress {
  /// The actual address, e.g., mailto:
  final String address;

  /// The common name (CN) parameter.
  final String? cn;

  /// The directory (DIR) parameter.
  final String? dir;

  /// The sent-by (SENT-BY) parameter.
  final String? sentby;

  /// The language (LANGUAGE) parameter.
  final String? language;

  /// The calendar user type (CUTYPE) parameter.
  final CalendarUserType? cutype;

  /// The name of the calendar user type (CUTYPE) parameter.
  final String? cutypeName;

  /// The members (MEMBER) parameter, list of URIs.
  final List<String>? members;

  /// The participation role (ROLE) parameter.
  final ParticipationRole? role;

  /// The name of the participation role (ROLE) parameter.
  final String? roleName;

  /// The participation status (PARTSTAT) parameter.
  final ParticipationStatus? partstat;

  /// The name of the participation status (PARTSTAT) parameter.
  final String? partstatName;

  /// Whether a response is requested (RSVP) parameter, defaults to false.
  final bool rsvp;

  /// The delegated-to (DELEGATED-TO) parameter, list of URIs.
  final List<String>? delegatedto;

  /// The delegated-from (DELEGATED-FROM) parameter, list of URIs.
  final List<String>? delegatedfrom;

  /// Creates a new calendar user address with the given parameters.
  const CalendarUserAddress({
    required this.address,
    this.cn,
    this.dir,
    this.sentby,
    this.language,
    this.cutype,
    this.cutypeName,
    this.members,
    this.role,
    this.roleName,
    this.partstat,
    this.partstatName,
    this.rsvp = false,
    this.delegatedto,
    this.delegatedfrom,
  });

  @override
  operator ==(Object other) {
    if (identical(this, other)) return true;
    final eq = const ListEquality().equals;
    return other is CalendarUserAddress &&
        other.address == address &&
        other.cn == cn &&
        other.dir == dir &&
        other.sentby == sentby &&
        other.language == language &&
        other.cutype == cutype &&
        other.cutypeName == cutypeName &&
        eq(other.members, members) &&
        other.role == role &&
        other.roleName == roleName &&
        other.partstat == partstat &&
        other.partstatName == partstatName &&
        other.rsvp == rsvp &&
        eq(other.delegatedto, delegatedto) &&
        eq(other.delegatedfrom, delegatedfrom);
  }

  @override
  int get hashCode => Object.hash(
    address,
    cn,
    dir,
    sentby,
    language,
    cutype,
    cutypeName,
    members == null ? null : Object.hashAll(members!),
    role,
    roleName,
    partstat,
    partstatName,
    rsvp,
    delegatedto == null ? null : Object.hashAll(delegatedto!),
    delegatedfrom == null ? null : Object.hashAll(delegatedfrom!),
  );
}

/// Represents a geographical location with latitude and longitude.
class GeoCoordinate {
  /// The latitude of the location.
  final double latitude;

  /// The longitude of the location.
  final double longitude;

  /// Creates a new geographical coordinate with the given latitude and longitude.
  const GeoCoordinate({required this.latitude, required this.longitude});

  @override
  operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GeoCoordinate &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => '$latitude;$longitude';
}

/// Represents a period with a start and either an end or a duration.
class Period {
  /// The start date/time of the period.
  final CalDateTime start;

  /// The end date/time of the period, if specified.
  final CalDateTime? end;

  /// The duration of the period, if specified.
  final CalDuration? duration;

  /// Creates a new period with an explicit start and end date/time.
  Period.explicit({required this.start, required CalDateTime this.end})
    : duration = null;

  /// Creates a new period with a start date/time and a duration.
  Period.start({required this.start, required CalDuration this.duration})
    : end = null,
      assert(
        duration.sign == Sign.positive,
        'Duration must be positive when used in a Period',
      );

  /// True if the period has an explicit end date/time.
  bool get isExplicit => end != null;

  /// True if the period has a duration instead of an end date/time.
  bool get isDuration => duration != null;

  @override
  operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Period &&
        other.start == start &&
        other.end == end &&
        other.duration == duration;
  }

  @override
  int get hashCode => Object.hash(start, end, duration);

  @override
  String toString() {
    if (isExplicit) return '${start.toString()}/${end.toString()}';
    if (isDuration) return '${start.toString()}/${duration.toString()}';
    throw StateError('Invalid Period state');
  }
}

/// Represents either a DATE-TIME or a PERIOD for recurrence dates (RDATE).
class RecurrenceDateTime {
  /// The DATE-TIME value, if specified.
  final CalDateTime? dateTime;

  /// The PERIOD value, if specified.
  final Period? period;

  /// Creates a RecurrenceDateTime with a DATE-TIME.
  const RecurrenceDateTime.dateTime(CalDateTime this.dateTime) : period = null;

  /// Creates a RecurrenceDateTime with a PERIOD.
  const RecurrenceDateTime.period(Period this.period) : dateTime = null;

  /// True if this instance represents a DATE-TIME.
  bool get isDateTime => dateTime != null;

  /// True if this instance represents a PERIOD.
  bool get isPeriod => period != null;

  @override
  operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecurrenceDateTime &&
        other.dateTime == dateTime &&
        other.period == period;
  }

  @override
  int get hashCode => Object.hash(dateTime, period);

  @override
  String toString() {
    if (!isPeriod) return dateTime.toString();
    if (isPeriod) return period.toString();
    throw StateError('Invalid RecurrenceDateTime state');
  }
}

/// RRULE value type covering RFC 5545 recurrence properties.
class RecurrenceRule {
  /// The frequency of the recurrence (e.g., DAILY, WEEKLY).
  final RecurrenceFrequency freq;

  /// The end date/time of the recurrence, if specified.
  final CalDateTime? until;

  /// The number of occurrences of the recurrence, if specified.
  final int? count;

  /// The interval between each recurrence, defaults to 1.
  final int interval;

  /// The set of seconds for BYSECOND rule, if specified.
  final Set<int>? bySecond;

  /// The set of minutes for BYMINUTE rule, if specified.
  final Set<int>? byMinute;

  /// The set of hours for BYHOUR rule, if specified.
  final Set<int>? byHour;

  /// The set of days for BYDAY rule, if specified.
  final Set<ByDay>? byDay;

  /// The set of month days for BYMONTHDAY rule, if specified.
  final Set<int>? byMonthDay;

  /// The set of year days for BYYEARDAY rule, if specified.
  final Set<int>? byYearDay;

  /// The set of week numbers for BYWEEKNO rule, if specified.
  final Set<int>? byWeekNo;

  /// The set of months for BYMONTH rule, if specified.
  final Set<int>? byMonth;

  /// The set of positions for BYSETPOS rule, if specified.
  final Set<int>? bySetPos;

  /// The week start day, if specified.
  final Weekday? wkst;

  /// Creates a new recurrence rule with the given parameters.
  const RecurrenceRule({
    required this.freq,
    this.until,
    this.count,
    this.interval = 1,
    this.bySecond,
    this.byMinute,
    this.byHour,
    this.byDay,
    this.byMonthDay,
    this.byYearDay,
    this.byWeekNo,
    this.byMonth,
    this.bySetPos,
    this.wkst,
  }) : assert(interval > 0, 'INTERVAL must be >= 1');

  @override
  operator ==(Object other) {
    if (identical(this, other)) return true;
    final eq = const SetEquality().equals;
    return other is RecurrenceRule &&
        other.freq == freq &&
        other.until == until &&
        other.count == count &&
        other.interval == interval &&
        eq(other.bySecond, bySecond) &&
        eq(other.byMinute, byMinute) &&
        eq(other.byHour, byHour) &&
        eq(other.byDay, byDay) &&
        eq(other.byMonthDay, byMonthDay) &&
        eq(other.byYearDay, byYearDay) &&
        eq(other.byWeekNo, byWeekNo) &&
        eq(other.byMonth, byMonth) &&
        eq(other.bySetPos, bySetPos) &&
        other.wkst == wkst;
  }

  @override
  int get hashCode => Object.hash(
    freq,
    until,
    count,
    interval,
    bySecond == null ? null : Object.hashAll(bySecond!),
    byMinute == null ? null : Object.hashAll(byMinute!),
    byHour == null ? null : Object.hashAll(byHour!),
    byDay == null ? null : Object.hashAll(byDay!),
    byMonthDay == null ? null : Object.hashAll(byMonthDay!),
    byYearDay == null ? null : Object.hashAll(byYearDay!),
    byWeekNo == null ? null : Object.hashAll(byWeekNo!),
    byMonth == null ? null : Object.hashAll(byMonth!),
    bySetPos == null ? null : Object.hashAll(bySetPos!),
    wkst,
  );

  @override
  String toString() {
    final parts = <String>[];
    parts.add('FREQ=${freq.toName()}');
    if (until != null) {
      parts.add('UNTIL=${until.toString()}');
    }
    if (count != null) {
      parts.add('COUNT=$count');
    }
    if (interval != 1) {
      parts.add('INTERVAL=$interval');
    }
    if (bySecond != null) {
      parts.add('BYSECOND=${bySecond!.join(',')}');
    }
    if (byMinute != null) {
      parts.add('BYMINUTE=${byMinute!.join(',')}');
    }
    if (byHour != null) {
      parts.add('BYHOUR=${byHour!.join(',')}');
    }
    if (byDay != null) {
      final byDayStr = byDay!.map((d) => d.toString()).join(',');
      parts.add('BYDAY=$byDayStr');
    }
    if (byMonthDay != null) {
      parts.add('BYMONTHDAY=${byMonthDay!.join(',')}');
    }
    if (byYearDay != null) {
      parts.add('BYYEARDAY=${byYearDay!.join(',')}');
    }
    if (byWeekNo != null) {
      parts.add('BYWEEKNO=${byWeekNo!.join(',')}');
    }
    if (byMonth != null) {
      parts.add('BYMONTH=${byMonth!.join(',')}');
    }
    if (bySetPos != null) {
      parts.add('BYSETPOS=${bySetPos!.join(',')}');
    }
    if (wkst != null) {
      parts.add('WKST=${wkst!.toName()}');
    }
    return parts.join(';');
  }
}

/// Sign for UtcOffset and CalDuration.
enum Sign { positive, negative }

/// TRIGGER can be a DURATION or a UTC DATE-TIME.
class Trigger {
  /// The duration value, if specified.
  final CalDuration? duration;

  /// The date-time value, if specified.
  final CalDateTime? dateTime;

  /// The RELATED parameter as enum value, if explicitly set.
  final TriggerRelated? related;

  /// The RELATED parameter as raw string, if explicitly set.
  final String? relatedName;

  /// Creates a Trigger with a DURATION.
  const Trigger.duration(
    CalDuration this.duration, {
    this.related,
    this.relatedName,
  }) : dateTime = null;

  /// Creates a Trigger with a UTC DATE-TIME.
  Trigger.dateTime(CalDateTime this.dateTime, {this.related, this.relatedName})
    : duration = null,
      assert(dateTime.isDateTime, 'time part must be present'),
      assert(dateTime.time!.isUtc);

  /// True if this trigger is a DURATION.
  bool get isDuration => duration != null;

  /// True if this trigger is a DATE-TIME.
  bool get isDateTime => dateTime != null;

  @override
  operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Trigger &&
        other.duration == duration &&
        other.dateTime == dateTime &&
        other.related == related &&
        other.relatedName == relatedName;
  }

  @override
  int get hashCode {
    return Object.hash(duration, dateTime, related, relatedName);
  }

  @override
  String toString() {
    if (isDuration) return duration.toString();
    if (isDateTime) return dateTime.toString();
    throw StateError('Invalid Trigger state');
  }
}

/// Represents a UTC offset like +hhmm or -hhmmss.
class UtcOffset {
  /// The sign of the offset, positive or negative.
  final Sign sign;

  /// The hours component of the offset (0..23).
  final int hours;

  /// The minutes component of the offset (0..59).
  final int minutes;

  /// The seconds component of the offset (0..59).
  final int seconds;

  /// Creates a new UTC offset with the given sign, hours, minutes, and optional seconds.
  const UtcOffset({
    required this.sign,
    required this.hours,
    required this.minutes,
    this.seconds = 0,
  }) : assert(hours >= 0 && hours <= 23, 'hours must be 0..23'),
       assert(minutes >= 0 && minutes <= 59, 'minutes must be 0..59'),
       assert(seconds >= 0 && seconds <= 59, 'seconds must be 0..59');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UtcOffset &&
        other.sign == sign &&
        other.hours == hours &&
        other.minutes == minutes &&
        other.seconds == seconds;
  }

  @override
  int get hashCode {
    return Object.hash(sign, hours, minutes, seconds);
  }

  @override
  String toString() {
    final signStr = sign == Sign.negative ? '-' : '+';
    final hoursStr = hours.toString().padLeft(2, '0');
    final minutesStr = minutes.toString().padLeft(2, '0');
    final secondsStr = seconds.toString().padLeft(2, '0');
    return '$signStr$hoursStr$minutesStr${seconds != 0 ? secondsStr : ''}';
  }
}
