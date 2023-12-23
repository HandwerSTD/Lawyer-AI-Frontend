import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lawyer_ai_frontend/common/constant/constants.dart';
import 'package:lawyer_ai_frontend/common/theme/theme.dart';
import 'package:lawyer_ai_frontend/short_video/apis/short_video_api.dart';
import 'package:lawyer_ai_frontend/short_video/short_video_list.dart';
import 'package:http/http.dart' as http;
import 'package:lawyer_ai_frontend/short_video/short_video_search.dart';
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
  bool isNetworkError = false;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    getVideoList((vid) {
      if (mounted) {
        setState(() {
          sttVideoList.add(vid);
        });
      }
    }, () {
      if (mounted) {
        setState(() {
          isNetworkError = true;
        });
      }
    });
    // 组件加载的时候调用刷新
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Border & Background as Design
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        titleSpacing: 4,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    )),
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Text('社区'),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.only(right: 6),
              child: SearchAppBar(
                hintLabel: "搜索视频",
                onSubmitted: (val) {},
                widthFactor: 0.65,
                readOnly: true,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ShortVideoSearch(
                              loggedAccount: widget.loggedAccount)));
                },
              ),
            )
          ],
        ),
      ),
      body: Center(
          child: Stack(children: [
        Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  RefreshIndicator(
                      child: (isNetworkError
                          ? NetworkErrorPlaceholder()
                          : ShortVideoWaterfallList(
                              videoList: sttVideoList,
                              loggedAccount: widget.loggedAccount,
                              providedAuthorAvatar: '',
                              loadMore: () async {
                                return videoRecommendLoadMoreContent((vid) {
                                  setState(() {
                                    sttVideoList.add(vid);
                                  });
                                }, () {
                                  setState(() {
                                    isNetworkError = true;
                                  });
                                }, () {});
                              },
                            )),
                      onRefresh: () async {
                        setState(() {
                          sttVideoList.clear();
                          isNetworkError = false;
                        });
                        await getVideoList((vid) {
                          setState(() {
                            sttVideoList.add(vid);
                          });
                        }, () {
                          setState(() {
                            isNetworkError = true;
                          });
                        });
                      }),
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        if (widget.loggedAccount.cookie == "") {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("请先登录"),
                            duration: Duration(milliseconds: 1000),
                          ));
                          return;
                        }
                        ImagePicker()
                            .pickVideo(source: ImageSource.gallery)
                            .then((selectVideo) {
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
                      label: const Text("上传视频"),
                      icon: const Icon(Icons.add),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ])),
    );
  }
}
