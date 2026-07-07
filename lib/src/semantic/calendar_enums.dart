/// Alarm action types.
enum AlarmAction { audio, display, email, procedure }

/// Names for [AlarmAction] enum values
class AlarmActionNames {
  /// Private constructor to prevent instantiation.
  AlarmActionNames._();

  /// The name for the audio action.
  static const audio = 'AUDIO';

  /// The name for the display action.
  static const display = 'DISPLAY';

  /// The name for the email action.
  static const email = 'EMAIL';

  /// The name for the procedure action.
  static const procedure = 'PROCEDURE';

  /// Tries to parse the given string into an AlarmAction enum value.
  static AlarmAction? tryParse(String s) {
    switch (s.toUpperCase()) {
      case audio:
        return AlarmAction.audio;
      case display:
        return AlarmAction.display;
      case email:
        return AlarmAction.email;
      case procedure:
        return AlarmAction.procedure;
      default:
        return null;
    }
  }
}

/// Extensions for [AlarmAction] enum.
extension AlarmActionExtensions on AlarmAction {
  /// Converts the enum value to its corresponding string name.
  String toName() => switch (this) {
    AlarmAction.audio => AlarmActionNames.audio,
    AlarmAction.display => AlarmActionNames.display,
    AlarmAction.email => AlarmActionNames.email,
    AlarmAction.procedure => AlarmActionNames.procedure,
  };
}

/// Calendar user types.
enum CalendarUserType { individual, group, resource, room, unknown }

/// Names for [CalendarUserType] enum values
class CalendarUserTypeNames {
  /// The private constructor to prevent instantiation.
  CalendarUserTypeNames._();

  /// The name for the individual user type.
  static const individual = 'INDIVIDUAL';

  /// The name for the group user type.
  static const group = 'GROUP';

  /// The name for the resource user type.
  static const resource = 'RESOURCE';

  /// The name for the room user type.
  static const room = 'ROOM';

  /// The name for the unknown user type.
  static const unknown = 'UNKNOWN';

  /// Tries to parse the given string into a CalendarUserType enum value.
  static CalendarUserType? tryParse(String s) {
    switch (s.toUpperCase()) {
      case individual:
        return CalendarUserType.individual;
      case group:
        return CalendarUserType.group;
      case resource:
        return CalendarUserType.resource;
      case room:
        return CalendarUserType.room;
      case unknown:
        return CalendarUserType.unknown;
      default:
        return null;
    }
  }
}

/// Extensions for [CalendarUserType] enum.
extension CalendarUserTypeExtensions on CalendarUserType {
  /// Converts the enum value to its corresponding string name.
  String toName() => switch (this) {
    CalendarUserType.individual => CalendarUserTypeNames.individual,
    CalendarUserType.group => CalendarUserTypeNames.group,
    CalendarUserType.resource => CalendarUserTypeNames.resource,
    CalendarUserType.room => CalendarUserTypeNames.room,
    CalendarUserType.unknown => CalendarUserTypeNames.unknown,
  };
}

/// Classification types.
enum Classification { public, private, confidential }

/// Names for [Classification] enum values
class ClassificationNames {
  /// The private constructor to prevent instantiation.
  ClassificationNames._();

  /// The name for the public classification.
  static const public = 'PUBLIC';

  /// The name for the private classification.
  static const private = 'PRIVATE';

  /// The name for the confidential classification.
  static const confidential = 'CONFIDENTIAL';

  /// Tries to parse the given string into a Classification enum value.
  static Classification? tryParse(String s) {
    switch (s.toUpperCase()) {
      case public:
        return Classification.public;
      case private:
        return Classification.private;
      case confidential:
        return Classification.confidential;
      default:
        return null;
    }
  }
}

/// Extensions for [Classification] enum.
extension ClassificationExtensions on Classification {
  /// Converts the enum value to its corresponding string name.
  String toName() => switch (this) {
    Classification.public => ClassificationNames.public,
    Classification.private => ClassificationNames.private,
    Classification.confidential => ClassificationNames.confidential,
  };
}

