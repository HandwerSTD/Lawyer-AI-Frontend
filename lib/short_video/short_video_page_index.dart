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
  bool isSearching = false;
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
        // automaticallyImplyLeading: false,
        title: const Text('社区'),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  isSearching = !isSearching;
                });
              },
              icon: const Icon(Icons.search)),
          IconButton(
              onPressed: () {
                sttVideoList.clear();
                setState(() {
                  isNetworkError = false;
                });
                getVideoList((vid) {
                  setState(() {
                    sttVideoList.add(vid);
                  });
                }, () {
                  setState(() {
                    isNetworkError = true;
                  });
                });
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: Center(
          child: Stack(children: [
        Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  (isNetworkError
                      ? NetworkErrorPlaceholder()
                      : ShortVideoWaterfallList(
                          videoList: sttVideoList,
                          loggedAccount: widget.loggedAccount, providedAuthorAvatar: '', loadMore: loadMoreContent,
                        )),
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
        AnimatedOpacity(
          opacity: (isSearching ? 1 : 0),
          duration: Duration(milliseconds: 100),
          child: Visibility(
              visible: isSearching,
              child: Padding(
                padding: EdgeInsets.only(left: 24, right: 24, bottom: 12),
                child: SearchBar(
                  controller: controller,
                  elevation: MaterialStatePropertyAll(3),
                  // shadowColor: MaterialStatePropertyAll(Colors.transparent),
                  backgroundColor: MaterialStatePropertyAll(Color(0xfff1f3f5)),
                  surfaceTintColor:
                      MaterialStatePropertyAll(Colors.transparent),
                  leading: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.search,
                      color: Colors.black,
                    ),
                  ),
                  onSubmitted: (value) {
                    setState(() {
                      sttVideoList.clear();
                    });
                    getSearchVideoList(value, (vid) {
                      setState(() {
                        sttVideoList.add(vid);
                      });
                    });
                  },
                ),
              )),
        )
      ])),
    );
  }
}
