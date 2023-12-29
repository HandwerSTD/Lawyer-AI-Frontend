import 'package:flutter/material.dart';
import 'package:lawyer_ai_frontend/common/theme/theme.dart';

class ChatHistory extends StatelessWidget {
  const ChatHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: ,
      appBar: AppBar(
        // leading: BackButton(),
        title: Text("对话历史"),
        // backgroundColor: Color(0xfff1f3f5),
      ),
      body: Container(
        margin: EdgeInsets.all(24),
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white
        ),
        child:  ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text("杀害野生动物会触犯什么法律？"),
              subtitle: Text("2023-12-17\n根据我国的相关法律法规，《中华人民共和国野生动物保护法》（以下简称“《野生动物保……"),
            ),
            Divider(),
            ListTile(
              title: Text("在法律纠纷收集取证的时候要注意什么？"),
              subtitle: Text("2023-12-15\n在处理法律纠纷时，首先要弄清楚争议的具体内容和相关法律法规的规定，以此为基础进行……"),
            ),
            Divider(),ListTile(
              title: Text("分析一下以下的法律纠纷案例。……"),
              subtitle: Text("2023-12-14\n根据我国《中华人民共和国治安管理处罚法》的规定，对于恶意诬告陷害他人，导致被诬告……"),
            ),
          ],
        ),
      ),
    );
  }
}
