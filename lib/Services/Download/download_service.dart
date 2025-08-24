abstract class DownloadService {
  Future<String?> addDownload(String url, {String? dir});
  Future<List<String?>> addBatch(List<String> urls, {String? dir});
  Future<Map<String, dynamic>> getStatus(String id);
  Future<void> pause(String id);
  Future<void> resume(String id);
  Future<void> remove(String id);
}
