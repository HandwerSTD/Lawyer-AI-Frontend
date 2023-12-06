import 'package:flutter/material.dart';
import 'package:lawyer_ai_frontend/short_video/short_video_page_index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lawyer_ai_frontend/short_video/short_video_play.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class ShortVideoWaterfallPage extends StatefulWidget {
  List<VideoDataModel> videoList;
  Function loadMoreContent;
  ShortVideoWaterfallPage(
      {super.key, required this.videoList, required this.loadMoreContent});

  @override
  State<ShortVideoWaterfallPage> createState() =>
      _ShortVideoWaterfallPageState();
}

class _ShortVideoWaterfallPageState extends State<ShortVideoWaterfallPage> {
  List<VideoDataModel> sttVideoList = [];

  ScrollController wfController = ScrollController();

  @override
  void initState() {
    super.initState();
    sttVideoList = widget.videoList;

    wfController.addListener(() {
      if (wfController.position.pixels ==
          wfController.position.maxScrollExtent) {
        widget.loadMoreContent(); // 到底部加载新内容
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: WaterfallFlow.count(
        crossAxisCount: 2,
        controller: wfController,
        children: List.generate(sttVideoList.length,
            (index) => gridVideoBlock(sttVideoList[index])),
      ),
    );
  }

  Widget gridVideoBlock(VideoDataModel video) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            /* TODO: Navigate to Video */
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ShortVideoPlay()));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 5, right: 5, top: 12, bottom: 12),
                child: CachedNetworkImage(
                  imageUrl: video.videoImageLink,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 18, right: 8, bottom: 6),
                child: Text(
                  video.videoTitle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 14, letterSpacing: 0.1),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
