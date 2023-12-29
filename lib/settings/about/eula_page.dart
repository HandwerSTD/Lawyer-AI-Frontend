import 'package:flutter/material.dart';
import 'package:lawyer_ai_frontend/common/constant/eula.dart';

class EULAPage extends StatelessWidget {
  const EULAPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("用户协议"),),
      body: Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: ListView(
          children: [
            Row(
              children: [Expanded(
                child: Text(EULA),
              )],
            )
          ],
        ),
      ),
    );
  }
}
