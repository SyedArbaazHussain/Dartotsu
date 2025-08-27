import 'dart:io';

import 'package:dartotsu/Preferences/ObjectBox/DefaultPlayerSettings.dart';
import 'package:dartotsu/Preferences/Preferences.dart';
import 'package:dartotsu/Preferences/PrefManager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'package:dartotsu_extension_bridge/Models/Video.dart' as v;
import 'BasePlayer.dart';

class WindowsPlayer extends BasePlayer {
  final Rx<BoxFit> resizeMode;
  final PlayerSettings settings;

  late final Player player;
  late final VideoController videoController;
  String? currentSubtitle;

  WindowsPlayer(this.resizeMode, this.settings) {
    final useCustomConfig =
        (PrefManager.getVal(PrefName.useCustomMpvConfig) as bool?) ?? false;

    final rawMpvConfPath = PrefManager.getVal(PrefName.mpvConfigDir) as String?;
    final mpvConfPath =
        (rawMpvConfPath != null && rawMpvConfPath.trim().isNotEmpty)
        ? rawMpvConfPath.trim()
        : Directory.current.path;

    player = Player(
      configuration: PlayerConfiguration(
        bufferSize: 1024 * 1024 * 64,
        config: useCustomConfig,
        configDir: mpvConfPath,
      ),
    );

    videoController = VideoController(player, configuration: _platformConfig());

    final initialRate =
        double.tryParse(settings.speed.replaceFirst('x', '')) ?? 1.0;
    player.setRate(initialRate);
  }

  VideoControllerConfiguration _platformConfig() {
    if (Platform.isAndroid) {
      return const VideoControllerConfiguration(
        androidAttachSurfaceAfterVideoParameters: true,
      );
    }
    return const VideoControllerConfiguration();
  }

  @override
  Future<void> pause() async => videoController.player.pause();

  @override
  Future<void> play() async => videoController.player.play();

  @override
  Future<void> playOrPause() async => videoController.player.playOrPause();

  @override
  Future<void> seek(final Duration duration) async {
    videoController.player.seek(duration);
  }

  @override
  Future<void> setRate(final double rate) async =>
      videoController.player.setRate(rate);

  @override
  Future<void> setVolume(final double volume) async =>
      videoController.player.setVolume(volume);

  @override
  Future<void> open(final v.Video video, final Duration duration) async {
    videoController.player.open(
      Media(video.url, start: duration, httpHeaders: video.headers),
    );
  }

  @override
  Future<void> setSubtitle(
    final String subtitleUri,
    final String language,
    final bool isUri,
  ) {
    currentSubtitle = language;
    return videoController.player.setSubtitleTrack(
      isUri
          ? SubtitleTrack.uri(subtitleUri, title: language)
          : SubtitleTrack(
              subtitleUri,
              language,
              language,
              uri: false,
              data: false,
            ),
    );
  }

  @override
  Future<void> setAudio(
    final String audioUri,
    final String language,
    final bool isUri,
  ) async {
    await videoController.player.setAudioTrack(
      isUri
          ? AudioTrack.uri(audioUri, title: language)
          : AudioTrack(audioUri, language, language, uri: false),
    );
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }

  @override
  void listenToPlayerStream() {
    videoController.player.stream.position.listen(
      (e) => currentTime.value = _formatTime(e.inSeconds),
    );
    videoController.player.stream.duration.listen(
      (e) => maxTime.value = _formatTime(e.inSeconds),
    );
    videoController.player.stream.buffer.listen(
      (e) => bufferingTime.value = _formatTime(e.inSeconds),
    );
    videoController.player.stream.position.listen(
      (e) => currentPosition.value = e,
    );
    videoController.player.stream.buffering.listen(isBuffering.call);
    videoController.player.stream.playing.listen(isPlaying.call);
    videoController.player.stream.tracks.listen(
      (e) => subtitles.value = e.subtitle,
    );
    videoController.player.stream.subtitle.listen((e) => subtitle.value = e);
    videoController.player.stream.tracks.listen((e) => audios.value = e.audio);
    videoController.player.stream.rate.listen((e) => currentSpeed.value = e);
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return [
      if (hours > 0) hours.toString().padLeft(2, '0'),
      minutes.toString().padLeft(2, '0'),
      secs.toString().padLeft(2, '0'),
    ].join(':');
  }

  @override
  Widget playerWidget() {
    return Video(
      filterQuality: FilterQuality.medium,
      subtitleViewConfiguration: const SubtitleViewConfiguration(
        visible: false,
      ),
      controller: videoController,
      controls: null,
      fit: resizeMode.value,
    );
  }
}
