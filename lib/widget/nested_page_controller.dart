import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show precisionErrorTolerance;
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';

class NestedPageController extends ScrollController {
  NestedPageController(
      {this.initialPage = 0,
        this.keepPage = true,
        this.viewportFraction = 1.0,
        this.coordinator,
        this.isInner})
      : assert(initialPage != null),
        assert(keepPage != null),
        assert(viewportFraction != null),
        assert(viewportFraction > 0.0);

  int initialPage;

  final bool keepPage;
  final bool isInner;

  final double viewportFraction;

  NestedPageCoordinator coordinator;

  double get page {
    assert(
    positions.isNotEmpty,
    'NestedPageController.page cannot be accessed before a NestedPrimaryPageView is built with it.',
    );
    assert(
    positions.length == 1,
    'The page property cannot be read when multiple PageViews are attached to '
        'the same NestedPageController.',
    );
    final NestedPagePosition position = this.position;
    return position.page;
  }

  Future<void> animateToPage(
      int page, {
        @required Duration duration,
        @required Curve curve,
      }) {
    final NestedPagePosition position = this.position;
    return position.animateTo(
      position.getPixelsFromPage(page.toDouble()),
      duration: duration,
      curve: curve,
    );
  }

  void jumpToPage(int page) {
    final NestedPagePosition position = this.position;
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
    return NestedPagePosition(
        physics: physics,
        context: context,
        initialPage: initialPage,
        keepPage: keepPage,
        viewportFraction: viewportFraction,
        coordinator: coordinator,
        oldPosition: oldPosition,
        isInner: isInner);
  }

  @override
  void attach(ScrollPosition position) {
    super.attach(position);
    final NestedPagePosition pagePosition = position;
    pagePosition.viewportFraction = viewportFraction;
  }
}

class NestedPagePosition extends ScrollPosition
    implements PageMetrics, ScrollActivityDelegate {
  NestedPagePosition(
      {ScrollPhysics physics,
        ScrollContext context,
        this.initialPage = 0,
        bool keepPage = true,
        double viewportFraction = 1.0,
        double initialPixels = 0.0,
        ScrollPosition oldPosition,
        this.coordinator,
        this.isInner})
      : assert(initialPage != null),
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
  final NestedPageCoordinator coordinator;
  final bool isInner;
  double _pageToUseOnStartup;

  @override
  double get viewportFraction => _viewportFraction;
  double _viewportFraction;

  set viewportFraction(double value) {
    if (_viewportFraction == value) return;
    final double oldPage = page;
    _viewportFraction = value;
    if (oldPage != null) forcePixels(getPixelsFromPage(oldPage));
  }

  // The amount of offset that will be added to [minScrollExtent] and subtracted
  // from [maxScrollExtent], such that every page will properly snap to the center
  // of the viewport when viewportFraction is greater than 1.
  //
  // The value is 0 if viewportFraction is less than or equal to 1, larger than 0
  // otherwise.
  double get _initialPageOffset =>
      math.max(0, viewportDimension * (viewportFraction - 1) / 2);

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
    final NestedPagePosition typedOther = other;
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

//  @override
//  void beginActivity(ScrollActivity newActivity) {
//    _heldPreviousVelocity = 0.0;
//    if (newActivity == null) return;
//    assert(newActivity.delegate == this);
//    super.beginActivity(newActivity);
//    _currentDrag?.dispose();
//    _currentDrag = null;
//    if (!activity.isScrolling) updateUserScrollDirection(ScrollDirection.idle);
//  }

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
    return coordinator.hold(holdCancelCallback);
//    final double previousVelocity = activity.velocity;
//    final HoldScrollActivity holdActivity = HoldScrollActivity(
//      delegate: this,
//      onHoldCanceled: holdCancelCallback,
//    );
//    beginActivity(holdActivity);
//    _heldPreviousVelocity = previousVelocity;
//    return holdActivity;
  }

  ScrollDragController _currentDrag;

  @override
  Drag drag(DragStartDetails details, VoidCallback dragCancelCallback) {
    return coordinator.drag(details, dragCancelCallback, isInner);
//    final ScrollDragController drag = ScrollDragController(
//      delegate: this,
//      details: details,
//      onDragCanceled: dragCancelCallback,
//      carriedVelocity: physics.carriedMomentum(_heldPreviousVelocity),
//      motionStartDistanceThreshold: physics.dragStartDistanceMotionThreshold,
//    );
//    beginActivity(DragScrollActivity(this, drag));
//    assert(_currentDrag == null);
//    _currentDrag = drag;
//    return drag;
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
}

