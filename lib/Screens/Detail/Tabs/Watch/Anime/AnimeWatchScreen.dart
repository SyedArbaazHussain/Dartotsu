import 'package:collection/collection.dart';
import 'package:dartotsu/DataClass/Media.dart';
import 'package:dartotsu/Screens/Detail/Tabs/Watch/BaseParser.dart';
import 'package:dartotsu/Screens/Detail/Tabs/Watch/BaseWatchScreen.dart';
import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../Adaptor/Episode/EpisodeAdaptor.dart';
import '../../../../../Theme/LanguageSwitcher.dart';
import 'AnimeParser.dart';
import 'Widget/BuildChunkSelector.dart';
import 'Widget/ContinueCard.dart';

// ⬇️ assumes you created DownloadPage at lib/services/download_page.dart
import '../../../../Downloads/DownloadPage.dart';

class AnimeWatchScreen extends StatefulWidget {
  final Media mediaData;

  const AnimeWatchScreen({super.key, required this.mediaData});

  @override
  AnimeWatchScreenState createState() => AnimeWatchScreenState();
}

class AnimeWatchScreenState extends BaseWatchScreen<AnimeWatchScreen> {
  late AnimeParser _viewModel;

  @override
  Media get mediaData => widget.mediaData;

  @override
  BaseParser get viewModel => _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = Get.put(AnimeParser(), tag: widget.mediaData.id.toString());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init(widget.mediaData);
    });
  }

  @override
  List<Widget> get widgetList => [_buildEpisodeList()];

  Widget _buildEpisodeList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(),
        Obx(() {
          final episodeMap = _viewModel.episodeList.value;
          if (episodeMap == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!_viewModel.episodeDataLoaded.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (episodeMap.isEmpty) {
            return Column(
              children: [
                Center(
                  child: Text(
                    _viewModel.errorType.value == ErrorType.NotFound
                        ? 'Media not found'
                        : 'No episodes found',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          }

          updateEpisodeDetails(episodeMap);

          final (chunks, initChunkIndex) = buildChunks(
            context,
            episodeMap,
            widget.mediaData.userProgress.toString(),
          );

          final selectedEpisode = episodeMap.values.firstWhereOrNull(
            (e) =>
                e.episodeNumber ==
                ((widget.mediaData.userProgress ?? 0) + 1).toString(),
          );

          RxInt selectedChunkIndex = (-1).obs;
          selectedChunkIndex = selectedChunkIndex.value == -1
              ? initChunkIndex
              : selectedChunkIndex;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ContinueCard(
                mediaData: widget.mediaData,
                episode: selectedEpisode,
                source: _viewModel.source.value!,
              ),
              ChunkSelector(
                context,
                chunks,
                selectedChunkIndex,
                _viewModel.reversed,
              ),
              // Existing visual adaptor
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 18),
                child: Obx(() {
                  final chunkSets = _viewModel.reversed.value
                      ? chunks.map((e) => e.reversed.toList()).toList()
                      : chunks;
                  return EpisodeAdaptor(
                    type: _viewModel.viewType.value,
                    source: _viewModel.source.value!,
                    episodeList: chunkSets[selectedChunkIndex.value],
                    mediaData: widget.mediaData,
                  );
                }),
              ),
              const SizedBox(height: 12),
              // ⬇️ New: per-episode Download list (non-scrollable)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Text(
                  'Downloads',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Obx(() {
                final chunkSets = _viewModel.reversed.value
                    ? chunks.map((e) => e.reversed.toList()).toList()
                    : chunks;

                final current = chunkSets[selectedChunkIndex.value];

                // Use a non-scrollable ListView so it nests safely in Column
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  itemCount: current.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final ep = current[i];
                    final title = 'Episode ${ep.episodeNumber}'
                        '${(ep.name != null && ep.name!.isNotEmpty) ? ' — ${ep.name}' : ''}';

                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                      title: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        tooltip: 'Download',
                        icon: const Icon(Icons.download_rounded),
                        onPressed: () {
                          final url = ep.url ?? '';
                          if (url.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('No stream URL for this episode')),
                            );
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DownloadPage(primaryUrl: url),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              }),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              getString.episode(_viewModel.episodeList.value?.length ?? 1),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          IconButton(
            onPressed: () => _viewModel.settingsDialog(context, mediaData),
            icon: Icon(
              Icons.menu_rounded,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  void updateEpisodeDetails(Map<String, DEpisode> episodeList) {
    widget.mediaData.anime?.episodes = episodeList;
    widget.mediaData.anime?.fillerEpisodes =
        _viewModel.fillerEpisodesList.value;
    widget.mediaData.anime?.kitsuEpisodes = _viewModel.kitsuEpisodeList.value;
    widget.mediaData.anime?.anifyEpisodes = _viewModel.anifyEpisodeList.value;

    episodeList.forEach((number, episode) {
      episode.name = _viewModel.anifyEpisodeList.value?[number]?.name ??
          _viewModel.kitsuEpisodeList.value?[number]?.name ??
          _viewModel.fillerEpisodesList.value?[number]?.name ??
          episode.name ??
          '';
      episode.description =
          _viewModel.anifyEpisodeList.value?[number]?.description ??
              _viewModel.kitsuEpisodeList.value?[number]?.description ??
              episode.description ??
              '';
      episode.thumbnail =
          _viewModel.anifyEpisodeList.value?[number]?.thumbnail ??
              _viewModel.kitsuEpisodeList.value?[number]?.thumbnail ??
              episode.thumbnail ??
              widget.mediaData.banner ??
              widget.mediaData.cover;
      episode.filler =
          _viewModel.fillerEpisodesList.value?[number]?.filler == true;
    });
  }
}
