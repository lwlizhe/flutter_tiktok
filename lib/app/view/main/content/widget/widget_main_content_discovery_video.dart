import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'widget_main_content_discovery_video_controller.dart';
import 'widget_main_content_discovery_video_description_menu.dart';
import 'widget_main_content_discovery_video_right_menu.dart';

class MainContentDiscoveryVideoListWidget extends StatefulWidget {
  final String videoUrl;
  final BoxConstraints constraints;

  MainContentDiscoveryVideoListWidget(this.videoUrl, this.constraints);

  @override
  _MainContentDiscoveryVideoListWidgetState createState() =>
      _MainContentDiscoveryVideoListWidgetState();
}

class _MainContentDiscoveryVideoListWidgetState
    extends State<MainContentDiscoveryVideoListWidget> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: widget.constraints.maxWidth,
        height: widget.constraints.maxHeight,
        alignment: Alignment.center,
        child: Stack(
          children: <Widget>[
            _controller.value.initialized
                ? Container(
                    alignment: Alignment.center,
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                    width: double.infinity,
                    height: double.infinity,
                  )
                : Container(
                    alignment: Alignment.center,
                    child: Text("Loading ……"),
                  ),
            Positioned.fill(
              child: VideoControllerWidget(_controller),
            ),
            Positioned.fill(
                child: Align(
              alignment: Alignment.bottomRight,
              child: VideoOperateRightMenuWidget(),
            )),
            Positioned.fill(
                child: Align(
              alignment: Alignment.bottomLeft,
              child: VideoDescriptionWidget(),
            ))
          ],
        ));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
    print("缓存移除 " + widget.videoUrl);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("缓存添加 " + widget.videoUrl);
  }
}
