import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:typed_data/typed_data.dart'; // Add this import for Uint8Buffer

class MqttService {
  DateTime? _lastSmsTime;
  final _smsCooldown = Duration(seconds: 20);
  bool _switchPressProcessed = false;
  final MqttServerClient _mqttClient;
  bool isDetectionActive = false;
  Timer? _connectionCheckTimer;
  StreamSubscription? _messageSubscription;
  ObjectDetector? _detector;
  FirebaseCustomModel? _customModel;

  static const INPUT_SIZE = 300; // Your model's required input size
  static const MEAN = 127.5; // Your model's mean
  static const STD = 127.5; // Your model's std

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
    _initializeDetector();
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
    _messageSubscription?.cancel();
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
    _messageSubscription?.cancel();
    _mqttClient.subscribe('camera/frame', MqttQos.atLeastOnce);
    _mqttClient.subscribe('switch/alert', MqttQos.atMostOnce);

    _messageSubscription = _mqttClient.updates!
        .listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      try {
        if (messages[0].payload is MqttPublishMessage) {
          final MqttPublishMessage recMess =
              messages[0].payload as MqttPublishMessage;
          final String messageContent =
              MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

          print(
              'Received message: $messageContent on topic: ${messages[0].topic}');

          if (messages[0].topic == 'switch/alert') {
            if (!_switchPressProcessed) {
              // Only process if not already handled
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                print('User email: ${user.email}');
                sendSmsAlert(user.email!);
                _switchPressProcessed = true; // Mark as processed
              }
            }
          } else if (messages[0].topic == 'camera/frame') {
            if (isDetectionActive) {
              _processObjectDetectionMessage(messages[0]);
            }
          }
        } else {
          print('Error: message.payload is not of type MqttPublishMessage');
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
      await Future.delayed(Duration(seconds: 2));
    }
    if (_mqttClient.connectionStatus!.state != MqttConnectionState.connected) {
      print('Failed to reconnect after $maxReconnectAttempts attempts');
      // Optionally, you can call sendSmsAlert here to notify about the disconnection
      // User? user = FirebaseAuth.instance.currentUser;
      // if (user != null) {
      //   print('User email: ${user.email}');
      //   sendSmsAlert(user.email!);
      // } else {
      //   print('No user is currently logged in.');
      // }
    }
  }

  void resetSwitchState() {
    _switchPressProcessed = false;
  }

  Future<void> sendSmsAlert(String email) async {
    if (_lastSmsTime != null) {
      final timeSinceLastSms = DateTime.now().difference(_lastSmsTime!);
      if (timeSinceLastSms < _smsCooldown) {
        print('SMS cooldown active. Skipping send.');
        return;
      }
    }
    try {
      _lastSmsTime = DateTime.now();
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
        Position position = Position(
            longitude: 0,
            latitude: 0,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0);
        try {
          position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          print(
              'Current location: ${position.latitude}, ${position.longitude}');
          resetSwitchState();
        } catch (e) {
          print('Error getting location: $e');
          resetSwitchState();
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
        String apiKey =
            'D3ArDxsdDmaEWAe9zHQb'; // Replace with your actual API key
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

  final Map<int, String> _labelMap = {0: 'car', 1: 'chair', 2: 'table'};

  Future<ObjectDetector> _createDetector() async {
    if (_detector != null) return _detector!;
    try {
      if (_customModel == null) {
        _customModel = await FirebaseModelDownloader.instance.getModel(
          "object_detection_model_1", // Your model name in Firebase
          FirebaseModelDownloadType.latestModel,
          FirebaseModelDownloadConditions(
            iosAllowsCellularAccess: true,
            iosAllowsBackgroundDownloading: true,
            androidChargingRequired: false,
            androidWifiRequired: false,
          ),
        );
        print('Custom model downloaded: ${_customModel!.file.path}');
      }
      final options = LocalObjectDetectorOptions(
        mode: DetectionMode.stream,
        classifyObjects: true,
        multipleObjects: true,
        modelPath: _customModel!.file.path,
      );
      _detector = ObjectDetector(options: options);
      return _detector!;
    } catch (e) {
      print('Detector creation error: $e');
      rethrow;
    }
  }

  Future<void> _initializeDetector() async {
    _detector = await _createDetector();
  }

  Future<void> _processObjectDetectionMessage(
    MqttReceivedMessage<MqttMessage> message) async {
  if (!isDetectionActive) return;
  try {
    final MqttPublishMessage pubMess = message.payload as MqttPublishMessage;

    // Convert Uint8Buffer to Uint8List
    final Uint8Buffer buffer = pubMess.payload.message as Uint8Buffer;
    final Uint8List imageBytes = Uint8List.fromList(buffer.toList());

    // Decode the image to ensure it's valid
    final img.Image? decodedImage = img.decodeImage(imageBytes);
    if (decodedImage == null) {
      throw Exception('Failed to decode image. Invalid image data.');
    }

    // Preprocess the image and ensure it matches the expected format
    final Float32List preprocessedImage = await _preprocessImage(decodedImage);

    // Convert Float32List to Uint8List, if necessary, and handle compatibility
    final Uint8List convertedBytes = Uint8List.view(preprocessedImage.buffer);

    final detector = await _createDetector();
    if (detector == null) {
      throw Exception('Failed to create detector');
    }

    // Create InputImage with verified metadata
    final inputImageMetadata = InputImageMetadata(
      size: ui.Size(decodedImage.width.toDouble(), decodedImage.height.toDouble()),
      rotation: InputImageRotation.rotation0deg,
      format: InputImageFormat.nv21, // Adjust to the format required
      bytesPerRow: decodedImage.width * 3, // Assuming RGB format
    );

    final inputImageFromBytes = InputImage.fromBytes(
      bytes: convertedBytes,
      metadata: inputImageMetadata,
    );

    // Detect objects in the image
    final List<DetectedObject> objects = await detector.processImage(inputImageFromBytes);
    if (objects.isEmpty) {
      print('No objects detected.');
    } else {
      // Process detected objects
      for (final detectedObject in objects) {
        if (detectedObject.labels.isNotEmpty) {
          final label = detectedObject.labels.first.text;
          final confidence = detectedObject.labels.first.confidence;
          print('Detected $label with ${(confidence * 100).toStringAsFixed(1)}% confidence');
        }
      }
    }
  } catch (e, stackTrace) {
    print('Error in object detection: $e');
    print('Stack trace: $stackTrace');
  }
}


  Future<Float32List> _preprocessImage(img.Image image) async {
    // Resize the image to the required input size
    final img.Image resizedImage =
        img.copyResize(image, width: 300, height: 300);

    // Get the raw bytes of the image
    final Uint8List bytes = resizedImage.getBytes();

    // Normalize the pixel values to the range [0, 1]
    final Float32List normalizedPixels = Float32List(bytes.length ~/ 4 * 3);
    int j = 0;
    for (int i = 0; i < bytes.length; i += 4) {
      final r = (bytes[i] - MEAN) / STD;
      final g = (bytes[i + 1] - MEAN) / STD;
      final b = (bytes[i + 2] - MEAN) / STD;
      normalizedPixels[j++] = r;
      normalizedPixels[j++] = g;
      normalizedPixels[j++] = b;
    }

    return normalizedPixels;
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
