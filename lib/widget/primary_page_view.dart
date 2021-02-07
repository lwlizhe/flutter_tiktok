// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart' show Drag, DragStartBehavior;
import 'package:flutter/foundation.dart' show precisionErrorTolerance;

class PrimaryPageController extends ScrollController {
  PrimaryPageController({
    this.initialPage = 0,
    this.keepPage = true,
    this.viewportFraction = 1.0,
    this.coordinator,
  })  : assert(initialPage != null),
        assert(keepPage != null),
        assert(viewportFraction != null),
        assert(viewportFraction > 0.0);

  int initialPage;

  final bool keepPage;

  final double viewportFraction;

  PrimaryPageCoordinator coordinator;

  List<PrimaryPageController> childPageController = [];

  PrimaryPagePosition get pagePosition => position;

  double get page {
    assert(
      positions.isNotEmpty,
      'PrimaryPageController.page cannot be accessed before a NestedPrimaryPageView is built with it.',
    );
    assert(
      positions.length == 1,
      'The page property cannot be read when multiple PageViews are attached to '
      'the same PrimaryPageController.',
    );
    final PrimaryPagePosition position = this.position;
    return position.page;
  }

  Future<void> animateToPage(
    int page, {
    @required Duration duration,
    @required Curve curve,
  }) {
    final PrimaryPagePosition position = this.position;
    return position.animateTo(
      position.getPixelsFromPage(page.toDouble()),
      duration: duration,
      curve: curve,
    );
  }

  void jumpToPage(int page) {
    final PrimaryPagePosition position = this.position;
    position.jumpTo(position.getPixelsFromPage(page.toDouble()));
  }

  Future<void> nextPage({@required Duration duration, @required Curve curve}) {
    return animateToPage(page.round() + 1, duration: duration, curve: curve);
  }

  Future<void> previousPage(
      {@required Duration duration, @required Curve curve}) {
    return animateToPage(page.round() - 1, duration: duration, curve: curve);
  }

  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics,
      ScrollContext context, ScrollPosition oldPosition) {
    PrimaryPagePosition result = PrimaryPagePosition(
      physics: physics,
      context: context,
      initialPage: initialPage,
      keepPage: keepPage,
      viewportFraction: viewportFraction,
      oldPosition: oldPosition,
    )..coordinator = coordinator;

    return result;
  }

  @override
  void attach(ScrollPosition position) {
    super.attach(position);
    final PrimaryPagePosition pagePosition = position;
    pagePosition.viewportFraction = viewportFraction;

    if (position is PrimaryPagePosition) {
      position.coordinator = coordinator;
      position.pageController = this;
    }
  }

  @override
  void detach(ScrollPosition position) {
    super.detach(position);
    if (position is PrimaryPagePosition) {
      position.pageController = null;
    }
  }
}

