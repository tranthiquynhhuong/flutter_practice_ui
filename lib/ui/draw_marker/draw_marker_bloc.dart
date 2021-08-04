import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';

class DrawMarkerBloc {
  BehaviorSubject<CameraPosition> bsCurrentCameraPosition = BehaviorSubject();

  DrawMarkerBloc() {
   ///
  }

  void dispose() {
    bsCurrentCameraPosition.close();
  }
}
