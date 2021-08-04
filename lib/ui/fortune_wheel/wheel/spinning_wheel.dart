import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'utils.dart';

class SpinningController {
  /// initial rotation angle from 0.0 to 2*pi
  /// default is 0.0
  double initialSpinAngle;

  /// number of equal divisions in the wheel

  // divider which is selected (positive y-coord)
  int currentDivider;

  /// has to be higher than 0.0 (no resistance) and lower or equal to 1.0
  /// default is 0.5
  final double spinResistance;

  NonUniformCircularMotion _motion;

//  NonUniformCircularMotion get motion => _motion;
  final _wheelNotifier = StreamController<_SpinningModel>.broadcast();
  final _speedNotifier = StreamController<double>.broadcast();
  final _shouldPlaySound = StreamController<bool>.broadcast();
  final _angleNotifier = StreamController<double>.broadcast();
  final _runSlowThenStopNotifier = StreamController<double>.broadcast();
  final _resetNotifier = StreamController<bool>.broadcast();

  Stream get speedStream => _speedNotifier.stream;

  Stream get angleStream => _angleNotifier.stream;

  Stream get shouldStartOrStop => _wheelNotifier.stream;

  Stream get runSlowThenStopStream => _runSlowThenStopNotifier.stream;

  Stream get resetStream => _resetNotifier.stream;

  SpinningController({
    this.initialSpinAngle = 0.0,
    this.spinResistance = 0.5,
  })  : assert(spinResistance > 0.0 && spinResistance <= 1.0),
        assert(initialSpinAngle >= 0.0 && initialSpinAngle <= (2 * pi)) {
    _motion = NonUniformCircularMotion(resistance: spinResistance);
  }

  void dispose() {
    _wheelNotifier.close();
    _speedNotifier.close();
    _shouldPlaySound.close();
    _resetNotifier.close();
    _angleNotifier.close();
    _runSlowThenStopNotifier.close();
  }

  void runSlowlyThenStopAtResultAngle({int destinationIndex, int dividers}) {
    var numberOfIndexesToRotate = dividers - destinationIndex;
    double destinationAngle = (2 * pi * numberOfIndexesToRotate) / dividers;
    _runSlowThenStopNotifier.sink.add(destinationAngle);
  }

  void resetWheel() {
    _resetNotifier.sink.add(true);
  }
}

class _SpinningModel {
  double velocity;
  bool isSteady;

  _SpinningModel({this.velocity = 0.0, this.isSteady = false});
}

class SpinningWheel extends StatefulWidget {
  /// width used by the container with the image
  final double radius;

  /// image that will be used as wheel
  final Widget backdrop;

  /// controller to get it's attribute
  final SpinningController controller;

// number of equal divisions in the wheel
// final int dividers;

  /// initial rotation angle from 0.0 to 2*pi
  /// default is 0.0
// final double initialSpinAngle;

  /// has to be higher than 0.0 (no resistance) and lower or equal to 1.0
  /// default is 0.5
// final double spinResistance;

  /// if true, the user can interact with the wheel while it spins
  /// default is true
  final bool canInteractWhileSpinning;

  /// will be rendered on top of the wheel and can be used to show a selector
  final Widget cursor;

  /// x dimension for the secondaty image, if provided
  /// if provided, has to be smaller than widget height
  final double cursorHeight;

  /// y dimension for the secondary image, if provided
  /// if provided, has to be smaller than widget width
  final double cursorWidth;

  /// can be used to fine tune the position for the secondary image, otherwise it will be centered
  final double cursorTop;

  /// can be used to fine tune the position for the secondary image, otherwise it will be centered
  final double cursorLeft;

  final Widget center;
  final double centerWidth;
  final double centerHeight;

  /// callback function to be executed when the wheel selection changes
  final Function onUpdate;

  /// callback function to be executed when the animation stops
  final Function onEnd;

  /// callback function when the velocity is large enough to roll
  final Function onStartToRoll;

  /// callback function when roll finish
  final Function onResult;

  ///absorbing = true => disable wheel
  final bool absorbing;

  /// callback function when absorbing
  final Function onAbsorbing;
  final int dividers;

  /// Stream<double> used to trigger an animation
  /// if triggered in an animation it will stop it, unless canInteractWhileSpinning is false
  /// the parameter is a double for pixelsPerSecond in axis Y, which defaults to 8000.0 as a medium-high velocity
//  final Stream shouldStartOrStop;

  SpinningWheel(
      {@required this.controller,
      @required this.backdrop,
      @required this.radius,
      this.canInteractWhileSpinning = false,
      this.cursor,
      this.center,
      this.cursorHeight,
      this.cursorWidth,
      this.cursorTop,
      this.cursorLeft,
      this.onUpdate,
      this.onEnd,
      this.onStartToRoll,
      this.centerWidth,
      this.centerHeight,
      this.onResult,
      this.absorbing = false,
      this.onAbsorbing,
      this.dividers})
      : assert(radius > 0.0);

  @override
  _SpinningWheelState createState() => _SpinningWheelState();
}