class PrimaryPagePosition extends ScrollPosition
    implements PageMetrics, ScrollActivityDelegate {
  PrimaryPagePosition({
    ScrollPhysics physics,
    ScrollContext context,
    this.initialPage = 0,
    bool keepPage = true,
    double viewportFraction = 1.0,
    double initialPixels = 0.0,
    ScrollPosition oldPosition,
  })  : assert(initialPage != null),
        assert(keepPage != null),
        assert(viewportFraction != null),
        assert(viewportFraction > 0.0),
        _viewportFraction = viewportFraction,
        _pageToUseOnStartup = initialPage.toDouble(),
        super(
          physics: physics,
          context: context,
          keepScrollOffset: keepPage,
          oldPosition: oldPosition,
        ) {
    if (activity == null) goIdle();
    assert(activity != null);
  }

  final int initialPage;
  double _pageToUseOnStartup;

  @override
  double get viewportFraction => _viewportFraction;
  double _viewportFraction;

  PrimaryPageCoordinator coordinator;
  PrimaryPageController pageController;

  set viewportFraction(double value) {
    if (_viewportFraction == value) return;
    final double oldPage = page;
    _viewportFraction = value;
    if (oldPage != null) forcePixels(getPixelsFromPage(oldPage));
  }

  double get _initialPageOffset =>
      math.max(0, viewportDimension * (viewportFraction - 1) / 2);

  ScrollActivity get scrollActivity => activity;

  double getPageFromPixels(double pixels, double viewportDimension) {
    final double actual = math.max(0.0, pixels - _initialPageOffset) /
        math.max(1.0, viewportDimension * viewportFraction);
    final double round = actual.roundToDouble();
    if ((actual - round).abs() < precisionErrorTolerance) {
      return round;
    }
    return actual;
  }

  double getPixelsFromPage(double page) {
    return page * viewportDimension * viewportFraction + _initialPageOffset;
  }

  @override
  double get page {
    assert(
      pixels == null || (minScrollExtent != null && maxScrollExtent != null),
      'Page value is only available after content dimensions are established.',
    );
    return pixels == null
        ? null
        : getPageFromPixels(
            pixels.clamp(minScrollExtent, maxScrollExtent), viewportDimension);
  }

  @override
  void saveScrollOffset() {
    PageStorage.of(context.storageContext)?.writeState(
        context.storageContext, getPageFromPixels(pixels, viewportDimension));
  }

  @override
  void restoreScrollOffset() {
    if (pixels == null) {
      final double value = PageStorage.of(context.storageContext)
          ?.readState(context.storageContext);
      if (value != null) _pageToUseOnStartup = value;
    }
  }

  @override
  bool applyViewportDimension(double viewportDimension) {
    final double oldViewportDimensions = this.viewportDimension;
    final bool result = super.applyViewportDimension(viewportDimension);
    final double oldPixels = pixels;
    final double page = (oldPixels == null || oldViewportDimensions == 0.0)
        ? _pageToUseOnStartup
        : getPageFromPixels(oldPixels, this.viewportDimension);
    final double newPixels = getPixelsFromPage(page);

    if (newPixels != oldPixels) {
      correctPixels(newPixels);
      return false;
    }
    return result;
  }

  @override
  bool applyContentDimensions(double minScrollExtent, double maxScrollExtent) {
    final double newMinScrollExtent = minScrollExtent + _initialPageOffset;
    return super.applyContentDimensions(
      newMinScrollExtent,
      math.max(newMinScrollExtent, maxScrollExtent - _initialPageOffset),
    );
  }

  @override
  PageMetrics copyWith({
    double minScrollExtent,
    double maxScrollExtent,
    double pixels,
    double viewportDimension,
    AxisDirection axisDirection,
    double viewportFraction,
  }) {
    return PageMetrics(
      minScrollExtent: minScrollExtent ?? this.minScrollExtent,
      maxScrollExtent: maxScrollExtent ?? this.maxScrollExtent,
      pixels: pixels ?? this.pixels,
      viewportDimension: viewportDimension ?? this.viewportDimension,
      axisDirection: axisDirection ?? this.axisDirection,
      viewportFraction: viewportFraction ?? this.viewportFraction,
    );
  }

  /// Velocity from a previous activity temporarily held by [hold] to potentially
  /// transfer to a next activity.
  double _heldPreviousVelocity = 0.0;

  @override
  AxisDirection get axisDirection => context.axisDirection;

  @override
  double setPixels(double newPixels) {
    assert(activity.isScrolling);
    return super.setPixels(newPixels);
  }

  @override
  void absorb(ScrollPosition other) {
    super.absorb(other);
    if (other is! ScrollPositionWithSingleContext) {
      goIdle();
      return;
    }
    activity.updateDelegate(this);
    final PrimaryPagePosition typedOther = other;
    _userScrollDirection = typedOther._userScrollDirection;
    assert(_currentDrag == null);
    if (typedOther._currentDrag != null) {
      _currentDrag = typedOther._currentDrag;
      _currentDrag.updateDelegate(this);
      typedOther._currentDrag = null;
    }
  }

  @override
  void applyNewDimensions() {
    super.applyNewDimensions();
    context.setCanDrag(physics.shouldAcceptUserOffset(this));
  }

  @override
  void beginActivity(ScrollActivity newActivity) {
    _heldPreviousVelocity = 0.0;
    if (newActivity == null) return;
    super.beginActivity(newActivity);
    _currentDrag?.dispose();
    _currentDrag = null;
    if (!activity.isScrolling) updateUserScrollDirection(ScrollDirection.idle);
  }

  @override
  void applyUserOffset(double delta) {
    updateUserScrollDirection(
        delta > 0.0 ? ScrollDirection.forward : ScrollDirection.reverse);
    setPixels(pixels - physics.applyPhysicsToUserOffset(this, delta));
  }

  @override
  void goIdle() {
    beginActivity(IdleScrollActivity(this));
  }

  /// Start a physics-driven simulation that settles the [pixels] position,
  /// starting at a particular velocity.
  ///
  /// This method defers to [ScrollPhysics.createBallisticSimulation], which
  /// typically provides a bounce simulation when the current position is out of
  /// bounds and a friction simulation when the position is in bounds but has a
  /// non-zero velocity.
  ///
  /// The velocity should be in logical pixels per second.
  @override
  void goBallistic(double velocity) {
    assert(pixels != null);
    final Simulation simulation =
        physics.createBallisticSimulation(this, velocity);
    if (simulation != null) {
      beginActivity(BallisticScrollActivity(this, simulation, context.vsync));
    } else {
      goIdle();
    }
  }

  @override
  ScrollDirection get userScrollDirection => _userScrollDirection;
  ScrollDirection _userScrollDirection = ScrollDirection.idle;

  /// Set [userScrollDirection] to the given value.
  ///
  /// If this changes the value, then a [UserScrollNotification] is dispatched.
  @protected
  @visibleForTesting
  void updateUserScrollDirection(ScrollDirection value) {
    assert(value != null);
    if (userScrollDirection == value) return;
    _userScrollDirection = value;
    didUpdateScrollDirection(value);
  }

  @override
  Future<void> animateTo(
    double to, {
    @required Duration duration,
    @required Curve curve,
  }) {
    if (nearEqual(to, pixels, physics.tolerance.distance)) {
      // Skip the animation, go straight to the position as we are already close.
      jumpTo(to);
      return Future<void>.value();
    }

    final DrivenScrollActivity activity = DrivenScrollActivity(
      this,
      from: pixels,
      to: to,
      duration: duration,
      curve: curve,
      vsync: context.vsync,
    );
    beginActivity(activity);
    return activity.done;
  }

  @override
  void jumpTo(double value) {
    goIdle();
    if (pixels != value) {
      final double oldPixels = pixels;
      forcePixels(value);
      notifyListeners();
      didStartScroll();
      didUpdateScrollPositionBy(pixels - oldPixels);
      didEndScroll();
    }
    goBallistic(0.0);
  }

  @Deprecated(
      'This will lead to bugs.') // ignore: flutter_deprecation_syntax, https://github.com/flutter/flutter/issues/44609
  @override
  void jumpToWithoutSettling(double value) {
    goIdle();
    if (pixels != value) {
      final double oldPixels = pixels;
      forcePixels(value);
      notifyListeners();
      didStartScroll();
      didUpdateScrollPositionBy(pixels - oldPixels);
      didEndScroll();
    }
  }

  @override
  ScrollHoldController hold(VoidCallback holdCancelCallback) {
    if (coordinator != null && coordinator.isOuterControllerEnable()) {
      return coordinator.hold(holdCancelCallback);
    } else {
      final double previousVelocity = activity.velocity;
      final HoldScrollActivity holdActivity = HoldScrollActivity(
        delegate: this,
        onHoldCanceled: holdCancelCallback,
      );
      beginActivity(holdActivity);
      _heldPreviousVelocity = previousVelocity;
      return holdActivity;
    }
  }

  ScrollDragController _currentDrag;

  @override
  Drag drag(DragStartDetails details, VoidCallback dragCancelCallback) {
    if (coordinator != null && coordinator.isOuterControllerEnable()) {
      return coordinator.drag(details, dragCancelCallback);
    } else {
      final ScrollDragController drag = ScrollDragController(
        delegate: this.coordinator ?? this,
        details: details,
        onDragCanceled: dragCancelCallback,
        carriedVelocity: physics.carriedMomentum(_heldPreviousVelocity),
        motionStartDistanceThreshold: physics.dragStartDistanceMotionThreshold,
      );
      beginActivity(DragScrollActivity(this, drag));
      assert(_currentDrag == null);
      _currentDrag = drag;
      return drag;
    }
  }

  @override
  void dispose() {
    _currentDrag?.dispose();
    _currentDrag = null;
    super.dispose();
  }

  @override
  void debugFillDescription(List<String> description) {
    super.debugFillDescription(description);
    description.add('${context.runtimeType}');
    description.add('$physics');
    description.add('$activity');
    description.add('$userScrollDirection');
  }

  // Returns the amount of delta that was not used.
  //
  // Positive delta means going down (exposing stuff above), negative delta
  // going up (exposing stuff below).
  double applyClampedDragUpdate(double delta) {
    assert(delta != 0.0);
    // If we are going towards the maxScrollExtent (negative scroll offset),
    // then the furthest we can be in the minScrollExtent direction is negative
    // infinity. For example, if we are already overscrolled, then scrolling to
    // reduce the overscroll should not disallow the overscroll.
    //
    // If we are going towards the minScrollExtent (positive scroll offset),
    // then the furthest we can be in the minScrollExtent direction is wherever
    // we are now, if we are already overscrolled (in which case pixels is less
    // than the minScrollExtent), or the minScrollExtent if we are not.
    //
    // In other words, we cannot, via applyClampedDragUpdate, _enter_ an
    // overscroll situation.
    //
    // An overscroll situation might be nonetheless entered via several means.
    // One is if the physics allow it, via applyFullDragUpdate (see below). An
    // overscroll situation can also be forced, e.g. if the scroll position is
    // artificially set using the scroll controller.
    final double min =
        delta < 0.0 ? -double.infinity : math.min(minScrollExtent, pixels);
    // The logic for max is equivalent but on the other side.
    final double max =
        delta > 0.0 ? double.infinity : math.max(maxScrollExtent, pixels);
    final double oldPixels = pixels;
    final double newPixels = (pixels - delta).clamp(min, max);
    final double clampedDelta = newPixels - pixels;
    if (clampedDelta == 0.0) return delta;
    final double overscroll = physics.applyBoundaryConditions(this, newPixels);
    final double actualNewPixels = newPixels - overscroll;
    final double offset = actualNewPixels - oldPixels;
    if (offset != 0.0) {
      forcePixels(actualNewPixels);
      didUpdateScrollPositionBy(offset);
    }
    return delta + offset;
  }

  double applyPageExtraUpdate(double delta) {
    final double min = delta < 0.0
        ? -double.infinity
        : math.min(page.toInt() * viewportDimension, pixels);
    // The logic for max is equivalent but on the other side.
    final double max = delta > 0.0
        ? double.infinity
        : math.max((page.toInt() + 1) * viewportDimension, pixels);
    final double oldPixels = pixels;
    final double newPixels = (pixels - delta).clamp(min, max);
    final double clampedDelta = newPixels - pixels;
    if (clampedDelta == 0.0) return delta;
    final double overscroll = physics.applyBoundaryConditions(this, newPixels);
    final double actualNewPixels = newPixels - overscroll;
    final double offset = actualNewPixels - oldPixels;
    if (offset != 0.0) {
      forcePixels(actualNewPixels);
      didUpdateScrollPositionBy(offset);
    }
    return (delta + offset).abs() < 0.00001 ? 0 : delta + offset;
  }

  // Returns the overscroll.
  double applyFullDragUpdate(double delta) {
    assert(delta != 0.0);
    final double oldPixels = pixels;
    // Apply friction:
    final double newPixels =
        pixels - physics.applyPhysicsToUserOffset(this, delta);
    if (oldPixels == newPixels)
      return 0.0; // delta must have been so small we dropped it during floating point addition
    // Check for overscroll:
    final double overscroll = physics.applyBoundaryConditions(this, newPixels);
    final double actualNewPixels = newPixels - overscroll;
    if (actualNewPixels != oldPixels) {
      forcePixels(actualNewPixels);
      didUpdateScrollPositionBy(actualNewPixels - oldPixels);
    }
    if (overscroll != 0.0) {
      didOverscrollBy(overscroll);
      return overscroll;
    }
    return 0.0;
  }

  ScrollActivity createBallisticScrollActivity(
    Simulation simulation, {
    @required _NestedBallisticScrollActivityMode mode,
    PageMetrics metrics,
  }) {
    if (simulation == null) return IdleScrollActivity(this);
    assert(mode != null);
    switch (mode) {
      case _NestedBallisticScrollActivityMode.outer:
        assert(metrics != null);
        if (metrics.minScrollExtent == metrics.maxScrollExtent)
          return IdleScrollActivity(this);
        return _NestedOuterBallisticScrollActivity(
          coordinator,
          this,
          metrics,
          simulation,
          context.vsync,
        );
      case _NestedBallisticScrollActivityMode.inner:
        return _NestedInnerBallisticScrollActivity(
          coordinator,
          this,
          simulation,
          context.vsync,
        );
      case _NestedBallisticScrollActivityMode.independent:
        return BallisticScrollActivity(this, simulation, context.vsync);
    }
    return null;
  }
}

