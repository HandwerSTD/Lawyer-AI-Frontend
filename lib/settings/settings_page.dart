import 'package:flutter/material.dart';
import 'package:lawyer_ai_frontend/account/my_account_page.dart';
import 'package:lawyer_ai_frontend/common/constant/constants.dart';
import 'package:lawyer_ai_frontend/common/data_model/data_models.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lawyer_ai_frontend/settings/about/about_page.dart';

import '../common/theme/theme.dart';

class SettingsPage extends StatefulWidget {
  AccountDataModel loggedAccount;
  SettingsPage({super.key, required this.loggedAccount});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("设置"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [SettingsList()],
      ),
    );
  }
}

class SettingsList extends StatefulWidget {
  const SettingsList({super.key});

  @override
  State<SettingsList> createState() => _SettingsListState();
}

class _SettingsListState extends State<SettingsList> {
  TextEditingController changeServerAddressController = TextEditingController(text: serverAddress);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        settingsItemBlock("消息设置", () {showSnackBar(context, "暂未开放");}),
        settingsItemBlock("[调试设置] 更改服务器地址", () {
          showDialog(context: context, builder: (context) {
            return Dialog(
              child: Container(
                padding: EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: changeServerAddressController,
                      decoration: InputDecoration(hintText: "服务器地址"),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      TextButton(onPressed: () {
                        Navigator.pop(context);
                      }, child: Text("取消")),
                      TextButton(onPressed: () {
                        serverAddress = changeServerAddressController.text;
                      }, child: Text("确定"))
                    ],)
                  ],
                ),
              ),
            );
          });
        }),
        settingsItemBlock("清除缓存", () {showSnackBar(context, "暂未开放");}),
        settingsItemBlock("关于本应用", () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AboutPage()));
        })
      ],
    );
  }

}
