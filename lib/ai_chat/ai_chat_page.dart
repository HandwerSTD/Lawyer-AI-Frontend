import 'package:flutter/material.dart';
import 'package:lawyer_ai_frontend/common/theme/theme.dart';

import '../common/data_model/data_models.dart';
import 'chat_api.dart';import 'dart:convert';
import 'dart:isolate';

import 'package:lawyer_ai_frontend/common/constant/constants.dart';

import '../common/data_model/data_models.dart';
import 'package:http/http.dart' as http;

bool instanceFirstOpen = false;

class AIChatPage extends StatefulWidget {
  AccountDataModel loggedAccount;
  AIChatPage({super.key, required this.loggedAccount});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}
class _AIChatPageState extends State<AIChatPage> {
  List<ChatMsgData> sttChatMsgList = [];
  bool sttTextFieldEnabled = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      sttChatMsgList.add(ChatMsgData("您好，我是您的专属 AI 律师顾问！我可以提供各种信息，或者回答一些法律问题。有什么问题想问的？", false));
    });
  }

  @override
  Widget build(BuildContext context) {
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
              readOnly: !sttTextFieldEnabled,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 24),
            child: ElevatedButton(onPressed: (){
              if (widget.loggedAccount.cookie == "") {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("请先登录"), duration: Duration(milliseconds: 1000),)
                );
                return;
              }
              setState(() {
                sttTextFieldEnabled = false;
              });
              submitNewMessage(controller.text, widget.loggedAccount.cookie, (val) {
                setState(() {
                  sttChatMsgList.add(val);
                });
              }, (apd) async {
                setState(() {
                  for (int i = 0; i < apd.length; ++i) {
                    sttChatMsgList.last.append(apd[i]);
                  }
                });
              }, () {
                setState(() {
                  sttTextFieldEnabled = true;
                });
              });
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
            margin: EdgeInsets.only(left: leftMargin, right: rightMargin, top: 12, bottom: 12),
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




