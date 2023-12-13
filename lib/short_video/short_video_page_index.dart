import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lawyer_ai_frontend/common/constant/constants.dart';
import 'package:lawyer_ai_frontend/short_video/short_video_list.dart';
import 'package:http/http.dart' as http;

import '../common/data_model/data_models.dart';


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
    // for (int index = 0; index < 10; ++index) {
    //   http.get(Uri.parse('https://api.likepoems.com/img/pe/?type=JSON'))
    //       .then((value) {
    //     http.get(Uri.parse("https://v1.hitokoto.cn/?encode=text&charset=utf-8"))
    //     .then((value2) {
    //       String videoImageURL = jsonDecode(value.body)["url"];
    //       String title = value2.body;
    //       if (kDebugMode) {
    //         print(videoImageURL);
    //         print(title);
    //       }
    //       setState(() {
    //         sttVideoList.add(VideoDataModel(
    //             "", videoImageURL, title, title
    //         ));
    //       });
    //     });
    //   });
    // }
    //
    print("[ShortVideoPageIndex] fetching video list");
    http.post(
        Uri.parse(serverAddress + API.videoSearch.api),
      headers: jsonHeaders,
      body: jsonEncode({"title": "原神"}),
    )
    .then((value) {
      var result = jsonDecode(Utf8Decoder().convert(value.bodyBytes));
      if (result["status"] != "success") throw HttpException(result["message"]);
      var videoList = result["result"];
      print(videoList);
      for (int i = 0; i < (videoList as List).length; ++i) {
        setState(() {
          sttVideoList.add(VideoDataModel(videoList[i]["sha1"], serverAddress + API.videoCover.api + videoList[i]["cover_sha1"], videoList[i]["title"], videoList[i]["title"]));
        });

      }
    })
    .onError((error, stackTrace) {
      print(error);
    });
  }
  void loadMoreContent(Function? callback)  {
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
                "", videoImageURL, title, title
            ));
          });
          if (callback != null) callback();
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
        child: ShortVideoWaterfallList(videoList: sttVideoList, loadMoreContent: loadMoreContent),
      ),
    );
  }
}



