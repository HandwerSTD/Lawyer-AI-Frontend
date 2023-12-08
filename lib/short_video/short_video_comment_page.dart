import 'package:flutter/material.dart';
import 'package:lawyer_ai_frontend/short_video/short_video_page_index.dart';

import '../account/my_account_page.dart';

class ShortVideoCommentPage extends StatelessWidget {
  VideoDataModel video;
  ShortVideoCommentPage({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("评论"),
      ),
      body: ShortVideoCommentList(video: video,),
    );
  }
}

class ShortVideoCommentList extends StatefulWidget {
  VideoDataModel video;
  ShortVideoCommentList({super.key, required this.video});

  @override
  State<ShortVideoCommentList> createState() => _ShortVideoCommentListState();
}

class _ShortVideoCommentListState extends State<ShortVideoCommentList> {
  List<CommentDataModel> commentList = [];
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    getCommentList();
    controller.addListener(() {

    });
  }

  void getCommentList() {
    // TODO: Get comment list
    setState(() {
      commentList.clear();
      for (int i = 0; i < 20; ++i) {
        commentList.add(CommentDataModel(AccountDataModel("张翼德", 1, "https://i2.hdslb.com/bfs/face/e1b90070c6a3ec7e5ee0248b8124b39488e741ee.jpg"), widget.video.videoTitle));
      }
      print("[ShortVideoCommentPage] comment loaded: ${commentList.length}");
    });
  }
  void loadMoreComment() {
    // TODO: Get comment list
    setState(() {
      for (int i = 0; i < 20; ++i) {
        commentList.add(CommentDataModel(AccountDataModel("张翼德", 1, "https://i2.hdslb.com/bfs/face/e1b90070c6a3ec7e5ee0248b8124b39488e741ee.jpg"), widget.video.videoTitle));
      }
    });
  }
  void submitNewComment(String text) {
    
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: ListView(
          controller: controller,
          children: List.generate(commentList.length, (index) => CommentBlock(comment: commentList[index])),
        )),
        bottomSendMsgButton()
      ],
    );
  }

  Widget bottomSendMsgButton() {
    TextEditingController controller = TextEditingController();

    return Container(
      margin: const EdgeInsets.only(left: 13, right: 12, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "想说什么？",
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 24),
            child: ElevatedButton(onPressed: (){
              submitNewComment(controller.text);
            }, child: const Icon(Icons.send)),
          )
        ],
      ),
    );
  }
}

class CommentBlock extends StatelessWidget {
  CommentDataModel comment;
  CommentBlock({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        authorInfo(),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
              child: Container(
                margin: EdgeInsets.only(left: 24, right: 24, bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      comment.content,
                      // softWrap: true,
                      style: TextStyle(
                          height: 1.5,
                          fontSize: 15
                      ),
                    ),
                    Divider()
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
  Widget authorInfo() {
    return Padding(padding: EdgeInsets.only(left: 24, bottom: 4), child: Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Icon(Icons.account_circle),
        Padding(padding: EdgeInsets.only(left: 4), child: Text(comment.author.name),)
      ],
    ),);
  }
}


class CommentDataModel {
  String content = "";
  AccountDataModel author;
  CommentDataModel(this.author, this.content);
}