enum _NestedBallisticScrollActivityMode { outer, inner, independent }

class _NestedInnerBallisticScrollActivity extends BallisticScrollActivity {
  _NestedInnerBallisticScrollActivity(
    this.coordinator,
    PrimaryPagePosition position,
    Simulation simulation,
    TickerProvider vsync,
  ) : super(position, simulation, vsync);

  final PrimaryPageCoordinator coordinator;

  @override
  PrimaryPagePosition get delegate => super.delegate as PrimaryPagePosition;

  @override
  void resetActivity() {
    delegate.beginActivity(coordinator.createInnerBallisticScrollActivity(
      delegate,
      velocity,
    ));
  }

  @override
  void applyNewDimensions() {
    delegate.beginActivity(coordinator.createInnerBallisticScrollActivity(
      delegate,
      velocity,
    ));
  }

  @override
  bool applyMoveTo(double value) {
    return super.applyMoveTo(value);
  }
}

class _NestedOuterBallisticScrollActivity extends BallisticScrollActivity {
  _NestedOuterBallisticScrollActivity(
    this.coordinator,
    PrimaryPagePosition position,
    this.metrics,
    Simulation simulation,
    TickerProvider vsync,
  )   : assert(metrics.minScrollExtent != metrics.maxScrollExtent),
        assert(metrics.maxScrollExtent > metrics.minScrollExtent),
        super(position, simulation, vsync);

