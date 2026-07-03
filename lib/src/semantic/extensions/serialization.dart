import '../../document/document.dart';
import '../calendar.dart';

/// Serialization helpers for semantic components.
extension CalendarComponentSerialization on CalendarComponent {
  /// Serializes this semantic component into iCalendar text.
  ///
  /// For components parsed from source, this uses the original raw property
  /// strings retained by the parser. For programmatically created components,
  /// the output reflects the provided [PropertyValue.property] metadata.
  ///
  /// Output includes `BEGIN:<NAME>` and `END:<NAME>` wrapper lines, nested
  /// components, CRLF line endings, and optional RFC 5545 line folding.
  String toIcsString({bool foldLines = true}) {
    final documentComponent = _toDocumentComponent(this);
    return serializeCalendarDocumentComponent(
      documentComponent,
      foldLines: foldLines,
    );
  }
}

CalendarDocumentComponent _toDocumentComponent(CalendarComponent component) {
  return CalendarDocumentComponent(
    name: component.name,
    properties: _orderedProperties(component.properties),
    components: component.components
        .map(_toDocumentComponent)
        .toList(growable: false),
  );
}

List<CalendarProperty> _orderedProperties(
  Map<String, List<PropertyValue>> properties,
) {
  final indexed = <({int index, CalendarProperty property})>[];
  var index = 0;
  for (final entry in properties.entries) {
    for (final value in entry.value) {
      indexed.add((index: index++, property: value.property));
    }
  }

  indexed.sort((a, b) {
    final aHasLine = a.property.lineNumber > 0;
    final bHasLine = b.property.lineNumber > 0;

    if (aHasLine && bHasLine) {
      final lineCompare = a.property.lineNumber.compareTo(
        b.property.lineNumber,
      );
      if (lineCompare != 0) return lineCompare;
    } else if (aHasLine != bHasLine) {
      return aHasLine ? -1 : 1;
    }

    return a.index.compareTo(b.index);
  });

  return indexed.map((e) => e.property).toList(growable: false);
}
