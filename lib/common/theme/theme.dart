import 'package:flutter/material.dart';

final themeAccent = Color(0xffded9fa);
final buttonThemeAccent = Color(0xff816cfd);
final bgAccent = Color(0xffebe8fc);
final BoxShadow fabBoxShadow = BoxShadow(
    color: Colors.black,
    offset: Offset.fromDirection(1, 1),
    spreadRadius: 3,
    blurRadius: 5);

final BoxShadow textBlockBoxShadow = BoxShadow(
    color: Colors.black26,
    offset: Offset.fromDirection(1, 1.1),
    spreadRadius: 0.01,
    blurRadius: 5);

Widget appBarIconButton(
    {required Icon icon,
    required Text text,
    required Function onPressed,
    Color color = const Color(0xff005ac2)}) {
  return ElevatedButton(
      onPressed: () {
        onPressed();
      },
      style: ButtonStyle(
        foregroundColor: MaterialStatePropertyAll(color),
        backgroundColor:
            const MaterialStatePropertyAll<Color>(Colors.transparent),
        surfaceTintColor:
            const MaterialStatePropertyAll<Color>(Colors.transparent),
        shadowColor: const MaterialStatePropertyAll<Color>(Colors.transparent),
      ),
      child: Row(
        children: [
          icon,
          Container(padding: const EdgeInsets.only(left: 5), child: text)
        ],
      ));
}

Widget settingsItemBlock(String text, Function onClick) {
  return Container(
      margin: EdgeInsets.only(left: 24, right: 24),
      child: Column(children: [
        Row(
          children: [
            Expanded(
                child: TextButton(
                    onPressed: () {
                      onClick();
                    },
                    style: const ButtonStyle(
                      // backgroundColor: MaterialStatePropertyAll(Color(0x19000000)),
                      foregroundColor: MaterialStatePropertyAll(Colors.black),
                      surfaceTintColor:
                          MaterialStatePropertyAll(Colors.transparent),
                      overlayColor: MaterialStatePropertyAll(Colors.black12),
                      alignment: Alignment.centerLeft,
                      // // side: MaterialStatePropertyAll(BorderSide(width: 1.2, color: Colors.blueGrey)),
                      // fixedSize: MaterialStatePropertyAll(Size.fromHeight(64)),
                      // shadowColor: MaterialStatePropertyAll(Colors.transparent),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(0)))),
                    ),
                    child: Text(
                      text,
                      style: TextStyle(fontSize: 18),
                    ))),
          ],
        ),
        Divider()
      ]));
}

class ExpandableText extends StatefulWidget {
  final String text;

  final int maxLines;

  final TextStyle style;

  final bool expand;

  const ExpandableText(
      {Key? key,
      required this.text,
      required this.maxLines,
      required this.style,
      required this.expand})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ExpandableTextState(text, maxLines, style, expand);
  }
}

class _ExpandableTextState extends State<ExpandableText> {
  final String text;

  final int maxLines;

  final TextStyle style;

  bool expand;

  _ExpandableTextState(this.text, this.maxLines, this.style, this.expand) {
    if (expand == null) {
      expand = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, size) {
      final span = TextSpan(text: text ?? '', style: style);

      final tp = TextPainter(
          text: span, maxLines: maxLines, textDirection: TextDirection.ltr);

      tp.layout(maxWidth: size.maxWidth);

      if (tp.didExceedMaxLines) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            expand
                ? Text(text ?? '', style: style)
                : Text(text ?? '',
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                    style: style),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                setState(() {
                  expand = !expand;
                });
              },
              child: Container(
                padding: EdgeInsets.only(top: 2),
                child: Text(expand ? '收起' : '全文',
                    style: TextStyle(
                        fontSize: style != null ? style.fontSize : null,
                        color: Colors.blue)),
              ),
            ),
          ],
        );
      } else {
        return Text(text ?? '', style: style);
      }
    });
  }
}

class NetworkErrorPlaceholder extends StatelessWidget {
  const NetworkErrorPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 500,
      height: 500,
      child: Column(
        children: [Icon(Icons.wifi_off), Text("网络错误")],
      ),
    );
  }
}

InputDecoration outlineBorderedInputDecoration(String hint, double rad,
        {bool dense = false, bool filled = false, fillColor}) =>
    InputDecoration(
      isDense: dense,
      contentPadding: EdgeInsets.symmetric(vertical: 8.5, horizontal: 12),
      border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(rad))),
      filled: filled,
      fillColor: fillColor,
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey),
    );

void showSnackBar(BuildContext context, String text, {int seconds = 1}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(text),
    duration: Duration(seconds: seconds),
  ));
}

Widget appIconImage({margin = const EdgeInsets.only(bottom: 12, top: 48)}) {
  return Container(
    width: 96,
    height: 96,
    margin: margin,
    child: Image.asset(
      "assets/rounded_app_icon.png",
    ),
  );
}
