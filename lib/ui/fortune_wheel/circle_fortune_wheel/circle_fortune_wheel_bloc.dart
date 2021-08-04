import 'dart:math';
import 'package:rxdart/rxdart.dart';

class CircleFortuneWheelBloc {
  BehaviorSubject<int> bsSelected = BehaviorSubject.seeded(0);
  BehaviorSubject<bool> bsAnimationEnd = BehaviorSubject();
  BehaviorSubject<List<String>> bsLstFortuneItem = BehaviorSubject();

  CircleFortuneWheelBloc() {
    getListFortuneItemValue();
    bsAnimationEnd.add(true);
  }

  int randomRange({int min, int max}) {
    var _random = Random();
    return min + _random.nextInt(max - min);
  }

  Future<void> setSelectedValue({int lstLength = 8}) {
    var random = Random();

    // Hard code Api return selected value
    return Future.delayed(Duration(seconds: 0)).then((value) {
      bsSelected.add(0);
    }).catchError((e) {});
  }

  Future<void> getListFortuneItemValue() {
    List<String> lst = [];
    // Hard code Api return list fortune values
    return Future.delayed(Duration(seconds: 1)).then((value) {
      for (int i = 0; i < 8; i++) {
        lst.add("$i");
      }
      bsLstFortuneItem.add(lst);
    }).catchError((e) {
      return null;
    });
  }

  void dispose() {
    bsSelected.close();
    bsAnimationEnd.close();
    bsLstFortuneItem.close();
  }
}
