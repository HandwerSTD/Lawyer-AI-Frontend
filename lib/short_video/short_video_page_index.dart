import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lawyer_ai_frontend/common/constant/constants.dart';
import 'package:lawyer_ai_frontend/short_video/apis/short_video_api.dart';
import 'package:lawyer_ai_frontend/short_video/short_video_list.dart';
import 'package:http/http.dart' as http;
import 'package:lawyer_ai_frontend/short_video/short_video_upload.dart';

import '../common/data_model/data_models.dart';

class ShortVideoPageIndex extends StatefulWidget {
  AccountDataModel loggedAccount;
  ShortVideoPageIndex({super.key, required this.loggedAccount});

  @override
  State<ShortVideoPageIndex> createState() => _ShortVideoPageIndexState();
}

class _ShortVideoPageIndexState extends State<ShortVideoPageIndex> {
  List<VideoDataModel> sttVideoList = [];

  @override
  void initState() {
    super.initState();
    getVideoList((vid) {
      setState(() {
        sttVideoList.add(vid);
      });
    }); // 组件加载的时候调用刷新
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('社区'),
        actions: [
          IconButton(
              onPressed: () {
                sttVideoList.clear();
                getVideoList((vid) {
                  setState(() {
                    sttVideoList.add(vid);
                  });
                });
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            ShortVideoWaterfallList(
              videoList: sttVideoList,
              loggedAccount: widget.loggedAccount,
            ),
           Padding(padding: EdgeInsets.all(24), child:  FloatingActionButton.extended(
             onPressed: () {
               if (widget.loggedAccount.cookie == "") {
                 ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text("请先登录"), duration: Duration(milliseconds: 1000),)
                 );
                 return;
               }
               ImagePicker().pickVideo(source: ImageSource.gallery).then((selectVideo) {
                 if (selectVideo == null) return;
                 Navigator.push(
                     context,
                     MaterialPageRoute(
                         builder: (context) => ShortVideoUpload(
                           loggedAccount: widget.loggedAccount,
                           selectedFile: selectVideo,
                         )));
               });

             },
             isExtended: true,
             label: Text("上传视频"),
             icon: Icon(Icons.add),
           ),)
          ],
        ),
      ),
    );
  }
}
