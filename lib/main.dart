import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LocationScreen(),
    );
  }
}

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  // Sample data for members and locations
  List<Member> members = [
    Member(
      name: 'John Doe',
      locations: [
        Location(
            latitude: 37.7749,
            longitude: -122.4194,
            timestamp: DateTime.now().subtract(Duration(hours: 2))),
        Location(
            latitude: 34.0522,
            longitude: -118.2437,
            timestamp: DateTime.now().subtract(Duration(hours: 1))),
        Location(
            latitude: 40.7128, longitude: -74.0060, timestamp: DateTime.now()),
      ],
    ),
    Member(
      name: 'Jane Smith',
      locations: [
        Location(
            latitude: 41.8781,
            longitude: -87.6298,
            timestamp: DateTime.now().subtract(Duration(days: 1))),
        Location(
            latitude: 33.7490,
            longitude: -84.3880,
            timestamp: DateTime.now().subtract(Duration(days: 2))),
      ],
    ),
  ];

  // Current selected member
  Member? selectedMember;

  // Initial map position
  LatLng initialPosition = LatLng(37.7749, -122.4194);

  // Map controller
  GoogleMapController? mapController;

  // List of markers on the map
  Set<Marker> markers = {};

  // List of polylines for the routes
  Set<Polyline> polylines = {};

  // Date filter for location data
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    // Add markers for initial locations
    _updateMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Tracker'),
      ),
      body: Column(
        children: [
          // Menu to select members
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(members[index].name),
                  onTap: () {
                    setState(() {
                      selectedMember = members[index];
                    });
                  },
                  trailing: Icon(selectedMember == members[index]
                      ? Icons.check_circle
                      : Icons.circle),
                );
              },
            ),
          ),
          // Map view
          Expanded(
            flex: 3,
            child: GoogleMap(
              initialCameraPosition:
              CameraPosition(target: initialPosition, zoom: 10.0),
              onMapCreated: _onMapCreated,
              markers: markers,
              polylines: polylines,
            ),
          ),
          // Date filter and route details
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date filter
                  Text(
                      'Date: ${selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : 'All'}'),
                  TextButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                          // Update markers and routes based on selected date
                          _updateMarkers();
                        });
                      }
                    },
                    child: Text('Select Date'),
                  ),
                  SizedBox(height: 16.0),
                  // Route details
                  if (selectedMember != null &&
                      selectedMember!.locations.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Start Location: ${selectedMember!.locations.first.latitude}, ${selectedMember!.locations.first.longitude}'),
                        Text(
                            'Stop Location: ${selectedMember!.locations.last.latitude}, ${selectedMember!.locations.last.longitude}'),
                        Text(
                            'Total Distance: ${_calculateTotalDistance(selectedMember!.locations)} KM'),
                        Text(
                            'Total Duration: ${_calculateTotalDuration(selectedMember!.locations)}'),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // Update markers based on selected member and date
  void _updateMarkers() {
    markers.clear();
    polylines.clear();
    if (selectedMember != null) {
      for (Location location in selectedMember!.locations) {
        if (selectedDate == null || location.timestamp.isAfter(selectedDate!)) {
          markers.add(
            Marker(
              markerId: MarkerId(
                  location.latitude.toString() + location.longitude.toString()),
              position: LatLng(location.latitude, location.longitude),
              infoWindow: InfoWindow(
                title: 'Location',
                snippet:
                DateFormat('yyyy-MM-dd HH:mm').format(location.timestamp),
              ),
            ),
          );
        }
      }
      // Add polylines for routes
      _drawRoutes(selectedMember!.locations);
    }
    setState(() {});
  }

  // Calculate total distance between locations
  double _calculateTotalDistance(List<Location> locations) {
    double totalDistance = 0;
    for (int i = 0; i < locations.length - 1; i++) {
      totalDistance += _calculateDistance(locations[i], locations[i + 1]);
    }
    return totalDistance;
  }

  // Calculate distance between two locations
  double _calculateDistance(Location location1, Location location2) {
    // Implementation for distance calculation
    // You can use the Haversine formula or any other suitable method
    return 0.0; // Replace with actual distance calculation
  }

  // Calculate total duration between locations
  Duration _calculateTotalDuration(List<Location> locations) {
    Duration totalDuration = Duration.zero;
    for (int i = 0; i < locations.length - 1; i++) {
      totalDuration +=
          locations[i + 1].timestamp.difference(locations[i].timestamp);
    }
    return totalDuration;
  }

  // Draw polylines for routes
  void _drawRoutes(List<Location> locations) {
    for (int i = 0; i < locations.length - 1; i++) {
      polylines.add(
        Polyline(
          polylineId: PolylineId(
              '${locations[i].latitude}${locations[i].longitude}-${locations[i + 1].latitude}${locations[i + 1].longitude}'),
          color: Colors.blue,
          width: 5,
          points: [
            LatLng(locations[i].latitude, locations[i].longitude),
            LatLng(locations[i + 1].latitude, locations[i + 1].longitude),
          ],
        ),
      );
    }
  }
}

// Member class
class Member {
  final String name;
  final List<Location> locations;

  Member({required this.name, required this.locations});
}

// Location class
class Location {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  Location(
      {required this.latitude,
        required this.longitude,
        required this.timestamp});
}