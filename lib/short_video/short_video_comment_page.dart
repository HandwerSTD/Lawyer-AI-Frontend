import 'package:flutter/material.dart';
import 'package:lawyer_ai_frontend/common/theme/theme.dart';
import 'package:lawyer_ai_frontend/common/utils/time_utils.dart';
import 'package:lawyer_ai_frontend/short_video/apis/short_video_comment_api.dart';
import 'package:lawyer_ai_frontend/short_video/short_video_page_index.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../account/my_account_page.dart';
import '../common/constant/constants.dart';
import '../common/data_model/data_models.dart';

class ShortVideoCommentPage extends StatelessWidget {
  AccountDataModel loggedAccount;
  VideoDataModel video;
  ShortVideoCommentPage({super.key, required this.video, required this.loggedAccount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("评论"),
      ),
      body: ShortVideoCommentList(video: video, loggedAccount: loggedAccount,),
    );
  }
}

class ShortVideoCommentList extends StatefulWidget {
  VideoDataModel video;
  AccountDataModel loggedAccount;
  ShortVideoCommentList({super.key, required this.video, required this.loggedAccount});

  @override
  State<ShortVideoCommentList> createState() => _ShortVideoCommentListState();
}

class _ShortVideoCommentListState extends State<ShortVideoCommentList> {
  List<CommentDataModel> commentList = [];
  ScrollController controller = ScrollController();
  int pageIndex = 1;
  /* TODO: Loading flag*/

  @override
  void initState() {
    super.initState();
    fetchComment(commentId: widget.video.commentId, add: (elem) {
      setState(() {
        commentList.add(elem);
      });
    });

    controller.addListener(() {
      if (controller.position.pixels ==
          controller.position.maxScrollExtent) {
        print("[ShortVideoCommentList] Scrolled to end, loading data");
        loadMoreComment(commentId: widget.video.commentId, add: (elem) {
          setState(() {
            commentList.add(elem);
          });
        }, pageNum: pageIndex + 1).then((value) {
          if (value > 0) ++pageIndex;
        });// 到底部加载新内容
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // TODO: Border & Background as Design
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: (commentList.length == 0 ? Text("空空如也"): ListView(
          controller: controller,
          children: List.generate(commentList.length, (index) => Container(
            padding: EdgeInsets.only(left: 24, right: 24, top: 12),
            child: CommentBlock(comment: commentList[index]),
          )),
        ))),
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
              if (widget.loggedAccount.cookie == "") {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("请先登录"), duration: Duration(milliseconds: 1000),)
                );
              } else {
                if (controller.text == "") return;
                submitComment(
                    comment: controller.text,
                    commentId: widget.video.commentId,
                    cookie: widget.loggedAccount.cookie
                ).then((val) {
                  setState(() {
                    commentList.clear();
                  });
                  fetchComment(commentId: widget.video.commentId, add: (elem) {
                    setState(() {
                      commentList.add(elem);
                    });
                  });
                });

                // controller.clear();
                // setState(() {
                //   commentList.clear();
                // });
                // fetchComment(commentId: widget.video.commentId, add: (elem) {
                //   setState(() {
                //     commentList.add(elem);
                //   });
                // });
              }
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
      children: [Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: EdgeInsets.only(right: 18, top: 12, bottom: 24), child: accountAvatar(comment.author),),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(comment.author.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16),),
              ExpandableText(text: comment.content, style: TextStyle(fontSize: 16), maxLines: 3, expand: false,),
              Padding(padding: EdgeInsets.only(top: 4, bottom: 4), child: Text(TimeUtils.formatDateTime(comment.timestamp.toInt()), style: TextStyle(fontSize: 14),),)
            ],
          ))
        ],
      )],
    );
  }

  Widget accountAvatar(AccountDataModel acc) {
    return CachedNetworkImage(
      imageBuilder: (context, image) => Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            image: DecorationImage(image: image, fit: BoxFit.cover)),
      ),
      imageUrl: serverAddress +
          API.userAvatar.api +
          acc.avatar,
      width: 48,
      height: 48,
    );
  }
}



