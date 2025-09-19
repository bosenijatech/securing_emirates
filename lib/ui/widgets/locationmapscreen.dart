// // location_map_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';

// class LocationMapScreen extends StatelessWidget {
//   final double latitude;
//   final double longitude;

//   const LocationMapScreen({
//     Key? key,
//     required this.latitude,
//     required this.longitude,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Your Location")),
//       body: FlutterMap(
//         options: MapOptions(
//           center: LatLng(latitude, longitude),
//           zoom: 16.0,
//         ),
//         children: [
//           TileLayer(
//             urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
//             subdomains: const ['a', 'b', 'c'],
//           ),
//           MarkerLayer(
//             markers: [
//               Marker(
//                 width: 40,
//                 height: 40,
//                 point: LatLng(latitude, longitude),
//                 child: const Icon(Icons.location_pin, size: 40, color: Colors.red),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:latlong2/latlong.dart';

class LocationMapScreen extends StatelessWidget {
  final double latitude;
  final double longitude;

  const LocationMapScreen({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (latitude == 0.0 && longitude == 0.0) {
      return const Scaffold(
        body: Center(child: Text("Invalid coordinates")),
      );
    }

    final location = LatLng(latitude, longitude);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Location"),
        backgroundColor: Colors.green,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCameraFit: CameraFit.bounds(
            bounds: LatLngBounds.fromPoints([location]),
            padding: const EdgeInsets.all(50),
          ),
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: location,
                width: 40,
                height: 40,
                child: const Icon(Icons.location_pin, size: 40, color: Colors.red),
              ),
            ],
          ),
          CircleLayer(
            circles: [
              CircleMarker(
                point: location,
                color: Colors.blue.withOpacity(0.1),
                borderColor: Colors.blue,
                borderStrokeWidth: 1,
                radius: 100,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
