import 'package:flutter/material.dart';
import 'package:lawyer_ai_frontend/common/theme/theme.dart';

import '../common/data_model/data_models.dart';

bool instanceFirstOpen = false;

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}
class _AIChatPageState extends State<AIChatPage> {
  List<ChatMsgData> sttChatMsgList = [];

  Future<String> getFromAPI() async {
    var result = await Future.delayed(const Duration(seconds: 2), () {
      return "|get api test";
    });
    return result;
  }

  void submitNewMessage(String text) {
    if (text != "") {
      setState(() {
        sttChatMsgList.add(ChatMsgData(text, true));
      });
      var networkResult = "";
      getFromAPI().then((value) {
        networkResult = value;
        setState(() {
          sttChatMsgList.add(ChatMsgData("你说的对，但是$text$networkResult", false));
        });
      }).catchError((err) {
        networkResult = "Error: Network failed";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!instanceFirstOpen) {
      setState(() {
        sttChatMsgList.add(ChatMsgData("您好，我是您的专属 AI 律师顾问！我可以提供各种信息，或者回答一些法律问题。有什么问题想问的？", false));
      });
      instanceFirstOpen = true;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: ListView(
          shrinkWrap: true,
          children: sttChatMsgList.map((e) => chatMessageBlock(e)).toList(),
        )),
        bottomSendMsgButton()
      ],
    );
  }

  Widget bottomSendMsgButton() {
    TextEditingController controller = TextEditingController();

    return Container(
      margin: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "向 AI 律师问点什么吧",
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 24),
            child: ElevatedButton(onPressed: (){
              submitNewMessage(controller.text);
            }, child: const Icon(Icons.send)),
          )
        ],
      ),
    );
  }

  Widget chatMessageBlock(ChatMsgData msgData) {
    Color foreground = (msgData.isMine ? Colors.white : Colors.black87);
    Color background = (msgData.isMine ? Colors.blueAccent : const Color(0xFFF0F0F0));
    double leftMargin = 24 + (msgData.isMine ? 24 : 0);
    double rightMargin = 24;
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: (msgData.isMine ? MainAxisAlignment.end : MainAxisAlignment.start),
      children: [
        Flexible(
          child: Container(
            margin: EdgeInsets.only(left: leftMargin, right: rightMargin, top: 24),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: background,
                boxShadow: [textBlockBoxShadow],
                borderRadius: BorderRadius.only(topLeft: const Radius.circular(20), topRight: const Radius.circular(20), bottomLeft: (msgData.isMine ? const Radius.circular(20) : const Radius.circular(8)), bottomRight: (!msgData.isMine ? const Radius.circular(20) : const Radius.circular(8)))
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  msgData.message,
                  // softWrap: true,
                  style: TextStyle(
                      color: foreground,
                      height: 1.5,
                      fontSize: 15
                  ),
                ),
                if (!msgData.isMine) {
                  const Padding(padding: EdgeInsets.only(top: 4), child: Text("对话由 AI 大模型生成，仅供参考", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),),)
                }.first
              ],
            ),
          ),
        )
      ],

    );
  }
}




