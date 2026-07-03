import 'dart:convert';

import 'calendar_document.dart';

/// Serializes a raw [CalendarDocumentComponent] (or [CalendarDocument]) to iCalendar text.
///
/// Output always uses CRLF (`\r\n`) line endings. When [foldLines] is true,
/// content lines are folded to RFC 5545's 75-octet limit.
String serializeCalendarDocumentComponent(
  CalendarDocumentComponent component, {
  bool foldLines = true,
}) {
  final buffer = StringBuffer();
  _writeComponent(buffer, component, foldLines: foldLines);
  return buffer.toString();
}

/// Serializes a [CalendarProperty] into a single iCalendar content line.
String serializeCalendarProperty(
  CalendarProperty property, {
  bool foldLine = true,
}) {
  final line = property.toString();
  if (!foldLine) return line;
  return _foldContentLine(line);
}

/// Serialization extensions for document-layer components and properties.
extension CalendarDocumentSerialization on CalendarDocumentComponent {
  /// Serializes this component into iCalendar text.
  ///
  /// Output includes `BEGIN:<NAME>` and `END:<NAME>` wrapper lines, nested
  /// components, CRLF line endings, and optional RFC 5545 line folding.
  String toICalendarString({bool foldLines = true}) {
    return serializeCalendarDocumentComponent(this, foldLines: foldLines);
  }
}

extension CalendarPropertySerialization on CalendarProperty {
  /// Serializes this property into an iCalendar content line.
  String toICalendarString({bool foldLine = true}) {
    return serializeCalendarProperty(this, foldLine: foldLine);
  }
}

void _writeComponent(
  StringBuffer buffer,
  CalendarDocumentComponent component, {
  required bool foldLines,
}) {
  _writeLine(buffer, 'BEGIN:${component.name}');

  for (final property in component.properties) {
    _writeLine(
      buffer,
      serializeCalendarProperty(property, foldLine: foldLines),
      alreadyFolded: foldLines,
    );
  }

  for (final child in component.components) {
    _writeComponent(buffer, child, foldLines: foldLines);
  }

  _writeLine(buffer, 'END:${component.name}');
}

void _writeLine(
  StringBuffer buffer,
  String line, {
  bool alreadyFolded = false,
}) {
  if (alreadyFolded) {
    buffer.write(line);
    buffer.write('\r\n');
    return;
  }

  buffer.write(line);
  buffer.write('\r\n');
}

String _foldContentLine(String line) {
  if (utf8.encode(line).length <= 75) return line;

  final out = StringBuffer();
  var currentLineOctets = 0;

  for (final rune in line.runes) {
    final char = String.fromCharCode(rune);
    final charOctets = utf8.encode(char).length;

    if (currentLineOctets + charOctets > 75) {
      out.write('\r\n ');
      currentLineOctets = 1; // continuation whitespace
    }

    out.write(char);
    currentLineOctets += charOctets;
  }

  return out.toString();
}
