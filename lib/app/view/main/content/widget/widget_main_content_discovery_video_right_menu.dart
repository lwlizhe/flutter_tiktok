import 'package:flutter/material.dart';
import 'package:flutter_tiktok/widget/widget_rotation_image.dart';

import 'widget_main_content_comment_bottom_sheet.dart';

class VideoOperateRightMenuWidget extends StatefulWidget {
  @override
  _VideoOperateRightMenuWidgetState createState() =>
      _VideoOperateRightMenuWidgetState();
}

class _VideoOperateRightMenuWidgetState
    extends State<VideoOperateRightMenuWidget> {



  @override
  Widget build(BuildContext context) {

    var commentSheetWidget=MainContentCommentBottomSheetWidget();

    return Container(
      height: 400,
      padding: EdgeInsets.only(left: 5, right: 5),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Stack(
            children: <Widget>[
              CircleAvatar(
                backgroundImage: AssetImage("imgs/avatar/avatar.png"),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.favorite,
                color: Colors.white,
                size: 40,
              ),
              Text(
                "666",
                style: TextStyle(color: Colors.white, fontSize: 12),
              )
            ],
          ),
          GestureDetector(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.textsms,
                  color: Colors.white,
                  size: 35,
                ),
                Text(
                  "666",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                )
              ],
            ),
            onTap: () {
              showModalBottomSheet(context: context, builder: (context){
                return commentSheetWidget;
              });
            },
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.share,
                color: Colors.white,
                size: 35,
              ),
              Text(
                "666",
                style: TextStyle(color: Colors.white, fontSize: 12),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 30, bottom: 10),
            child: RotationImageWidget(
              Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                        child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: CircleAvatar(
                          backgroundImage: AssetImage("imgs/avatar/avatar.png"),
                        ),
                      ),
                    )),
                    Image.asset("imgs/bet.png"),
                  ],
                ),
              ),
              isRepeat: true,
            ),
          ),
        ],
      ),
    );
  }
}
