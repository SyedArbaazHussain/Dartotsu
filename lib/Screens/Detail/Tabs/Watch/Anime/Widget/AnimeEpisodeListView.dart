import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../Widgets/download_tile.dart';
import '../AnimeParser.dart';

class AnimeEpisodeListView extends StatelessWidget {
  final AnimeParser parser;
  const AnimeEpisodeListView({super.key, required this.parser});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final map = parser.episodeList.value;
      if (map == null) return const Center(child: CircularProgressIndicator());
      if (map.isEmpty) return const Center(child: Text("No episodes"));

      // your map is keyed by normalized episodeNumber -> DEpisode
      final entries = map.entries.toList();
      // reverse if user setting says so
      if (parser.reversed.value) entries.reversed.toList();

      return ListView.builder(
        itemCount: entries.length,
        itemBuilder: (_, i) {
          final epNum = entries[i].key;
          final ep = entries[i].value;

          // If ep.url is not the *direct* stream url, you can later pipe through your extractor.
          final url = ep.url ?? "";

          return DownloadTile(
            title: "Episode $epNum",
            videoUrl: url,
            // If your source gives explicit subtitle links, pass them via `extra: [...]`
          );
        },
      );
    });
  }
}
