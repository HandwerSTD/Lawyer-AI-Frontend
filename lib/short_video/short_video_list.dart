import 'package:flutter/material.dart';
import 'package:lawyer_ai_frontend/common/constant/constants.dart';
import 'package:lawyer_ai_frontend/short_video/apis/short_video_api.dart';
import 'package:lawyer_ai_frontend/short_video/short_video_page_index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lawyer_ai_frontend/short_video/short_video_play.dart';
import 'package:typicons_flutter/typicons_flutter.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../common/data_model/data_models.dart';

class ShortVideoWaterfallList extends StatefulWidget {
  List<VideoDataModel> videoList;
  AccountDataModel loggedAccount;
  String providedAuthorAvatar = "";
  Function loadMore;
  ShortVideoWaterfallList(
      {super.key,
      required this.videoList,
      required this.loggedAccount,
      required this.providedAuthorAvatar,
      required this.loadMore});

  @override
  State<ShortVideoWaterfallList> createState() =>
      _ShortVideoWaterfallListState();
}

class _ShortVideoWaterfallListState extends State<ShortVideoWaterfallList> {
  List<VideoDataModel> sttVideoList = [];

  ScrollController wfController = ScrollController();

  @override
  void initState() {
    super.initState();
    sttVideoList = widget.videoList;

    wfController.addListener(() {
      if (wfController.position.pixels ==
          wfController.position.maxScrollExtent) {
        print("[ShortVideoList] Scrolled to end, loading data");
        // if (widget.searchInfo == "") {
        //   widget.loadMore((vid) {
        //     setState(() {
        //       sttVideoList.add(vid);
        //     });
        //   }, () {
        //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("网络错误")));
        //   } , () {}); // 到底部加载新内容
        // } else {
        //   widget.loadMore(widget.searchInfo, (vid) {
        //     setState(() {
        //       sttVideoList.add(vid);
        //     });
        //   }, () {
        //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("网络错误")));
        //   } , () {}); // 到底部加载新内容
        // }
        widget.loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: const EdgeInsets.only(left: 5, right: 5),
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
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ShortVideoPlay(
                          videos: sttVideoList,
                          videoIndex: sttVideoList.indexOf(video),
                          loggedAccount: widget.loggedAccount,
                        )));
          },
          child: Padding(
            padding: EdgeInsets.only(left: 6, right: 4, top: 4, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 5, right: 5, top: 5, bottom: 12),
                  child: CachedNetworkImage(
                    imageUrl: video.videoImageLink,
                    placeholder: (context, url) => const Center(
                        child: SizedBox(
                      height: 300,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 10, right: 10, bottom: 6),
                  child: Text(
                    video.videoTitle,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 14, letterSpacing: 0.1),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CachedNetworkImage(
                              imageUrl: serverAddress +
                                  API.userAvatar.api +
                                  video.authorIcon,
                              height: 22,
                              width: 22,
                              imageBuilder: (context, image) => Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        image: DecorationImage(
                                            image: image, fit: BoxFit.cover)),
                                  )),
                          Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Text(
                              video.author,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                      Row(
                        // crossAxisAlignment: en,
                        children: [
                          const Icon(
                            TypIconData(0xE087),
                            color: Color(0xbb000000),
                          ),
                          Text(" ${video.gotLikes.toString()}")
                        ],
                      )
                    ],
                  ),
                ),
                // Divider()
              ],
            ),
          ),
        )
      ],
    );
  }
}
