import 'package:objectbox/objectbox.dart';

@Entity()
class ShowResponse {
  @Id()
  int id = 0;

  @Unique()
  late String key;

  final String? name;
  final String? link;
  final String? coverUrl;
  final List<String> otherNames;
  final int? total;

  ShowResponse({
    this.name,
    this.link,
    this.coverUrl,
    this.otherNames = const [],
    this.total,
  });

  factory ShowResponse.fromJson(Map<String, dynamic> json) {
    return ShowResponse(
      name: json['name'] as String?,
      link: json['link'] as String?,
      coverUrl: json['coverUrl'] as String?,
      otherNames:
          (json['otherNames'] as List?)?.map((e) => e as String).toList() ??
          const [],
      total: json['total'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'link': link,
      'coverUrl': coverUrl,
      'otherNames': otherNames,
      'total': total,
    };
  }
}
