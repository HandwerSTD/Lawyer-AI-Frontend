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

// class AccountPage extends StatefulWidget {
//   AccountDataModel loggedAccount;
//   AccountPage({super.key, required this.loggedAccount});
//
//   @override
//   State<AccountPage> createState() => _AccountPageState();
// }
//
// class _AccountPageState extends State<AccountPage> {
//   @override
//   Widget build(BuildContext context) {
//     return widget.loggedAccount.cookie == ""
//         ? AccountLogin(
//             isFirstLogin: false,
//             loggedAccount: widget.loggedAccount,
//           )
//         : MyAccount(
//             loggedAccount: widget.loggedAccount,
//           );
//   }
// }

class MyAccount extends StatefulWidget {
  AccountDataModel loggedAccount;
  MyAccount({super.key, required this.loggedAccount});

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  List<VideoDataModel> videoList = [];

  @override
  void initState() {
    super.initState();
    // TODO: Fetch User's Video
    getVideoList((vid) {
      setState(() {
        videoList.add(vid);
      });
    });
  }
  
  void refreshState() {
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("我的"),
        actions: [
          appBarIconButton(onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage(loggedAccount: widget.loggedAccount))).then((value) => refreshState());
          }, icon: Icon(Icons.settings), text: Text("设置"), color: Colors.black)
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          myAccountBlock(),
          const Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(padding: EdgeInsets.only(left: 36, top: 12, bottom: 12), child: Text("我的视频", style: TextStyle(fontSize: 18, ),),),],
          ),
          (widget.loggedAccount.cookie == "" || videoList.isEmpty ? const Text("请先登录") :
          Expanded(child: ShortVideoWaterfallList(videoList: videoList, loggedAccount: widget.loggedAccount,)))
        ],
      ),
    );
  }

  Widget myAccountBlock() {
    return GestureDetector(
      onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => (widget.loggedAccount.cookie == "" ? AccountLogin(isFirstLogin: false, loggedAccount: widget.loggedAccount) : AccountDetails(loggedAccount: widget.loggedAccount,))
                      )).then((value) => refreshState());
        setState(() {});
      },
      child: Container(
        margin: EdgeInsets.only(left: 24, right: 24, bottom: 12),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(12),
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
          )
        : CachedNetworkImage(
            imageBuilder: (context, image) => Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
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