  final PrimaryPageCoordinator coordinator;
  final PageMetrics metrics;

  @override
  PrimaryPagePosition get delegate => super.delegate as PrimaryPagePosition;

  @override
  void resetActivity() {
    delegate.beginActivity(
        coordinator.createOuterBallisticScrollActivity(velocity));
  }

  @override
  void applyNewDimensions() {
    delegate.beginActivity(
        coordinator.createOuterBallisticScrollActivity(velocity));
  }

  @override
  bool applyMoveTo(double value) {
    bool done = false;
    if (velocity > 0.0) {
      if (value < metrics.minScrollExtent) return true;
      if (value > metrics.maxScrollExtent) {
        value = metrics.maxScrollExtent;
        done = true;
      }
    } else if (velocity < 0.0) {
      if (value > metrics.maxScrollExtent) return true;
      if (value < metrics.minScrollExtent) {
        value = metrics.minScrollExtent;
        done = true;
      }
    } else {
      value = value.clamp(metrics.minScrollExtent, metrics.maxScrollExtent)
          as double;
      done = true;
    }
    final bool result = super.applyMoveTo(value);
    assert(
        result); // since we tried to pass an in-range value, it shouldn't ever overflow
    return !done;
  }
}

//class _PrimaryScrollMetrics extends FixedScrollMetrics {
//  _PrimaryScrollMetrics({
//    @required double minScrollExtent,
//    @required double maxScrollExtent,
//    @required double pixels,
//    @required double viewportDimension,
//    @required AxisDirection axisDirection,
//    @required this.minRange,
//    @required this.maxRange,
//    @required this.correctionOffset,
//  }) : super(
//          minScrollExtent: minScrollExtent,
//          maxScrollExtent: maxScrollExtent,
//          pixels: pixels,
//          viewportDimension: viewportDimension,
//          axisDirection: axisDirection,
//        );
//
//  @override
//  _PrimaryScrollMetrics copyWith({
//    double minScrollExtent,
//    double maxScrollExtent,
//    double pixels,
//    double viewportDimension,
//    AxisDirection axisDirection,
//    double minRange,
//    double maxRange,
//    double correctionOffset,
//  }) {
//    return _PrimaryScrollMetrics(
//      minScrollExtent: minScrollExtent ?? this.minScrollExtent,
//      maxScrollExtent: maxScrollExtent ?? this.maxScrollExtent,
//      pixels: pixels ?? this.pixels,
//      viewportDimension: viewportDimension ?? this.viewportDimension,
//      axisDirection: axisDirection ?? this.axisDirection,
//      minRange: minRange ?? this.minRange,
//      maxRange: maxRange ?? this.maxRange,
//      correctionOffset: correctionOffset ?? this.correctionOffset,
//    );
//  }
//
//  final double minRange;
//
//  final double maxRange;
//
//  final double correctionOffset;
//}

typedef _NestedScrollActivityGetter = ScrollActivity Function(
    PrimaryPagePosition position);

