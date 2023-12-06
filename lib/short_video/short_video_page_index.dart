import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lawyer_ai_frontend/short_video/short_video_list.dart';
import 'package:http/http.dart' as http;


class ShortVideoPageIndex extends StatefulWidget {
  const ShortVideoPageIndex({super.key});

  @override
  State<ShortVideoPageIndex> createState() => _ShortVideoPageIndexState();
}

class _ShortVideoPageIndexState extends State<ShortVideoPageIndex> {
  List<VideoDataModel> sttVideoList = [];

  void getVideoList() {
    /* TODO: Implement API */
    sttVideoList.clear();
    for (int index = 0; index < 10; ++index) {
      http.get(Uri.parse('https://api.likepoems.com/img/pe/?type=JSON'))
          .then((value) {
        http.get(Uri.parse("https://v1.hitokoto.cn/?encode=text&charset=utf-8"))
        .then((value2) {
          String videoImageURL = jsonDecode(value.body)["url"];
          String title = value2.body;
          if (kDebugMode) {
            print(videoImageURL);
            print(title);
          }
          setState(() {
            sttVideoList.add(VideoDataModel(
                "", videoImageURL, title
            ));
          });
        });
      });
    }
  }
  void loadMoreContent() {
    /* TODO: Implement API */
    for (int index = 0; index < 10; ++index) {
      http.get(Uri.parse('https://api.likepoems.com/img/pe/?type=JSON'))
          .then((value) {
        http.get(Uri.parse("https://v1.hitokoto.cn/?encode=text&charset=utf-8"))
            .then((value2) {
          String videoImageURL = jsonDecode(value.body)["url"];
          String title = value2.body;
          if (kDebugMode) {
            print(videoImageURL);
            print(title);
          }
          setState(() {
            sttVideoList.add(VideoDataModel(
                "", videoImageURL, title
            ));
          });
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getVideoList(); // 组件加载的时候调用刷新
  }

  @override
  Widget build(BuildContext context) {
    // if (firstInRefresh) {
    //   getVideoList();
    //   firstInRefresh = false;
    // }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('社区'),
        actions: [
          IconButton(onPressed: getVideoList, icon: const Icon(Icons.refresh))
        ],
      ),
      body: Center(
        child: ShortVideoWaterfallPage(videoList: sttVideoList, loadMoreContent: loadMoreContent),
      ),
    );
  }
}

class VideoDataModel {
  int id = 0;
  String videoLink = "";
  String videoImageLink = "";
  String videoTitle = "";
  VideoDataModel(vLink, iLink, title) {
    videoImageLink = iLink;
    videoLink = vLink;
    videoTitle = title;
  }
}

