import 'dart:convert';
import 'dart:io';

import '../../common/constant/constants.dart';
import '../../common/data_model/data_models.dart';
import 'package:http/http.dart' as http;

void getVideoList(Function(VideoDataModel video) add, Function setNetworkError,
    {String cookie = ""}) {
  /* TODO: Implement API */
  print("[ShortVideoPageIndex] fetching video list");
  http
      .post(
        Uri.parse(serverAddress + API.videoRecommended.api),
        headers: (cookie != "" ? jsonHeadersWithCookie(cookie) : jsonHeaders),
        body: jsonEncode({"page_size": videosPerPage}),
      )
      .timeout(Duration(seconds: 10))
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
          id: (videoList[i]["uid"]),
          author: videoList[i]["author"],
          commentId: videoList[i]["comments_id"],
          authorIcon: videoList[i]["avatar"]));
    }
  }).onError((error, stackTrace) {
    print(error);
    setNetworkError();
  });
}

void videoRecommendLoadMoreContent(Function(VideoDataModel video) add,
    Function setNetworkError, Function? callback) {
  getVideoList(add, setNetworkError);
}

Future<int> getSearchVideoList(String search, int pageNum,
    Function(VideoDataModel video) add, Function setNetworkError) {
  print("[ShortVideoPageIndex] searching video list: $search");
  return http
      .post(
    Uri.parse(serverAddress + API.videoSearch.api),
    headers: jsonHeaders,
    body: jsonEncode(
        {"title": search, "page": pageNum, "page_size": videosPerPage}),
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
          id: (videoList[i]["uid"]),
          author: videoList[i]["author"],
          commentId: videoList[i]["comments_id"],
          authorIcon: videoList[i]["avatar"]));
    }
    return videoList.length;
  }).catchError((error, stackTrace) {
    setNetworkError();
    print(error);
  });
}

Future uploadNewVideo(
    {required String title,
    required String desc,
    required String tags,
    required List<int> videoData,
    required List<int> coverData,
    required String cookie}) async {
  print("[ShortVideo] Uploading Video");
  var req = http.MultipartRequest(
      'post', Uri.parse(serverAddress + API.videoUpload.api));
  req.headers.addAll({"content-type": "multipart/form-data", "cookie": cookie});
  req.fields.addAll({"title": title, "description": desc, "tags": tags});
  req.files
      .add(http.MultipartFile.fromBytes('video', videoData, filename: "video"));
  req.files
      .add(http.MultipartFile.fromBytes('cover', coverData, filename: "cover"));
  return req.send();
}

Future getVideoIsLiked(String cookie, VideoDataModel nowPlaying) {
  return http.post(Uri.parse(serverAddress + API.videoIsLiked.api),
      headers: cookie == "" ? jsonHeaders : jsonHeadersWithCookie(cookie),
      // headers: jsonHeaders,
      body: jsonEncode({'vid': nowPlaying.id}));
}

Future<void> likeVideo(VideoDataModel video, String cookie, Function modify) {
  return http
      .post(Uri.parse(serverAddress + API.videoLikeIt.api),
          headers: jsonHeadersWithCookie(cookie),
          body: jsonEncode({'vid': video.id}))
      .then((value) {
    var result = jsonDecode(Utf8Decoder().convert(value.bodyBytes));
    print(result);
    if (result["status"] != "success") throw HttpException("failed to like");
    modify();
  }).catchError((error) {
    print("[ShortVideoPlay] Like error: $error");
  });
}

Future<int> loadVideoByUser(
    {required String uid,
    required int pageNum,
    required Function(VideoDataModel video) add,
    required Function setNetworkError}) {
  print("[LoadVideoByUser] uid = $uid");
  return http
      .post(
    Uri.parse(serverAddress + API.userListVideo.api),
    headers: jsonHeaders,
    body: jsonEncode({'uid': uid, 'page': pageNum, 'page_size': videosPerPage}),
  )
      .then((value) {
    var result = jsonDecode(Utf8Decoder().convert(value.bodyBytes));
    print(result);
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
          id: (videoList[i]["uid"]),
          author: videoList[i]["author"],
          commentId: videoList[i]["comments_id"],
          authorIcon: videoList[i]["avatar"]));
    }
    return videoList.length;
  }).catchError((error, stackTrace) {
    setNetworkError();
    print(error);
  });
}
