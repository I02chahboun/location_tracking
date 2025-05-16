import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:location_tracking/constants/constants.dart';
import 'package:location_tracking/constants/images.dart';
import 'package:location_tracking/constants/style.dart';

class MapController extends ChangeNotifier {
  final Location location = Location();
  final LatLng _sourceLocation = LatLng(31.962766, -6.568048);
  final LatLng _destination = LatLng(31.942548, -6.607221);
  LocationData? _currentLocation;
  final Completer<GoogleMapController> _controller = Completer();
  final List<LatLng> _polylineCoordinates = [];

  List<LatLng> get polylineCoordinates => _polylineCoordinates;
  Completer<GoogleMapController> get controller => _controller;
  LatLng get sourceLocation => _sourceLocation;
  LatLng get destination => _destination;
  LocationData? get currentLocation => _currentLocation;
  bool get isLoading => _currentLocation == null;

  BitmapDescriptor _sourceLocationIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  BitmapDescriptor _destinationLocationIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
  BitmapDescriptor _currentLocationIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);

  BitmapDescriptor get currentLocationIcon => _currentLocationIcon;
  BitmapDescriptor get sourceLocationIcon => _sourceLocationIcon;
  BitmapDescriptor get destinationLocationIcon => _destinationLocationIcon;

  void setCustomMarkerIcon() {
    BitmapDescriptor.asset(ImageConfiguration.empty, AppAssets.truck,
            width: Sizes.s45, height: Sizes.s45)
        .then((icon) {
      _currentLocationIcon = icon;
    });
    BitmapDescriptor.asset(ImageConfiguration.empty, AppAssets.source,
            width: Sizes.s45, height: Sizes.s45)
        .then((icon) {
      _sourceLocationIcon = icon;
    });
    BitmapDescriptor.asset(ImageConfiguration.empty, AppAssets.destination,
            width: Sizes.s45, height: Sizes.s45)
        .then((icon) {
      _destinationLocationIcon = icon;
    });
  }

  Future<void> getCurrentLocation() async {
    _currentLocation = await location.getLocation();
    notifyListeners();
  }

  Future<void> updateCurrentLocation() async {
    final GoogleMapController googleMapController = await _controller.future;
    location.onLocationChanged.listen((newLoc) {
      _currentLocation = newLoc;
      notifyListeners();
      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(newLoc.latitude!, newLoc.longitude!),
            zoom: 15.0,
          ),
        ),
      );
    });
  }

  Future<void> getPolyline() async {
    final PolylinePoints polylinePoints = PolylinePoints();
    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          request: PolylineRequest(
            origin: PointLatLng(
                _sourceLocation.latitude, _sourceLocation.longitude),
            destination:
                PointLatLng(_destination.latitude, _destination.longitude),
            mode: TravelMode.driving,
          ),
          googleApiKey: googleMapsApiKey);

      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          _polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      }
    } catch (e) {
      log(e.toString());
    }

    notifyListeners();
  }
}
