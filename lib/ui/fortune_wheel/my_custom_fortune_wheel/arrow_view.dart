import 'dart:math';

import 'package:flutter/material.dart';

class ArrowView extends StatelessWidget {
  final double angle;
  final List<Color> lstArrowColor;

  ArrowView({this.angle, this.lstArrowColor}) {
    ///
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Transform.rotate(
        angle: angle ?? pi,
        child: Padding(
          padding: EdgeInsets.only(top: 80),
          child: ClipPath(
            clipper: _ArrowClipper(),
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: lstArrowColor ?? [Colors.black12, Colors.black])),
              height: 40,
              width: 40,
            ),
          ),
        ),
      ),
    );
  }
}

class _ArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path _path = Path();
    Offset _center = size.center(Offset.zero);
    _path.lineTo(_center.dx, size.height);
    _path.lineTo(size.width, 0);
    _path.lineTo(_center.dx, _center.dy);
    _path.close();
    return _path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
