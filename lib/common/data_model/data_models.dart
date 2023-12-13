
import 'package:flutter/cupertino.dart';

class ChatMsgData {
  String message = "";
  bool isMine = true;
  ChatMsgData(String msg, bool mine) {
    message = msg;
    isMine = mine;
  }
}

class VideoDataModel {
  int id = 0;
  String videoSha1 = "";
  String videoImageLink = "";
  String videoTitle = "";
  String videoDesc = "";
  VideoDataModel(this.videoSha1, this.videoImageLink, this.videoTitle, this.videoDesc);
}

class CommentDataModel {
  String content = "";
  AccountDataModel author;
  CommentDataModel(this.author, this.content);
}

class AccountDataModel {
  String name = "";
  String uid = "";
  String avatar = "";
  String cookie = "";
  AccountDataModel(this.name, this.uid, this.avatar, this.cookie);
}

class StorageDataModel extends ChangeNotifier {
  AccountDataModel loggedAccount = AccountDataModel("", "", "", "");

  void notify() {
    notifyListeners();
  }
  void modifyAccount(AccountDataModel acc) {
    loggedAccount = acc;
    notifyListeners();
  }
}