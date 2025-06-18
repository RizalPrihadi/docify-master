import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class OpenStreetMapView extends StatefulWidget {
  final double latitude;
  final double longitude;
  final double height;

  const OpenStreetMapView({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.height,
  });

  @override
  State<OpenStreetMapView> createState() => _OpenStreetMapViewState();
}

class _OpenStreetMapViewState extends State<OpenStreetMapView> {
  late MapController controller;

  @override
  void initState() {
    super.initState();
    controller = MapController.withUserPosition(
      trackUserLocation: const UserTrackingOption(
        enableTracking: false,
        unFollowUser: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: OSMFlutter(
        controller: controller,
        osmOption: OSMOption(
          userTrackingOption: const UserTrackingOption(
            enableTracking: false,
            unFollowUser: true,
          ),
          zoomOption: const ZoomOption(
            initZoom: 15,
            minZoomLevel: 8,
            maxZoomLevel: 19,
            stepZoom: 1.0,
          ),
          staticPoints: [
            StaticPositionGeoPoint(
              "doctor_location",
              const MarkerIcon(
                icon: Icon(Icons.location_on, color: Colors.red, size: 48),
              ),
              [
                GeoPoint(
                  latitude: widget.latitude,
                  longitude: widget.longitude,
                ),
              ],
            ),
          ],
          roadConfiguration: const RoadOption(roadColor: Colors.yellow),
        ),
        onMapIsReady: (isReady) async {
          if (isReady) {
            await controller.setZoom(zoomLevel: 15);
            await controller.goToLocation(
              GeoPoint(
                latitude: widget.latitude,
                longitude: widget.longitude,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
