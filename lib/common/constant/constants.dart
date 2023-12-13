const serverAddress = "http://10.17.245.41:5000";

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
  videoLike("/api/video/like"),

  userRegister("/api/user/register"),
  userLogin("/api/user/login"),
  userInfo("/api/user/info"),
  userSearch("/api/user/search"),
  userAvatar("/api/avatar/");

  const API(this.api);
  final String api;
}

Map<String, String> jsonHeaders = {"content-type": "application/json"};