import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_tracking/controllers/map_controller.dart';
import 'package:provider/provider.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  void initState() {
    final mapController = Provider.of<MapController>(context, listen: false);
    if (mapController.isLoading) {
      mapController.getCurrentLocation();
    }
    mapController.updateCurrentLocation();
    mapController.setCustomMarkerIcon();
    mapController.getPolyline();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MapController>(builder: (context, controller, _) {
        if (controller.isLoading) {
          return Center(child: Text('Loading...'));
        } else {
          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: controller.sourceLocation,
              zoom: 15.0,
            ),
            polylines: {
              Polyline(
                polylineId: const PolylineId('route'),
                color: Colors.black,
                points: controller.polylineCoordinates,
              ),
            },
            markers: {
              Marker(
                  markerId: MarkerId('currentLocation'),
                  position: LatLng(
                    controller.currentLocation!.latitude!,
                    controller.currentLocation!.longitude!,
                  ),
                  icon: controller.currentLocationIcon),
              Marker(
                  markerId: MarkerId('source'),
                  position: controller.sourceLocation,
                  icon: controller.sourceLocationIcon),
              Marker(
                  markerId: MarkerId('destination'),
                  position: controller.destination,
                  icon: controller.destinationLocationIcon),
            },
            onMapCreated: (GoogleMapController googleMapController) {
              controller.controller.complete(googleMapController);
            },
          );
        }
      }),
    );
  }
}
