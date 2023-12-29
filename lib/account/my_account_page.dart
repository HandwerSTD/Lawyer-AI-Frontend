import 'package:flutter/material.dart';
import 'package:lawyer_ai_frontend/account/account_details.dart';
import 'package:lawyer_ai_frontend/account/account_login/account_login.dart';
import 'package:lawyer_ai_frontend/common/constant/constants.dart';
import 'package:lawyer_ai_frontend/common/data_model/data_models.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lawyer_ai_frontend/common/theme/theme.dart';
import 'package:lawyer_ai_frontend/settings/settings_page.dart';
import 'package:lawyer_ai_frontend/short_video/apis/short_video_api.dart';
import 'package:lawyer_ai_frontend/short_video/short_video_list.dart';

class MyAccount extends StatefulWidget {
  AccountDataModel loggedAccount;
  bool isVisitor;
  MyAccount({super.key, required this.loggedAccount, required this.isVisitor});

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  List<VideoDataModel> videoList = [];
  int pageNum = 1;
  bool isVisitor = false;

  void loadVideo() {
    loadVideoByUser(
      uid: widget.loggedAccount.uid,
      add: (vid) {
        setState(() {
          videoList.add(vid);
        });
      },
      pageNum: pageNum, setNetworkError: () {},
    ).then((value) {
      if (value["length"] != 0) {
        ++pageNum;
      }
      widget.loggedAccount.videoNum = value["count"]!;
    });
  }

  @override
  void initState() {
    super.initState();
    isVisitor = widget.isVisitor;
    if (widget.loggedAccount.cookie != "") {
      loadVideo();
    }
  }

  void refreshState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final title, listTitle, appBarItems;
    if (isVisitor) {
      title = "Ta 的主页";
      listTitle = "Ta 的视频";
      appBarItems = <Widget>[];
    } else {
      title = "我的";
      listTitle = "我的视频";
      appBarItems = [
        appBarIconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SettingsPage(
                          loggedAccount: widget.loggedAccount)))
                  .then((value) => refreshState());
            },
            icon: Icon(Icons.settings),
            text: Text("设置"),
            color: Colors.black)
      ];
    }


    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: appBarItems,
      ),
      body: Container(
        // color: themeAccent,
        color: Color(0xffebe8fc),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            myAccountBlock(),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 36, top: 12, bottom: 12),
                  child: Text(
                    listTitle + (videoList.isEmpty ? "" : " ${widget.loggedAccount.videoNum} 条"),
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            (widget.loggedAccount.cookie == ""
                ? const Text("请先登录")
                : (videoList.isEmpty
                ? const Text("空空如也")
                : Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: ShortVideoWaterfallList(
                    videoList: videoList,
                    loggedAccount: widget.loggedAccount,
                    providedAuthorAvatar: widget.loggedAccount.avatar,
                    loadMore: () {
                      loadVideoByUser(uid: widget.loggedAccount.uid, pageNum: pageNum, add: (vid) {
                        setState(() {
                          videoList.add(vid);
                        });
                      }, setNetworkError: () {}).then((value) {
                        if (value != 0) {
                          ++pageNum;
                        }
                      });
                    },
                  ),
                ))))
          ],
        ),
      ),
    );
  }

  Widget myAccountBlock() {
    return GestureDetector(
      onTap: () {
        if (isVisitor) return;

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => (widget.loggedAccount.cookie == ""
                    ? AccountLogin(
                        isFirstLogin: false,
                        loggedAccount: widget.loggedAccount)
                    : AccountDetails(
                        loggedAccount: widget.loggedAccount,
                      )))).then((value) {
                        if (widget.loggedAccount.cookie != "") {
                          setState(() {

                            loadVideo();
                          });
                        }
        });
        setState(() {});
      },
      child: Container(
        margin: EdgeInsets.only(left: 24, right: 24, bottom: 12, top: 18),
        child: Card(
          // shadowColor: Colors.black26,
          color: themeAccent,
          surfaceTintColor: Color(0xffebe8fc),
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.only(left: 24, top: 12, bottom: 12),
            child: Row(
              children: [
                accountAvatar(),
                Container(
                  margin: EdgeInsets.only(left: 24, right: 12),
                  child: Text(
                    (widget.loggedAccount.cookie == ""
                        ? "未登录"
                        : widget.loggedAccount.name),
                    style: TextStyle(fontSize: 18),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget accountAvatar() {
    return (widget.loggedAccount.cookie == ""
        ? const Icon(
            Icons.account_circle,
            size: 48,
      color: Colors.black87,
          )
        : CachedNetworkImage(
            imageBuilder: (context, image) => Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(48),
                  image: DecorationImage(image: image, fit: BoxFit.cover)),
            ),
            imageUrl: serverAddress +
                API.userAvatar.api +
                widget.loggedAccount.avatar,
            width: 96,
            height: 96,
          ));
  }
}
