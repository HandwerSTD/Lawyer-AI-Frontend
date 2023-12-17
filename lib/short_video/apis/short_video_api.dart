import 'dart:convert';
import 'dart:io';

import '../../common/constant/constants.dart';
import '../../common/data_model/data_models.dart';
import 'package:http/http.dart' as http;

void getVideoList(Function(VideoDataModel video) add) {
  /* TODO: Implement API */
  print("[ShortVideoPageIndex] fetching video list");
  http
      .post(
    Uri.parse(serverAddress + API.videoSearch.api),
    headers: jsonHeaders,
    body: jsonEncode({"title": "原神"}),
  )
      .then((value) {
    var result = jsonDecode(Utf8Decoder().convert(value.bodyBytes));
    if (result["status"] != "success") throw HttpException(result["message"]);
    var videoList = result["result"];
    print(videoList);
    for (int i = 0; i < (videoList as List).length; ++i) {
      add(VideoDataModel(
          videoSha1: videoList[i]["sha1"],
          videoImageLink:
              serverAddress + API.videoCover.api + videoList[i]["cover_sha1"],
          videoTitle: videoList[i]["title"],
          videoDesc: videoList[i]["description"],
          gotLikes: videoList[i]["like"],
          liked: -1,
          authorUid: videoList[i]["author_id"],
          id: (videoList[i]["uid"]), author: videoList[i]["author"], commentId: videoList[i]["comments_id"]));
    }
  }).onError((error, stackTrace) {
    print(error);
  });
}

void loadMoreContent(Function(VideoDataModel video) add, Function? callback) {
  getVideoList(add);
}

void getSearchVideoList(String search, Function(VideoDataModel video) add) {
  print("[ShortVideoPageIndex] searching video list: $search");
  http
      .post(
    Uri.parse(serverAddress + API.videoSearch.api),
    headers: jsonHeaders,
    body: jsonEncode({"title": search}),
  )
      .then((value) {
    var result = jsonDecode(Utf8Decoder().convert(value.bodyBytes));
    if (result["status"] != "success") throw HttpException(result["message"]);
    var videoList = result["result"];
    print(videoList);
    for (int i = 0; i < (videoList as List).length; ++i) {
      add(VideoDataModel(
          videoSha1: videoList[i]["sha1"],
          videoImageLink:
            serverAddress + API.videoCover.api + videoList[i]["cover_sha1"],
          videoTitle: videoList[i]["title"],
          videoDesc: videoList[i]["description"],
          gotLikes: videoList[i]["like"],
          liked: -1,
          authorUid: videoList[i]["author_id"],
          id: (videoList[i]["uid"]), author: videoList[i]["author"], commentId: videoList[i]["comments_id"]));
    }
  }).onError((error, stackTrace) {
    print(error);
  });
}

void uploadNewVideo({required String title, required Uri fileUri, required String cookie}) async {

}

Future getVideoIsLiked(String cookie, VideoDataModel nowPlaying) {
  return http.post(
      Uri.parse(serverAddress + API.videoIsLiked.api),
      headers: cookie == "" ? jsonHeaders : jsonHeadersWithCookie(cookie),
      // headers: jsonHeaders,
      body: jsonEncode({
        'vid': nowPlaying.id
      })
  );
}

Future<void> likeVideo(VideoDataModel video, String cookie, Function modify) {
  return http.post(Uri.parse(serverAddress + API.videoLikeIt.api),
      headers: jsonHeadersWithCookie(cookie),
      body: jsonEncode({
        'vid': video.id
      })
  ).then((value) {
    var result = jsonDecode(Utf8Decoder().convert(value.bodyBytes));
    print(result);
    if (result["status"] != "success") throw HttpException("failed to like");
    modify();
  }).catchError((error) {
    print("[ShortVideoPlay] Like error: $error");
  });
}
