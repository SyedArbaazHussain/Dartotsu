import 'dart:io';
import 'package:dartotsu/Preferences/PrefManager.dart';
import 'package:dartotsu/Preferences/Preferences.dart';
import 'package:dartotsu/logger.dart';
import 'package:path/path.dart' as p;

class MpvConf {
  static final shaderProfiles = {
    "MID-END": {
      'Anime4K: Mode A (Fast)': [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Restore_CNN_M.glsl',
        'Anime4K_Upscale_CNN_x2_M.glsl',
      ],
      'Anime4K: Mode B (Fast)': [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Restore_CNN_Soft_M.glsl',
        'Anime4K_Upscale_CNN_x2_M.glsl',
      ],
      'Anime4K: Mode C (Fast)': [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Upscale_Denoise_CNN_x2_M.glsl',
      ],
      'Anime4K: Mode A+A (Fast)': [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Restore_CNN_VL.glsl',
        'Anime4K_Upscale_CNN_x2_VL.glsl',
        'Anime4K_Restore_CNN_M.glsl',
        'Anime4K_Upscale_CNN_x2_M.glsl',
      ],
      'Anime4K: Mode B+B (Fast)': [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Restore_CNN_Soft_VL.glsl',
        'Anime4K_Upscale_CNN_x2_VL.glsl',
        'Anime4K_Restore_CNN_Soft_M.glsl',
        'Anime4K_Upscale_CNN_x2_M.glsl',
      ],
      'Anime4K: Mode C+A (Fast)': [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Upscale_Denoise_CNN_x2_VL.glsl',
        'Anime4K_Restore_CNN_M.glsl',
        'Anime4K_Upscale_CNN_x2_M.glsl',
      ],
    },
    "HIGH-END": {
      'Anime4K: Mode A (HQ)': [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Restore_CNN_VL.glsl',
        'Anime4K_Upscale_CNN_x2_VL.glsl',
        'Anime4K_AutoDownscalePre_x2.glsl',
        'Anime4K_AutoDownscalePre_x4.glsl',
        'Anime4K_Upscale_CNN_x2_M.glsl',
      ],
      'Anime4K: Mode B (HQ)': [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Restore_CNN_Soft_VL.glsl',
        'Anime4K_Upscale_CNN_x2_VL.glsl',
        'Anime4K_AutoDownscalePre_x2.glsl',
        'Anime4K_AutoDownscalePre_x4.glsl',
        'Anime4K_Upscale_CNN_x2_M.glsl',
      ],
      'Anime4K: Mode C (HQ)': [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Upscale_Denoise_CNN_x2_VL.glsl',
        'Anime4K_AutoDownscalePre_x2.glsl',
        'Anime4K_AutoDownscalePre_x4.glsl',
        'Anime4K_Upscale_CNN_x2_M.glsl',
      ],
      'Anime4K: Mode A+A (HQ)': [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Restore_CNN_VL.glsl',
        'Anime4K_Upscale_CNN_x2_VL.glsl',
        'Anime4K_Restore_CNN_M.glsl',
        'Anime4K_AutoDownscalePre_x2.glsl',
        'Anime4K_AutoDownscalePre_x4.glsl',
        'Anime4K_Upscale_CNN_x2_M.glsl',
      ],
      'Anime4K: Mode B+B (HQ)': [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Restore_CNN_Soft_VL.glsl',
        'Anime4K_Upscale_CNN_x2_VL.glsl',
        'Anime4K_AutoDownscalePre_x2.glsl',
        'Anime4K_AutoDownscalePre_x4.glsl',
        'Anime4K_Restore_CNN_Soft_M.glsl',
        'Anime4K_Upscale_CNN_x2_M.glsl',
      ],
      'Anime4K: Mode C+A (HQ)': [
        'Anime4K_Clamp_Highlights.glsl',
        'Anime4K_Upscale_Denoise_CNN_x2_VL.glsl',
        'Anime4K_AutoDownscalePre_x2.glsl',
        'Anime4K_AutoDownscalePre_x4.glsl',
        'Anime4K_Restore_CNN_M.glsl',
        'Anime4K_Upscale_CNN_x2_M.glsl',
      ],
    },
  };

  static List<String> getShaderProfiles() => shaderProfiles.keys.toList();

  static List<String> getConfigs(String profile) {
    final map = shaderProfiles[profile];
    return map == null ? const [] : map.keys.toList();
  }

  static List<String> getShaders(String profile, String configName) {
    final configs = shaderProfiles[profile];
    return (configs?[configName] ?? const <String>[]);
  }

  static Future<String> getShaderBasePath() async {
    final mpvPath = await getMpvPath();
    return p.join(mpvPath, 'Shaders');
  }

  static Future<List<String>> getShaderPathsForConfig(
    String profile,
    String configName,
  ) async {
    final base = await getShaderBasePath();
    final files = getShaders(profile, configName);
    return files.map((f) => p.join(base, f)).toList();
  }

  static Future<void> setShaders(
    dynamic player,
    String profile,
    String configName,
  ) async {
    try {
      final paths = await getShaderPathsForConfig(profile, configName);
      final joined = paths.join(';');
      final platform = (player as dynamic).platform;
      platform.setProperty('glsl-shaders', joined);
      Logger.log('Applied shaders: $joined');
    } catch (e) {
      Logger.log('Failed to apply shaders: $e');
      rethrow;
    }
  }

  static Future<void> init() async {
    Logger.log('Initializing MPV config...');
    await createMpvConfigFolder();
    Logger.log('MPV config initialized!');
    Logger.log(
      'Status => useCustomMpvConfig: ${PrefManager.getVal(PrefName.useCustomMpvConfig)}, mpvConfigPath: ${PrefManager.getVal(PrefName.mpvConfigDir)}',
    );
  }

  static Future<bool> createMpvConfigFolder() async {
    try {
      final mpvPath = await getMpvPath();
      Logger.log('Saving mpv config path to preferences');
      PrefManager.setVal(PrefName.mpvConfigDir, mpvPath);

      final configDir = Directory(mpvPath);
      if (!await configDir.exists()) {
        await configDir.create(recursive: true);
        Logger.log('Created MPV directory: ${configDir.path}');
      }

      final configFile = File(p.join(configDir.path, 'mpv.conf'));
      if (!await configFile.exists()) {
        await configFile.writeAsString('');
        Logger.log('Created empty MPV config file: ${configFile.path}');
      }
      return true;
    } catch (e) {
      Logger.log('Error creating MPV config folder/file: $e');
      return false;
    }
  }

  static Future<String> getMpvPath() async {
    final dir = await PrefManager.getDirectory(subPath: 'mpv');
    return dir?.path ?? '';
  }

  static Future<String> getMpvConfigPath() async {
    final mpvPath = await getMpvPath();
    return p.join(mpvPath, 'mpv.conf');
  }

  static Future<bool> doesMpvConfigExist() async {
    try {
      final configPath = await getMpvConfigPath();
      final configFile = File(configPath);
      return await configFile.exists();
    } catch (e) {
      Logger.log('Error checking MPV config existence: $e');
      return false;
    }
  }
}
