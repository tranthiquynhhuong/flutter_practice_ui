import 'package:flutter/material.dart';
import 'package:flutter_practice_ui/ui/story/normal_story/story_view.dart';
import 'package:flutter_practice_ui/ui/story/story_with_package/story_with_package_view.dart';

class StoryMainView extends StatefulWidget {
  @override
  _StoryMainViewState createState() => _StoryMainViewState();
}

class _StoryMainViewState extends State<StoryMainView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Story Main"),
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
                  MaterialPageRoute(builder: (context) => StoryView()),
                );
              },
              child: Text("Story normal demo"),
            ),
            RaisedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StoryWithPackageView()),
                );
              },
              child: Text("Story use package demo"),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
