// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart' hide NestedPageController;
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/foundation.dart' show precisionErrorTolerance;
import 'package:flutter/src/gestures/drag.dart';
import 'package:flutter_tiktok/widget/nested_page_controller.dart';

final NestedPageController _defaultPageController = NestedPageController(initialPage: 0,isInner: false);
final NestedPageController _defaultChildPageController = NestedPageController(initialPage: 0,isInner: true);
const PageScrollPhysics _kPagePhysics = PageScrollPhysics();

class PageScrollPhysics extends ScrollPhysics {
  /// Creates physics for a [NestedPrimaryPageView].
  const PageScrollPhysics({ScrollPhysics parent}) : super(parent: parent);

  @override
  PageScrollPhysics applyTo(ScrollPhysics ancestor) {
    return PageScrollPhysics(parent: buildParent(ancestor));
  }

  double _getPage(ScrollPosition position) {
    if (position is NestedPagePosition) return position.page;
    return position.pixels / position.viewportDimension;
  }

  double _getPixels(ScrollPosition position, double page) {
    if (position is NestedPagePosition) return position.getPixelsFromPage(page);
    return page * position.viewportDimension;
  }

  double _getTargetPixels(
      ScrollPosition position, Tolerance tolerance, double velocity) {
    double page = _getPage(position);
    if (velocity < -tolerance.velocity)
      page -= 0.5;
    else if (velocity > tolerance.velocity) page += 0.5;
    return _getPixels(position, page.roundToDouble());
  }

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // If we're out of range and not headed back in range, defer to the parent
    // ballistics, which should put us back in range at a page boundary.
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent))
      return super.createBallisticSimulation(position, velocity);
    final Tolerance tolerance = this.tolerance;
    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels)
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}

class NestedPrimaryPageView extends StatefulWidget {
  NestedPrimaryPageView({
    Key key,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    NestedPageController controller,
    NestedPageController childController,
    this.physics,
    this.pageSnapping = true,
    this.onPageChanged,
    List<Widget> children = const <Widget>[],
    this.dragStartBehavior = DragStartBehavior.start,
  })  : controller = controller ?? _defaultPageController,
        childController = childController ?? _defaultChildPageController,
        childrenDelegate = SliverChildListDelegate(children),
        super(key: key);

  NestedPrimaryPageView.builder({
    Key key,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    NestedPageController controller,
    NestedPageController childController,
    this.physics,
    this.pageSnapping = true,
    this.onPageChanged,
    @required IndexedWidgetBuilder itemBuilder,
    int itemCount,
    this.dragStartBehavior = DragStartBehavior.start,
  })  : controller = controller ?? _defaultPageController,
        childController = childController ?? _defaultChildPageController,
      childrenDelegate =
            SliverChildBuilderDelegate(itemBuilder, childCount: itemCount),
        super(key: key);

  NestedPrimaryPageView.custom({
    Key key,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    NestedPageController controller,
    NestedPageController childController,
    this.physics,
    this.pageSnapping = true,
    this.onPageChanged,
    @required this.childrenDelegate,
    this.dragStartBehavior = DragStartBehavior.start,
  })  : assert(childrenDelegate != null),
        controller = controller ?? _defaultPageController,
        childController = childController ?? _defaultChildPageController,
      super(key: key);

  final Axis scrollDirection;

  final bool reverse;

  final NestedPageController controller;
  final NestedPageController childController;

  final ScrollPhysics physics;

  final bool pageSnapping;

  final ValueChanged<int> onPageChanged;

  final SliverChildDelegate childrenDelegate;

  final DragStartBehavior dragStartBehavior;

  @override
  _PageViewState createState() => _PageViewState();

}

class _PageViewState extends State<NestedPrimaryPageView> {
  int _lastReportedPage = 0;

  NestedPageCoordinator _coordinator;

  @override
  void initState() {
    super.initState();
    _coordinator=NestedPageCoordinator(widget.controller,widget.childController);
    _lastReportedPage = widget.controller.initialPage;
  }

  AxisDirection _getDirection(BuildContext context) {
    switch (widget.scrollDirection) {
      case Axis.horizontal:
        assert(debugCheckHasDirectionality(context));
        final TextDirection textDirection = Directionality.of(context);
        final AxisDirection axisDirection =
            textDirectionToAxisDirection(textDirection);
        return widget.reverse
            ? flipAxisDirection(axisDirection)
            : axisDirection;
      case Axis.vertical:
        return widget.reverse ? AxisDirection.up : AxisDirection.down;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final AxisDirection axisDirection = _getDirection(context);
    final ScrollPhysics physics = widget.pageSnapping
        ? _kPagePhysics.applyTo(widget.physics)
        : widget.physics;

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification.depth == 0 &&
            widget.onPageChanged != null &&
            notification is ScrollUpdateNotification) {
          final PageMetrics metrics = notification.metrics;
          final int currentPage = metrics.page.round();
          if (currentPage != _lastReportedPage) {
            _lastReportedPage = currentPage;
            widget.onPageChanged(currentPage);
          }
        }
        return false;
      },
      child: Scrollable(
        dragStartBehavior: widget.dragStartBehavior,
        axisDirection: axisDirection,
        controller: _coordinator.getOuterController(),
        physics: physics,
        viewportBuilder: (BuildContext context, ViewportOffset position) {
          return Viewport(
            cacheExtent: 0.0,
            axisDirection: axisDirection,
            offset: position,
            slivers: <Widget>[
              PrimaryScrollController(
                  controller: _coordinator.getInnerController(),
                  child: SliverFillViewport(
                    viewportFraction: widget.controller.viewportFraction,
                    delegate: widget.childrenDelegate,
                  )),
            ],
          );
        },
      ),
    );
  }
}
