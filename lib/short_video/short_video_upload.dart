import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../common/data_model/data_models.dart';

class ShortVideoUpload extends StatefulWidget {
  AccountDataModel loggedAccount;
  XFile selectedFile;
  ShortVideoUpload({super.key, required this.loggedAccount, required this.selectedFile});

  @override
  State<ShortVideoUpload> createState() => _ShortVideoUploadState();
}

class _ShortVideoUploadState extends State<ShortVideoUpload> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("上传视频"),
      ),
      body: Placeholder(),
    );
  }
}
