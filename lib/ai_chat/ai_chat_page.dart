import 'package:flutter/material.dart';
import 'package:lawyer_ai_frontend/ai_chat/chat_history.dart';
import 'package:lawyer_ai_frontend/common/theme/theme.dart';

import '../common/data_model/data_models.dart';
import 'chat_api.dart';
import 'dart:convert';
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
  bool sttIsInputable = true;
  ScrollController scrollController = ScrollController();
  FocusNode teFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    setState(() {
      sttChatMsgList.add(ChatMsgData(
          "您好，我是您的专属 AI 律师顾问紫小藤！我可以提供各种信息，或者回答一些法律问题。有什么问题想问的？", false));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: themeAccent
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Divider(height: 1,),
          Expanded(
              child: ListView(
            // physics: (!sttIsInputable
            //     ? NeverScrollableScrollPhysics()
            //     : ClampingScrollPhysics()),
            shrinkWrap: true,
            controller: scrollController,
            children: sttChatMsgList.map((e) => chatMessageBlock(e)).toList(),
          )),
          bottomSendMsgButton()
        ],
      ),
    );
  }

  void scrollToBottom() {
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500), curve: Curves.ease);
  }

  Widget bottomSendMsgButton() {
    TextEditingController controller = TextEditingController();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Color(0xffebe8fc),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: multilineTextField(
              controller,
            ),
          ),
          IconButton(
              onPressed: () {
                // TODO: Voice Recognize
                showSnackBar(context, "暂未开放");
                // Navigator.push(context, MaterialPageRoute(builder: (context) => ChatHistory()));
              },
              icon: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                    color: Color(0xfff1f2fb),
                    border: Border.all(color: Color(0x99005ac2), width: 1.5),
                    borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.keyboard_voice_rounded,
                    color: Color(0xff005ac2)),
              )),
          Container(
            margin: const EdgeInsets.only(left: 5),
            child: ElevatedButton(
              onPressed: () {
                // print("[ChatAPI] server = $serverAddress");
                // Pre init
                if (widget.loggedAccount.cookie == "") {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("请先登录"),
                    duration: Duration(milliseconds: 1000),
                  ));
                  return;
                }
                setState(() {
                  teFocus.unfocus();
                  scrollToBottom();
                });
                // Submit
                submitNewMessage(controller.text, widget.loggedAccount.cookie,
                    (val) {
                  setState(() {
                    sttIsInputable = false;
                    sttChatMsgList.add(val);
                  });
                }, (apd) async {
                  setState(() {
                    sttChatMsgList.last.append(apd);
                    scrollToBottom();
                  });
                }, () {
                  setState(() {
                    sttIsInputable = true;
                  });
                  scrollToBottom();
                }, () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text("网络错误")));
                  sttIsInputable = true;
                });
              },
              style: const ButtonStyle(
                  alignment: Alignment.center,
                  fixedSize: MaterialStatePropertyAll(Size.zero),
                  padding: MaterialStatePropertyAll(EdgeInsets.only(left: 0)),
                  side: MaterialStatePropertyAll(
                      BorderSide(color: Color(0x99005ac2), width: 1.5))),
              child: const Icon(
                Icons.send,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget chatMessageBlock(ChatMsgData msgData) {
    Color foreground = (msgData.isMine ? Colors.white : Colors.black87);
    Color background =
        (msgData.isMine ? Colors.blueAccent : Color(0xffffffff));
    double leftMargin = 24 + (msgData.isMine ? 24 : 0);
    double rightMargin = 24;
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment:
          (msgData.isMine ? MainAxisAlignment.end : MainAxisAlignment.start),
      children: [
        Flexible(
          child: Container(
            margin: EdgeInsets.only(
                left: leftMargin, right: rightMargin, top: 12, bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: background,
                // boxShadow: [textBlockBoxShadow],
                borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: (msgData.isMine
                        ? const Radius.circular(20)
                        : const Radius.circular(8)),
                    bottomRight: (!msgData.isMine
                        ? const Radius.circular(20)
                        : const Radius.circular(8)))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  (msgData.message == "" ? "思考中..." : msgData.message),
                  // softWrap: true,
                  style:
                      TextStyle(color: foreground, height: 1.5, fontSize: 15),
                ),
                if (!msgData.isMine)
                  {
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        "对话由 AI 大模型生成，仅供参考",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                      ),
                    )
                  }.first
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget multilineTextField(TextEditingController cont) {
    return Container(
      margin: EdgeInsets.only(right: 2),
      // color: Colors.red,
      constraints: BoxConstraints(
        maxHeight: 144.0,
        // minHeight: 36.0,
      ),
      child: TextField(
        focusNode: teFocus,
        autocorrect: false,
        autofocus: false,
        readOnly: !sttIsInputable,
        controller: cont,
        minLines: 1,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        decoration:
            outlineBorderedInputDecoration("向紫小藤问点什么吧", 24, dense: true, filled: true, fillColor: Colors.white),
      ),
    );
  }
}
