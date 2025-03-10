# VisioSense

VisioSense is an innovative assistive technology designed to aid visually impaired individuals by integrating IoT, machine learning, and a mobile application. The project features an ESP32-CAM mounted on modified sunglasses that captures real-time video and processes it for object detection and face recognition, providing voice feedback to the user. Additionally, an emergency alert system enables users to notify guardians with their live GPS location in critical situations.

## Features
- **Object Detection**: Uses YOLOv8 to detect specific objects (chairs and desks) within a predefined range (1.5m - 2m).
- **Face Recognition**: Captures and stores faces in the cloud for identification and voice feedback.
- **Voice Feedback**: Provides real-time voice-based assistance upon recognizing objects or faces.
- **Emergency System**: Sends an SMS alert with the user's GPS location and a Google Maps link when the switch is pressed.
- **Live Video Processing**: Captures real-time video from ESP32-CAM and processes it in the mobile app without displaying the video feed.
- **Mobile App (Flutter/Dart)**: Acts as the primary interface for managing object detection, face recognition, and emergency alerts.
- **Cloud Storage & Database (Firebase)**: Stores user data, trained models, and emergency contact information.

## Technologies Used
- **IoT**: ESP32-CAM (C++, Arduino IDE)
- **Machine Learning**: YOLOv8 for object detection, Face recognition models
- **Mobile App**: Flutter (Dart) with Firebase integration
- **Backend & Database**: Firebase (Firestore, Cloud Storage)
- **Communication Protocol**: MQTT for ESP32-CAM & mobile app connection
- **Email & SMS Service**: Gmail SMTP for OTP verification, SMS alerts for emergencies

## System Architecture
1. **ESP32-CAM** captures real-time video and sends data to the mobile app.
2. **Mobile App** processes the video for object detection and face recognition.
3. **Voice Feedback** is given based on detected objects or recognized faces.
4. **Emergency System** triggers an SMS alert with GPS data when the switch is pressed.
5. **Firebase** manages user data, face models, and cloud storage.

## Setup Guide
### 1. ESP32-CAM Configuration
- Flash the ESP32-CAM with the provided Arduino code.
- Connect the device to a Wi-Fi network.
- Ensure MQTT is configured correctly for communication with the mobile app.

### 2. Mobile App Setup
- Install Flutter and set up the development environment.
- Clone the VisioSense repository.
- Configure Firebase with the necessary API keys and authentication.
- Run `flutter pub get` to install dependencies.
- Deploy the app to an Android/iOS device.

### 3. Object Detection & Face Recognition
- Upload custom-trained YOLOv8 models to Firebase Storage.
- Train face recognition models using the mobile app interface.
- Enable object detection and recognition settings within the app.

### 4. Emergency System
- Configure the guardian's phone number in Firebase.
- Ensure GPS permissions are enabled on the mobile device.
- Test the emergency button to confirm SMS alerts are sent correctly.

## Project Progress
✔ Mobile app development completed  
✔ ESP32-CAM integration completed  
✔ Object detection dataset created and trained  
✔ Firebase authentication and database configured  
✔ Face recognition feature designed  
✔ Integrated IoT with mobile app via MQTT  
✔ Connected emergency system for real-time SMS alerts  
✔ Stored trained datasets in Firebase Cloud  

## Future Enhancements
- Expand dataset to recognize more objects and environments.
- Improve real-time processing speed and accuracy.
- Implement low-power optimization for ESP32-CAM.
- Integrate additional AI models for better scene understanding.

## Contributors
- **[Your Name]** - Project Lead & Developer
- [Other Contributors]

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact
For inquiries, reach out via [Your Email] or visit [Your GitHub Profile].
