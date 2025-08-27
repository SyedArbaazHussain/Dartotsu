import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class ReaderSettings {
  @Id()
  int id = 0;

  @Transient()
  late LayoutType layoutType;

  @Transient()
  late Direction direction;

  @Transient()
  late DualPageMode dualPageMode;

  bool scrollToNext;
  bool spacedPages;
  bool hideScrollbar;
  bool hidePageNumber;
  bool keepScreenOn;
  bool changePageWithVolumeButtons;
  bool openImageWithLongTap;

  ReaderSettings({
    this.id = 0,
    this.scrollToNext = true,
    this.spacedPages = false,
    this.hideScrollbar = false,
    this.hidePageNumber = false,
    this.keepScreenOn = false,
    this.changePageWithVolumeButtons = false,
    this.openImageWithLongTap = true,
    LayoutType layoutType = LayoutType.Continuous,
    Direction direction = Direction.UTD,
    DualPageMode dualPageMode = DualPageMode.Auto,
  }) : layoutType = layoutType,
       direction = direction,
       dualPageMode = dualPageMode;

  // Persisted backing fields for enums (use int mapping).
  // Use getters/setters to map to/from the transient enum fields.
  int get dbLayoutType {
    _ensureStableLayoutTypeValues();
    return layoutType.index;
  }

  set dbLayoutType(int value) {
    _ensureStableLayoutTypeValues();
    layoutType = value >= 0 && value < LayoutType.values.length
        ? LayoutType.values[value]
        : LayoutType.Continuous;
  }

  int get dbDirection {
    _ensureStableDirectionValues();
    return direction.index;
  }

  set dbDirection(int value) {
    _ensureStableDirectionValues();
    direction = value >= 0 && value < Direction.values.length
        ? Direction.values[value]
        : Direction.UTD;
  }

  int get dbDualPageMode {
    _ensureStableDualPageModeValues();
    return dualPageMode.index;
  }

  set dbDualPageMode(int value) {
    _ensureStableDualPageModeValues();
    dualPageMode = value >= 0 && value < DualPageMode.values.length
        ? DualPageMode.values[value]
        : DualPageMode.Auto;
  }

  // Optional asserts to ensure the enum order stays stable across edits.
  void _ensureStableLayoutTypeValues() {
    assert(LayoutType.Continuous.index == 0);
    assert(LayoutType.Paged.index == 1);
  }

  void _ensureStableDirectionValues() {
    assert(Direction.UTD.index == 0);
    assert(Direction.DTU.index == 1);
    assert(Direction.RTL.index == 2);
    assert(Direction.LTR.index == 3);
  }

  void _ensureStableDualPageModeValues() {
    assert(DualPageMode.Auto.index == 0);
    assert(DualPageMode.Single.index == 1);
    assert(DualPageMode.ForcedDouble.index == 2);
  }

  Map<String, dynamic> toJson() {
    return {
      'layoutType': layoutType.index,
      'direction': direction.index,
      'dualPageMode': dualPageMode.index,
      'scrollToNext': scrollToNext,
      'spacedPages': spacedPages,
      'hideScrollbar': hideScrollbar,
      'hidePageNumber': hidePageNumber,
      'keepScreenOn': keepScreenOn,
      'changePageWithVolumeButtons': changePageWithVolumeButtons,
      'openImageWithLongTap': openImageWithLongTap,
    };
  }

  factory ReaderSettings.fromJson(Map<String, dynamic> json) {
    return ReaderSettings(
      layoutType: LayoutType.values[(json['layoutType'] as int?) ?? 0],
      direction: Direction.values[(json['direction'] as int?) ?? 0],
      dualPageMode: DualPageMode.values[(json['dualPageMode'] as int?) ?? 0],
      scrollToNext: (json['scrollToNext'] as bool?) ?? true,
      spacedPages: (json['spacedPages'] as bool?) ?? false,
      hideScrollbar: (json['hideScrollbar'] as bool?) ?? false,
      hidePageNumber: (json['hidePageNumber'] as bool?) ?? false,
      keepScreenOn: (json['keepScreenOn'] as bool?) ?? false,
      changePageWithVolumeButtons:
          (json['changePageWithVolumeButtons'] as bool?) ?? false,
      openImageWithLongTap: (json['openImageWithLongTap'] as bool?) ?? true,
    );
  }
}

enum LayoutType {
  Continuous,
  Paged;

  IconData get icon {
    switch (this) {
      case LayoutType.Paged:
        return Icons.amp_stories_rounded;
      case LayoutType.Continuous:
        return Icons.view_column_rounded;
    }
  }
}

enum Direction {
  UTD,
  DTU,
  RTL,
  LTR;

  @override
  String toString() {
    switch (this) {
      case Direction.UTD:
        return 'getString.utd';
      case Direction.DTU:
        return 'getString.dtu';
      case Direction.RTL:
        return 'getString.rtl';
      case Direction.LTR:
        return 'getString.ltr';
    }
  }

  IconData get icon {
    switch (this) {
      case Direction.UTD:
        return Icons.swipe_down_alt_rounded;
      case Direction.DTU:
        return Icons.swipe_up_alt_rounded;
      case Direction.RTL:
        return Icons.swipe_left_alt_rounded;
      case Direction.LTR:
        return Icons.swipe_right_alt_rounded;
    }
  }

  Direction get next {
    switch (this) {
      case Direction.UTD:
        return Direction.RTL;
      case Direction.RTL:
        return Direction.DTU;
      case Direction.DTU:
        return Direction.LTR;
      case Direction.LTR:
        return Direction.UTD;
    }
  }
}

enum DualPageMode { Auto, Single, ForcedDouble }
