import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lawyer_ai_frontend/account/my_account_page.dart';
import 'package:lawyer_ai_frontend/common/constant/constants.dart';
import 'package:lawyer_ai_frontend/common/theme/theme.dart';
import 'package:lawyer_ai_frontend/common/utils/time_utils.dart';
import 'package:lawyer_ai_frontend/short_video/apis/short_video_api.dart';
import 'package:lawyer_ai_frontend/short_video/short_video_comment_page.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../common/data_model/data_models.dart';

class ShortVideoPlay extends StatefulWidget {
  AccountDataModel loggedAccount;
  List<VideoDataModel> videos;
  int videoIndex;
  Function loadVideo;

  ShortVideoPlay(
      {super.key,
      required this.videos,
      required this.videoIndex,
      required this.loggedAccount,
      required this.loadVideo});

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
    List<Widget> pageViewList = List.generate(
        videos.length,
        (index) => VideoPlayBlock(
            nowPlaying: videos[index], loggedAccount: widget.loggedAccount));
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0, //去除状态栏下的一条阴影
        toolbarHeight: 0,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        // systemOverlayStyle: SystemUiOverlayStyle(
        //   // statusBarColor: Colors.black,
        //   systemNavigationBarColor: Colors.black,
        //   // systemNavigationBarIconBrightness: Brightness.light,
        //   // statusBarIconBrightness: Brightness.light,
        //   // statusBarBrightness: Brightness.light,
        // ),
        // systemOverlayStyle: SystemUiOverlayStyle.dark,
        // backgroundColor: Colors.white,
      ),
      body: Container(
        // padding: EdgeInsets.only(top: 24),
        child: PageView(
          controller: pgController,
          scrollDirection: Axis.vertical,
          onPageChanged: (index) async {
            if (index == videos.length - 1) {
              print("[ShortVideoPlay] Scrolled to end");
              await widget.loadVideo();
              setState(() {
                print("[ShortVideoPlay] Loading more data");
                for (int ind = index; ind < videos.length; ++ind) {
                  print("[ShortVideoPlay] Loading $ind");
                  pageViewList.add(VideoPlayBlock(
                    nowPlaying: videos[ind],
                    loggedAccount: widget.loggedAccount,
                  ));
                }
              });
            }
          },
          children: pageViewList,
        ),
      ),
    );
  }
}

class VideoPlayBlock extends StatefulWidget {
  AccountDataModel loggedAccount;
  VideoDataModel nowPlaying;
  VideoPlayBlock(
      {super.key, required this.nowPlaying, required this.loggedAccount});

  @override
  State<VideoPlayBlock> createState() => _VideoPlayBlockState();
}

class _VideoPlayBlockState extends State<VideoPlayBlock> {
  late VideoPlayerController videoPlayerController;
  late ChewieController videoController;
  // bool isPlaying = true;
  bool loaded = false;

  void pauseVideo() {
    setState(() {
      videoPlayerController.pause();
    });
  }
  void resumeVideo() {
    setState(() {
      videoPlayerController.play();
    });
  }

