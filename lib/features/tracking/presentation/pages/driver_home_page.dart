import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/datasources/socket_service.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  final TextEditingController _orderIdController = TextEditingController();
  final SocketService _socketService = SocketService();
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isTracking = false;
  String _statusMessage = "Enter Order ID to start delivering";

  @override
  void initState() {
    super.initState();
    _socketService.initSocket();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _socketService.dispose();
    _orderIdController.dispose();
    super.dispose();
  }

  Future<void> _startDelivery() async {
    final orderId = _orderIdController.text.trim();
    if (orderId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter an Order ID")));
      return;
    }

    // Check Permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _statusMessage = "Location permissions are denied");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(
        () => _statusMessage = "Location permissions are permanently denied",
      );
      return;
    }

    // Join Room
    _socketService.joinOrder(orderId);

    // Start Location Stream
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _positionStreamSubscription =
        Geolocator.getPositionStream(
          locationSettings: locationSettings,
        ).listen((Position position) {
          print("New Location: ${position.latitude}, ${position.longitude}");
          _socketService.sendLocationUpdate(
            orderId,
            position.latitude,
            position.longitude,
          );
          setState(() {
            _statusMessage =
                "Sending location for Order #$orderId\nLat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}";
          });
        });

    setState(() {
      _isTracking = true;
      _statusMessage = "Starting delivery for Order #$orderId...";
    });
  }

  void _stopDelivery() {
    _positionStreamSubscription?.cancel();
    setState(() {
      _isTracking = false;
      _statusMessage = "Delivery stopped.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver Dashboard"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      "Active Delivery",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _orderIdController,
              decoration: const InputDecoration(
                labelText: "Order ID / Package ID",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory_2),
              ),
              enabled: !_isTracking,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isTracking ? _stopDelivery : _startDelivery,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isTracking ? Colors.red : Colors.green,
                ),
                child: Text(
                  _isTracking ? "Stop Delivery" : "Assign Order & Start",
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
