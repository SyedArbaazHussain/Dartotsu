import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../Widgets/download_tile.dart';
import '../MangaParser.dart';

class MangaChapterListView extends StatelessWidget {
  final MangaParser parser;
  const MangaChapterListView({super.key, required this.parser});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = parser.chapterList.value;
      if (list == null) return const Center(child: CircularProgressIndicator());
      if (list.isEmpty) return const Center(child: Text("No chapters"));

      final items = parser.reversed.value ? list.reversed.toList() : list;

      return ListView.builder(
        itemCount: items.length,
        itemBuilder: (_, i) {
          final ch = items[i];
          final title = "Chapter ${ch.episodeNumber}";
          final url = ch.url ?? "";
          return DownloadTile(
            title: title,
            chapterUrl: url,
          );
        },
      );
    });
  }
}