class PrimaryPageCoordinator
    implements ScrollActivityDelegate, ScrollHoldController {
  PrimaryPageController _outerController;
  PrimaryPageController _selfController;

  ScrollDragController _currentDrag;

//  bool isOperateBody = false;

  PrimaryPageCoordinator(PrimaryPageController selfController,
      PrimaryPageController parentController) {
    _selfController = selfController;
    _selfController.coordinator = this;
    if (_selfController.hasClients) {
      (_selfController.position as PrimaryPagePosition).coordinator = this;
    }

    _outerController = parentController;
    _outerController.coordinator = this;
    if (_outerController.hasClients) {
      (_outerController.position as PrimaryPagePosition).coordinator = this;
    }

    if (!_outerController.childPageController.contains(_selfController)) {
      _outerController.childPageController.add(_selfController);
    }
  }

  PrimaryPageController getOuterController() {
    return _outerController;
  }

  bool isOuterControllerEnable() {
    return _outerController != null && _outerController.hasClients;
  }

  PrimaryPageController getInnerController() {
    return _selfController;
  }

  bool isInnerControllerEnable() {
    return _selfController != null && _selfController.hasClients;
  }

  @override
  void applyUserOffset(double delta) {
    updateUserScrollDirection(
        delta > 0.0 ? ScrollDirection.forward : ScrollDirection.reverse);

    PrimaryPagePosition outPosition = isOuterControllerEnable()
        ? (getOuterController().position as PrimaryPagePosition)
        : null;

    int currentOuterPage = math.min(math.max((outPosition.page).round(), 0),
        getOuterController().childPageController.length - 1);

    print(
        "-------------------------------------------------------------------");
    print("outPosition page : " + outPosition.page.toString());
    print("currentOuterPage page : " + currentOuterPage.toString());
    print(
        "-------------------------------------------------------------------");

    // PrimaryPagePosition innerPosition = getInnerController().pagePosition;
    PrimaryPagePosition innerPosition =
        getOuterController().childPageController[currentOuterPage].position;

    // if (getInnerController().childPageController.isEmpty) {
    //   innerPosition.applyFullDragUpdate(delta);
    // } else if (delta < 0.0) {

    if (outPosition.page % 1 == 0) {
      if (delta < 0.0) {
        final double innerDelta = innerPosition.applyClampedDragUpdate(delta);
        if (innerDelta != 0.0) {
          outPosition.applyFullDragUpdate(innerDelta);
//        for (final PrimaryPageController controller
//            in getOuterController().childPageController)
//          (controller.position as PrimaryPagePosition)
//              .applyFullDragUpdate(innerDelta);
        }
      } else {
        double outerDelta = 0.0; // it will go positive if it changes
        double overscrolls = 0;
        final List<PrimaryPagePosition> innerPositions = getOuterController()
            .childPageController
            .map((e) => e.pagePosition)
            .toList();
        final double overscroll = innerPosition.applyClampedDragUpdate(delta);
        outerDelta = math.max(outerDelta, overscroll);
        overscrolls = overscroll;

        if (outerDelta != 0.0)
          outerDelta -= outPosition.applyClampedDragUpdate(outerDelta);
        // now deal with any overscroll
        final double remainingDelta = overscrolls - outerDelta;
        if (remainingDelta > 0.0)
          innerPosition.applyFullDragUpdate(remainingDelta);
      }
    } else {
      double remainDelta = outPosition.applyPageExtraUpdate(delta);
      if (remainDelta != 0) {
        print(
            "-------------------------------------------------------------------");
        print("到地方了" + outPosition.page.toString());
        print(
            "-------------------------------------------------------------------");
        ((getOuterController().childPageController[currentOuterPage].position)
                as PrimaryPagePosition)
            .applyClampedDragUpdate(remainDelta);
      }
    }

//    if ((outPosition?.pixels == outPosition?.minScrollExtent ||
//            outPosition?.pixels == outPosition?.maxScrollExtent) &&
//        (delta < 0
//            ? innerPosition.pixels < innerPosition.maxScrollExtent
//            : innerPosition.pixels > innerPosition.minScrollExtent)) {
//      innerPosition.applyUserOffset(delta);
//    } else {
//      outPosition.applyUserOffset(delta);
//    }
  }

  @override
  AxisDirection get axisDirection => _outerController.position.axisDirection;

  @override
  void cancel() {
    goBallistic(0.0);
  }

  @override
  void goBallistic(double velocity) {
    beginActivity(
      createOuterBallisticScrollActivity(velocity),
      (PrimaryPagePosition position) {
        return createInnerBallisticScrollActivity(
          position,
          velocity,
        );
      },
    );
  }

  void beginActivity(ScrollActivity newOuterActivity,
      _NestedScrollActivityGetter innerActivityGetter) {
    PrimaryPagePosition _outerPosition = isOuterControllerEnable()
        ? (getOuterController().position as PrimaryPagePosition)
        : null;
    PrimaryPagePosition _innerPosition = isInnerControllerEnable()
        ? (getInnerController().position as PrimaryPagePosition)
        : null;
    final List<PrimaryPagePosition> innerPositions = getOuterController()
        .childPageController
        .map((e) => e.pagePosition)
        .toList();

    _outerPosition.beginActivity(newOuterActivity);
    bool scrolling = newOuterActivity.isScrolling;

    final ScrollActivity newInnerActivity = innerActivityGetter(_innerPosition);
    _innerPosition.beginActivity(newInnerActivity);
    scrolling = newInnerActivity.isScrolling;

    _currentDrag?.dispose();
    _currentDrag = null;
    if (!scrolling) updateUserScrollDirection(ScrollDirection.idle);
  }

//  @override
//  void goBallistic(double velocity) {
//    PrimaryPagePosition innerPosition =
//        (getInnerController().position as PrimaryPagePosition);
//    PrimaryPagePosition outPosition = isOuterControllerEnable()
//        ? (getOuterController().position as PrimaryPagePosition)
//        : null;
//
//    if ((outPosition != null) &&
//        (outPosition.pixels > outPosition.minScrollExtent &&
//            outPosition.pixels < outPosition.maxScrollExtent)) {
//      outPosition.goBallistic(velocity);
//      innerPosition.goIdle();
//
//      _currentDrag?.dispose();
//      _currentDrag = null;
//
//      return;
//    }
//
//    if (velocity > 0) {
//      if (innerPosition.pixels < innerPosition.maxScrollExtent &&
//          innerPosition.pixels > innerPosition.minScrollExtent) {
//        innerPosition.goBallistic(velocity);
//        outPosition?.goIdle();
//      } else {
//        outPosition?.goBallistic(velocity);
//        innerPosition.goIdle();
//      }
//    } else {
//      if (innerPosition.pixels < innerPosition.maxScrollExtent) {
//        innerPosition.goBallistic(velocity);
//        outPosition?.goIdle();
//      } else {
//        outPosition?.goBallistic(velocity);
//        innerPosition.goIdle();
//      }
//    }
//
//    _currentDrag?.dispose();
//    _currentDrag = null;
//  }
  static IdleScrollActivity _createIdleScrollActivity(
      PrimaryPagePosition position) {
    return IdleScrollActivity(position);
  }

  @override
  void goIdle() {
    PrimaryPagePosition _outerPosition = isOuterControllerEnable()
        ? (getOuterController().position as PrimaryPagePosition)
        : null;

    beginActivity(
      _createIdleScrollActivity(_outerPosition),
      _createIdleScrollActivity,
    );
  }

  @override
  double setPixels(double pixels) {
    return 0.0;
  }

  ScrollHoldController hold(VoidCallback holdCancelCallback) {
    PrimaryPagePosition _outerPosition = isOuterControllerEnable()
        ? (getOuterController().position as PrimaryPagePosition)
        : null;

    beginActivity(
      HoldScrollActivity(
        delegate: _outerPosition,
        onHoldCanceled: holdCancelCallback,
      ),
      (PrimaryPagePosition position) => HoldScrollActivity(delegate: position),
    );
    return this;
  }

  Drag drag(DragStartDetails details, VoidCallback dragCancelCallback) {
    PrimaryPagePosition _outerPosition = isOuterControllerEnable()
        ? (getOuterController().position as PrimaryPagePosition)
        : null;

    final ScrollDragController drag = ScrollDragController(
      delegate: this,
      details: details,
      onDragCanceled: dragCancelCallback,
    );
    beginActivity(
      DragScrollActivity(_outerPosition, drag),
      (PrimaryPagePosition position) => DragScrollActivity(position, drag),
    );
    assert(_currentDrag == null);
    _currentDrag = drag;
    return drag;
  }

  ScrollDirection get userScrollDirection => _userScrollDirection;
  ScrollDirection _userScrollDirection = ScrollDirection.idle;

  void updateUserScrollDirection(ScrollDirection value) {
    assert(value != null);
    if (userScrollDirection == value) return;
    _userScrollDirection = value;
    getInnerController().position.didUpdateScrollDirection(value);
    if (isOuterControllerEnable()) {
      getOuterController().position.didUpdateScrollDirection(value);
    }
  }

  ScrollActivity createOuterBallisticScrollActivity(double velocity) {
    // This function creates a ballistic scroll for the outer scrollable.
    //
    // It assumes that the outer scrollable can't be overscrolled, and sets up a
    // ballistic scroll over the combined space of the innerPositions and the
    // outerPosition.

    // First we must pick a representative inner position that we will care
    // about. This is somewhat arbitrary. Ideally we'd pick the one that is "in
    // the center" but there isn't currently a good way to do that so we
    // arbitrarily pick the one that is the furthest away from the infinity we
    // are heading towards.
    PrimaryPagePosition innerPosition;

    final List<PrimaryPagePosition> _innerPositions = getOuterController()
        .childPageController
        .map((e) => e.pagePosition)
        .toList();

    PrimaryPagePosition outPosition = isOuterControllerEnable()
        ? (getOuterController().position as PrimaryPagePosition)
        : null;

    if (velocity != 0.0) {
      int currentOuterPage = math.min(math.max((outPosition.page).round(), 0),
          getOuterController().childPageController.length - 1);
      PrimaryPagePosition position = _innerPositions[currentOuterPage];
      if (innerPosition != null) {
        if (velocity > 0.0) {
          if (innerPosition.pixels < position.pixels) ;
        } else {
          assert(velocity < 0.0);
          if (innerPosition.pixels > position.pixels) ;
        }
      }
      innerPosition = position;
    }

    if (innerPosition != null &&
        (velocity > 0
            ? innerPosition.pixels < innerPosition.maxScrollExtent
            : innerPosition.pixels > innerPosition.minScrollExtent)) {
      return IdleScrollActivity(this);
    }

    if (innerPosition == null) {
      // It's either just us or a velocity=0 situation.
      return outPosition.createBallisticScrollActivity(
        outPosition.physics.createBallisticSimulation(
          outPosition,
          velocity,
        ),
        mode: _NestedBallisticScrollActivityMode.independent,
      );
    }

//    final PageMetrics metrics = _getMetrics(innerPosition, velocity);

    return outPosition.createBallisticScrollActivity(
      outPosition.physics.createBallisticSimulation(outPosition, velocity),
      mode: _NestedBallisticScrollActivityMode.outer,
      metrics: outPosition,
    );
  }

  @protected
  ScrollActivity createInnerBallisticScrollActivity(
      PrimaryPagePosition position, double velocity) {
    var outPosition = getOuterController().position;
    if (outPosition is PrimaryPagePosition && outPosition.page % 1 == 0) {
      ScrollActivity activity = position.createBallisticScrollActivity(
        position.physics.createBallisticSimulation(
          position,
          velocity,
        ),
        mode: _NestedBallisticScrollActivityMode.inner,
      );
      return activity;
    } else {
      return IdleScrollActivity(this);
    }
  }

//  _PrimaryScrollMetrics _getMetrics(
//      PrimaryPagePosition innerPosition, double velocity) {
//    assert(innerPosition != null);
//
//    PrimaryPagePosition _outerPosition = isOuterControllerEnable()
//        ? (getOuterController().position as PrimaryPagePosition)
//        : null;
//
//    double pixels, minRange, maxRange, correctionOffset, extra;
//    if (innerPosition.pixels == innerPosition.minScrollExtent) {
//      pixels = _outerPosition.pixels.clamp(
//        _outerPosition.minScrollExtent,
//        _outerPosition.maxScrollExtent,
//      ) as double; // TODO(ianh): gracefully handle out-of-range outer positions
//      minRange = _outerPosition.minScrollExtent;
//      maxRange = _outerPosition.maxScrollExtent;
//      assert(minRange <= maxRange);
//      correctionOffset = 0.0;
//      extra = 0.0;
//    } else {
//      assert(innerPosition.pixels != innerPosition.minScrollExtent);
//      if (innerPosition.pixels < innerPosition.minScrollExtent) {
//        pixels = innerPosition.pixels -
//            innerPosition.minScrollExtent +
//            _outerPosition.minScrollExtent;
//      } else {
//        assert(innerPosition.pixels > innerPosition.minScrollExtent);
//        pixels = innerPosition.pixels -
//            innerPosition.minScrollExtent +
//            _outerPosition.maxScrollExtent;
//      }
//      if ((velocity > 0.0) &&
//          (innerPosition.pixels > innerPosition.minScrollExtent)) {
//        // This handles going forward (fling up) and inner list is scrolled past
//        // zero. We want to grab the extra pixels immediately to shrink.
//        extra = _outerPosition.maxScrollExtent - _outerPosition.pixels;
//        assert(extra >= 0.0);
//        minRange = pixels;
//        maxRange = pixels + extra;
//        assert(minRange <= maxRange);
//        correctionOffset = _outerPosition.pixels - pixels;
//      } else if ((velocity < 0.0) &&
//          (innerPosition.pixels < innerPosition.minScrollExtent)) {
//        // This handles going backward (fling down) and inner list is
//        // underscrolled. We want to grab the extra pixels immediately to grow.
//        extra = _outerPosition.pixels - _outerPosition.minScrollExtent;
//        assert(extra >= 0.0);
//        minRange = pixels - extra;
//        maxRange = pixels;
//        assert(minRange <= maxRange);
//        correctionOffset = _outerPosition.pixels - pixels;
//      } else {
//        // This handles going forward (fling up) and inner list is
//        // underscrolled, OR, going backward (fling down) and inner list is
//        // scrolled past zero. We want to skip the pixels we don't need to grow
//        // or shrink over.
//        if (velocity > 0.0) {
//          // shrinking
//          extra = _outerPosition.minScrollExtent - _outerPosition.pixels;
//        } else {
//          assert(velocity < 0.0);
//          // growing
//          extra = _outerPosition.pixels -
//              (_outerPosition.maxScrollExtent - _outerPosition.minScrollExtent);
//        }
//        assert(extra <= 0.0);
//        minRange = _outerPosition.minScrollExtent;
//        maxRange = _outerPosition.maxScrollExtent + extra;
//        assert(minRange <= maxRange);
//        correctionOffset = 0.0;
//      }
//    }
//    return _PrimaryScrollMetrics(
//      minScrollExtent: _outerPosition.minScrollExtent,
//      maxScrollExtent: _outerPosition.maxScrollExtent +
//          innerPosition.maxScrollExtent -
//          innerPosition.minScrollExtent +
//          extra,
//      pixels: pixels,
//      viewportDimension: _outerPosition.viewportDimension,
//      axisDirection: _outerPosition.axisDirection,
//      minRange: minRange,
//      maxRange: maxRange,
//      correctionOffset: correctionOffset,
//    );
//  }

  double unnestOffset(double value, PrimaryPagePosition source) {
    PrimaryPagePosition _outerPosition = isOuterControllerEnable()
        ? (getOuterController().position as PrimaryPagePosition)
        : null;

    if (source == _outerPosition)
      return value.clamp(
        _outerPosition.minScrollExtent,
        _outerPosition.maxScrollExtent,
      ) as double;
    if (value < source.minScrollExtent)
      return value - source.minScrollExtent + _outerPosition.minScrollExtent;
    return value - source.minScrollExtent + _outerPosition.maxScrollExtent;
  }

  double nestOffset(double value, PrimaryPagePosition target) {
    PrimaryPagePosition _outerPosition = isOuterControllerEnable()
        ? (getOuterController().position as PrimaryPagePosition)
        : null;

    if (target == _outerPosition)
      return value.clamp(
        _outerPosition.minScrollExtent,
        _outerPosition.maxScrollExtent,
      ) as double;
    if (value < _outerPosition.minScrollExtent)
      return value - _outerPosition.minScrollExtent + target.minScrollExtent;
    if (value > _outerPosition.maxScrollExtent)
      return value - _outerPosition.maxScrollExtent + target.minScrollExtent;
    return value;
  }
}

