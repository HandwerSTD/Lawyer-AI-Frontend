import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:lawyer_ai_frontend/common/data_model/data_models.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../../common/constant/constants.dart';

class AccountRegister extends StatefulWidget {
  AccountDataModel loggedAccount;
  AccountRegister({super.key, required this.loggedAccount});

  @override
  State<AccountRegister> createState() => _AccountRegisterState();
}

class _AccountRegisterState extends State<AccountRegister> {
  bool checkboxSelected = false;
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPasswd = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: (AppBar()),
        body: Center(
          child: Column(
            // TODO: Border & Background as Design
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(padding: EdgeInsets.only(bottom: 36), child: Text(
                "注册",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24),
              ),),
              loginInput(),
              Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton(
                  onPressed: () {
                    setRegister(
                      onNetworkErr: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("网络错误")));
                      },
                      onRegErr: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("注册失败")));
                      }
                    );
                  },
                  style: const ButtonStyle(
                      fixedSize: MaterialStatePropertyAll(Size.fromWidth(280))),
                  child: const Text("确认"),
                ),
              ),
              privacyStatement(),
              const Padding(
                padding: EdgeInsets.only(top: 48, bottom: 12),
                child: Text("其他"),
              ),
              thirdPartyLogin(),
            ],
          ),
        ));
  }

  Widget loginInput() {

    return SizedBox(
      width: 300,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              autocorrect: false,
              controller: controllerEmail,
              decoration: InputDecoration(hintText: "邮箱"),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              autocorrect: false,
              controller: controllerName,
              decoration: InputDecoration(hintText: "用户名"),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              autocorrect: false,
              controller: controllerPasswd,
              obscureText: true,
              decoration: InputDecoration(hintText: "密码"),
            ),
          ),
          Text("密码不少于6位，需要至少包含字母和数字")
        ],
      ),
    );
  }
  Widget privacyStatement() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Checkbox(value: checkboxSelected, onChanged: (value) {
          setState(() {
            checkboxSelected = !checkboxSelected;
          });
        }),
        Text("我已阅读并同意"),
        InkWell(
          child: Text("《用户协议》", style: TextStyle(color: Colors.blueAccent),),
          onTap: () {
            // TODO: 用户协议
            launchUrl(Uri.parse(privacyStatementAddress), mode: LaunchMode.externalApplication);
          },
        )
      ],
    );
  }

  Widget thirdPartyLogin() {
    return SizedBox(
        width: 140,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(onPressed: () {setThirdPartyLogin();}, icon: Icon(Icons.shop_two)),
            IconButton(
                onPressed: () {setThirdPartyLogin();}, icon: Icon(Icons.accessible_forward_outlined))
          ],
        ));
  }

  void setThirdPartyLogin() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("暂未开放")));
  }
  bool checkPwd(String pwd) {
    return true;
  }
  void setRegister({required Function onNetworkErr, required Function onRegErr}) {
    String user = controllerName.text, pwd = controllerPasswd.text, email = controllerEmail.text;
    if (user == "" || email == "") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("用户名和邮箱不能为空")));
      return;
    }
    if (!checkPwd(pwd)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("密码不符合要求")));
      return;
    }
    if (!checkboxSelected) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("请阅读并同意我们的《用户协议》")));
      return;
    }
    print("[AccountRegister] sending data");
    http.post(Uri.parse(serverAddress + API.userRegister.api),
        headers: jsonHeaders,
        body: jsonEncode({"user": user, "password": sha1.convert(utf8.encode(pwd)).toString()})
    ).timeout(Duration(seconds: 5))
    .then((value) {
      print(value.body);
      var result = jsonDecode(Utf8Decoder().convert(value.bodyBytes));
      if (result["status"] != "success") {
        print(result["message"]);
        onRegErr();
        return;
      }
      // setLogin();
      Navigator.pop(context);
    }).catchError((error) {
      print(error);
      onNetworkErr();
    });
  }
  // void setLogin() {
  //   String user = controllerName.text, pwd = controllerPasswd.text;
  //
  //   http.post(Uri.parse(serverAddress + API.userLogin.api),
  //       headers: jsonHeaders,
  //       body: jsonEncode({"user": user, "password": sha1.convert(utf8.encode(pwd)).toString()})
  //   ).then((value) {
  //     print(value.body);
  //     var result = jsonDecode(Utf8Decoder().convert(value.bodyBytes));
  //     if (result["status"] != "success") throw HttpException(result["message"]);
  //     var cookie = value.headers["set-cookie"];
  //     if (cookie != null) {
  //       int index = cookie.indexOf(';');
  //       widget.loggedAccount.cookie = (index == -1 ? cookie : cookie.substring(0, index));
  //       widget.loggedAccount.name = user;
  //       http.post(Uri.parse(serverAddress + API.userInfo.api),
  //           headers: jsonHeaders,
  //           body: jsonEncode({"user": user})
  //       ).then((value) {
  //         var result = jsonDecode(Utf8Decoder().convert(value.bodyBytes));
  //         print("[AccountLogin] User info fetched: $result");
  //         widget.loggedAccount.avatar = result["result"]["avatar"];
  //         widget.loggedAccount.uid = result["result"]["uid"];
  //       });
  //     } else throw HttpException("failed");
  //   }).catchError((error) {
  //     print(error);
  //   });
  // }
}
