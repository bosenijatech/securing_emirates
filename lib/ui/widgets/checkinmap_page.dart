import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:securing_emirates/ui/constant/app_color.dart';

class CheckInMap extends StatefulWidget {
  final LatLng initialLocation;

  const CheckInMap({
    super.key,
    required this.initialLocation,
  });

  @override
  State<CheckInMap> createState() => CheckInMapState();
}

class CheckInMapState extends State<CheckInMap> {
  late LatLng _currentLocation;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.initialLocation;
  }

  void updateLocation(LatLng newLocation) {
    setState(() {
      _currentLocation = newLocation;
    });
    _mapController.move(newLocation, 16); // Move the map to the new location
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentLocation,
        initialZoom: 16,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          tileProvider: NetworkTileProvider(
            headers: {
              'User-Agent': 'MyFlutterCheckInApp/1.0 (me@myapp.com)',
            },
          ),
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: _currentLocation,
              width: 120,
              height: 120,
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.withOpacity(0.2),
                    ),
                  ),
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
