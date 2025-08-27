part of '../SimklQueries.dart';

extension on SimklQueries {
  Future<Map<String, List<media.Media>>> _getAnimeList() async {
    final list = <String, List<media.Media>>{};
    final urls = {
      'Incoming':
          'https://api.simkl.com/anime/premieres/param?type=all&client_id=${SimklLogin.clientId}',
      'Airing':
          'https://api.simkl.com/anime/airing?date?sort=time&client_id=${SimklLogin.clientId}',
    };
    final animeLayoutMap = PrefManager.getVal(PrefName.simklAnimeLayout);

    Map<String, String> generate = Map.fromEntries(
      urls.entries.where((entry) => animeLayoutMap[entry.key] == true),
    );

    generate.addAll({
      'trendingAnime':
          'https://api.simkl.com/anime/trending/today?extended=overview,metadata,tmdb,genres,trailer&client_id=${SimklLogin.clientId}',
      'popularAnime':
          'https://api.simkl.com/anime/genres/all/all-types/all-countries/all-years?client_id=${SimklLogin.clientId}',
    });
    final results = await Future.wait(
      generate.entries.map((entry) async {
        return MapEntry(
          entry.key,
          await _loadCache(entry.value, 'anime', entry.key),
        );
      }),
    );

    list.addEntries(results);
    return list;
  }

  Future<Map<String, List<media.Media>>> _getMangaList() async {
    final list = <String, List<media.Media>>{};
    final urls = {
      'Incoming Shows':
          'https://api.simkl.com/tv/premieres/param?type=all&client_id=${SimklLogin.clientId}',
      'Airing Shows':
          'https://api.simkl.com/tv/airing?date?sort=time&client_id=${SimklLogin.clientId}',
    };
    final mangaLayoutMap = PrefManager.getVal(PrefName.simklMangaLayout);

    Map<String, String> generate = Map.fromEntries(
      urls.entries.where((entry) => mangaLayoutMap[entry.key] == true),
    );

    generate.addAll({
      'trendingMovies':
          'https://api.simkl.com/movies/trending/today?extended=overview,metadata,tmdb,genres,trailer&client_id=${SimklLogin.clientId}',
      'popularMovies':
          'https://api.simkl.com/movies/genres/all/all-types/all-countries/all-years?client_id=${SimklLogin.clientId}',
    });
    final results = await Future.wait(
      generate.entries.map((entry) async {
        return MapEntry(
          entry.key,
          await _loadCache(
            entry.value,
            entry.key == 'trendingMovies' || entry.key == 'popularMovies'
                ? 'movies'
                : 'shows',
            entry.key,
          ),
        );
      }),
    );

    list.addEntries(results);
    return list;
  }

  Future<List<Media>> updateDataFromLocal(Media m, String type) async {
    var med = await precessMedia(m, type);

    final String? localData = PrefManager.getCustomVal<String>(
      'simklUserAnimeList',
    );

    if (localData == null) return med;

    final parsed = Media.fromJson(jsonDecode(localData));

    if (parsed.anime?.isEmpty ?? true) return med;

    final localList = await precessMedia(parsed, type);

    for (final localMedia in localList) {
      for (final existingMedia in med) {
        if (existingMedia.id == localMedia.id) {
          existingMedia.description = localMedia.description;
          existingMedia.userProgress = localMedia.userProgress;
          existingMedia.userScore = localMedia.userScore;
          existingMedia.userStatus = localMedia.userStatus;
          existingMedia.anime?.totalEpisodes ??=
              localMedia.anime?.totalEpisodes;
        }
      }
    }

    return med;
  }

  Future<List<media.Media>> precessMedia(Media m, String type) async {
    return type == 'anime'
        ? await processMediaResponse(m)
        : type == 'movies'
        ? await processMovieResponse(m)
        : await processShowsResponse(m);
  }

  Future<List<media.Media>> _loadCache(
    String query,
    String mapKey,
    String key,
  ) async {
    final localData = PrefManager.getCustomVal<String>('simkl${key}List');
    final time = PrefManager.getCustomVal<int>('simkl${key}time');
    if (localData == null || checkTime()) {
      final response = await executeQuery<Media>(query, mapKey: mapKey);
      PrefManager.setCustomVal('simkl${key}List', jsonEncode(response));
      PrefManager.setCustomVal(
        'simkl${key}time',
        DateTime.now().millisecondsSinceEpoch,
      );
      if (response == null) return [];
      return await updateDataFromLocal(response, mapKey);
    }
    final parsed = Media.fromJson(jsonDecode(localData));
    return await updateDataFromLocal(parsed, mapKey); 
  }

  Future<List<media.Media>> getTrending(String type, {String? time}) async {
    Media? updaterShowList;
    if (type != 'anime') {
      updaterShowList = await executeQuery<Media>(
        'https://api.simkl.com/$type/trending/?extended=overview,metadata,tmdb,genres,trailer&client_id=${SimklLogin.clientId}',
        mapKey: type == 'tv' ? 'shows' : type,
      );
    } else {
      updaterShowList = await executeQuery<Media>(
        'https://api.simkl.com/anime/trending/$time?extended=overview,metadata,tmdb,genres,trailer&client_id=${SimklLogin.clientId}',
        mapKey: 'anime',
      );
    }

    if (updaterShowList == null) return [];
    return await updateDataFromLocal(updaterShowList, type);
  }

  Future<List<media.Media>> loadNextPage(String type, int page) async {
    var updaterShowList = await executeQuery<Media>(
      'https://api.simkl.com/$type/genres/all/all-types/all-countries/all-years?client_id=${SimklLogin.clientId}&page=$page',
      mapKey: type,
    );
    if (updaterShowList == null) return [];
    return await updateDataFromLocal(updaterShowList, type);
  }
}
