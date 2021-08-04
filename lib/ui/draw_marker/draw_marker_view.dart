import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_practice_ui/ui/draw_marker/draw_marker_bloc.dart';
import 'package:flutter_practice_ui/ui/draw_marker/marker_generator.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class DrawMarkerView extends StatefulWidget {
  @override
  _DrawMarkerViewState createState() => _DrawMarkerViewState();
}

class _DrawMarkerViewState extends State<DrawMarkerView> {
  Completer<GoogleMapController> _controller = Completer();
  Position position;
  DrawMarkerBloc bloc;
  var location = new Location();
  LocationData userLocation;
  BitmapDescriptor myCanvasIcon;

  void initMyCanvasIcon() {
    MarkerGenerator markerGenerator = new MarkerGenerator();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      markerGenerator
          .getMarkerIcon(
        size: Size(100, 100),
        deviceSize: MediaQuery.of(context).devicePixelRatio,
        tagValue: "1",
        leftPadding: 8.0,
        rightPadding: 8.0,
      )
          .then((myIcon) {
        setState(() {
          myCanvasIcon = myIcon;
        });
      });
    });
  }

  void getCurrentPosition() {
//    Position res = await Geolocator().getCurrentPosition();
    location.getLocation().then((res) {
      print('latitude: -------- ${res.latitude.toString()}');
      print('longitude: -------- ${res.longitude.toString()}');
      setState(() {
        userLocation = res;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentPosition();
    initMyCanvasIcon();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Draw marker in map demo"),
      ),
      body: Container(
        child: userLocation != null
            ? GoogleMap(
                markers: Set.from([
                  Marker(
                      icon: myCanvasIcon ?? BitmapDescriptor.defaultMarker,
                      markerId: MarkerId("home"),
                      position:
                          LatLng(userLocation.latitude, userLocation.longitude),
                      infoWindow: InfoWindow(title: "my location"))
                ]),
                initialCameraPosition: CameraPosition(
                    zoom: 20,
                    target:
                        LatLng(userLocation.latitude, userLocation.longitude)),
                mapType: MapType.normal,
//                myLocationEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                onCameraMove: (CameraPosition position) {
                  debugPrint(
                      "Camera position: Lat: ${position.target.latitude} - Long: ${position.target.longitude}");
                },
              )
            : Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
      ),

      // Button support hot reload marker when you want to fix icon and show again
//      floatingActionButton: FloatingActionButton.extended(
//        onPressed: () {
//          setState(() {
//            initMyCanvasIcon();
//          });
//        },
//        label: Text('Refresh marker'),
//        icon: Icon(Icons.update),
//      ),
    );
  }
}
