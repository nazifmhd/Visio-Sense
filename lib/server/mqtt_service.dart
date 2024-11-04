import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:cloud_functions/cloud_functions.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:tflite/tflite.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';

class MqttService {
  final MqttServerClient _mqttClient;
  bool isDetectionActive = false;
  Timer? _connectionCheckTimer;

  // Track the last detected object and time
  String? _lastDetectedObject;
  DateTime _lastDetectionTime = DateTime.now();

  MqttService(String brokerUrl, String clientId)
      : _mqttClient = MqttServerClient(brokerUrl, clientId) {
    _mqttClient.setProtocolV311();
    _mqttClient.port = 1883;
    _mqttClient.keepAlivePeriod = 30;
    _mqttClient.logging(on: true);

    // Start the periodic connection check
    _startConnectionCheck();
  }

  void _startConnectionCheck() {
    _connectionCheckTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (_mqttClient.connectionStatus!.state !=
          MqttConnectionState.connected) {
        print('MQTT connection lost. Attempting to reconnect...');
        _attemptReconnect();
      }
    });
  }

  void _stopConnectionCheck() {
    _connectionCheckTimer?.cancel();
  }

  Future<void> connect() async {
    _mqttClient.onConnected = onConnected;
    _mqttClient.onDisconnected = onDisconnected;
    _mqttClient.onSubscribed = onSubscribed;

    // Request TTS permission
    await _requestPermissions();

    try {
      await _mqttClient.connect();
    } catch (e) {
      print('Exception: $e');
      _mqttClient.disconnect();
    }
  }

  void disconnect() {
    _mqttClient.disconnect();
    _stopConnectionCheck();
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.speech.status;
    if (!status.isGranted) {
      var result = await Permission.speech.request();
      if (result.isGranted) {
        print('Speech permission granted.');
      } else {
        print('Speech permission denied.');
      }
    } else {
      print('Speech permission already granted.');
    }
  }

  void onConnected() {
    print('MQTT Connected');
    _mqttClient.subscribe('camera/frame', MqttQos.atLeastOnce);
    _mqttClient.subscribe('switch/alert', MqttQos.atMostOnce);

    _mqttClient.updates!
        .listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      try {
        final MqttPublishMessage recMess =
            messages[0].payload as MqttPublishMessage;
        final String message =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

        print('Received message: $message on topic: ${messages[0].topic}');

        if (messages[0].topic == 'switch/alert') {
          // Get the current user's email from Firebase Authentication
          User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            print('User email: ${user.email}');
            sendSmsAlert(user.email!);
          } else {
            print('No user is currently logged in.');
          }
        } else if (messages[0].topic == 'camera/frame') {
          if (isDetectionActive) {
            _processObjectDetectionMessage(message);
          }
        }
      } catch (e) {
        print('Error processing message: $e');
      }
    });
  }

  void onDisconnected() {
    print('MQTT Disconnected');
    _attemptReconnect();
  }

  void _attemptReconnect() async {
    const int maxReconnectAttempts = 5;
    int attempt = 0;
    while (attempt < maxReconnectAttempts &&
        _mqttClient.connectionStatus!.state != MqttConnectionState.connected) {
      attempt++;
      print('Attempting to reconnect... (Attempt $attempt)');
      try {
        await _mqttClient.connect();
        if (_mqttClient.connectionStatus!.state ==
            MqttConnectionState.connected) {
          print('Reconnected successfully');
          break;
        }
      } catch (e) {
        print('Reconnection attempt failed: $e');
      }
      await Future.delayed(Duration(seconds: 2)); // Wait before retrying
    }
    if (_mqttClient.connectionStatus!.state != MqttConnectionState.connected) {
      print('Failed to reconnect after $maxReconnectAttempts attempts');
      // Optionally, you can call sendSmsAlert here to notify about the disconnection
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('User email: ${user.email}');
        sendSmsAlert(user.email!);
      } else {
        print('No user is currently logged in.');
      }
    }
  }

  Future<void> sendSmsAlert(String email) async {
    try {
      print('sendSmsAlert called with email: $email');
      // Request location permission
      await requestLocationPermission();
      print('Location permission requested.');

      // Query the guardian's phone number from Firestore using the email address
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Guardian_User-Data')
          .where('Email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot snapshot = querySnapshot.docs.first;
        String guardianPhoneNumber = snapshot['Guardian PNumber'];
        print('Guardian phone number: $guardianPhoneNumber');

        // Get current location
        Position position;
        try {
          position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          print(
              'Current location: ${position.latitude}, ${position.longitude}');
        } catch (e) {
          print('Error getting location: $e');
          return;
        }

        // Construct the alert message with location link
        String locationUrl =
            'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';
        String alertMessage =
            'Emergency alert! The user needs assistance. Location: $locationUrl';

        print('Sending SMS to: $guardianPhoneNumber');
        print('SMS content: $alertMessage');

        // Prepare your Notify.lk API credentials
        String userId = '28341'; // Replace with your actual user ID
        String apiKey = 'D3ArDxsdDmaEWAe9zHQb'; // Replace with your actual API key
        String senderId =
            'NotifyDEMO'; // Replace with your sender ID if different

        // Construct the request URL with parameters
        final requestUrl =
            'https://app.notify.lk/api/v1/send?user_id=$userId&api_key=$apiKey&sender_id=$senderId&to=$guardianPhoneNumber&message=${Uri.encodeComponent(alertMessage)}';

        // Send the SMS alert
        final response = await http.get(Uri.parse(requestUrl));

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          print('SMS alert sent successfully: ${responseData['message']}');
        } else {
          print('Error sending SMS alert: ${response.body}');
        }
      } else {
        print('Guardian data not found for user email: $email');
      }
    } catch (e) {
      print(
          'Error fetching guardian phone number, location, or sending SMS alert: $e');
    }
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
  }

  Future<void> _processObjectDetectionMessage(String message) async {
    if (!isDetectionActive) return;

    print('Received camera frame message: $message');

    // Load the TensorFlow Lite model
    try {
      print('Loading TensorFlow Lite model...');
      await Tflite.loadModel(
        model: "assets/model.tflite", // Ensure model in assets folder
        labels: "assets/labels.txt",
      );
      print('Model loaded successfully.');

      List<dynamic>? recognitions = await Tflite.runModelOnImage(
        path: message, // Path of the image
        numResults: 5,
        threshold: 0.5,
      );

      if (recognitions != null && recognitions.isNotEmpty) {
        String detectedObject = recognitions[0]['label'];
        double confidence = recognitions[0]['confidence'];
        print("Detected $detectedObject with confidence $confidence");

        // Check if it's the same object detected within the last 2 seconds
        if (detectedObject != _lastDetectedObject ||
            DateTime.now().difference(_lastDetectionTime).inSeconds > 3) {
          // Update last detected object and time
          _lastDetectedObject = detectedObject;
          _lastDetectionTime = DateTime.now();

          // Provide voice feedback
          print('Calling _speak function...');
          await _speak(
              "Detected $detectedObject with confidence ${(confidence * 100).toStringAsFixed(0)}%");
          print("Voice feedback provided successfully for $detectedObject");
        } else {
          print(
              "Skipping announcement for repetitive detection of $detectedObject");
        }
      } else {
        print('No recognitions found.');
      }

      await Tflite.close(); // Free up memory by closing the model
    } catch (e) {
      print('Error in object detection: $e');
    }
  }

  Future<void> _speak(String text) async {
    final apiKey = 'AIzaSyDRlwACSO6fSlqZeYzcrosNrkfOz_t87Hs';
    final url =
        'https://texttospeech.googleapis.com/v1/text:synthesize?key=$apiKey';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'input': {'text': text},
        'voice': {'languageCode': 'en-US', 'name': 'en-US-Wavenet-D'},
        'audioConfig': {'audioEncoding': 'MP3'},
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final audioContent = responseData['audioContent'];
      final player = AudioPlayer();
      print('Playing audio...');
      await player.play(BytesSource(base64Decode(audioContent)));
      print('Audio played successfully.');
    } else {
      print('Error in Text-to-Speech API: ${response.body}');
    }
  }

  void onSubscribed(String topic) {
    print('Subscribed to $topic');
  }
}