/// Event status types.
enum EventStatus { tentative, confirmed, cancelled }

/// Names for [EventStatus] enum values
class EventStatusNames {
  /// The private constructor to prevent instantiation.
  EventStatusNames._();

  /// The name for the tentative status.
  static const tentative = 'TENTATIVE';

  /// The name for the confirmed status.
  static const confirmed = 'CONFIRMED';

  /// The name for the cancelled status.
  static const cancelled = 'CANCELLED';

  /// Tries to parse the given string into an EventStatus enum value.
  static EventStatus? tryParse(String s) {
    switch (s.toUpperCase()) {
      case tentative:
        return EventStatus.tentative;
      case confirmed:
        return EventStatus.confirmed;
      case cancelled:
        return EventStatus.cancelled;
      default:
        return null;
    }
  }
}

/// Extensions for [EventStatus] enum.
extension EventStatusExtensions on EventStatus {
  /// Converts the enum value to its corresponding string name.
  String toName() => switch (this) {
    EventStatus.tentative => EventStatusNames.tentative,
    EventStatus.confirmed => EventStatusNames.confirmed,
    EventStatus.cancelled => EventStatusNames.cancelled,
  };
}

/// Free/busy types.
enum FreeBusyType { free, busy, busyUnavailable, busyTentative }

/// Names for [FreeBusyType] enum values
class FreeBusyTypeNames {
  /// Private constructor to prevent instantiation.
  FreeBusyTypeNames._();

  /// The name for the free type.
  static const free = 'FREE';

  /// The name for the busy type.
  static const busy = 'BUSY';

  /// The name for the busy-unavailable type.
  static const busyUnavailable = 'BUSY-UNAVAILABLE';

  /// The name for the busy-tentative type.
  static const busyTentative = 'BUSY-TENTATIVE';

  /// Tries to parse the given string into a FreeBusyType enum value.
  static FreeBusyType? tryParse(String s) {
    switch (s.toUpperCase()) {
      case free:
        return FreeBusyType.free;
      case busy:
        return FreeBusyType.busy;
      case busyUnavailable:
        return FreeBusyType.busyUnavailable;
      case busyTentative:
        return FreeBusyType.busyTentative;
      default:
        return null;
    }
  }
}

/// Extensions for [FreeBusyType] enum.
extension FreeBusyTypeExtensions on FreeBusyType {
  /// Converts the enum value to its corresponding string name.
  String toName() => switch (this) {
    FreeBusyType.free => FreeBusyTypeNames.free,
    FreeBusyType.busy => FreeBusyTypeNames.busy,
    FreeBusyType.busyUnavailable => FreeBusyTypeNames.busyUnavailable,
    FreeBusyType.busyTentative => FreeBusyTypeNames.busyTentative,
  };
}

/// Journal status types.
enum JournalStatus { draft, final_, amended }

/// Names for [JournalStatus] enum values
class JournalStatusNames {
  /// The private constructor to prevent instantiation.
  JournalStatusNames._();

  /// The name for the draft status.
  static const draft = 'DRAFT';

  /// The name for the final status.
  static const final_ = 'FINAL';

  /// The name for the amended status.
  static const amended = 'AMENDED';

  /// Tries to parse the given string into a JournalStatus enum value.
  static JournalStatus? tryParse(String s) {
    switch (s.toUpperCase()) {
      case draft:
        return JournalStatus.draft;
      case final_:
        return JournalStatus.final_;
      case amended:
        return JournalStatus.amended;
      default:
        return null;
    }
  }
}

/// Extensions for [JournalStatus] enum.
extension JournalStatusExtensions on JournalStatus {
  /// Converts the enum value to its corresponding string name.
  String toName() => switch (this) {
    JournalStatus.draft => JournalStatusNames.draft,
    JournalStatus.final_ => JournalStatusNames.final_,
    JournalStatus.amended => JournalStatusNames.amended,
  };
}