class NestedPageCoordinator
    implements ScrollActivityDelegate, ScrollHoldController {
  NestedPageController _outerController;
  NestedPageController _innerController;

  NestedPageController parentController;
  NestedPageController childController;

  ScrollDragController _currentDrag;

  bool isOperateBody = false;

  NestedPageCoordinator(this.parentController,this.childController) {
    _outerController =parentController??
        NestedPageController(initialPage: parentController.initialPage, coordinator: this, isInner: false);
    _outerController.coordinator=this;
    _innerController =
        NestedPageController(initialPage: childController.initialPage, coordinator: this, isInner: true);
  }

  NestedPageController getOuterController() {
    return _outerController;
  }

  NestedPageController getInnerController() {
    return _innerController;
  }

//  void setOperateBody(bool isOperateBody) {
//    if (this.isOperateBody ^ isOperateBody) {
//      if (isOperateBody) {
//        this.isOperateBody = true;
//        (_outerController.position as NestedPagePosition).goIdle();
//      } else {
//        this.isOperateBody = false;
//        (_innerController.position as NestedPagePosition).goIdle();
//      }
//    }
//  }

  @override
  void applyUserOffset(double delta) {
    updateUserScrollDirection(
        delta > 0.0 ? ScrollDirection.forward : ScrollDirection.reverse);

    NestedPagePosition innerPosition =
    (getInnerController().position as NestedPagePosition);
    NestedPagePosition outPosition = (getOuterController().position as NestedPagePosition);

//    print("applyUserOffset:"+delta.toString());

    if (isOperateBody) {
      if ((outPosition.pixels==outPosition.minScrollExtent||outPosition.pixels==outPosition.maxScrollExtent)&&(delta<0?innerPosition.pixels  < innerPosition.maxScrollExtent:innerPosition.pixels  > innerPosition.minScrollExtent)) {
        innerPosition.applyUserOffset(delta);
//        outPosition.goIdle();
      } else {

        outPosition.applyUserOffset(delta);
      }
    } else {


      outPosition.applyUserOffset(delta);
    }
  }

  @override
  AxisDirection get axisDirection => _outerController.position.axisDirection;

  @override
  void cancel() {
    goBallistic(0.0);
  }

  @override
  void goBallistic(double velocity) {
    NestedPagePosition innerPosition =
    (getInnerController().position as NestedPagePosition);
    NestedPagePosition outPosition = (getOuterController().position as NestedPagePosition);

    if (isOperateBody) {

      if(outPosition.pixels>outPosition.minScrollExtent&&outPosition.pixels<outPosition.maxScrollExtent){
        outPosition.goBallistic(velocity);
        innerPosition.goIdle();

        _currentDrag?.dispose();
        _currentDrag = null;

        return;
      }

      if(velocity>0){
        if(innerPosition.pixels<innerPosition.maxScrollExtent&&innerPosition.pixels>innerPosition.minScrollExtent){
          innerPosition.goBallistic(velocity);
          outPosition.goIdle();
        }else{
          outPosition.goBallistic(velocity);
          innerPosition.goIdle();
        }
      }else{
        if(innerPosition.pixels<innerPosition.maxScrollExtent){
          innerPosition.goBallistic(velocity);
          outPosition.goIdle();
        }else{
          outPosition.goBallistic(velocity);
          innerPosition.goIdle();
        }
      }

    } else {
      outPosition.goBallistic(velocity);
      innerPosition.goIdle();
    }

    _currentDrag?.dispose();
    _currentDrag = null;
  }

  @override
  void goIdle() {
    beginActivity(IdleScrollActivity(this), IdleScrollActivity(this));
  }

  @override
  double setPixels(double pixels) {
    return 0.0;
  }

  ScrollHoldController hold(VoidCallback holdCancelCallback) {
    beginActivity(
        HoldScrollActivity(delegate: this, onHoldCanceled: holdCancelCallback),
        HoldScrollActivity(delegate: this, onHoldCanceled: holdCancelCallback));

    return this;
  }

  Drag drag(
      DragStartDetails details, VoidCallback dragCancelCallback, bool isInner) {

    isOperateBody = isInner;

    final ScrollDragController drag = ScrollDragController(
      delegate: this,
      details: details,
      onDragCanceled: dragCancelCallback,
    );

    beginActivity(
        DragScrollActivity(this, drag), DragScrollActivity(this, drag));

    assert(_currentDrag == null);
    _currentDrag = drag;
    return drag;
  }

  void beginActivity(
      ScrollActivity newOuterActivity, ScrollActivity newInnerActivity) {
    getInnerController().position.beginActivity(newInnerActivity);
    getOuterController().position.beginActivity(newOuterActivity);

    _currentDrag?.dispose();
    _currentDrag = null;

    if ((newOuterActivity == null || !newOuterActivity.isScrolling) &&
        (newInnerActivity == null || !newInnerActivity.isScrolling)) {
      updateUserScrollDirection(ScrollDirection.idle);
    }
  }

  ScrollDirection get userScrollDirection => _userScrollDirection;
  ScrollDirection _userScrollDirection = ScrollDirection.idle;

  void updateUserScrollDirection(ScrollDirection value) {
    assert(value != null);
    if (userScrollDirection == value) return;
    _userScrollDirection = value;
    getOuterController().position.didUpdateScrollDirection(value);
    getInnerController().position.didUpdateScrollDirection(value);
  }
}
