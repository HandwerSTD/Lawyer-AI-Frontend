import 'package:flutter/material.dart';
import 'package:lawyer_ai_frontend/common/constant/constants.dart';
import 'package:lawyer_ai_frontend/common/theme/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("关于应用"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                appIconImage(),
                Text("紫藤法道", style: TextStyle(fontSize: 20),),
                Text("版本 Alpha v0.1"),
              ],
            ),
            Padding(padding: EdgeInsets.all(24), child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("我们的"),
                    InkWell(
                      child: Text("用户协议", style: TextStyle(color: Colors.blueAccent),),
                      onTap: () {
                        // TODO: 用户协议
                        launchUrl(Uri.parse(privacyStatementAddress), mode: LaunchMode.externalApplication);
                      },
                    ),
                    Text("与"),
                    InkWell(
                      child: Text("开放源代码许可", style: TextStyle(color: Colors.blueAccent),),
                      onTap: () {
                        // TODO: 用户协议
                        launchUrl(Uri.parse(privacyStatementAddress), mode: LaunchMode.externalApplication);
                      },
                    ),
                  ],
                )
              ],
            ),)
          ],
        ),
      ),
    );
  }
}