/// Participation status types.
enum ParticipationStatus {
  needsAction,
  accepted,
  declined,
  tentative,
  delegated,
  completed,
  inProcess,
}

/// Names for [ParticipationStatus] enum values
class ParticipationStatusNames {
  /// The private constructor to prevent instantiation.
  ParticipationStatusNames._();

  /// The name for the needs-action status.
  static const needsAction = 'NEEDS-ACTION';

  /// The name for the accepted status.
  static const accepted = 'ACCEPTED';

  /// The name for the declined status.
  static const declined = 'DECLINED';

  /// The name for the tentative status.
  static const tentative = 'TENTATIVE';

  /// The name for the delegated status.
  static const delegated = 'DELEGATED';

  /// The name for the completed status.
  static const completed = 'COMPLETED';

  /// The name for the in-process status.
  static const inProcess = 'IN-PROCESS';

  /// Tries to parse the given string into a ParticipationStatus enum value.
  static ParticipationStatus? tryParse(String s) {
    switch (s.toUpperCase()) {
      case needsAction:
        return ParticipationStatus.needsAction;
      case accepted:
        return ParticipationStatus.accepted;
      case declined:
        return ParticipationStatus.declined;
      case tentative:
        return ParticipationStatus.tentative;
      case delegated:
        return ParticipationStatus.delegated;
      case completed:
        return ParticipationStatus.completed;
      case inProcess:
        return ParticipationStatus.inProcess;
      default:
        return null;
    }
  }
}

/// Extensions for [ParticipationStatus] enum.
extension ParticipationStatusExtensions on ParticipationStatus {
  /// Converts the enum value to its corresponding string name.
  String toName() => switch (this) {
    ParticipationStatus.needsAction => ParticipationStatusNames.needsAction,
    ParticipationStatus.accepted => ParticipationStatusNames.accepted,
    ParticipationStatus.declined => ParticipationStatusNames.declined,
    ParticipationStatus.tentative => ParticipationStatusNames.tentative,
    ParticipationStatus.delegated => ParticipationStatusNames.delegated,
    ParticipationStatus.completed => ParticipationStatusNames.completed,
    ParticipationStatus.inProcess => ParticipationStatusNames.inProcess,
  };
}

/// Participation role types.
enum ParticipationRole { chair, reqParticipant, optParticipant, nonParticipant }

/// Names for [ParticipationRole] enum values
class ParticipationRoleNames {
  /// The private constructor to prevent instantiation.
  ParticipationRoleNames._();

  /// The name for the chair role.
  static const chair = 'CHAIR';

  /// The name for the required participant role.
  static const reqParticipant = 'REQ-PARTICIPANT';

  /// The name for the optional participant role.
  static const optParticipant = 'OPT-PARTICIPANT';

  /// The name for the non-participant role.
  static const nonParticipant = 'NON-PARTICIPANT';

  /// Tries to parse the given string into a ParticipationRole enum value.
  static ParticipationRole? tryParse(String s) {
    switch (s.toUpperCase()) {
      case chair:
        return ParticipationRole.chair;
      case reqParticipant:
        return ParticipationRole.reqParticipant;
      case optParticipant:
        return ParticipationRole.optParticipant;
      case nonParticipant:
        return ParticipationRole.nonParticipant;
      default:
        return null;
    }
  }
}

/// Extensions for [ParticipationRole] enum.
extension ParticipationRoleExtensions on ParticipationRole {
  /// Converts the enum value to its corresponding string name.
  String toName() => switch (this) {
    ParticipationRole.chair => ParticipationRoleNames.chair,
    ParticipationRole.reqParticipant => ParticipationRoleNames.reqParticipant,
    ParticipationRole.optParticipant => ParticipationRoleNames.optParticipant,
    ParticipationRole.nonParticipant => ParticipationRoleNames.nonParticipant,
  };
}

