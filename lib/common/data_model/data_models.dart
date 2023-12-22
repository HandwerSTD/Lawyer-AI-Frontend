import 'package:flutter/cupertino.dart';

class ChatMsgData {
  String message = "";
  bool isMine = true;
  ChatMsgData(String msg, bool mine) {
    message = msg;
    isMine = mine;
  }
  void append(String ad) {
    message += ad;
  }
}

class VideoDataModel {
  String id = "";
  String author = "";
  String authorUid = "";
  String authorIcon = "";
  String commentId = "";
  String videoSha1 = "";
  String videoImageLink = "";
  String videoTitle = "";
  String videoDesc = "";
  int gotLikes = 0;
  int liked = -1; // -1: undefined
  VideoDataModel(
      {required this.videoSha1,
      required this.videoImageLink,
      required this.videoTitle,
      required this.videoDesc,
      required this.gotLikes,
      required this.liked,
      required this.authorUid,
      required this.id,
      required this.author,
      required this.authorIcon,
      required this.commentId});
}

class CommentDataModel {
  String content = "";
  AccountDataModel author;
  double timestamp;
  bool expand = false;
  CommentDataModel(this.author, this.content, this.timestamp);
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