  @override
  void initState() {
    super.initState();
    widget.nowPlaying.liked = -1;
    if (widget.loggedAccount.cookie != "") {
      getVideoIsLiked(widget.loggedAccount.cookie, widget.nowPlaying)
          .then((value) {
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
        resumeVideo();
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
    var appBarHeight = MediaQuery.of(context).size.height * 0.8;

    return GestureDetector(
      onTap: () {
        if (!loaded) return;
        if (videoPlayerController.value.isPlaying) {
          pauseVideo();
        } else {
          resumeVideo();
        }
        // setState(() {
        //   isPlaying = !isPlaying;
        // });
      },
      onDoubleTap: () {
        if (!loaded) return;
        if (widget.nowPlaying.liked == -1) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("请先登录"),
            duration: Duration(milliseconds: 1000),
          ));
          return;
        }
        setState(() {
          widget.nowPlaying.liked = (widget.nowPlaying.liked == 1 ? 0 : 1);
        });
        likeVideo(widget.nowPlaying, widget.loggedAccount.cookie, () {})
            .onError((error, stackTrace) {
          setState(() {
            widget.nowPlaying.liked = (widget.nowPlaying.liked == 1 ? 0 : 1);
          });
        });
      },
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          Column(
            children: [
              Flexible(
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
                            child: loaded
                                ? Chewie(
                                    controller: videoController,
                                  )
                                : CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                          ),
                          bottomWidget(widget.nowPlaying, context),
                        ],
                      )),
                    ],
                  ),
                  Icon(
                    Icons.play_arrow,
                    color: ((!loaded || (loaded && videoController.isPlaying)) ? Colors.transparent : Colors.white70),
                    shadows: ((!loaded || (loaded && videoController.isPlaying)) ? [] : kElevationToShadow[6]),
                    size: 60,
                  ),
                ],
              ))
            ],
          ),
          Row(
            children: [
              Expanded(
                  child: Container(
                height: appBarHeight,
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(left: 6),
                decoration: const BoxDecoration(
                    // color: Colors.black12
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment(0, -0.8),
                        colors: [Colors.black54, Colors.transparent])),
                // margin: EdgeInsets.only(top: 24),
                child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    )),
              ))
            ],
          )
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
              gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment(0, 0.5),
                  colors: [Colors.black54, Colors.transparent])),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
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
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    ),

                                    Padding(padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4), child: Text(
                                      TimeUtils.formatDateTime(video.timestamp.toInt()),
                                      style: TextStyle(color: Colors.black54),
                                    ),),const Padding(
                                      padding:
                                      EdgeInsets.only(left: 24, right: 24),
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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            authorInfo(video),
                            Text(
                              video.videoTitle,
                              style: TextStyle(
                                  shadows: kElevationToShadow[3],
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                              maxLines: 2,
                            )
                          ],
                        ),
                      ))),
              bottomFAB(video)
            ],
          ),
        ))
      ],
    );
  }

  Widget authorInfo(VideoDataModel video) {
    return GestureDetector(
      onTap: () {
        if (!loaded) return;
        pauseVideo();
        // setState(() {
        //   isPlaying = false;
        // });
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MyAccount(
                      loggedAccount: AccountDataModel(video.author,
                          video.authorUid, video.authorIcon, widget.loggedAccount.cookie),
                      isVisitor: true,
                    )));
      },
      child: Container(
        margin: EdgeInsets.only(left: 0, top: 4, bottom: 12),
        child: Row(
          children: [
            CachedNetworkImage(
                imageUrl: serverAddress + API.userAvatar.api + video.authorIcon,
                height: 48,
                width: 48,
                imageBuilder: (context, image) => Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          image:
                              DecorationImage(image: image, fit: BoxFit.cover)),
                    )),
            Padding(
              padding: EdgeInsets.only(left: 12, top: 2),
              child: Text(
                video.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
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
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("请先登录"),
                  duration: Duration(milliseconds: 1000),
                ));
                return;
              }
              setState(() {
                widget.nowPlaying.liked =
                    (widget.nowPlaying.liked == 1 ? 0 : 1);
              });
              likeVideo(video, widget.loggedAccount.cookie, () {});
            }),
        bottomFABSingle(
            icon: Icons.comment,
            onPressed: () {
              if (!loaded) return;
              pauseVideo();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ShortVideoCommentPage(
                            video: video,
                            loggedAccount: widget.loggedAccount,
                          )));
            }),
        // bottomFABSingle(
        //     icon: Icons.share,
        //     onPressed: () {
        //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //         content: Text("暂未开放"),
        //         duration: Duration(milliseconds: 1000),
        //       ));
        //     }),
      ],
    );
  }

  Widget bottomFABSingle(
      {required IconData icon, required Function onPressed}) {
    return Container(
      height: 52,
      width: 52,
      margin: const EdgeInsets.all(12),
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
