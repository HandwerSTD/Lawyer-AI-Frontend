
import 'package:flutter/material.dart';
import 'package:lawyer_ai_frontend/account/account_login/account_login.dart';
import 'package:lawyer_ai_frontend/common/constant/constants.dart';
import 'package:lawyer_ai_frontend/common/data_model/data_models.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AccountPage extends StatefulWidget {
  AccountDataModel loggedAccount;
  AccountPage({super.key, required this.loggedAccount});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {

  @override
  Widget build(BuildContext context) {
    return widget.loggedAccount.cookie == "" ? AccountLogin(isFirstLogin: false, loggedAccount: widget.loggedAccount,) : MyAccount(loggedAccount: widget.loggedAccount,);
  }
}

class MyAccount extends StatefulWidget {
  AccountDataModel loggedAccount;
  MyAccount({super.key, required this.loggedAccount});

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("我的账户"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [

          ],
        ),
      ),
    );
  }

  Widget myAccountBlock() {
    return Container(
      child: Row(
        children: [
          Padding(padding: EdgeInsets.all(6), child: CachedNetworkImage(imageUrl: (serverAddress + API.userAvatar.api + widget.loggedAccount.avatar),
            width: 512,
            height: 512,
          ),),
          Text(widget.loggedAccount.name)
        ],
      ),
    );
  }
}
