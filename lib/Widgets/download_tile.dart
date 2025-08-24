import 'package:flutter/material.dart';
import '../../Screens/Downloads/DownloadPage.dart';

class DownloadTile extends StatelessWidget {
  final String title;
  final String? videoUrl; // for anime
  final String? chapterUrl; // for manga

  const DownloadTile({
    super.key,
    required this.title,
    this.videoUrl,
    this.chapterUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: IconButton(
          icon: const Icon(Icons.download),
          onPressed: () {
            final url = videoUrl ?? chapterUrl;
            if (url != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      DownloadPage(primaryUrl: url), // ✅ correct param name
                ),
              );
            }
          }),
    );
  }
}
