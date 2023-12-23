import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lawyer_ai_frontend/account/apis/account_apis.dart';
import 'package:lawyer_ai_frontend/common/data_model/data_models.dart';
import 'package:lawyer_ai_frontend/common/theme/theme.dart';

class AccountDetails extends StatefulWidget {
  AccountDataModel loggedAccount;
  AccountDetails({super.key, required this.loggedAccount});

  @override
  State<AccountDetails> createState() => _AccountDetailsState();
}

class _AccountDetailsState extends State<AccountDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("编辑我的信息"),
      ),
      body: ListView(
        children: [
          settingsItemBlock(("上传新头像"), () async {
            var avatar = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1000, requestFullMetadata: false);
            if (avatar == null) return;
            var avatarData = await ImageCropper().cropImage(sourcePath: avatar.path, aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1));
            if (avatarData == null) return;
            showSnackBar(context, "上传中");
            var response = await uploadNewAvatar(avatar: await avatarData.readAsBytes(), cookie: widget.loggedAccount.cookie);
            var resp =
                await response.stream.transform(utf8.decoder).join();
            print("[UploadNewAvatar] res: $resp");
            showSnackBar(context, "${jsonDecode(resp)["message"]}");
            var newUserInfo = await getUserInfoById(widget.loggedAccount.uid);
            widget.loggedAccount.avatar = newUserInfo.avatar;
          }),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [ElevatedButton(onPressed: () {
              widget.loggedAccount.cookie = "";
              Navigator.popUntil(context, ModalRoute.withName('/'));
            }, child: Text("退出账号"))],
          )
        ],
      ),
    );
  }
}