class _SpinningWheelState extends State<SpinningWheel>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;
  AnimationController _animationTouchController;

  // giaToc = -1 to make wheel scroll slow when start
  double giaToc = -1;
  bool isStartToSlower = false;

  // we need to store if has the widget behaves differently depending on the status
  // AnimationStatus _animationStatus = AnimationStatus.dismissed;

  // it helps calculating the velocity based on position and pixels per second velocity and angle
  SpinVelocity _spinVelocity;
  NonUniformCircularMotion _motion;

  // keeps the last local position on pan update
  // we need it onPanEnd to calculate in which cuadrant the user was when last dragged
  Offset _localPositionOnPanUpdate;

  // duration of the animation based on the initial velocity
  double _totalDuration = 0;

  // initial velocity for the wheel when the user spins the wheel
  double _initialCircularVelocity = 0;

  // Angle for each divider: 2 * pi / numberOfDividers
  double _dividerAngle;

  // current (circular) distance (angle) covered during the animation
  double _currentDistance = 0;

//  // initial spin angle when the wheels starts the animation
//  double widget.controller.initialSpinAngle;

  // Spin angle when animation is stopped
  double _currentSpinAngle;
  double destionationAngle;
  double currentVelocity;
  bool isStartSpinningSteady = false;
  double distanceBeforeSteady;
  double timeBeforeSteady;

  // will be used to do transformations between global and local
  RenderBox _renderBox;

  // subscription to the stream used to trigger an animation
  StreamSubscription _subscription;

  double currentTimeSlow = 0;
  double distanceToStop = 0;
  bool isStartToRunSlowerFirstTime = false;
  double angleToStop = 0;
  int numberCirclesBeforeStop = 2;
  double velocityStartToSteady = 4;
  double lastDistance = 0;
  int millisecondsSinceEpoch = 0;
  double valueBeforeGoToBackground = 0;
  double lastAngle = 0;
  bool canStart = true;

  @override
  void initState() {
    super.initState();

    _spinVelocity =
        SpinVelocity(width: widget.radius * 2, height: widget.radius * 2);
    _motion = widget.controller._motion;

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 0),
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.linear));

    _dividerAngle = _motion.anglePerDivision(widget.dividers);

    _animation.addStatusListener((status) {
      canStart = false;
      if (status == AnimationStatus.completed) {
        _stopAnimation();
      } else if (status == AnimationStatus.dismissed) {
        canStart = true;
      }
    });

    _animation.addListener(() {
      _updateAnimationValues();
    });

    widget.controller.runSlowThenStopStream.listen((angle) {
      destionationAngle = angle;
    });

    if (widget.controller.resetStream != null) {
      _subscription = widget.controller.resetStream.listen(forceReset);
    }
  }

  void forceReset(dynamic data) {
    setState(() {
      _currentSpinAngle = 0;
      _currentDistance = 0;
    });
  }

  // @override
  // void onPause() {
  //   super.onPause();
  //   if (_animationController.isAnimating) {
  //     valueBeforeGoToBackground = _animationController.value;
  //     _animationController.reset();
  //   }
  // }
  //
  // @override
  // void onResume() {
  //   super.onResume();
  //   //print('[TUNG] ===> SpinningWheel onResume');
  //   if (valueBeforeGoToBackground != 0) {
  //     _animationController.forward(from: valueBeforeGoToBackground);
  //   }
  // }

  double get radius => widget.radius ?? 150.0;

  double get cursorHeight => widget.cursorHeight ?? radius / 3;

  double get cursorWidth => widget.cursorWidth ?? radius * 0.7;

  double get cursorTop => widget.cursorTop ?? 0.105 * radius;

  double get cursorLeft => widget.cursorLeft ?? radius - cursorWidth / 2;

  double get centerHeight => widget.centerHeight ?? radius / 2;

  double get centerWidth => widget.centerWidth ?? radius / 2;

  Widget buildCenterButton() {
    return InkWell(
      onTap: () {
        if (canStart || _userCanInteract) {
          _startAnimation(customVelocity: 4000);
        }
      },
      child: widget.center ?? Container(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          height: widget.radius * 2,
          width: widget.radius * 2,
          child: AnimatedBuilder(
              animation: _animation,
              child: Container(child: widget.backdrop),
              builder: (context, child) {
                if (widget.onUpdate != null) {
                  widget.onUpdate(widget.controller.currentDivider);
                }
                return Transform.rotate(
                  angle: widget.controller.initialSpinAngle + _currentDistance,
                  child: child,
                );
              }),
        ),
        widget.center != null ? buildCenterButton() : Container(),
        widget.cursor != null
            ? Positioned(
                top: cursorTop * 0.7,
                left: cursorLeft,
                child: Container(
                  alignment: Alignment.topCenter,
                  height: cursorHeight,
                  width: cursorWidth,
                  child: widget.cursor,
                ))
            : Container(),
      ],
    );
  }

  // user can interact only if widget allows or wheel is not spinning
  bool get _userCanInteract =>
      (!_animationController.isAnimating || widget.canInteractWhileSpinning) &&
      !widget.absorbing;

  // this is called just before the animation starts
  void _updateAnimationValues() {
    if (_animationController.isAnimating) {
      // calculate total distance covered
      double currentTime = _totalDuration * _animation.value;
      if (isStartToSlower) {
        /// Calculate distance then speed start to slower when receive result (may be from API) to end animation
        if (isStartToRunSlowerFirstTime) {
          currentTimeSlow = currentTime;
          distanceToStop = _currentDistance.abs() + angleToStop;
          isStartToRunSlowerFirstTime = false;
        }
        if (distanceToStop.abs() - _currentDistance.abs() < 0.01) {
          _stopAnimation(force: true);
          widget.onResult();
        }

        // s = (v0 * t) + (1/2 * a * t^2)
        // _currentDistance = distanceBeforeSteady + s
        _currentDistance = distanceBeforeSteady +
            currentVelocity * (currentTime - timeBeforeSteady) +
            (0.5 * giaToc * pow(currentTime - currentTimeSlow, 2));
      } else {
        /// Calculate distance when start rorate & waiting result (may be from API) - constant speed
        if (isStartSpinningSteady == false) {
          // s = (v0 * t) + (1/2 * a * t^2)
          _currentDistance = (_initialCircularVelocity * currentTime) +
              (0.5 * giaToc * pow(currentTime, 2));
        } else {
          // s = (v0 * t) + (1/2 * a * t^2); (a = 0) => s = v0 * t
          // _currentDistance = distanceBeforeSteady + s
          _currentDistance = distanceBeforeSteady +
              currentVelocity * (currentTime - timeBeforeSteady);
        }

        double v = _initialCircularVelocity + giaToc * currentTime;
        if (v <= velocityStartToSteady && isStartSpinningSteady == false) {
          distanceBeforeSteady = _currentDistance;
          timeBeforeSteady = currentTime;
          currentVelocity = v;
          isStartSpinningSteady = true;
        }
      }
    }
    // calculate current divider selected
    var modulo =
        _motion.modulo(_currentDistance + widget.controller.initialSpinAngle);
    var divider =
        widget.dividers - ((modulo + pi / widget.dividers) ~/ _dividerAngle);
    widget.controller.currentDivider = divider < widget.dividers ? divider : 0;
    _currentSpinAngle = modulo;

    if (destionationAngle != null &&
        isStartToSlower == false &&
        isStartSpinningSteady != false) {
      _startSlowThenStopAnimation(destionationAngle);
    }
    if (_animationController.isCompleted) {
      resetSpinAngle();
    }
  }

  void resetSpinAngle() {
    isStartToSlower = false;
    destionationAngle = null;
    valueBeforeGoToBackground = 0;
  }

  void _stopAnimation({bool force = false}) {
    if (!_userCanInteract && !force) return;

    isStartSpinningSteady = false;
    _animationController.reset();
    _animationController.stop();
    resetSpinAngle();

    if (widget.onEnd != null) {
      widget.onEnd(widget.controller.currentDivider);
    }
  }

  void _startAnimation({double customVelocity}) {
    // [customVelocity] First velocity customed
    var velocity = customVelocity;

    if (widget.onStartToRoll != null) {
      widget.onStartToRoll();
    }

    _initialCircularVelocity = pixelsPerSecondToRadians(velocity.abs());

    //Always rotate 10 rounds then steady at velocity [velocityStartToSteady]
    // v^2 - v0^2 = 2as => a = v^2 - v0^2 / 2s (s= 10 * 2* pi)
    giaToc =
        (pow(velocityStartToSteady, 2) - pow(_initialCircularVelocity, 2)) /
            (2 * 20 * pi);

    _totalDuration = 30.0;

    _animationController.duration =
        Duration(milliseconds: (_totalDuration * 1000).round());

    _animationController.reset();
    _animationController.forward();
  }

  void _startSlowThenStopAnimation(double destinationAngle) {
    int randomAngleRange = 180 ~/ widget.dividers; // calculate by degree
    double randomAngle =
        (Random().nextInt(2 * randomAngleRange) - randomAngleRange).toDouble();
    if (randomAngle < 0)
      randomAngle += 3;
    else
      randomAngle -= 3;

    // [angleToRotate] Angle need to rotate to end scroll proccess
    double angleToRotate;
    angleToRotate = 2 * pi * numberCirclesBeforeStop +
        destinationAngle -
        _currentSpinAngle +
        randomAngle * pi / 180; //convert degree to radiant

    // v^2 - v0^2 = 2as; v = 0 (when stop rotate, v = 0) => a = -v0^2 / 2s
    giaToc = (-pow(currentVelocity, 2) / (2 * angleToRotate));

    angleToStop = angleToRotate;
    isStartToSlower = true;
    isStartToRunSlowerFirstTime = true;
    _localPositionOnPanUpdate = null;
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _animationTouchController?.dispose();
    _subscription?.cancel();
    super.dispose();
  }
}
