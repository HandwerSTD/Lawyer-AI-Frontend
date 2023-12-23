import 'dart:convert';
import 'dart:isolate';

import 'package:lawyer_ai_frontend/common/constant/constants.dart';

import '../common/data_model/data_models.dart';
import 'package:http/http.dart' as http;

void submitNewMessage(String text, String cookie, Function(ChatMsgData msg) add, Function(String dt) append, Function callback, Function onNetworkErr) async {
  if (text != "") {
    add(ChatMsgData(text, true));
    // var networkResult = "";
    // http.post().then((value) {
    //   networkResult = value;
    //   add(ChatMsgData(networkResult, false));
    // }).catchError((err) {
    //   networkResult = "Error: Network failed";
    // });
    http.post(
      Uri.parse(serverAddress + API.chatCreateSession.api),
      headers: jsonHeadersWithCookie(cookie),
      body: jsonEncode({
        "type": "chat",
        "data": text
      })
    ).timeout(Duration(seconds: 10))
        .then((value) async {
      var result = jsonDecode(Utf8Decoder().convert(value.bodyBytes));
      print(result); print(value.statusCode);
      String session = result["session_id"];
      print(session);
      add(ChatMsgData("", false));
      await isolateFlushSession(append, session: session, cookie: cookie, callback: callback);
    }).catchError((err) {
      print(err);
      onNetworkErr();
    });
  }
}

Future isolateFlushSession(Function(String dt) append, {required String session, required String cookie, required Function callback}) async {
  final response = ReceivePort();
  final isolate = await Isolate.spawn(flushSession, response.sendPort);
  bool start = true;
  response.listen((message) async {
    if (message is String) {
      if (message.endsWith("<EOF>")) {
        message = message.replaceAll("<EOF>", "");
        await append(message);
        print("[ChatAPI] Isolate killed");
        isolate.kill(priority: Isolate.immediate);
        callback();
      } else {
        if (start && message.startsWith('\n')) {
          message = message.replaceAll('\n', '');
          start = false;
        }
        await append(message);
      }
    }
    if (message is SendPort) {
      print("[ChatAPI] sendport got");
      message.send({
        "cookie": cookie,
        "session": session
      });
    }
  });
}

void flushSession(SendPort sp) {
  ReceivePort receivePort = ReceivePort();
  sp.send(receivePort.sendPort);
  String cookie = "", session = "";
  receivePort.listen((message) async {
    cookie = message["cookie"];
    session = message["session"];
    // print("[FlushSession], received cookie $cookie");
    try {
      while (true) {
        var value = await http
            .post(Uri.parse(serverAddress + API.chatFlushSession.api),
            headers: jsonHeadersWithCookie(cookie),
            body: jsonEncode({"session_id": session}));
        var chatRes = jsonDecode(Utf8Decoder().convert(value.bodyBytes));
        print(chatRes);
        if (chatRes["status"] != "success" || chatRes["data"] == "<EOF>") {
          break;
        }
        // append(chatRes["data"]);
        sp.send((chatRes["data"].toString()));
      }
    } catch(err) {
      print(err);
    } finally {
      sp.send("<EOF>");
    }
  });
}