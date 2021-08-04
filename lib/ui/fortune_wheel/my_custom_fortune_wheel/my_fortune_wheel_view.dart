import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_practice_ui/model/luck.dart';
import 'package:flutter_practice_ui/ui/fortune_wheel/my_custom_fortune_wheel/my_fortune_wheel_bloc.dart';
import 'board_view.dart';

class MyFortuneWheel extends StatefulWidget {
  @override
  _MyFortuneWheelState createState() => _MyFortuneWheelState();
}

class _MyFortuneWheelState extends State<MyFortuneWheel>
    with SingleTickerProviderStateMixin {
  double _angle = 0;
  double _current = 0;
  AnimationController _ctrl;
  Animation _ani;
  List<Luck> _items = [
    Luck("bee", Colors.accents[0], 0, 0.0, 0.0),
    Luck("cat", Colors.accents[2], 1, 0.0, 0.0),
    Luck("chicken", Colors.accents[4], 2, 0.0, 0.0),
    Luck("fish", Colors.accents[6], 3, 0.0, 0.0),
//    Luck("penguin", Colors.accents[8], 4, 0.0, 0.0),
//    Luck("pig", Colors.accents[10], 5, 0.0, 0.0),
//    Luck("snail", Colors.accents[12], 6, 0.0, 0.0),
//    Luck("whale", Colors.accents[14], 7, 0.0, 0.0),
  ];
  double eachItemRange;
  double firstPoint;
  Duration _duration;
  MyFortuneWheelBloc bloc = MyFortuneWheelBloc();

  /// Calculate start & end coordinate of each item in list items on circle
  void initPoint() {
    for (int i = 0; i < _items.length; i++) {
      if (i == 0) {
        _items[i].start = 0.0;
        _items[i].end = eachItemRange;
      } else {
        _items[i].start = _items[i - 1].end;
        _items[i].end = _items[i].start + eachItemRange;
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _duration = Duration(milliseconds: 1000);
    _ctrl = AnimationController(vsync: this, duration: _duration);
    _ani = CurvedAnimation(parent: _ctrl, curve: Curves.linear);
    eachItemRange = 1 / _items.length;
    firstPoint = eachItemRange / 2;
    initPoint();
    listenComplete();
  }

  bool canStart = true;

  void listenComplete() {
    _ctrl.addListener(() {
      if (_ctrl.isCompleted) {
        setState(() {
          canStart = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My custom circle fortune wheel"),
      ),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.white])),
        child: AnimatedBuilder(
            animation: _ani,
            builder: (context, child) {
              final _value = _ani.value;
              final _angle = _value * this._angle;
              return Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  BoardView(items: _items, current: _current, angle: _angle),
                  _buildGo(),
                  _buildResult(_value),
                ],
              );
            }),
      ),
    );
  }

  _buildGo() {
    return Material(
      color: Colors.white,
      shape: CircleBorder(),
      child: InkWell(
        customBorder: CircleBorder(),
        child: Container(
          alignment: Alignment.center,
          height: 72,
          width: 72,
          child: Text(
            canStart ? "Start" : "Wait",
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
          ),
        ),
        onTap: () {
          if (canStart) {
            _startAnimation();
            setState(() {
              canStart = false;
            });
          }
        },
      ),
    );
  }

  double previousCurrent;

  _startAnimation() {
    bloc.getLuck();

    /// previous current angle after rotate
    previousCurrent = _current;

    if (!_ctrl.isAnimating) {
      bloc.bsIsSuccess.listen((isSuccess) {
        if (isSuccess) {
          setState(() {
            _ctrl.duration = Duration(milliseconds: 2000);
            _ani =
                CurvedAnimation(parent: _ctrl, curve: Curves.linearToEaseOut);
          });

          var result = randomDouble(
              start: _items[bloc.bsLuckIndexReturn.value].start -
                  (eachItemRange / 2),
              end: _items[bloc.bsLuckIndexReturn.value].end -
                  (eachItemRange / 2));

          /// set angle return 0 before start rotate
          /// angle = 20(rotate index) - previousCurrent(previous current angle after rotate) + result(coordinate item want to finish in this point)
          _angle = 1 - previousCurrent + result;
          _ctrl.forward(from: 0.0).then((_) {
            _current = result;
            _ctrl.reset();
          });
        } else {
          /// if not receive result from server -> continue rotate circle with linear curve animation
          setState(() {
            _ctrl.duration = Duration(milliseconds: 200);
            _ani = CurvedAnimation(parent: _ctrl, curve: Curves.linear);
          });
          _angle = 1;
          _ctrl.forward(from: 0.0).then((_) {
            _current = _current;
            _ctrl.reset();
          });
          _ctrl.repeat();
        }
      });
    }
  }

  double randomDouble({double start, double end}) {
    var _random = Random();
    double random = _random.nextDouble();
    double result = start + (random * (end - start));
    return result;
  }

  int _calIndex(value) {
    var _base = (2 * pi / _items.length / 2) / (2 * pi);
    return (((_base + value) % 1) * _items.length).floor();
  }

  _buildResult(_value) {
    var _index = _calIndex(_value * _angle + _current);
    String _asset = _items[_index].asset;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Image.asset(_asset, height: 80, width: 80),
      ),
    );
  }
}
