import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';

class PositionedTapDetector extends StatefulWidget {
  PositionedTapDetector({
    Key key,
    this.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onContinuousClick,
    this.doubleTapDelay: _DEFAULT_DELAY,
    this.behavior,
    this.controller,
  }) : super(key: key);

  static const _DEFAULT_DELAY = Duration(milliseconds: 300);
  static const _DOUBLE_TAP_MAX_OFFSET = 48.0;

  final Widget child;
  final HitTestBehavior behavior;
  final TapPositionCallback onTap;
  final TapPositionCallback onDoubleTap;
  final TapPositionCallback onLongPress;
  final TapPositionCallback onContinuousClick;
  final Duration doubleTapDelay;
  final PositionedTapController controller;

  @override
  _TapPositionDetectorState createState() => _TapPositionDetectorState();
}

class _TapPositionDetectorState extends State<PositionedTapDetector> {
  StreamController<TapDownDetails> _controller = StreamController();

  Stream<TapDownDetails> get _stream => _controller.stream;

  Sink<TapDownDetails> get _sink => _controller.sink;

  PositionedTapController _tapController;
  TapDownDetails _pendingTap;
  TapDownDetails _firstTap;

  bool isContinuousClick = false;

  @override
  void initState() {
    _updateController();
    _stream
        .timeout(widget.doubleTapDelay)
        .handleError(_onTimeout, test: (e) => e is TimeoutException)
        .listen(_onTapConfirmed);
    super.initState();
  }

  @override
  void didUpdateWidget(PositionedTapDetector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _updateController();
    }
  }

  void _updateController() {
    _tapController?._state = null;
    if (widget.controller != null) {
      widget.controller._state = this;
      _tapController = widget.controller;
    }
  }

  void _onTimeout(dynamic error) {
    if (isContinuousClick) {
      _firstTap = null;
    }

    if (_firstTap != null && _pendingTap == null) {
      _postCallback(_firstTap, widget.onTap);
    }
    isContinuousClick = false;
  }

  void _onTapConfirmed(TapDownDetails details) {
    if (_firstTap == null) {
      _firstTap = details;
    } else {
      _handleSecondTap(details);
    }
  }

  void _handleSecondTap(TapDownDetails secondTap) {
    if (_isDoubleTap(_firstTap, secondTap)) {
      if (!isContinuousClick) {
        isContinuousClick = true;
      }
      _postCallback(secondTap, widget.onDoubleTap);
      _postCallback(secondTap, widget.onContinuousClick);
    }else if(isContinuousClick){
      _postCallback(secondTap, widget.onContinuousClick);
    } else {
      _postCallback(_firstTap, widget.onTap);
      _postCallback(secondTap, widget.onTap);
      isContinuousClick = false;
    }
  }

  bool _isDoubleTap(TapDownDetails d1, TapDownDetails d2) {
    final dx = (d1.globalPosition.dx - d2.globalPosition.dx);
    final dy = (d1.globalPosition.dy - d2.globalPosition.dy);
    return sqrt(dx * dx + dy * dy) <=
        PositionedTapDetector._DOUBLE_TAP_MAX_OFFSET;
  }

  void _onTapDownEvent(TapDownDetails details) {
    _pendingTap = details;
  }

  void _onTapEvent() {
    if (widget.onDoubleTap == null&&widget.onContinuousClick==null) {
      _postCallback(_pendingTap, widget.onTap);
    } else {
      _sink.add(_pendingTap);
    }
    _pendingTap = null;
  }

  void _onLongPressEvent() {
    if (_firstTap == null) {
      _postCallback(_pendingTap, widget.onLongPress);
    } else {
      _sink.add(_pendingTap);
      _pendingTap = null;
    }
  }

  void _postCallback(
      TapDownDetails details, TapPositionCallback callback) async {
    if (!isContinuousClick) {
      _firstTap = null;
    }
    if (callback != null) {
      callback(_getTapPositions(details));
    }
  }

  TapPosition _getTapPositions(TapDownDetails details) {
    final topLeft = _getWidgetTopLeft();
    final global = details.globalPosition;
    final relative = topLeft != null ? global - topLeft : null;
    return TapPosition(global, relative);
  }

  Offset _getWidgetTopLeft() {
    final translation =
        context?.findRenderObject()?.getTransformTo(null)?.getTranslation();
    return translation != null ? Offset(translation.x, translation.y) : null;
  }

  @override
  void dispose() {
    _controller.close();
    _tapController?._state = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller != null) return widget.child;
    return GestureDetector(
      child: widget.child,
      behavior: (widget.behavior ??
          (widget.child == null
              ? HitTestBehavior.translucent
              : HitTestBehavior.deferToChild)),
      onTap: _onTapEvent,
      onLongPress: _onLongPressEvent,
      onTapDown: _onTapDownEvent,
    );
  }
}

typedef TapPositionCallback(TapPosition position);

class TapPosition {
  TapPosition(this.global, this.relative);

  Offset global;
  Offset relative;

  @override
  bool operator ==(dynamic other) {
    if (other is! TapPosition) return false;
    final TapPosition typedOther = other;
    return global == typedOther.global && relative == other.relative;
  }

  @override
  int get hashCode => hashValues(global, relative);
}

class PositionedTapController {
  _TapPositionDetectorState _state;

  void onTap() => _state?._onTapEvent();

  void onLongPress() => _state?._onLongPressEvent();

  void onTapDown(TapDownDetails details) => _state?._onTapDownEvent(details);
}
