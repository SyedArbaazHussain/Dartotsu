import 'package:dartotsu/DataClass/Media.dart';
import 'package:dartotsu/Functions/Extensions.dart';
import 'package:dartotsu/Preferences/PrefManager.dart';
import 'package:get/get.dart';
import 'package:objectbox/objectbox.dart';

import 'package:dartotsu/Preferences/ObjectBox/DefaultPlayerSettings.dart'
    show PlayerSettings;
import 'package:dartotsu/Preferences/ObjectBox/DefaultReaderSettings.dart'
    show ReaderSettings;

@Entity()
class MediaSettings {
  @Id()
  int id = 0;

  int viewType = 0;
  bool isReverse = false;

  @Unique()
  late String key;

  int navIndex;
  String? lastUsed;
  String? server;

  List<String>? selectedScans;

  final playerSettings = ToOne<PlayerSettings>();
  final readerSettings = ToOne<ReaderSettings>();

  MediaSettings({
    int viewType = 0,
    bool isReverse = false,
    this.navIndex = 0,
    this.lastUsed,
    this.server,
    this.selectedScans,
    PlayerSettings? playerSetting,
    ReaderSettings? readerSetting,
  }) {
    playerSettings.target = playerSetting ?? PlayerSettings();
    readerSettings.target = readerSetting ?? ReaderSettings();
  }

  factory MediaSettings.fromJson(Map<String, dynamic> json) {
    return MediaSettings(
      navIndex: (json['navBarIndex'] as int?) ?? 0,
      lastUsed: json['lastUsedSource'] as String?,
      viewType: (json['viewType'] as int?) ?? 0,
      isReverse: (json['isReverse'] as bool?) ?? false,
      server: json['server'] as String?,
      selectedScans: (json['selectedScanlators'] as List?)
          ?.map((e) => e as String)
          .toList(),
      playerSetting: (json['playerSettings'] is Map<String, dynamic>)
          ? PlayerSettings.fromJson(
              json['playerSettings'] as Map<String, dynamic>,
            )
          : null,
      readerSetting: (json['readerSettings'] is Map<String, dynamic>)
          ? ReaderSettings.fromJson(
              json['readerSettings'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'navBarIndex': navIndex,
      'lastUsedSource': lastUsed,
      'viewType': viewType,
      'isReverse': isReverse,
      'server': server,
      'selectedScanlators': selectedScans,
      'playerSettings': playerSettings.target?.toJson(),
      'readerSettings': readerSettings.target?.toJson(),
    };
  }

  static void saveMediaSettings(Media media) {
    final service = Get.context!.currentService(listen: false);
    final key = '${service.getName}-${media.id}-Settings';
    PrefManager.setCustomVal(key, media.settings);
  }
}
