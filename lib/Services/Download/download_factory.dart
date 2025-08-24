import 'dart:io' show Platform;
import 'download_service.dart';
import 'aria2_service.dart';
import 'flutter_downloader_service.dart';

class DownloadFactory {
  static DownloadService create() {
    if (Platform.isAndroid || Platform.isIOS) {
      return FlutterDownloaderService();
    } else {
      return Aria2Service();
    }
  }
}
