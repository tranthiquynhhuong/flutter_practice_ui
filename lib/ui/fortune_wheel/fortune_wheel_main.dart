import 'package:flutter/material.dart';
import 'package:flutter_practice_ui/ui/fortune_wheel/circle_fortune_wheel/circle_fortune_wheel_view.dart';
import 'package:flutter_practice_ui/ui/fortune_wheel/my_custom_fortune_wheel/my_fortune_wheel_view.dart';
import 'package:flutter_practice_ui/ui/fortune_wheel/wheel/wheel_view.dart';

class DrawFortuneWheelMain extends StatefulWidget {
  @override
  _DrawFortuneWheelMainState createState() => _DrawFortuneWheelMainState();
}

class _DrawFortuneWheelMainState extends State<DrawFortuneWheelMain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fortune wheel main"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CircleFortuneWheelView()),
                );
              },
              child: Text("Circle fortune wheel"),
            ),
            RaisedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyFortuneWheel()),
                );
              },
              child: Text("My custom circle fortune wheel"),
            ),
            RaisedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WheelView()),
                );
              },
              child: Text("Wheel example by QuanNgo"),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