const PageScrollPhysics _kPagePhysics = PageScrollPhysics();

class PrimaryPageView extends StatefulWidget {
  /// Creates a scrollable list that works page by page from an explicit [List]
  /// of widgets.
  ///
  /// This constructor is appropriate for page views with a small number of
  /// children because constructing the [List] requires doing work for every
  /// child that could possibly be displayed in the page view, instead of just
  /// those children that are actually visible.
  PrimaryPageView({
    Key key,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    PrimaryPageController controller,
    this.physics,
    this.pageSnapping = true,
    this.onPageChanged,
    this.primary = false,
    List<Widget> children = const <Widget>[],
    this.dragStartBehavior = DragStartBehavior.start,
  })  : childrenDelegate = SliverChildListDelegate(children),
        super(key: key) {
    if (controller == null) {
      this.controller = PrimaryPageController();
    } else {
      this.controller = controller;
    }
  }

  /// Creates a scrollable list that works page by page using widgets that are
  /// created on demand.
  ///delta
  /// This constructor is appropriate for page views with a large (or infinite)
  /// number of children because the builder is called only for those children
  /// that are actually visible.
  ///
  /// Providing a non-null [itemCount] lets the [PrimaryPageView] compute the maximum
  /// scroll extent.
  ///
  /// [itemBuilder] will be called only with indices greater than or equal to
  /// zero and less than [itemCount].
  ///
  /// [PrimaryPageView.builder] by default does not support child reordering. If
  /// you are planning to change child order at a later time, consider using
  /// [PrimaryPageView] or [PrimaryPageView.custom].
  PrimaryPageView.builder({
    Key key,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    PrimaryPageController controller,
    this.physics,
    this.pageSnapping = true,
    this.onPageChanged,
    @required IndexedWidgetBuilder itemBuilder,
    int itemCount,
    this.primary = false,
    this.dragStartBehavior = DragStartBehavior.start,
  })  : childrenDelegate =
            SliverChildBuilderDelegate(itemBuilder, childCount: itemCount),
        super(key: key) {
    if (controller == null) {
      this.controller = PrimaryPageController();
    } else {
      this.controller = controller;
    }
  }

