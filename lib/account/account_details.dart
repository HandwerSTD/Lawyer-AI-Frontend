import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
          settingsItemBlock(("上传新头像"), () {
            ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1000, requestFullMetadata: false);
            /* TODO: Implement API */
          }),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [ElevatedButton(onPressed: () {
              widget.loggedAccount.cookie = "";
              Navigator.popUntil(context, ModalRoute.withName('/home'));
            }, child: Text("退出账号"))],
          )
        ],
      ),
    );
  }
}
