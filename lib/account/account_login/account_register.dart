import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:lawyer_ai_frontend/account/account_login/account_login.dart';
import 'package:lawyer_ai_frontend/common/data_model/data_models.dart';
import 'package:lawyer_ai_frontend/common/theme/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../../common/constant/constants.dart';
import '../../settings/about/eula_page.dart';

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
        body: Container(
          alignment: Alignment.center,
          color: themeAccent,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                      offset: Offset(1, 1),
                      spreadRadius: 1,
                      color: Color(0x10000000),
                      blurRadius: 20)
                ]),
            padding: EdgeInsets.only(left: 12, right: 12, top: 36, bottom: 24),
            margin: EdgeInsets.only(bottom: 24),
            child: Column(
              // TODO: Border & Background as Design
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 12, bottom: 36),
                  child: Text(
                    "注册",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ),
                loginInput(),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: ElevatedButton(
                    onPressed: () {
                      setRegister(onNetworkErr: () {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text("网络错误")));
                      }, onRegErr: () {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text("注册失败")));
                      });
                    },
                    style: ButtonStyle(
                        foregroundColor: MaterialStatePropertyAll(Colors.white),
                        backgroundColor:
                            MaterialStatePropertyAll(Color(0xff5966cd)),
                        fixedSize:
                            MaterialStatePropertyAll(Size.fromWidth(280)),
                        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)))),
                    child: const Text("确认"),
                  ),
                ),
                privacyStatement(),
                const Padding(
                  padding: EdgeInsets.only(top: 24, bottom: 12),
                  child: Text("其他"),
                ),
                thirdPartyLogin(),
              ],
            ),
          ),
        ));
  }

  Widget loginInput() {
    return SizedBox(
      width: 280,
      child: Column(
        children: [
          loginInputTextField(text: "邮箱", controller: controllerEmail),
          loginInputTextField(text: "用户名", controller: controllerName),
          loginInputTextField(
              text: "密码", controller: controllerPasswd, secure: true),
          Text("密码不少于6位，需要至少包含字母和数字")
        ],
      ),
    );
  }

  Widget privacyStatement() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Checkbox(
            value: checkboxSelected,
            onChanged: (value) {
              setState(() {
                checkboxSelected = !checkboxSelected;
              });
            }),
        Text("我已阅读并同意"),
        InkWell(
          child: Text(
            "《用户协议》",
            style: TextStyle(color: Colors.blueAccent),
          ),
          onTap: () {
            // TODO: 用户协议
            // launchUrl(Uri.parse(privacyStatementAddress),
            //     mode: LaunchMode.externalApplication);

            Navigator.push(context, MaterialPageRoute(builder: (context) => EULAPage()));
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
            IconButton(
                onPressed: () {
                  setThirdPartyLogin();
                },
                icon: Icon(Icons.shop_two)),
            IconButton(
                onPressed: () {
                  setThirdPartyLogin();
                },
                icon: Icon(Icons.accessible_forward_outlined))
          ],
        ));
  }

  void setThirdPartyLogin() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("暂未开放")));
  }

  bool checkPwd(String pwd) {
    return true;
  }

  void setRegister(
      {required Function onNetworkErr, required Function onRegErr}) {
    String user = controllerName.text,
        pwd = controllerPasswd.text,
        email = controllerEmail.text;
    if (user == "" || email == "") {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("用户名和邮箱不能为空")));
      return;
    }
    if (!checkPwd(pwd)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("密码不符合要求")));
      return;
    }
    if (!checkboxSelected) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("请阅读并同意我们的《用户协议》")));
      return;
    }
    print("[AccountRegister] sending data");
    http
        .post(Uri.parse(serverAddress + API.userRegister.api),
            headers: jsonHeaders,
            body: jsonEncode({
              "user": user,
              "password": sha1.convert(utf8.encode(pwd)).toString()
            }))
        .timeout(Duration(seconds: 5))
        .then((value) {
      print(value.body);
      var result = jsonDecode(Utf8Decoder().convert(value.bodyBytes));
      if (result["status"] != "success") {
        print(result["message"]);
        onRegErr();
        return;
      }
      showSnackBar(context, "注册成功，请登录");
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