  PrimaryPageView.custom({
    Key key,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    PrimaryPageController controller,
    this.physics,
    this.pageSnapping = true,
    this.onPageChanged,
    @required this.childrenDelegate,
    this.primary = false,
    this.dragStartBehavior = DragStartBehavior.start,
  })  : assert(childrenDelegate != null),
        super(key: key) {
    if (controller == null) {
      this.controller = PrimaryPageController();
    } else {
      this.controller = controller;
    }
  }

  /// The axis along which the page view scrolls.
  ///
  /// Defaults to [Axis.horizontal].
  final Axis scrollDirection;

  /// Whether the page view scrolls in the reading direction.
  ///
  /// For example, if the reading direction is left-to-right and
  /// [scrollDirection] is [Axis.horizontal], then the page view scrolls from
  /// left to right when [reverse] is false and from right to left when
  /// [reverse] is true.
  ///
  /// Similarly, if [scrollDirection] is [Axis.vertical], then the page view
  /// scrolls from top to bottom when [reverse] is false and from bottom to top
  /// when [reverse] is true.
  ///
  /// Defaults to false.
  final bool reverse;

  /// An object that can be used to control the position to which this page
  /// view is scrolled.
  PrimaryPageController controller;

  /// How the page view should respond to user input.
  ///
  /// For example, determines how the page view continues to animate after the
  /// user stops dragging the page view.
  ///
  /// The physics are modified to snap to page boundaries using
  /// [PageScrollPhysics] prior to being used.
  ///
  /// Defaults to matching platform conventions.
  final ScrollPhysics physics;

