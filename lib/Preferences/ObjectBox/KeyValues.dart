import 'dart:convert';
import 'package:objectbox/objectbox.dart';

@Entity()
class KeyValue {
  @Id()
  int id = 0;

  @Unique()
  late String key;

  String? stringValue;
  int? intValue;
  double? doubleValue;
  bool? boolValue;
  String? dateTimeValue;

  // Persist lists as JSON strings to ensure portability in ObjectBox Dart
  @Transient()
  List<String>? stringListValue;
  String? stringListValueJson;

  @Transient()
  List<int>? intListValue;
  String? intListValueJson;

  @Transient()
  List<bool>? boolListValue;
  String? boolListValueJson;

  // Persist maps as JSON string
  String? serializedMapValue;
}

extension KeyValueX on KeyValue {
  set value(dynamic value) {
    if (value is String) {
      stringValue = value;
      intValue = null;
      doubleValue = null;
      boolValue = null;
      dateTimeValue = null;
      stringListValue = null;
      intListValue = null;
      boolListValue = null;
      stringListValueJson = null;
      intListValueJson = null;
      boolListValueJson = null;
      serializedMapValue = null;
    } else if (value is int) {
      intValue = value;
      stringValue = null;
      doubleValue = null;
      boolValue = null;
      dateTimeValue = null;
      stringListValue = null;
      intListValue = null;
      boolListValue = null;
      stringListValueJson = null;
      intListValueJson = null;
      boolListValueJson = null;
      serializedMapValue = null;
    } else if (value is double) {
      doubleValue = value;
      stringValue = null;
      intValue = null;
      boolValue = null;
      dateTimeValue = null;
      stringListValue = null;
      intListValue = null;
      boolListValue = null;
      stringListValueJson = null;
      intListValueJson = null;
      boolListValueJson = null;
      serializedMapValue = null;
    } else if (value is bool) {
      boolValue = value;
      stringValue = null;
      intValue = null;
      doubleValue = null;
      dateTimeValue = null;
      stringListValue = null;
      intListValue = null;
      boolListValue = null;
      stringListValueJson = null;
      intListValueJson = null;
      boolListValueJson = null;
      serializedMapValue = null;
    } else if (value is DateTime) {
      dateTimeValue = value.toIso8601String();
      stringValue = null;
      intValue = null;
      doubleValue = null;
      boolValue = null;
      stringListValue = null;
      intListValue = null;
      boolListValue = null;
      stringListValueJson = null;
      intListValueJson = null;
      boolListValueJson = null;
      serializedMapValue = null;
    } else if (value is List<String>) {
      stringListValue = value;
      stringListValueJson = jsonEncode(value);
      intListValue = null;
      boolListValue = null;
      intListValueJson = null;
      boolListValueJson = null;
      stringValue = null;
      intValue = null;
      doubleValue = null;
      boolValue = null;
      dateTimeValue = null;
      serializedMapValue = null;
    } else if (value is List<int>) {
      intListValue = value;
      intListValueJson = jsonEncode(value);
      stringListValue = null;
      boolListValue = null;
      stringListValueJson = null;
      boolListValueJson = null;
      stringValue = null;
      intValue = null;
      doubleValue = null;
      boolValue = null;
      dateTimeValue = null;
      serializedMapValue = null;
    } else if (value is List<bool>) {
      boolListValue = value;
      boolListValueJson = jsonEncode(value);
      stringListValue = null;
      intListValue = null;
      stringListValueJson = null;
      intListValueJson = null;
      stringValue = null;
      intValue = null;
      doubleValue = null;
      boolValue = null;
      dateTimeValue = null;
      serializedMapValue = null;
    } else if (value is Map<dynamic, dynamic>) {
      serializedMapValue = jsonEncode(value);
      stringListValue = null;
      intListValue = null;
      boolListValue = null;
      stringListValueJson = null;
      intListValueJson = null;
      boolListValueJson = null;
      stringValue = null;
      intValue = null;
      doubleValue = null;
      boolValue = null;
      dateTimeValue = null;
    } else {
      throw UnsupportedError('${value.runtimeType} is not supported');
    }
  }

  dynamic get value {
    if (stringValue != null) return stringValue;
    if (intValue != null) return intValue;
    if (doubleValue != null) return doubleValue;
    if (boolValue != null) return boolValue;

    if (stringListValue != null) return stringListValue;
    if (intListValue != null) return intListValue;
    if (boolListValue != null) return boolListValue;

    if (stringListValueJson != null) {
      return (jsonDecode(stringListValueJson!) as List)
          .map((e) => e as String)
          .toList();
    }
    if (intListValueJson != null) {
      return (jsonDecode(intListValueJson!) as List)
          .map((e) => (e as num).toInt())
          .toList();
    }
    if (boolListValueJson != null) {
      return (jsonDecode(boolListValueJson!) as List)
          .map((e) => e as bool)
          .toList();
    }

    if (dateTimeValue != null) return DateTime.parse(dateTimeValue!);
    if (serializedMapValue != null) return jsonDecode(serializedMapValue!);
    return null;
  }
}
