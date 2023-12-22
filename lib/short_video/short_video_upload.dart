import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lawyer_ai_frontend/common/theme/theme.dart';
import 'package:lawyer_ai_frontend/short_video/apis/short_video_api.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../common/data_model/data_models.dart';

class ShortVideoUpload extends StatefulWidget {
  AccountDataModel loggedAccount;
  XFile selectedFile;
  ShortVideoUpload(
      {super.key, required this.loggedAccount, required this.selectedFile});

  @override
  State<ShortVideoUpload> createState() => _ShortVideoUploadState();
}

class _ShortVideoUploadState extends State<ShortVideoUpload> {
  TextEditingController titleController = TextEditingController();
  TextEditingController tagsController = TextEditingController();
  TextEditingController descController = TextEditingController();
  Uint8List coverData = Uint8List(0);
  bool loaded = false;

  @override
  void initState() {
    VideoThumbnail.thumbnailData(
            video: widget.selectedFile.path,
            imageFormat: ImageFormat.PNG,
            quality: 100)
        .then((value) {
      setState(() {
        coverData = value!;
        loaded = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("上传视频"),
      ),
      body: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: TextField(
                        decoration: outlineBorderedInputDecoration("视频标题", 36),
                        controller: titleController,
                        style: TextStyle(fontSize: 15),
                      ),
                    ))
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: TextField(
                    decoration:
                        outlineBorderedInputDecoration("视频标签，用英文逗号分隔", 36),
                    controller: tagsController,
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: multilineTextField(descController),
                ),
              ],
            ),
            Expanded(
                child: GestureDetector(
              onTap: () async {
                print("[ShortVideoUpload] selecting another cover");
                // var result = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 720, maxHeight: 720);
                // setState(() {
                //   coverData = (await result?.readAsBytes() ?? coverData);
                // });
                ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 720, maxHeight: 720)
                .then((value) {
                  value?.readAsBytes().then((val) {
                    setState(() {
                      coverData = (val.isEmpty ? coverData : val);
                    });
                  });
                });
              },
              child: Padding(
                padding: EdgeInsets.all(12),
                child: (loaded ? Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    (Image.memory(coverData)),
                    const Text(
                      "点击更换封面",
                      style: TextStyle(
                          fontSize: 18,
                          backgroundColor: Colors.black54, color: Colors.white),
                    ),
                  ],
                ) : CircularProgressIndicator()),
              ),
            )),
            ElevatedButton(
                onPressed: () async {
                  String title = titleController.value.text,
                      desc = descController.value.text,
                      tags = tagsController.value.text;
                  if (title == "" || desc == "" || tags == "") {
                    showSnackBar(context, "视频信息不能为空");
                  }
                  var videoData = await widget.selectedFile.readAsBytes();
                  showSnackBar(context, "视频上传中");
                  var response = await uploadNewVideo(
                      title: title,
                      desc: desc,
                      tags: tags,
                      videoData: videoData,
                      coverData: coverData,
                      cookie: widget.loggedAccount.cookie);
                  var resp =
                      await response.stream.transform(utf8.decoder).join();
                  print("[ShortVideoUpload] res: $resp");
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("${jsonDecode(resp)["message"]}")));
                  Navigator.pop(context);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Text(
                      "上传视频",
                      textAlign: TextAlign.center,
                    ))
                  ],
                ))
          ],
        ),
      ),
    );
  }

  Widget multilineTextField(TextEditingController cont) {
    return Container(
      // color: Colors.red,
      constraints: BoxConstraints(
        maxHeight: 144.0,
        minHeight: 96.0,
      ),
      child: TextField(
        controller: cont,
        minLines: 3,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        decoration: outlineBorderedInputDecoration("视频简介", 18),
      ),
    );
  }
}
