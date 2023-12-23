var serverAddress = "http://10.17.245.148:5000";

const privacyStatementAddress = "https://www.baidu.com/";

// class ServerAPI {
//   String api = "";
//   ServerAPI(this.api);
// }

enum API {


  videoFile("/video/"),
  videoUpload("/api/video/upload_video"),
  videoSearch("/api/video/search"),
  videoInfo("/api/video/info"),
  videoCover("/api/cover/"),
  videoLikeIt("/api/video/like"),
  videoIsLiked("/api/video/is_like"),
  videoRecommended("/api/video/random"),

  commentSubmit("/api/comment/commit_comment"),
  commentList("/api/comment/list_comment"),

  userRegister("/api/user/register"),
  userLogin("/api/user/login"),
  userInfo("/api/user/info"),
  userSearch("/api/user/search"),
  userAvatar("/api/avatar/"),
  userUploadAvatar("/api/user/upload_avatar"),
  userListVideo("/api/video/list_video"),

  chatCreateSession("/api/chat/create_session"),
  chatFlushSession("/api/chat/flush_session");

  const API(this.api);
  final String api;
}

Map<String, String> jsonHeaders = {"content-type": "application/json"};
Map<String, String> jsonHeadersWithCookie(String cookie) => {"content-type": "application/json", "cookie": cookie};

const videosPerPage = 10;
const commentsPerPage = 20;
