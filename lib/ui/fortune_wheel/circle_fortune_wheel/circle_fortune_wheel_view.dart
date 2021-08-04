import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_practice_ui/ui/fortune_wheel/circle_fortune_wheel/flutter_fortune_wheel/core/core.dart';
import 'package:flutter_practice_ui/ui/fortune_wheel/circle_fortune_wheel/flutter_fortune_wheel/wheel/wheel.dart';

import 'circle_fortune_wheel_bloc.dart';

class CircleFortuneWheelView extends StatefulWidget {
  @override
  _CircleFortuneWheelViewState createState() => _CircleFortuneWheelViewState();
}

class _CircleFortuneWheelViewState extends State<CircleFortuneWheelView>
    with TickerProviderStateMixin {
  CircleFortuneWheelBloc bloc = CircleFortuneWheelBloc();
  List<FortuneItem> lstFortuneItem = [];

  @override
  void initState() {
    super.initState();
//    bloc.setSelectedValue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Circle fortune wheel"),
      ),
      body: StreamBuilder<List<String>>(
          stream: bloc.bsLstFortuneItem,
          builder: (context, lstItemSnap) {
            return !lstItemSnap.hasData
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.only(left: 20.0, right: 20.0),
                          child: FortuneWheel(
                            animateFirst: false,
                            items: List.generate(
                                lstItemSnap.data.length,
                                (index) => FortuneItem(
                                    child: Text(lstItemSnap.data[index]))),
                            selected: bloc.bsSelected,
                            rotationCount: 3,
                            onFling: () {
                              if (bloc.bsAnimationEnd.value) {
                                bloc.setSelectedValue(
                                    lstLength: lstItemSnap.data.length);
                              }
                            },
                            onAnimationStart: () {
                              bloc.bsAnimationEnd.add(false);
                            },
                            onAnimationEnd: () {
                              bloc.bsAnimationEnd.add(true);
                            },
                          ),
                        ),
                      ),
                      StreamBuilder<bool>(
                          initialData: true,
                          stream: bloc.bsAnimationEnd,
                          builder: (context, animationEndSnap) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 50.0),
                              child: RaisedButton(
                                color: animationEndSnap.data
                                    ? Colors.blue.shade500
                                    : Colors.grey.shade400,
                                onPressed: () {
                                  if (animationEndSnap.data) {
                                    bloc.setSelectedValue(
                                        lstLength: lstItemSnap.data.length);
                                  }
                                },
                                child: Text(
                                  animationEndSnap.data
                                      ? "Start"
                                      : "Waiting...",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          }),
                    ],
                  );
          }), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
