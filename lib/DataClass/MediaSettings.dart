import 'package:json_annotation/json_annotation.dart';

part 'media_settings.g.dart';

/// MediaSettings holds user preferences for a Media item
@JsonSerializable(explicitToJson: true)
class MediaSettings {
  String? key;

  bool isFavorite;
  bool notifyOnUpdate;
  int? userScore;
  int? userProgress;
  bool isListPrivate;
  int userRepeat;
  String? notes;

  MediaSettings({
    this.key,
    this.isFavorite = false,
    this.notifyOnUpdate = false,
    this.userScore,
    this.userProgress,
    this.isListPrivate = false,
    this.userRepeat = 0,
    this.notes,
  });

  /// JSON deserialization
  factory MediaSettings.fromJson(Map<String, dynamic> json) =>
      _$MediaSettingsFromJson(json);

  /// JSON serialization
  Map<String, dynamic> toJson() => _$MediaSettingsToJson(this);
}
