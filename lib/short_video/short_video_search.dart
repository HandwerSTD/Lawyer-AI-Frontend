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

class ShortVideoSearch extends StatefulWidget {
  AccountDataModel loggedAccount;
  ShortVideoSearch({super.key, required this.loggedAccount});

  @override
  State<ShortVideoSearch> createState() => _ShortVideoSearchState();
}

class _ShortVideoSearchState extends State<ShortVideoSearch> {
  List<VideoDataModel> sttVideoList = [];
  bool isSearchEmpty = false;
  bool isNetworkError = false;
  String searchContent = "";
  int pageNum = 1;
  // TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void setNetworkError() {
    setState(() {
      isNetworkError = true;
    });
  }

  void appendVideoList(vid) {
    setState(() {
      sttVideoList.add(vid);
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Border & Background as Design
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        // title: const Text('社区'),
        title: SearchAppBar(
          hintLabel: '搜索视频',
          onSubmitted: (value) {
            searchContent = value;
            setState(() {
              isSearchEmpty = false;
              isNetworkError = false;
              sttVideoList.clear();
            });
            pageNum = 1;
            getSearchVideoList(value, pageNum, appendVideoList, setNetworkError)
                .then((value) {
              if (value != 0) {
                ++pageNum;
              } else {
                setState(() {
                  isSearchEmpty = true;
                });
              }
            });
          },
          widthFactor: 0.8, readOnly: false, onTap: (){},
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
                  (isNetworkError
                      ? NetworkErrorPlaceholder()
                      : (isSearchEmpty
                          ? Text("空空如也")
                          : ShortVideoWaterfallList(
                              videoList: sttVideoList,
                              loggedAccount: widget.loggedAccount,
                              providedAuthorAvatar: '',
                              loadMore: () {
                                getSearchVideoList(searchContent, pageNum,
                                        appendVideoList, setNetworkError)
                                    .then((value) {
                                  if (value != 0) {
                                    ++pageNum;
                                  }
                                });
                              },
                            ))),
                ],
              ),
            )
          ],
        ),
      ])),
    );
  }
}

class SearchAppBar extends StatefulWidget {
  SearchAppBar(
      {Key? key,
      required this.hintLabel,
      required this.onSubmitted,
      required this.widthFactor,
      required this.readOnly,
      required this.onTap})
      : super(key: key);
  final String hintLabel;
  double widthFactor = 0.8;
  bool readOnly = false;
  Function onTap;
  // 回调函数
  final Function(String) onSubmitted;

  @override
  State<StatefulWidget> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  // 焦点对象
  FocusNode _focusNode = FocusNode();
  // 文本的值
  String searchVal = '';
  //用于清空输入框
  TextEditingController _controller = TextEditingController();

  void initState() {
    super.initState();
    //  获取焦点
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 获取屏幕尺寸
    MediaQueryData queryData = MediaQuery.of(context);
    return Container(
      // 宽度为width * factor
      width: queryData.size.width * widget.widthFactor,
      // appBar默认高度是56，这里搜索框设置为40
      height: 40,
      // 设置padding
      padding: EdgeInsets.only(left: 20, top: 0),
      // 设置子级位置
      alignment: Alignment.centerLeft,
      // 设置修饰
      decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.black26),
          borderRadius: BorderRadius.circular(10),
          color: Color(0xfffefbff)),
      child: TextField(
        // style: TextStyle(height: 1),
        textAlignVertical: TextAlignVertical.center,
        controller: _controller,
        // 自动获取焦点
        focusNode: _focusNode,
        autofocus: true,
        readOnly: widget.readOnly,
        onTap: (widget.readOnly ? () {widget.onTap();} : null),
        decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            hintText: widget.hintLabel,
            hintStyle: TextStyle(color: Colors.grey),
            // 取消掉文本框下面的边框
            border: InputBorder.none,
            icon: Padding(
                padding: const EdgeInsets.only(left: 0),
                child: Icon(
                  Icons.search,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                )),
            //  关闭按钮，有值时才显示
            suffixIcon: this.searchVal.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      //   清空内容
                      setState(() {
                        this.searchVal = '';
                        _controller.clear();
                      });
                    },
                  )
                : null),
        onChanged: (value) {
          setState(() {
            this.searchVal = value;
          });
        },
        onSubmitted: (value) {
          widget.onSubmitted(value);
        },
      ),
    );
  }
}
