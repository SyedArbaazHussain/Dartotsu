import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadPage extends StatefulWidget {
  final String primaryUrl;
  final String? subtitleUrl;

  const DownloadPage({
    super.key,
    required this.primaryUrl,
    this.subtitleUrl,
  });

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  final ReceivePort _port = ReceivePort();
  List<_TaskInfo> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback as DownloadCallback);
    _prepare();
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  void _bindBackgroundIsolate() {
    bool success = IsolateNameServer.registerPortWithName(
      _port.sendPort,
      'downloader_send_port',
    );
    if (!success) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];

      final task = _tasks.firstWhere(
        (task) => task.taskId == id,
        orElse: () => _TaskInfo(name: "", link: ""),
      );
      if (task.taskId == id) {
        setState(() {
          task.status = status;
          task.progress = progress;
        });
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  @pragma('vm:entry-point')
  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  Future<void> _prepare() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    // Build download task list dynamically from widget parameters
    _tasks = [
      _TaskInfo(
        name: "Anime Episode",
        link: widget.primaryUrl,
      ),
      if (widget.subtitleUrl != null)
        _TaskInfo(
          name: "Subtitles",
          link: widget.subtitleUrl!,
        ),
    ];

    setState(() {
      _loading = false;
    });
  }

  Future<void> _requestDownload(_TaskInfo task) async {
    final dir = await getApplicationDocumentsDirectory();
    task.taskId = await FlutterDownloader.enqueue(
      url: task.link,
      headers: {},
      savedDir: dir.path,
      fileName: task.name,
      showNotification: true,
      openFileFromNotification: true,
    );
  }

  Widget _buildDownloadList() {
    return ListView(
      children: _tasks.map((task) {
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(task.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: (task.progress ?? 0) / 100,
                ),
                Text("${task.progress ?? 0}%"),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (task.status == DownloadTaskStatus.undefined)
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () => _requestDownload(task),
                  ),
                if (task.status == DownloadTaskStatus.running)
                  IconButton(
                    icon: const Icon(Icons.pause),
                    onPressed: () =>
                        FlutterDownloader.pause(taskId: task.taskId!),
                  ),
                if (task.status == DownloadTaskStatus.paused)
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () =>
                        FlutterDownloader.resume(taskId: task.taskId!),
                  ),
                if (task.status == DownloadTaskStatus.failed)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => _requestDownload(task),
                  ),
                if (task.status == DownloadTaskStatus.complete)
                  const Icon(Icons.check, color: Colors.green),
                IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () {
                    if (task.taskId != null) {
                      FlutterDownloader.cancel(taskId: task.taskId!);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Downloads")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildDownloadList(),
    );
  }
}

class _TaskInfo {
  final String name;
  final String link;
  String? taskId;
  DownloadTaskStatus? status = DownloadTaskStatus.undefined;
  int? progress = 0;

  _TaskInfo({required this.name, required this.link});
}