/// Recurrence frequencies.
enum RecurrenceFrequency {
  secondly,
  minutely,
  hourly,
  daily,
  weekly,
  monthly,
  yearly,
}

/// Names for [RecurrenceFrequency] enum values
class RecurrenceFrequencyNames {
  /// The private constructor to prevent instantiation.
  RecurrenceFrequencyNames._();

  /// The name for the secondly frequency.
  static const secondly = 'SECONDLY';

  /// The name for the minutely frequency.
  static const minutely = 'MINUTELY';

  /// The name for the hourly frequency.
  static const hourly = 'HOURLY';

  /// The name for the daily frequency.
  static const daily = 'DAILY';

  /// The name for the weekly frequency.
  static const weekly = 'WEEKLY';

  /// The name for the monthly frequency.
  static const monthly = 'MONTHLY';

  /// The name for the yearly frequency.
  static const yearly = 'YEARLY';

  /// Tries to parse the given string into a RecurrenceFrequency enum value.
  static RecurrenceFrequency? tryParse(String s) {
    switch (s.toUpperCase()) {
      case secondly:
        return RecurrenceFrequency.secondly;
      case minutely:
        return RecurrenceFrequency.minutely;
      case hourly:
        return RecurrenceFrequency.hourly;
      case daily:
        return RecurrenceFrequency.daily;
      case weekly:
        return RecurrenceFrequency.weekly;
      case monthly:
        return RecurrenceFrequency.monthly;
      case yearly:
        return RecurrenceFrequency.yearly;
      default:
        return null;
    }
  }
}

/// Extensions for [RecurrenceFrequency] enum.
extension RecurrenceFrequencyExtensions on RecurrenceFrequency {
  /// Converts the enum value to its corresponding string name.
  String toName() => switch (this) {
    RecurrenceFrequency.secondly => RecurrenceFrequencyNames.secondly,
    RecurrenceFrequency.minutely => RecurrenceFrequencyNames.minutely,
    RecurrenceFrequency.hourly => RecurrenceFrequencyNames.hourly,
    RecurrenceFrequency.daily => RecurrenceFrequencyNames.daily,
    RecurrenceFrequency.weekly => RecurrenceFrequencyNames.weekly,
    RecurrenceFrequency.monthly => RecurrenceFrequencyNames.monthly,
    RecurrenceFrequency.yearly => RecurrenceFrequencyNames.yearly,
  };
}

/// Relationship types.
enum RelationshipType { child, parent, sibling }

/// Names for [RelationshipType] enum values
class RelationshipTypeNames {
  /// The private constructor to prevent instantiation.
  RelationshipTypeNames._();

  /// The name for the child relationship type.
  static const child = 'CHILD';

  /// The name for the parent relationship type.
  static const parent = 'PARENT';

  /// The name for the sibling relationship type.
  static const sibling = 'SIBLING';

  /// Tries to parse the given string into a RelationshipType enum value.
  static RelationshipType? tryParse(String s) {
    switch (s.toUpperCase()) {
      case child:
        return RelationshipType.child;
      case parent:
        return RelationshipType.parent;
      case sibling:
        return RelationshipType.sibling;
      default:
        return null;
    }
  }
}

/// Extensions for [RelationshipType] enum.
extension RelationshipTypeExtensions on RelationshipType {
  /// Converts the enum value to its corresponding string name.
  String toName() => switch (this) {
    RelationshipType.child => RelationshipTypeNames.child,
    RelationshipType.parent => RelationshipTypeNames.parent,
    RelationshipType.sibling => RelationshipTypeNames.sibling,
  };
}

/// Time transparency types.
enum TimeTransparency { opaque, transparent }

/// Names for [TimeTransparency] enum values
class TimeTransparencyNames {
  /// The private constructor to prevent instantiation.
  TimeTransparencyNames._();

  /// The name for the opaque transparency.
  static const opaque = 'OPAQUE';

  /// The name for the transparent transparency.
  static const transparent = 'TRANSPARENT';

