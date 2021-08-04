import 'package:flutter/material.dart';
import 'package:flutter_practice_ui/utils/calculate_value.dart';
import 'package:interpolate/interpolate.dart';
import 'package:url_launcher/url_launcher.dart';

class StoryWithPackageView extends StatefulWidget {
  @override
  _StoryWithPackageViewState createState() => _StoryWithPackageViewState();
}

class _StoryWithPackageViewState extends State<StoryWithPackageView> {
  ScrollController _controller;
  double delta = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
  }

  double interpolateCalculate({List<double> lstInputRange, List<double> lstOutputRange}) {
    return calculateInterpolate(lstInputRange: lstInputRange, lstOutputRange: lstOutputRange, val: delta);
  }

  _scrollListener() {
    if (_controller.offset == _controller.position.maxScrollExtent && !_controller.position.outOfRange) {
      setState(() {
        if (delta <= 0) {
          debugPrint("reach the bottom: delta $delta");
        }
        delta = _controller.offset / 200;
      });
    }
    if (_controller.offset == _controller.position.minScrollExtent && !_controller.position.outOfRange) {
      setState(() {
        delta = _controller.offset / 200;
        if (delta >= 1) {
          debugPrint("reach the top: delta $delta");
        }
      });
    }

    if ((_controller.position.minScrollExtent < _controller.offset) &&
        (_controller.offset < _controller.position.maxScrollExtent) &&
        !_controller.position.outOfRange) {
      setState(() {
        delta = _controller.offset / 200;
        if (0 < delta && delta < 1) {
          debugPrint("delta = $delta");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Story use package demo"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            child: InkWell(
                child: Text.rich(
                  TextSpan(
                    text: 'Use ',
                    style: TextStyle(fontSize: 20),
                    children: <TextSpan>[
                      TextSpan(
                          text: 'interpolate',
                          style: TextStyle(decoration: TextDecoration.underline, color: Colors.blue)),
                      TextSpan(
                        text: ' package',
                      ),
                      // can add more TextSpans here...
                    ],
                  ),
                ),
                onTap: () async {
                  String _url = 'https://pub.dev/packages/interpolate';
                  try {
                    await canLaunch(_url)
                        ? await launch(
                            _url,
                            forceSafariVC: false,
                            forceWebView: false,
                          )
                        : throw 'Could not launch $_url';
                  } catch (e) {
                    debugPrint("Could not launch catch error: $e");
                  }
                }),
          ),
          Container(
            height: 400,
            color: Colors.blueGrey,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: Stack(
                children: [
                  ListView.builder(
                    controller: _controller,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return index == 0
                          ? emptyStoryItem()
                          : friendStoryItem(
                              name: "Nasumi Polero Kirioro Jatsuka",
                              avatarImg: "https://picsum.photos/200",
                              storyImg: "https://picsum.photos/450/800",
                              seen: false);
                    },
                    itemCount: 10,
                  ),
                  myStoryItem(avatarImg: "https://picsum.photos/300", onClick: () {}),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget emptyStoryItem() {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Container(
        color: Colors.black.withOpacity(0),
        width: 200,
      ),
    );
  }

  Widget friendStoryItem({String avatarImg, String storyImg, String name, bool seen}) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Container(
        width: 200,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  image: DecorationImage(
                    image: NetworkImage(storyImg),
                    fit: BoxFit.fill,
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                    border: Border.all(
                      width: 3,
                      color: Colors.blueAccent,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0),
                    radius: 27,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(avatarImg),
                      radius: 24,
                    ),
                  )),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                  child: Container(
                    child: Text(
                      "$name",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget myStoryItem({String avatarImg, Function() onClick}) {
    return Positioned(
      top: delta <= 0
          ? 0
          : delta >= 1
              ? 145
              : interpolateCalculate(lstInputRange: [0, 1, 0], lstOutputRange: [0, 145, 0]),
      bottom: delta <= 0
          ? 0
          : delta >= 1
              ? 145
              : interpolateCalculate(lstInputRange: [0, 1, 0], lstOutputRange: [0, 145, 0]),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 0),
        curve: Curves.fastOutSlowIn,
        child: Padding(
          padding: EdgeInsets.only(
            left: delta <= 0
                ? 10
                : delta >= 1
                    ? 0
                    : interpolateCalculate(lstInputRange: [0, 1, 0], lstOutputRange: [10, 0, 10]),
          ),
          child: GestureDetector(
            onTap: () {
              if (onClick != null) {
                onClick();
              }
            },
            child: Container(
              //delta <= 0: show - delta >= 1: hide
              decoration: BoxDecoration(
                color: delta <= 0
                    ? Colors.grey
                    : delta >= 1
                        ? Colors.blueGrey
                        : Colors.grey.withOpacity((1 - delta).abs()),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(
                    delta <= 0
                        ? 15
                        : delta >= 1
                            ? 0
                            : 15,
                  ),
                  bottomLeft: Radius.circular(
                    delta <= 0
                        ? 15
                        : delta >= 1
                            ? 0
                            : 15,
                  ),
                  bottomRight: Radius.circular(
                    delta <= 0
                        ? 15
                        : interpolateCalculate(lstInputRange: [0, 1, 0], lstOutputRange: [15, 200, 200]),
                  ),
                  topRight: Radius.circular(
                    delta <= 0
                        ? 15
                        : interpolateCalculate(lstInputRange: [0, 1, 0], lstOutputRange: [15, 200, 200]),
                  ),
                ),
              ),
              width: delta <= 0
                  ? 200
                  : delta >= 1
                      ? 70
                      : interpolateCalculate(lstInputRange: [0, 1, 0], lstOutputRange: [200, 70, 70]),
              height: delta <= 0
                  ? 400
                  : delta >= 1
                      ? 70
                      : interpolateCalculate(lstInputRange: [0, 1, 0], lstOutputRange: [200, 70, 70]),
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 0),
                    curve: Curves.fastOutSlowIn,
                    height: 300,
                    child: Padding(
                      padding: EdgeInsets.all(
                        delta <= 0
                            ? 0
                            : delta >= 1
                                ? 10
                                : interpolateCalculate(lstInputRange: [0, 1, 0], lstOutputRange: [0, 10, 0]),
                      ),
                      child: Container(
                        child: Stack(
                          children: [
                            AnimatedContainer(
                              duration: Duration(milliseconds: 0),
                              curve: Curves.fastOutSlowIn,
                              height: delta <= 0
                                  ? 275
                                  : delta >= 1
                                      ? 50
                                      : interpolateCalculate(
                                          lstInputRange: [0, 1, 0], lstOutputRange: [275, 50, 275]),
                              width: delta <= 0
                                  ? 275
                                  : delta >= 1
                                      ? 50
                                      : interpolateCalculate(
                                          lstInputRange: [0, 1, 0], lstOutputRange: [275, 50, 275]),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(
                                      interpolateCalculate(
                                          lstInputRange: [0, 1, 0], lstOutputRange: [15, 275, 275]),
                                    ),
                                    topRight: Radius.circular(
                                      interpolateCalculate(
                                          lstInputRange: [0, 1, 0], lstOutputRange: [15, 275, 275]),
                                    ),
                                    bottomLeft: Radius.circular(
                                      interpolateCalculate(
                                          lstInputRange: [0, 1, 0], lstOutputRange: [0, 275, 275]),
                                    ),
                                    bottomRight: Radius.circular(
                                      interpolateCalculate(
                                          lstInputRange: [0, 1, 0], lstOutputRange: [0, 275, 275]),
                                    ),
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(avatarImg),
                                    fit: BoxFit.fill,
                                  )),
                            ),
                            Positioned(
                              right: delta <= 0
                                  ? 75
                                  : delta >= 1
                                      ? 0
                                      : interpolateCalculate(lstOutputRange: [75, 0, 75]),
                              child: Container(
                                width: delta <= 0
                                    ? 50
                                    : delta >= 1
                                        ? 20
                                        : interpolateCalculate(lstOutputRange: [50, 20, 50]),
                                height: delta <= 0
                                    ? 50
                                    : delta >= 1
                                        ? 20
                                        : interpolateCalculate(lstOutputRange: [50, 20, 50]),
                                child: CircleAvatar(
                                  backgroundColor: Colors.grey.withOpacity(1),
                                  radius: delta <= 0
                                      ? 30
                                      : delta >= 1
                                          ? 20
                                          : interpolateCalculate(lstOutputRange: [30, 20, 30]),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.blueAccent,
                                    radius: delta <= 0
                                        ? 20
                                        : delta >= 1
                                            ? 10
                                            : interpolateCalculate(lstOutputRange: [20, 10, 20]),
                                  ),
                                ),
                              ),
                              bottom: 0,
                            ),
                            Positioned(
                              right: delta <= 0
                                  ? 75
                                  : delta >= 1
                                      ? 5.5
                                      : interpolateCalculate(lstOutputRange: [75, 5.5, 75]),
                              bottom: delta <= 0
                                  ? 0
                                  : delta >= 1
                                      ? 5.5
                                      : interpolateCalculate(lstOutputRange: [0, 5.5, 0]),
                              child: Container(
                                  width: delta <= 0
                                      ? 50
                                      : delta >= 1
                                          ? 20
                                          : interpolateCalculate(
                                              lstInputRange: [0, 1, 0], lstOutputRange: [50, 20, 50]),
                                  height: delta <= 0
                                      ? 50
                                      : delta >= 1
                                          ? 20
                                          : interpolateCalculate(
                                              lstInputRange: [0, 1, 0], lstOutputRange: [50, 20, 50]),
                                  child: IconButton(
                                    iconSize: delta <= 0
                                        ? 20
                                        : delta >= 1
                                            ? 15
                                            : interpolateCalculate(
                                                lstInputRange: [0, 1, 0], lstOutputRange: [20, 15, 20]),
                                    icon: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {},
                                  )),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                        child: Container(
                          child: Center(
                            child: Text(
                              "Create story",
                              style: TextStyle(
                                color: Colors.white.withOpacity(
                                  delta <= 0
                                      ? 1
                                      : delta >= 1
                                          ? 0
                                          : interpolateCalculate(
                                              lstInputRange: [0, 1, 0], lstOutputRange: [1, 0, 1]),
                                ),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
