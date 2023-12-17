import 'dart:convert';
import 'dart:io';

import 'package:lawyer_ai_frontend/account/apis/account_apis.dart';

import '../../common/constant/constants.dart';
import '../../common/data_model/data_models.dart';
import 'package:http/http.dart' as http;

Future submitComment({required String commentId, required String comment, required String cookie}) {
  return http.post(Uri.parse(serverAddress + API.commentSubmit.api),
    headers: jsonHeadersWithCookie(cookie),
    body: jsonEncode({
      'cid': commentId,
      'comment': comment
    })
  ).then((value) {
    var result = jsonDecode(Utf8Decoder().convert(value.bodyBytes));
    print(result);
    print(value.statusCode);
    if (result["status"] != "success") throw HttpException(result["message"]);
    return result;
  });
}

Future fetchComment({required String commentId, required Function add}) {
  return loadMoreComment(commentId: commentId, add: add, pageNum: 1);
}

Future<int> loadMoreComment({required String commentId, required Function add, required pageNum}) {
  return http.post(Uri.parse(serverAddress + API.commentList.api),
      headers: jsonHeaders,
      body: jsonEncode({
        'cid': commentId,
        'page': pageNum,
        'page_size': commentsPerPage
      })
  ).then((value) {
    print(value.statusCode);
    var result = jsonDecode(Utf8Decoder().convert(value.bodyBytes));
    print(result);
    if (result["status"] != "success") throw HttpException(result["message"]);
    List commentList = result["result"];
    print(commentList);
    for (var element in commentList) {
      add(CommentDataModel(AccountDataModel(element["author"], element["author_id"], element["avatar"], ""), element["content"], element["timestamp"]));
    }
    return commentList.length;
  }).catchError((err) {
    print(err);
  });
}