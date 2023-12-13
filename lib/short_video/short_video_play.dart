import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:lawyer_ai_frontend/common/constant/constants.dart';
import 'package:lawyer_ai_frontend/common/theme/theme.dart';
import 'package:lawyer_ai_frontend/short_video/short_video_comment_page.dart';
import 'package:lawyer_ai_frontend/short_video/short_video_page_index.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

import '../common/data_model/data_models.dart';

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
  late VideoPlayerController videoPlayerController;
  late ChewieController videoController;

  @override
  void initState() {
    super.initState();
    videos = widget.videos;
    videoIndex = widget.videoIndex;
    pgController = PageController(initialPage: videoIndex);
    print(serverAddress + API.videoFile.api + videos[videoIndex].videoSha1);
    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(serverAddress + API.videoFile.api + videos[videoIndex].videoSha1));
    videoController = ChewieController(
      autoInitialize: true,
        autoPlay: true,
        videoPlayerController: videoPlayerController
    );
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
        body: PageView(
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
        );
  }

  Widget videoPlayBlock(VideoDataModel video) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Flexible(child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(2),
              child: Chewie(
                controller: videoController,
              ),
            ),
            bottomWidget(video, context),
          ],
        ))
      ],
    );
  }

  Widget bottomWidget(VideoDataModel video, BuildContext context) {
    return Row(
      children: [
        Flexible(child: Container(
          decoration: const BoxDecoration(
            // color: Colors.black12
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
                end: Alignment(0, 0.5),
                colors: [Colors.black54, Colors.transparent]
            )
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(left: 24, right: 12, top: 0, bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      print("[ShortVideoPlay] open desc");
                      showModalBottomSheet(context: context, builder: (context) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 0), child:
                              Text(video.videoTitle, style: TextStyle(fontSize: 24),)
                              ,),
                            Padding(padding: EdgeInsets.only(left: 24, right: 24, bottom: 12), child: Divider(),),
                            Padding(padding: EdgeInsets.only(left: 24, right: 24, bottom: 24), child:
                            Text(video.videoDesc, style: TextStyle(fontSize: 16),),)
                          ],
                        );
                      });
                    },
                    child: Text(
                      video.videoTitle,
                      style: TextStyle(
                          shadows: kElevationToShadow[3],
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      ),
                      maxLines: 2,
                    ),
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
        bottomFABSingle(icon: Icons.thumb_up_outlined, onPressed: () {
          // TODO: Like & Dislike
        }),
        bottomFABSingle(icon: Icons.comment, onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ShortVideoCommentPage(
                    video: video,
                  )));
        }),
        bottomFABSingle(icon: Icons.share, onPressed: () {
          // TODO: Share
        }),
      ],
    );
  }
  Widget bottomFABSingle({required IconData icon, required Function onPressed}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: IconButton(
        onPressed: () {
          onPressed();
        },
        icon: Icon(
          icon,
          size: 36,
          shadows: [fabBoxShadow],
          color: Colors.white,
        ),
      ),
    );
  }
}
