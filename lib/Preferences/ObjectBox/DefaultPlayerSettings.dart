import 'package:objectbox/objectbox.dart';

@Entity()
class PlayerSettings {
  @Id()
  int id = 0;

  String speed;
  int resizeMode;
  bool useCustomMpvConfig;

  // subtitlesSettings
  bool showSubtitle;
  String subtitleLanguage;
  int subtitleSize;
  int subtitleColor;
  String subtitleFont;
  int subtitleBackgroundColor;
  int subtitleOutlineColor;
  int subtitleBottomPadding;
  int skipDuration;
  int subtitleWeight;

  PlayerSettings({
    this.id = 0,
    this.speed = '1x',
    this.resizeMode = 0,
    this.useCustomMpvConfig = false,
    this.subtitleLanguage = 'en',
    this.subtitleSize = 32,
    this.subtitleColor = 0xFFFFFFFF,
    this.subtitleFont = 'Poppins',
    this.subtitleBackgroundColor = 0x00000000,
    this.subtitleOutlineColor = 0x00000000,
    this.showSubtitle = true,
    this.subtitleBottomPadding = 0,
    this.skipDuration = 85,
    this.subtitleWeight = 5,
  });

  factory PlayerSettings.fromJson(Map<String, dynamic> json) {
    return PlayerSettings(
      id: (json['id'] ?? 0) as int,
      speed: (json['speed'] as String?) ?? '1x',
      resizeMode: (json['resizeMode'] as int?) ?? 0,
      useCustomMpvConfig: (json['useCustomMpvConfig'] as bool?) ?? false,
      subtitleLanguage: (json['subtitleLanguage'] as String?) ?? 'en',
      subtitleSize: (json['subtitleSize'] as int?) ?? 32,
      subtitleColor: (json['subtitleColor'] as int?) ?? 0xFFFFFFFF,
      subtitleFont: (json['subtitleFont'] as String?) ?? 'Poppins',
      subtitleBackgroundColor:
          (json['subtitleBackgroundColor'] as int?) ?? 0x00000000,
      subtitleOutlineColor:
          (json['subtitleOutlineColor'] as int?) ?? 0x00000000,
      showSubtitle: (json['showSubtitle'] as bool?) ?? true,
      subtitleBottomPadding: (json['subtitleBottomPadding'] as int?) ?? 0,
      skipDuration: (json['skipDuration'] as int?) ?? 85,
      subtitleWeight: (json['subtitleWeight'] as int?) ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'speed': speed,
      'resizeMode': resizeMode,
      'useCustomMpvConfig': useCustomMpvConfig,
      'subtitleLanguage': subtitleLanguage,
      'subtitleSize': subtitleSize,
      'subtitleColor': subtitleColor,
      'subtitleFont': subtitleFont,
      'subtitleBackgroundColor': subtitleBackgroundColor,
      'subtitleOutlineColor': subtitleOutlineColor,
      'showSubtitle': showSubtitle,
      'subtitleBottomPadding': subtitleBottomPadding,
      'skipDuration': skipDuration,
      'subtitleWeight': subtitleWeight,
    };
  }
}
