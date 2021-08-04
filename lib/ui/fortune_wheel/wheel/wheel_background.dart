import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_practice_ui/model/luck.dart';
import 'package:rxdart/rxdart.dart';

class LightStatus {
  bool isOn;
  double angle;

  LightStatus({this.isOn, this.angle});
}

class WheelBackdrop extends StatefulWidget {
  final double radius;
  final int totalDividers;
  final List<Luck> listItem;

  WheelBackdrop({
    this.radius = 150.0,
    this.totalDividers = 8,
    this.listItem,
  });

  @override
  _WheelBackdropState createState() => _WheelBackdropState();
}

class _WheelBackdropState extends State<WheelBackdrop> {
  List<LightStatus> lightStatus;
  BehaviorSubject<bool> lightController = BehaviorSubject<bool>();
  bool isBlink = true;
  Timer t;
  Widget lightOn;
  Widget lightOff;

  double get radius => widget.radius * 0.86;

  List<Luck> get _items => widget.listItem ?? [];

  double subtractAngle(double angle, double subtractBy) {
    double result = angle - subtractBy;
    if (result < 0) result = 360 + result;
    return result;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    lightController?.close();
    t?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        for (var luck in _items) ...[_buildCard(luck)],
        Stack(
          children: getListCard(context),
        ),
      ],
    );
  }

  /// Build list item widget
  List<Widget> getListCard(BuildContext context) {
    final List<Widget> widgets = [];
    final dividers = _items.length;

    /// height = r * rad
    final height = radius * (2 * pi / dividers);
    for (int i = 0; i < dividers; i++) {
      final cardWidget = Transform.rotate(
        angle: i * (2 * pi / dividers) - pi / 2,
        child: Container(
          alignment: Alignment.center,
          width: radius * 2,
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                width: radius * 0.45,
                height: radius * 0.45,
                alignment: Alignment.center,
                child: Container(
                  child: _buildImage(_items[i]),
                ),
              ),
              Container(
                width: radius * 0.2,
              )
            ],
          ),
        ),
      );
      widgets.add(cardWidget);
    }
    return widgets;
  }

  /// Build each item image
  _buildImage(Luck luck) {
    return Transform.rotate(
      angle: 0.25 * 2 * pi,
      child: Container(
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints:
              BoxConstraints.expand(height: double.infinity / 3, width: 44),
          child: Image.asset(luck.asset),
        ),
      ),
    );
  }

  /// Calculate angle rototate of each item
  double _rotote(int index) => (index / _items.length) * 2 * pi;

  /// Build backgound for each item
  _buildCard(Luck luck) {
    var _rotate = _rotote(_items.indexOf(luck));
    var _angle = 2 * pi / _items.length;
    return Transform.rotate(
      angle: _rotate,
      child: ClipPath(
        clipper: _LuckPath(_angle),
        child: Container(
          height: radius * 2,
          width: radius * 2,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [luck.color, luck.color.withOpacity(0)])),
        ),
      ),
    );
  }
}

class _LuckPath extends CustomClipper<Path> {
  final double angle;

  _LuckPath(this.angle);

  @override
  Path getClip(Size size) {
    Path _path = Path();
    Offset _center = size.center(Offset.zero);
    Rect _rect = Rect.fromCircle(center: _center, radius: size.width / 2);
    _path.moveTo(_center.dx, _center.dy);
    _path.arcTo(_rect, -pi / 2 - angle / 2, angle, false);
    _path.close();
    return _path;
  }

  @override
  bool shouldReclip(_LuckPath oldClipper) {
    return angle != oldClipper.angle;
  }
}
