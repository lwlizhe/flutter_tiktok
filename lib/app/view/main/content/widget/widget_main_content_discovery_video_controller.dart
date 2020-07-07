import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tiktok/widget/positioned_tap_detector.dart';
import 'dart:ui' as ui;
import 'package:simple_animations/simple_animations.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

class VideoControllerWidget extends StatefulWidget {
  final VideoPlayerController videoPlayerController;

  VideoControllerWidget(this.videoPlayerController);

  @override
  _VideoControllerWidgetState createState() => _VideoControllerWidgetState();
}

class _VideoControllerWidgetState extends State<VideoControllerWidget> {
  final List<_HeartModel> hearts = [];

  bool isImageLoaded = false;

  ui.Image image;

  @override
  void initState() {
    init();
    super.initState();
  }

  Future<Null> init() async {
    final ByteData data = await rootBundle.load('imgs/icon_heart.png');
    image = await loadImage(new Uint8List.view(data.buffer));
  }

  Future<ui.Image> loadImage(List<int> img) async {
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      isImageLoaded = true;
      if (mounted) {
        setState(() {});
      }
      return completer.complete(img);
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    var videoPlayerController = widget?.videoPlayerController;

    if (this.isImageLoaded) {
      return Rendering(
        startTime: Duration(seconds: 50),
        onTick: _simulateFinish,
        builder: (context, time) {
          _simulateFinish(time);
          return LayoutBuilder(
            builder: (context, constrains) {
              return PositionedTapDetector(
                onTap: (detail) {
                  print("tap");
                  videoPlayerController?.value?.isPlaying ?? false
                      ? videoPlayerController?.pause()
                      : videoPlayerController?.play();
                  setState(() {});
                },
                onContinuousClick: (detail) {
                  print("continuous");
                  hearts.add(_HeartModel(
                      Offset((detail.relative.dx) / constrains.maxWidth,
                          detail.relative.dy / constrains.maxHeight),
                      time: time));
                },
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                        child: CustomPaint(
                      painter: HeartPainter(hearts, time, image),
                    )),
                    Positioned.fill(
                      child: Align(
                        child: Text(
                          videoPlayerController?.value?.isPlaying ?? false
                              ? "暂停"
                              : "播放",
                          style: TextStyle(color: Colors.white),
                        ),
                        alignment: Alignment.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    } else {
      return new Center(child: new Text('loading'));
    }
  }

  _simulateFinish(Duration time) {
    hearts.removeWhere((particle) {
      return particle.isFinish(time);
    });
  }
}

class _HeartModel {
  Animatable tween;
  double size;
  AnimationProgress animationProgress;
  int defaultMilliseconds;

  _HeartModel(Offset offset, {this.defaultMilliseconds = 500, Duration time}) {
    init(offset, time: time);
  }

  init(Offset tapPos, {Duration time = Duration.zero}) {
    final startPosition = tapPos;

    final endPosition = Offset(tapPos.dx, tapPos.dy - 0.1);

    final duration = Duration(milliseconds: defaultMilliseconds + 200);

    tween = MultiTrackTween([
      Track("x").add(
          duration, Tween(begin: startPosition.dx, end: endPosition.dx),
          curve: Curves.easeInOutSine),
      Track("y").add(
          duration, Tween(begin: startPosition.dy, end: endPosition.dy),
          curve: Curves.easeIn),
      Track("color").add(
          duration, ColorTween(begin: Colors.red, end: Colors.transparent),
          curve: Curves.easeInOut)
    ]);
    animationProgress = AnimationProgress(duration: duration, startTime: time);
    size = 1;
  }

  bool isFinish(Duration time) {
    return animationProgress.progress(time) == 1.0;
  }
}

class HeartPainter extends CustomPainter {
  List<_HeartModel> heartIcons = [];
  Duration time;
  ui.Image image;
  Paint painter = Paint();

  HeartPainter(this.heartIcons, this.time, this.image);

  @override
  void paint(Canvas canvas, Size size) {
    heartIcons.forEach((particle) {
      print("paint");

      var progress = particle.animationProgress.progress(time);
      final animation = particle.tween.transform(progress);
      final position =
          Offset(animation["x"] * size.width, animation["y"] * size.height);
      painter.color = animation["color"];

      final Rect srcRct =
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
      final Rect dstRct = Rect.fromLTWH(
          position.dx - image.width.toDouble() / 4,
          position.dy - image.height.toDouble() / 2,
          image.width.toDouble() / 2,
          image.height.toDouble() / 2);

      canvas.drawImageRect(image, srcRct, dstRct, painter); //
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    print("shouldRepaint :"+heartIcons.isNotEmpty.toString());

    return heartIcons.isNotEmpty;
  }
}
