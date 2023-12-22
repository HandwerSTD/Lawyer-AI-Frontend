import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:lawyer_ai_frontend/account/my_account_page.dart';
import 'package:lawyer_ai_frontend/common/data_model/data_models.dart';
import 'package:lawyer_ai_frontend/settings/settings_page.dart';
import 'package:lawyer_ai_frontend/short_video/short_video_page_index.dart';
import 'package:provider/provider.dart';

import 'ai_chat/ai_chat_page.dart';
import 'common/theme/theme.dart';

void main() {
  runApp(GetMaterialApp(
      title: '紫藤法道',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        fontFamily: "HarmonyOS Sans SC"
      ),
      home: ChangeNotifierProvider(
        create: (context) => StorageDataModel(),
        child: MyApp(),
      ),
      routes: { //注册路由
        // //search 表示注册名  SearchPage表示跳转页面
        // '/search':(context) => SearchPage(),
        // '/textWork':(context)=>TextWordPage()
      }
    )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AccountDataModel loggedAccount = AccountDataModel("", "", "", "");

  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage("assets/rounded_app_icon.png"), context);
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: themeAccent,
        title: const Text("紫藤法道"),
        actions: [
          appBarIconButton(icon: const Icon(Icons.home), text: const Text("社区"), onPressed: () {
            if (kDebugMode) {
              print("[Main Page] Navigating to ShortVideoWaterfall");
            }
            Navigator.push(context, MaterialPageRoute(builder: (context) => ShortVideoPageIndex(loggedAccount: loggedAccount,), settings: RouteSettings(name: '/home')));
          }),
          appBarIconButton(icon: const Icon(Icons.account_circle), text: const Text("我的"), onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MyAccount(loggedAccount: loggedAccount), settings: RouteSettings(name: '/home')));
          }),
        ],
      ),
      body: AIChatPage(loggedAccount: loggedAccount,),
    );
  }
}