  /// Tries to parse the given string into a TimeTransparency enum value.
  static TimeTransparency? tryParse(String s) {
    switch (s.toUpperCase()) {
      case opaque:
        return TimeTransparency.opaque;
      case transparent:
        return TimeTransparency.transparent;
      default:
        return null;
    }
  }
}

/// Extensions for [TimeTransparency] enum.
extension TimeTransparencyExtensions on TimeTransparency {
  /// Converts the enum value to its corresponding string name.
  String toName() => switch (this) {
    TimeTransparency.opaque => TimeTransparencyNames.opaque,
    TimeTransparency.transparent => TimeTransparencyNames.transparent,
  };
}

/// To-do status types.
enum TodoStatus { needsAction, completed, inProcess, cancelled }

/// Names for [TodoStatus] enum values
class TodoStatusNames {
  /// The private constructor to prevent instantiation.
  TodoStatusNames._();

  /// The name for the needs-action status.
  static const needsAction = 'NEEDS-ACTION';

  /// The name for the completed status.
  static const completed = 'COMPLETED';

  /// The name for the in-process status.
  static const inProcess = 'IN-PROCESS';

  /// The name for the cancelled status.
  static const cancelled = 'CANCELLED';

  /// Tries to parse the given string into a TodoStatus enum value.
  static TodoStatus? tryParse(String s) {
    switch (s.toUpperCase()) {
      case needsAction:
        return TodoStatus.needsAction;
      case completed:
        return TodoStatus.completed;
      case inProcess:
        return TodoStatus.inProcess;
      case cancelled:
        return TodoStatus.cancelled;
      default:
        return null;
    }
  }
}

/// Extensions for [TodoStatus] enum.
extension TodoStatusExtensions on TodoStatus {
  /// Converts the enum value to its corresponding string name.
  String toName() => switch (this) {
    TodoStatus.needsAction => TodoStatusNames.needsAction,
    TodoStatus.completed => TodoStatusNames.completed,
    TodoStatus.inProcess => TodoStatusNames.inProcess,
    TodoStatus.cancelled => TodoStatusNames.cancelled,
  };
}

/// Trigger relation types.
enum TriggerRelated { start, end }

/// Names for [TriggerRelated] enum values
class TriggerRelatedNames {
  /// The private constructor to prevent instantiation.
  TriggerRelatedNames._();

  /// The name for trigger relation to START.
  static const start = 'START';

  /// The name for trigger relation to END.
  static const end = 'END';

  /// Tries to parse the given string into a TriggerRelated enum value.
  static TriggerRelated? tryParse(String s) {
    switch (s.toUpperCase()) {
      case start:
        return TriggerRelated.start;
      case end:
        return TriggerRelated.end;
      default:
        return null;
    }
  }
}

/// Extensions for [TriggerRelated] enum.
extension TriggerRelatedExtensions on TriggerRelated {
  /// Converts the enum value to its corresponding string name.
  String toName() => switch (this) {
    TriggerRelated.start => TriggerRelatedNames.start,
    TriggerRelated.end => TriggerRelatedNames.end,
  };
}

/// Value types.
enum ValueType {
  binary,
  boolean,
  calAddress,
  date,
  dateTime,
  duration,
  float,
  integer,
  period,
  recur,
  text,
  time,
  uri,
  utcOffset,
}

/// Names for [ValueType] enum values
class ValueTypeNames {
  /// The private constructor to prevent instantiation.
  ValueTypeNames._();

  /// The name for the binary value type.
  static const binary = 'BINARY';

  /// The name for the boolean value type.
  static const boolean = 'BOOLEAN';

  /// The name for the calendar address value type.
  static const calAddress = 'CAL-ADDRESS';

  /// The name for the date value type.
  static const date = 'DATE';

  /// The name for the date-time value type.
  static const dateTime = 'DATE-TIME';

  /// The name for the duration value type.
  static const duration = 'DURATION';

  /// The name for the float value type.
  static const float = 'FLOAT';

