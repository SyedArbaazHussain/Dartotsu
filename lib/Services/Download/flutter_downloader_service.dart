import 'package:flutter_downloader/flutter_downloader.dart';
import 'download_service.dart';

class FlutterDownloaderService implements DownloadService {
  FlutterDownloaderService() {
    FlutterDownloader.initialize(debug: true);
  }

  @override
  Future<String?> addDownload(String url, {String? dir}) async {
    return await FlutterDownloader.enqueue(
      url: url,
      savedDir: dir ?? "/storage/emulated/0/Download",
      showNotification: true,
      openFileFromNotification: true,
    );
  }

  @override
  Future<Map<String, dynamic>> getStatus(String id) async {
    final task = await FlutterDownloader.loadTasksWithRawQuery(
      query: "SELECT * FROM task WHERE task_id='$id'",
    );
    if (task != null && task.isNotEmpty) {
      final t = task.first;
      return {
        "status": t.status.toString(),
        "progress": t.progress,
      };
    }
    return {};
  }

  @override
  Future<void> pause(String id) async => FlutterDownloader.pause(taskId: id);

  @override
  Future<void> resume(String id) async => FlutterDownloader.resume(taskId: id);

  @override
  Future<void> remove(String id) async => FlutterDownloader.remove(taskId: id);

  @override
  Future<List<String?>> addBatch(List<String> urls, {String? dir}) async {
    List<String?> ids = [];
    for (final url in urls) {
      final id = await addDownload(url, dir: dir);
      ids.add(id);
    }
    return ids;
  }
}
