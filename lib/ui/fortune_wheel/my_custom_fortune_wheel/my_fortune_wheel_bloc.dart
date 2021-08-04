import 'package:rxdart/rxdart.dart';

class MyFortuneWheelBloc {
  BehaviorSubject<bool> bsIsSuccess = BehaviorSubject();
  BehaviorSubject<int> bsLuckIndexReturn = BehaviorSubject();

  MyFortuneWheelBloc() {
    bsIsSuccess.add(true);
    bsLuckIndexReturn.add(0);
  }

  /// Hardcode item index return from api
  void getLuck() {
    bsIsSuccess.add(false);
    Future.delayed(Duration(seconds: 3)).then((value) {
      bsLuckIndexReturn.add(1);
      bsIsSuccess.add(true);
      return;
    });
  }

  void dispose() {
    bsIsSuccess.close();
    bsLuckIndexReturn.close();
  }
}
