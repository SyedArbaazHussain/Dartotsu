class SubtitleHelper {
  static List<String> getSubtitleUrls(String videoUrl) {
    // Example: replace extension with .srt/.ass if your API provides them
    final base = videoUrl.split('.').first;
    return [
      "$base.srt",
      "$base.ass",
    ];
  }
}
