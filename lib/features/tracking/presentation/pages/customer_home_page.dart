import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/datasources/socket_service.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  final TextEditingController _orderIdController = TextEditingController();
  final Completer<GoogleMapController> _controller = Completer();
  final SocketService _socketService = SocketService();

  // Default location (e.g., San Francisco)
  static const CameraPosition _kDefaultLocation = CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 14.0,
  );

  Set<Marker> _markers = {};
  bool _isTracking = false;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _socketService.initSocket();
  }

  @override
  void dispose() {
    _socketService.dispose();
    _orderIdController.dispose();
    super.dispose();
  }

  void _startTracking() {
    final orderId = _orderIdController.text.trim();
    if (orderId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter an Order ID")));
      return;
    }

    _socketService.joinOrder(orderId);

    _socketService.listenToLocationUpdates((lat, lng) {
      _updateMarker(LatLng(lat, lng));
    });

    setState(() {
      _isTracking = true;
    });

    // Hide keyboard
    FocusScope.of(context).unfocus();
  }

  Future<void> _updateMarker(LatLng pos) async {
    setState(() {
      _currentLocation = pos;
      _markers = {
        Marker(
          markerId: const MarkerId('driver'),
          position: pos,
          infoWindow: const InfoWindow(title: 'Driver Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          // Ideally use a custom car icon here
        ),
      };
    });

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: pos, zoom: 16)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Top Section: Google Map
          Positioned.fill(
            bottom: 150, // Leave space for bottom sheet
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _kDefaultLocation,
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),

          // Bottom Section: Input
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 200,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Track Your Order",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _orderIdController,
                          decoration: InputDecoration(
                            labelText: "Package ID",
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          enabled: !_isTracking,
                        ),
                      ),
                      const SizedBox(width: 15),
                      ElevatedButton(
                        onPressed: _isTracking ? null : _startTracking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                        child: const Icon(
                          Icons.location_searching,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_isTracking && _currentLocation == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Waiting for driver update...",
                        style: TextStyle(
                          color: Colors.orange,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  if (_currentLocation != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Driver is active!",
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
