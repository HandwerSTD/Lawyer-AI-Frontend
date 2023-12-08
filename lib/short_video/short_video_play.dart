import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lawyer_ai_frontend/short_video/short_video_comment_page.dart';
import 'package:lawyer_ai_frontend/short_video/short_video_page_index.dart';

class ShortVideoPlay extends StatefulWidget {
  List<VideoDataModel> videos;
  int videoIndex;
  Function loadMoreContent;

  ShortVideoPlay(
      {super.key,
      required this.videos,
      required this.videoIndex,
      required this.loadMoreContent});

  @override
  State<ShortVideoPlay> createState() => _ShortVideoPlayState();
}

class _ShortVideoPlayState extends State<ShortVideoPlay> {
  List<VideoDataModel> videos = [];
  int videoIndex = 0;
  PageController pgController = PageController();

  @override
  void initState() {
    super.initState();
    videos = widget.videos;
    videoIndex = widget.videoIndex;
    pgController = PageController(initialPage: videoIndex);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pageViewList =
        List.generate(videos.length, (index) => videoPlayBlock(videos[index]));
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: GestureDetector(
          onTap: () {
            // TODO: Pause Video
            print("[ShortVideoPlay] Video Tap -> Paused");
          },
          onDoubleTap: () {
            // TODO: Like & Dislike
          },
          child: PageView(
            controller: pgController,
            scrollDirection: Axis.vertical,
            onPageChanged: (index) {
              if (index == videos.length - 1) {
                print("[ShortVideoPlay] Scrolled to end");
                widget.loadMoreContent(() {
                  setState(() {
                    print("[ShortVideoPlay] Loading more data");
                    for (int ind = videos.length - 1;
                        ind < videos.length;
                        ++ind) {
                      print("[ShortVideoPlay] Loading $ind");
                      pageViewList.add(videoPlayBlock(videos[ind]));
                    }
                  });
                });
              }
            },
            children: pageViewList,
          ),
        ));
  }

  Widget videoPlayBlock(VideoDataModel video) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
            child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(6),
              child: CachedNetworkImage(
                imageUrl: video.videoImageLink,
                placeholder: (context, url) => const Center(
                    child: SizedBox(
                  height: 300,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            bottomWidget(video),
          ],
        )),
      ],
    );
  }

  Widget bottomWidget(VideoDataModel video) {
    return Row(
      children: [
        Flexible(child: Container(
          decoration: BoxDecoration(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(
                          left: 24, right: 12, top: 0, bottom: 12),
                      child: Text(
                        video.videoTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        maxLines: 2,
                      ))),
              bottomFAB(video)
            ],
          ),
        ))
      ],
    );
  }

  Widget bottomFAB(VideoDataModel video) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.all(12),
          child: IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ShortVideoCommentPage(
                            video: video,
                          )));
            },
            icon: Icon(
              Icons.comment,
              size: 36,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(12),
          child: IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.share,
              size: 36,
            ),
          ),
        ),
      ],
    );
  }
}