  /// Set to false to disable page snapping, useful for custom scroll behavior.
  final bool pageSnapping;

  /// Called whenever the page in the center of the viewport changes.
  final ValueChanged<int> onPageChanged;

  /// A delegate that provides the children for the [PrimaryPageView].
  ///
  /// The [PrimaryPageView.custom] constructor lets you specify this delegate
  /// explicitly. The [PrimaryPageView] and [PrimaryPageView.builder] constructors create a
  /// [childrenDelegate] that wraps the given [List] and [IndexedWidgetBuilder],
  /// respectively.
  final SliverChildDelegate childrenDelegate;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  final bool primary;

  @override
  _PageViewState createState() => _PageViewState();
}

class _PageViewState extends State<PrimaryPageView> {
  int _lastReportedPage = 0;

  @override
  void initState() {
    super.initState();
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

    final ScrollController scrollController = widget.primary
        ? PrimaryScrollController.of(context)
        : widget.controller;

    if (widget.primary && scrollController is PrimaryPageController) {
      scrollController.initialPage = _lastReportedPage;
      PrimaryPageCoordinator(widget.controller, scrollController);
    }

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
        /// magic code,魔法代码勿动……这个key很重要
        /// 如果PrimaryPageView下面还有多个同级PrimaryPageView，
        /// 那么竟然会导致父PrimaryPageView识别为子PrimaryPageView
        /// 进而在didUpdateWidget中解绑父PrimaryPageView中controller绑定的position
        /// 并将其赋予给子PrimaryPageView的controller
        /// 这样就导致父PrimaryPageView就这么神奇的丢失了自己的position……
        /// 进而无法触发任何父PrimaryPageView的滑动事件
        /// 不知道是我的问题还是flutter的问题
        /// 不过既然知道原因了
        /// 用key打个补丁，加上个身份证就好了……有空研究下这个神奇的问题
        // key: Key(widget.controller.toString()),
        dragStartBehavior: widget.dragStartBehavior,
        axisDirection: axisDirection,
        controller: widget.controller,
        physics: physics,
        viewportBuilder: (BuildContext context, ViewportOffset position) {
          return Viewport(
            cacheExtent: 0.0,
            axisDirection: axisDirection,
            offset: position,
            slivers: <Widget>[
              PrimaryScrollController(
                  controller: widget.controller,
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description
        .add(EnumProperty<Axis>('scrollDirection', widget.scrollDirection));
    description.add(
        FlagProperty('reverse', value: widget.reverse, ifTrue: 'reversed'));
    description.add(DiagnosticsProperty<PrimaryPageController>(
        'controller', widget.controller,
        showName: false));
    description.add(DiagnosticsProperty<ScrollPhysics>(
        'physics', widget.physics,
        showName: false));
    description.add(FlagProperty('pageSnapping',
        value: widget.pageSnapping, ifFalse: 'snapping disabled'));
  }
}
