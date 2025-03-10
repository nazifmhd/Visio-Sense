#include <WiFi.h>
//#include <WiFiClientSecure.h>
#include <PubSubClient.h>
#include "esp_camera.h"  // Include the camera library

const char* ssid = "Dialog 4G 460";
const char* password = "7eECF0C1";
const char* mqtt_server = "broker.hivemq.com";
const char* mqtt_topic = "esp32test/device/alert";

WiFiClient espClient;
PubSubClient client(espClient);

const int switchPin = 2;  // GPIO pin for the switch

void setup() {
  Serial.begin(115200);
  delay(100);
  pinMode(switchPin, INPUT_PULLUP);  // Setup the switch with pull-up resistor
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi connected");
  client.setServer(mqtt_server, 1883);
  reconnectMQTT();

  // Initialize the camera (you may need to add your camera configuration here)
  camera_config_t config;
  // Configure the camera settings (resolution, pixel format, etc.)
  // For example:
  config.ledc_channel = LEDC_CHANNEL_0;
  config.ledc_timer = LEDC_TIMER_0;
  config.pin_d0 = 5;
  config.pin_d1 = 18;
  config.pin_d2 = 19;
  config.pin_d3 = 21;
  config.pin_d4 = 36;
  config.pin_d5 = 39;
  config.pin_d6 = 34;
  config.pin_d7 = 35;
  config.pin_xclk = 0;
  config.pin_pclk = 22;
  config.pin_vsync = 25;
  config.pin_href = 23;
  config.pin_sccb_sda = 26;  // Updated field name
  config.pin_sccb_scl = 27;  // Updated field name
  config.pin_reset = -1;
  config.xclk_freq_hz = 20000000;
  config.pixel_format = PIXFORMAT_JPEG; 
  config.frame_size = FRAMESIZE_SVGA; 
  config.jpeg_quality = 12; 
  config.fb_count = 2;

  // Initialize the camera with the configuration
  esp_err_t err = esp_camera_init(&config);
  if (err != ESP_OK) {
    Serial.printf("Camera init failed with error 0x%x", err);
    while (true) {
      delay(1000);  // Stop the program here if camera init fails
    }
  }
}

void reconnectMQTT() {
  // Try to reconnect to MQTT broker
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    if (client.connect("ESP32CAM_Test_Client")) { // Optional: Add a unique client ID here
      Serial.println("connected");
      client.publish(mqtt_topic, "ESP32CAM is online!"); // Send a test message
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" retrying in 2 seconds...");
      delay(2000); // Wait and try again
    }
  }
}

void loop() {
  Serial.println("Entering loop()");

  if (digitalRead(switchPin) == HIGH) {
    Serial.println("Switch Released");
  }

  if (!client.connected()) {
    Serial.println("Connection issue.. Reconnecting MQTT");
    reconnectMQTT(); // Try to reconnect if connection is lost
  }

  client.loop();
  Serial.println("MQTT client loop called");

  // Check for a single button press (no debounce)
  if (digitalRead(switchPin) == LOW) {
    Serial.println("Sending MQTT...");
    bool success = client.publish(mqtt_topic, "Switch pressed!");
    if (success) {
      Serial.println("Message sent to MQTT");
    } else {
      Serial.println("Failed sending MQTT.");
    }

    // Wait until button is released to prevent repeated messages
    while (digitalRead(switchPin) == LOW) {
      delay(10); // Small delay to avoid hammering the loop
    }
  }

  Serial.println("Exiting loop()");
}