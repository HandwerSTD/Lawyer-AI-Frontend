import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lawyer_ai_frontend/account/my_account_page.dart';
import 'package:lawyer_ai_frontend/common/data_model/data_models.dart';
import 'package:lawyer_ai_frontend/short_video/short_video_page_index.dart';
import 'package:provider/provider.dart';

import 'ai_chat/ai_chat_page.dart';

void main() {
  runApp(MaterialApp(
      title: '软件名称',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        fontFamily: "HarmonyOS Sans SC"
      ),
      home: ChangeNotifierProvider(
        create: (context) => StorageDataModel(),
        child: MyApp(),
      ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI 律师对话"),
        actions: [
          appBarIconButton(icon: const Icon(Icons.home), text: const Text("社区"), onPressed: () {
            if (kDebugMode) {
              print("[Main Page] Navigating to ShortVideoWaterfall");
            }
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ShortVideoPageIndex()));
          }),
          appBarIconButton(icon: const Icon(Icons.account_circle), text: const Text("我的"), onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AccountPage(loggedAccount: loggedAccount,)));
          }),
        ],
      ),
      body: const AIChatPage(),
    );
  }

  Widget appBarIconButton({required Icon icon, required Text text, required Function onPressed}) {
    return ElevatedButton(
        onPressed: () { onPressed(); },
        style: const ButtonStyle(
          backgroundColor: MaterialStatePropertyAll<Color>(Colors.transparent),
          surfaceTintColor: MaterialStatePropertyAll<Color>(Colors.transparent),
          shadowColor: MaterialStatePropertyAll<Color>(Colors.transparent),
        ),
        child: Row(
          children: [icon, Container(padding: const EdgeInsets.only(left: 5), child: text)],
        )
    );
  }
}
