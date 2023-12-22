import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:lawyer_ai_frontend/common/constant/constants.dart';
import 'package:lawyer_ai_frontend/common/theme/theme.dart';
import 'package:lawyer_ai_frontend/short_video/apis/short_video_api.dart';
import 'package:lawyer_ai_frontend/short_video/short_video_comment_page.dart';
import 'package:lawyer_ai_frontend/short_video/short_video_page_index.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

import '../common/data_model/data_models.dart';

class ShortVideoPlay extends StatefulWidget {
  AccountDataModel loggedAccount;
  List<VideoDataModel> videos;
  int videoIndex;

  ShortVideoPlay(
      {super.key,
      required this.videos,
      required this.videoIndex,
      required this.loggedAccount});

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
    print(serverAddress + API.videoFile.api + videos[videoIndex].videoSha1);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pageViewList =
        List.generate(videos.length, (index) => VideoPlayBlock(nowPlaying: videos[index], loggedAccount: widget.loggedAccount));
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
            videoRecommendLoadMoreContent((vid) => (vid) {
              setState(() {
                videos.add(vid);
              });
            },() {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("网络错误")));
            } , () {
              setState(() {
                print("[ShortVideoPlay] Loading more data");
                for (int ind = videos.length - 1; ind < videos.length; ++ind) {
                  print("[ShortVideoPlay] Loading $ind");
                  pageViewList.add(VideoPlayBlock(nowPlaying: videos[ind], loggedAccount: widget.loggedAccount,));
                }
              });
            });
          }
        },
        children: pageViewList,
      ),
    );
  }
}

class VideoPlayBlock extends StatefulWidget {
  AccountDataModel loggedAccount;
  VideoDataModel nowPlaying;
  VideoPlayBlock({super.key, required this.nowPlaying, required this.loggedAccount});

  @override
  State<VideoPlayBlock> createState() => _VideoPlayBlockState();
}

class _VideoPlayBlockState extends State<VideoPlayBlock> {
  late VideoPlayerController videoPlayerController;
  late ChewieController videoController;
  bool isPlaying = true;
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    widget.nowPlaying.liked = -1;
    if (widget.loggedAccount.cookie != "") {
      getVideoIsLiked(widget.loggedAccount.cookie, widget.nowPlaying).then((value) {
        var result = jsonDecode(value.body);
        print(result);
        widget.nowPlaying.liked = (result["message"] == 0 ? 0 : 1);
      });
    }
    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(
        serverAddress + API.videoFile.api + widget.nowPlaying.videoSha1))
      ..initialize().then((_) {
        setState(() {
          videoController = ChewieController(
              videoPlayerController: videoPlayerController,
              showControls: false,
              showOptions: false,
              autoPlay: true,
              looping: true,
              aspectRatio: videoPlayerController.value.aspectRatio);
          loaded = true;
        });
      });
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    if (loaded) videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!loaded) return;
        if (videoPlayerController.value.isPlaying) {
          videoPlayerController.pause();
        } else {
          videoPlayerController.play();
        }
        setState(() {
          isPlaying = !isPlaying;
        });
      },
      onDoubleTap: () {
        if (!loaded) return;
        if (widget.nowPlaying.liked == -1) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("请先登录"), duration: Duration(milliseconds: 1000),)
          );
          return;
        }
        setState(() {
          widget.nowPlaying.liked = (widget.nowPlaying.liked == 1 ? 0 : 1);
        });
        likeVideo(widget.nowPlaying, widget.loggedAccount.cookie, () {

        }).onError((error, stackTrace) {
          setState(() {
            widget.nowPlaying.liked = (widget.nowPlaying.liked == 1 ? 0 : 1);
          });
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(2),
                        child: loaded ? Chewie(
                          controller: videoController,
                        )
                            : CircularProgressIndicator(color: Colors.white,),
                      ),
                      bottomWidget(widget.nowPlaying, context),
                    ],
                  )),
            ],
          ),
          Icon(
            Icons.play_arrow,
            color: (isPlaying ? Colors.transparent : Colors.white70),
            shadows: (!isPlaying ? kElevationToShadow[6] : []),
            size: 60,
          ),
        ],
      ),
    );
  }

  Widget bottomWidget(VideoDataModel video, BuildContext context) {
    return Row(
      children: [
        Flexible(
            child: Container(
              decoration: const BoxDecoration(
                // color: Colors.black12
                  gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment(0, 0.5),
                      colors: [Colors.black54, Colors.transparent])),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                      child: Padding(
                          padding: const EdgeInsets.only(
                              left: 24, right: 12, top: 0, bottom: 12),
                          child: GestureDetector(
                            onDoubleTap: () {
                              print("[ShortVideoPlay] test for double tap");
                            },
                            onTap: () {
                              if (!loaded) return;
                              print("[ShortVideoPlay] open desc");
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 24,
                                              right: 24,
                                              top: 24,
                                              bottom: 0),
                                          child: Text(
                                            video.videoTitle,
                                            style: const TextStyle(fontSize: 24),
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.only(
                                              left: 24, right: 24, bottom: 12),
                                          child: Divider(),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 24, right: 24, bottom: 24),
                                          child: Text(
                                            video.videoDesc,
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                        )
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
                                  fontWeight: FontWeight.bold),
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
        bottomFABSingle(
            icon: (video.liked == 1 ? Icons.thumb_up : Icons.thumb_up_outlined),
            onPressed: () {
              if (!loaded) return;
              if (video.liked == -1) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("请先登录"), duration: Duration(milliseconds: 1000),));
                return;
              }
              setState(() {
                widget.nowPlaying.liked =
                (widget.nowPlaying.liked == 1 ? 0 : 1);
              });
              likeVideo(video, widget.loggedAccount.cookie, (){});
            }),
        bottomFABSingle(
            icon: Icons.comment,
            onPressed: () {
              if (!loaded) return;
              videoController.pause(); setState(() {
                isPlaying = false;
              });
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ShortVideoCommentPage(
                        video: video, loggedAccount: widget.loggedAccount,
                      )));
            }),
        bottomFABSingle(
            icon: Icons.share,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("暂未开放"), duration: Duration(milliseconds: 1000),)
              );
            }),
      ],
    );
  }

  Widget bottomFABSingle(
      {required IconData icon, required Function onPressed}) {
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