  /// The name for the integer value type.
  static const integer = 'INTEGER';

  /// The name for the period value type.
  static const period = 'PERIOD';

  /// The name for the recurrence value type.
  static const recur = 'RECUR';

  /// The name for the text value type.
  static const text = 'TEXT';

  /// The name for the time value type.
  static const time = 'TIME';

  /// The name for the URI value type.
  static const uri = 'URI';

  /// The name for the UTC offset value type.
  static const utcOffset = 'UTC-OFFSET';

  /// Tries to parse the given string into a ValueType enum value.
  static ValueType? tryParse(String s) {
    switch (s.toUpperCase()) {
      case binary:
        return ValueType.binary;
      case boolean:
        return ValueType.boolean;
      case calAddress:
        return ValueType.calAddress;
      case date:
        return ValueType.date;
      case dateTime:
        return ValueType.dateTime;
      case duration:
        return ValueType.duration;
      case float:
        return ValueType.float;
      case integer:
        return ValueType.integer;
      case period:
        return ValueType.period;
      case recur:
        return ValueType.recur;
      case text:
        return ValueType.text;
      case time:
        return ValueType.time;
      case uri:
        return ValueType.uri;
      case utcOffset:
        return ValueType.utcOffset;
      default:
        return null;
    }
  }
}

/// Extensions for [ValueType] enum.
extension ValueTypeExtensions on ValueType {
  /// Converts the enum value to its corresponding string name.
  String toName() => switch (this) {
    ValueType.binary => ValueTypeNames.binary,
    ValueType.boolean => ValueTypeNames.boolean,
    ValueType.calAddress => ValueTypeNames.calAddress,
    ValueType.date => ValueTypeNames.date,
    ValueType.dateTime => ValueTypeNames.dateTime,
    ValueType.duration => ValueTypeNames.duration,
    ValueType.float => ValueTypeNames.float,
    ValueType.integer => ValueTypeNames.integer,
    ValueType.period => ValueTypeNames.period,
    ValueType.recur => ValueTypeNames.recur,
    ValueType.text => ValueTypeNames.text,
    ValueType.time => ValueTypeNames.time,
    ValueType.uri => ValueTypeNames.uri,
    ValueType.utcOffset => ValueTypeNames.utcOffset,
  };
}

/// Days of the week.
enum Weekday { su, mo, tu, we, th, fr, sa }

/// Names for [Weekday] enum values
class WeekdayNames {
  /// The private constructor to prevent instantiation.
  WeekdayNames._();

  /// The name for Sunday.
  static const su = 'SU';

  /// The name for Monday.
  static const mo = 'MO';

  /// The name for Tuesday.
  static const tu = 'TU';

  /// The name for Wednesday.
  static const we = 'WE';

  /// The name for Thursday.
  static const th = 'TH';

  /// The name for Friday.
  static const fr = 'FR';

  /// The name for Saturday.
  static const sa = 'SA';

  /// Tries to parse the given string into a Weekday enum value.
  static Weekday? tryParse(String s) {
    switch (s.toUpperCase()) {
      case su:
        return Weekday.su;
      case mo:
        return Weekday.mo;
      case tu:
        return Weekday.tu;
      case we:
        return Weekday.we;
      case th:
        return Weekday.th;
      case fr:
        return Weekday.fr;
      case sa:
        return Weekday.sa;
      default:
        return null;
    }
  }
}

/// Extensions for [Weekday] enum.
extension WeekdayExtensions on Weekday {
  /// Converts the enum value to its corresponding string name.
  String toName() => switch (this) {
    Weekday.mo => WeekdayNames.mo,
    Weekday.tu => WeekdayNames.tu,
    Weekday.we => WeekdayNames.we,
    Weekday.th => WeekdayNames.th,
    Weekday.fr => WeekdayNames.fr,
    Weekday.sa => WeekdayNames.sa,
    Weekday.su => WeekdayNames.su,
  };
}
