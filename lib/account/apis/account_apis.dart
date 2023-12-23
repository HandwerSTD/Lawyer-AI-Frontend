import 'dart:convert';
import 'dart:io';

import '../../common/constant/constants.dart';
import '../../common/data_model/data_models.dart';
import 'package:http/http.dart' as http;

Future<AccountDataModel> getUserInfoById(String uid, {String providedCookie = "", int providedVideoNum = 0}) {
  return http
      .post(Uri.parse(serverAddress + API.userInfo.api),
          headers: jsonHeaders, body: jsonEncode({"uid": uid}))
      .then((value) {
    var result = jsonDecode(Utf8Decoder().convert(value.bodyBytes));
    if (result["status"] != "success") throw HttpException(result["message"]);
    print(result);
    return AccountDataModel(result["result"]["user"], result["result"]["uid"],
        result["result"]["avatar"], providedCookie, videoNum: providedVideoNum);
  });
}

Future uploadNewAvatar(
    {required List<int> avatar, required String cookie}) async {
  print("[AccountAPI] Uploading new avatar");
  var req = http.MultipartRequest(
      'post', Uri.parse(serverAddress + API.userUploadAvatar.api));
  req.headers.addAll({"content-type": "multipart/form-data", "cookie": cookie});
  // req.fields.addAll({"title": title, "description": desc, "tags": tags});
  req.files
      .add(http.MultipartFile.fromBytes('avatar', avatar, filename: "avatar"));
  return req.send();
}
