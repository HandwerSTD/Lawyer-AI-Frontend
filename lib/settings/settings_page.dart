import 'package:flutter/material.dart';
import 'package:lawyer_ai_frontend/account/my_account_page.dart';
import 'package:lawyer_ai_frontend/common/constant/constants.dart';
import 'package:lawyer_ai_frontend/common/data_model/data_models.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

class SettingsList extends StatelessWidget {
  const SettingsList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        settingsItemBlock("消息设置", () {}),
        settingsItemBlock("清除缓存", () {}),
        settingsItemBlock("关于本应用", () {})
      ],
    );
  }


}
