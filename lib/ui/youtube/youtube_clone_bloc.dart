import 'package:flutter_practice_ui/model/video.dart';
import 'package:rxdart/rxdart.dart';

class YoutubeCloneBloc {
  BehaviorSubject<double> bsBottomBarHeight = BehaviorSubject();
  BehaviorSubject<Video> bsVideoSelected = BehaviorSubject();

  YoutubeCloneBloc() {
    bsBottomBarHeight.add(56);
  }

  void dispose() {
    bsBottomBarHeight.close();
    bsVideoSelected.close();
  }
}
