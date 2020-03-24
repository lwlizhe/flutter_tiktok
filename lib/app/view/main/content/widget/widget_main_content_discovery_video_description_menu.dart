import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tiktok/base/util/utils_toast.dart';
import 'package:flutter_tiktok/widget/marquee.dart';

class VideoDescriptionWidget extends StatefulWidget {
  @override
  _VideoDescriptionWidgetState createState() => _VideoDescriptionWidgetState();
}

class _VideoDescriptionWidgetState extends State<VideoDescriptionWidget> {

  String testBgmTitle;

  @override
  void initState() {
    super.initState();
    testBgmTitle="此处假装从网络获取到了bgm名";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 250),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: "@lwlizhe",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ]),
          ),
          RichText(
            text: TextSpan(
                text: "各位看官大爷大家好，我是练习时长一年的个人练习生lwlizhe，如果你喜欢这个项目，点击这里： ",
                style: TextStyle(color: Colors.white, fontSize: 16),
                children: [
                  TextSpan(
                      text: "点我点我",
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          ToastUtils.showToast(
                              "跳转到项目地址,https://github.com/lwlizhe/flutter_tiktok");
                        }),
                  TextSpan(
                    text: " 给个Star or Issue呗，你的支持才是我更新的动力",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ]),
          ),
          Padding(
            padding: EdgeInsets.only(top: 12, bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.music_note,
                  color: Colors.white,
                ),
                testBgmTitle.length==0?Container():
                Container(
                  height: 20,
                  width: 200,
                  child: Marquee(
                    text: testBgmTitle,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                    scrollAxis: Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    blankSpace: 20.0,
                    velocity: 60.0,
                    startPadding: 10.0,
                    accelerationCurve: Curves.linear,
                    decelerationCurve: Curves.easeOut,
                    pauseAfterRound: Duration(seconds: 1),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
