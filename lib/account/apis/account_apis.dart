import 'dart:convert';
import 'dart:io';

import '../../common/constant/constants.dart';
import '../../common/data_model/data_models.dart';
import 'package:http/http.dart' as http;

Future<AccountDataModel> getUserInfoById(String uid) {
  return http.post(Uri.parse(serverAddress + API.userInfo.api),
    headers: jsonHeaders,
    body: jsonEncode({
      "uid": uid
    })
  ).then((value) {
    var result = jsonDecode(Utf8Decoder().convert(value.bodyBytes));
    if (result["status"] != "success") throw HttpException(result["message"]);
    print(result);
    return AccountDataModel(result["result"]["user"], result["result"]["uid"], result["result"]["avatar"], "");
  });
}

// Future uploadNewAvatar() {
//
// }