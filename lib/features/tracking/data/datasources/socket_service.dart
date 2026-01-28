import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../../core/constants/app_constants.dart';

class SocketService {
  late IO.Socket _socket;

  // Initialize Socket Connection
  void initSocket() {
    _socket = IO.io(
      AppConstants.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket']) // for Flutter or Node
          .disableAutoConnect() // disable auto-connection
          .build(),
    );

    _socket.connect();

    _socket.onConnect((_) {
      print('Connection established');
    });

    _socket.onDisconnect((_) => print('Connection Disconnection'));
    _socket.onConnectError((err) => print(err));
    _socket.onError((err) => print(err));
  }

  // Join Order Room
  void joinOrder(String orderId) {
    _socket.emit('join_room', orderId);
  }

  // Send Location Update (Driver)
  void sendLocationUpdate(String orderId, double lat, double lng) {
    _socket.emit('update_location', {
      'orderId': orderId,
      'lat': lat,
      'lng': lng,
    });
  }

  // Listen for Location Updates (Customer)
  void listenToLocationUpdates(
    Function(double lat, double lng) onLocationReceived,
  ) {
    _socket.on('receive_location', (data) {
      if (data != null && data['lat'] != null && data['lng'] != null) {
        onLocationReceived(
          double.parse(data['lat'].toString()),
          double.parse(data['lng'].toString()),
        );
      }
    });
  }

  void dispose() {
    _socket.disconnect();
    _socket.dispose();
  }
}
