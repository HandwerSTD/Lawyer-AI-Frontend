import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lawyer_ai_frontend/account/account_login/account_register.dart';
import 'package:lawyer_ai_frontend/common/constant/constants.dart';
import 'package:lawyer_ai_frontend/common/data_model/data_models.dart';
import 'package:lawyer_ai_frontend/common/theme/theme.dart';
import 'package:lawyer_ai_frontend/main.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class AccountLogin extends StatefulWidget {
  AccountDataModel loggedAccount;
  bool isFirstLogin;
  AccountLogin(
      {super.key, required this.isFirstLogin, required this.loggedAccount});

  @override
  State<AccountLogin> createState() => _AccountLoginState();
}

class _AccountLoginState extends State<AccountLogin> {
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerPasswd = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: (widget.isFirstLogin ? null : AppBar()),
        body: Center(
          child: ClipRect(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                appIconImage(margin: EdgeInsets.only(bottom: 12)),
                // TODO: Border & Background as Design
                const Padding(
                  padding: EdgeInsets.only(top: 12, bottom: 36),
                  child: Text(
                    "登录",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ),
                loginInput(),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: ElevatedButton(
                    onPressed: () {
                      setLogin(onLoginErr: () {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text("用户名或密码错误")));
                      }, onNetworkErr: () {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text("网络错误")));
                      });
                    },
                    style: const ButtonStyle(
                        fixedSize:
                            MaterialStatePropertyAll(Size.fromWidth(280))),
                    child: const Text("确认"),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 48, bottom: 12),
                  child: Text("其他"),
                ),
                thirdPartyLogin(),
                Padding(
                  padding: EdgeInsets.only(top: 6, bottom: 24),
                  child: TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AccountRegister(
                                      loggedAccount: widget.loggedAccount,
                                    )));
                      },
                      child: const Text("注册")),
                )
              ],
            ),
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
        ],
      ),
    );
  }

  Widget thirdPartyLogin() {
    return SizedBox(
        width: 140,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(onPressed: () {}, icon: Icon(Icons.shop_two)),
            IconButton(
                onPressed: () {}, icon: Icon(Icons.accessible_forward_outlined))
          ],
        ));
  }

  void setLogin(
      {required Function onNetworkErr, required Function onLoginErr}) {
    String user = controllerName.text, pwd = controllerPasswd.text;
    if (user == "" || pwd == "") return;

    http
        .post(Uri.parse(serverAddress + API.userLogin.api),
            headers: jsonHeaders,
            body: jsonEncode({
              "user": user,
              "password": sha1.convert(utf8.encode(pwd)).toString()
            }))
        .timeout(Duration(seconds: 5))
        .then((value) {
      print(value.body);
      var result = jsonDecode(Utf8Decoder().convert(value.bodyBytes));
      var cookie = value.headers["set-cookie"];
      if (cookie != null) {
        int index = cookie.indexOf(';');
        widget.loggedAccount.cookie =
            (index == -1 ? cookie : cookie.substring(0, index));
        widget.loggedAccount.name = user;
        http
            .post(Uri.parse(serverAddress + API.userInfo.api),
                headers: jsonHeaders, body: jsonEncode({"user": user}))
            .timeout(Duration(seconds: 5))
            .then((value) {
          var result = jsonDecode(Utf8Decoder().convert(value.bodyBytes));
          print("[AccountLogin] User info fetched: $result");
          widget.loggedAccount.avatar = result["result"]["avatar"];
          widget.loggedAccount.uid = result["result"]["uid"];
          Navigator.pop(context);
        });
      } else {
        onLoginErr();
      }
    }).catchError((error) {
      print(error);
      onNetworkErr();
    });
  }
}
