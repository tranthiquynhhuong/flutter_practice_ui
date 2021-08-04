import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_practice_ui/model/luck.dart';
import 'package:flutter_practice_ui/ui/fortune_wheel/my_custom_fortune_wheel/arrow_view.dart';
import '../wheel/spinning_wheel.dart';
import '../wheel/wheel_background.dart';

class WheelView extends StatefulWidget {
  @override
  _WheelViewState createState() => _WheelViewState();
}

class _WheelViewState extends State<WheelView> {
  final _spinningController =
      SpinningController(initialSpinAngle: 0, spinResistance: 0.125);

  List<Luck> lisItem = [
    Luck("bee", Colors.accents[0], 0, 0.0, 0.0),
    Luck("cat", Colors.accents[2], 1, 0.0, 0.0),
    Luck("chicken", Colors.accents[4], 2, 0.0, 0.0),
    Luck("fish", Colors.accents[6], 3, 0.0, 0.0),
    Luck("penguin", Colors.accents[8], 4, 0.0, 0.0),
    Luck("pig", Colors.accents[10], 5, 0.0, 0.0),
    Luck("snail", Colors.accents[12], 6, 0.0, 0.0),
    Luck("whale", Colors.accents[14], 7, 0.0, 0.0),
  ];

  @override
  Widget build(BuildContext context) {
    final diameter = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Wheel example by QuanNgo"),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              child: ArrowView(
                lstArrowColor: [Colors.red.withOpacity(0.2), Colors.red],
                angle: 2 * pi,
              ),
            ),
            SpinningWheel(
              dividers: 8,
              controller: _spinningController,
              backdrop: WheelBackdrop(
                listItem: lisItem,
                totalDividers: 8,
                radius: diameter / 2,
              ),
              radius: diameter / 2,
              canInteractWhileSpinning: false,
              onUpdate: (divider) {},
              onEnd: (divider) {},
              onStartToRoll: () {
                Future.delayed(Duration(seconds: 4), () {
                  _spinningController.runSlowlyThenStopAtResultAngle(
                      destinationIndex: 5, dividers: 8);
                });
              },
              onResult: () {},
              center: ClipOval(
                child: Container(
                    width: 70,
                    height: 70,
                    color: Colors.white,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "GO",
                        style: TextStyle(
                            fontSize: 22.0, fontWeight: FontWeight.bold),
                      ),
                    )),
              ),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
