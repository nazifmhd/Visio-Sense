import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  final MqttServerClient _mqttClient;
  bool isDetectionActive = false;

  MqttService(String brokerUrl, String clientId)
      : _mqttClient = MqttServerClient(brokerUrl, clientId) {
    _mqttClient.setProtocolV311();
    _mqttClient.port = 1883;
    _mqttClient.keepAlivePeriod = 30;
    _mqttClient.logging(on: true);
  }

  Future<void> connect() async {
    _mqttClient.onConnected = onConnected;
    _mqttClient.onDisconnected = onDisconnected;
    _mqttClient.onSubscribed = onSubscribed;

    try {
      await _mqttClient.connect();
    } catch (e) {
      print('Exception: $e');
      _mqttClient.disconnect();
    }
  }

  void onConnected() {
    print('MQTT Connected');
    _mqttClient.subscribe('camera/frame', MqttQos.atLeastOnce);
    _mqttClient.subscribe('switch/alert', MqttQos.atMostOnce);

    _mqttClient.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      final MqttPublishMessage recMess = messages[0].payload as MqttPublishMessage;
      final String message = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      if (messages[0].topic == 'switch/alert') {
        sendSmsAlert("USER_UID");  // Pass the user UID to fetch their guardian's phone number
      } else {
        _processObjectDetectionMessage(message);
      }
    });
  }

  Future<void> sendSmsAlert(String email) async {
  try {
    // Query the guardian's phone number from Firestore using the email address
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Guardian_User-Data')
        .where('Email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot snapshot = querySnapshot.docs.first;
      String guardianPhoneNumber = snapshot['Guardian PNumber'];

      // Get current location
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Construct the alert message with location link
      String locationUrl =
          'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';
      String alertMessage =
          'Emergency alert! The user needs assistance. Location: $locationUrl';

      // Send the SMS alert using Firebase Cloud Functions
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendSmsAlert');
      final response = await callable.call(<String, dynamic>{
        'toPhoneNumber': guardianPhoneNumber,
        'message': alertMessage,
      });

      if (response.data['success']) {
        print('SMS alert sent successfully with location!');
      } else {
        print('Error sending SMS alert: ${response.data['error']}');
      }
    } else {
      print('Guardian data not found for user email: $email');
    }
  } catch (e) {
    print('Error fetching guardian phone number, location, or sending SMS alert: $e');
  }
}

  void _processObjectDetectionMessage(String message) {
    print('Received camera frame message: $message');
  }

  void onDisconnected() {
    print('MQTT Disconnected');
  }

  void onSubscribed(String topic) {
    print('Subscribed to $topic');
  }

  void disconnect() {
    _mqttClient.disconnect();
  }
}
