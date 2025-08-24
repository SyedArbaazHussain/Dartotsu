import 'dart:convert';
import 'package:http/http.dart' as http;
import 'download_service.dart';

class Aria2Service implements DownloadService {
  final String rpcUrl;

  Aria2Service({this.rpcUrl = "http://localhost:6800/jsonrpc"});

  Future<Map<String, dynamic>> _send(String method, List params) async {
    final body = {
      "jsonrpc": "2.0",
      "method": method,
      "id": "flutter",
      "params": params
    };
    final response = await http.post(
      Uri.parse(rpcUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
    return jsonDecode(response.body);
  }

  @override
  Future<String?> addDownload(String url, {String? dir}) async {
    final result = await _send("aria2.addUri", [
      [url],
      {"dir": dir ?? "./downloads"}
    ]);
    return result["result"];
  }

  @override
  Future<Map<String, dynamic>> getStatus(String id) async {
    final result = await _send("aria2.tellStatus", [id]);
    return result["result"];
  }

  @override
  Future<void> pause(String id) async => _send("aria2.pause", [id]);

  @override
  Future<void> resume(String id) async => _send("aria2.unpause", [id]);

  @override
  Future<void> remove(String id) async => _send("aria2.remove", [id]);

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
