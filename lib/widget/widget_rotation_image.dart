import 'package:flutter/material.dart';

class RotationImageWidget extends StatefulWidget {
  final Widget child;
  final bool isRepeat;
  final Duration duration;

  static const Duration _defaultDuration = Duration(seconds: 10);

  RotationImageWidget(this.child,
      {this.isRepeat = true, this.duration = _defaultDuration});

  @override
  _RotationImageWidgetState createState() => _RotationImageWidgetState();
}

class _RotationImageWidgetState extends State<RotationImageWidget>
    with SingleTickerProviderStateMixin {
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    controller.addStatusListener((status) {
      if (widget.isRepeat && status == AnimationStatus.completed) {
        //重置起点
        controller.reset();
        //开启
        controller.forward();
      }
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: RotationTransition(
      alignment: Alignment.center,
      turns: controller,
      child: widget.child,
    ));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
