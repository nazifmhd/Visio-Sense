/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */


// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");
const axios = require("axios");

admin.initializeApp();

// Configure your Gmail account
const gmailEmail = "visiosense123@gmail.com";
const gmailPassword = "xnvajwayxyruacah";

// Set up Nodemailer transport
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: gmailEmail,
    pass: gmailPassword,
  },
});

// Function to send OTP Email
exports.sendOtpEmail = functions.https.onCall((data, context) => {
  const email = data.email;
  const otp = data.otp;

  const mailOptions = {
    from: gmailEmail,
    to: email,
    subject: "Password Reset OTP",
    text: `Your OTP code is ${otp}`,
  };

  return transporter.sendMail(mailOptions, (error, info) => {
    if (error) {
      console.log("Error sending email:", error);
      return {success: false, error: error.toString()};
    } else {
      console.log("Email sent:", info.response);
      return {success: true};
    }
  });
});

// Function to send SMS Alert
exports.sendSmsAlert = functions.https.onCall(async (data, context) => {
  const {toPhoneNumber, message} = data;

  // Your WebSMS.lk credentials and endpoi
  const apiKey = functions.config().websms.api_key;
  const apiUrl = "https://cloud.websms.lk/smsAPI";

  try {
    // Make the POST request to WebSMS.lk
    const response = await axios.post(apiUrl, {
      username: "visiosense123@gmail.com",
      password: apiKey,
      to: toPhoneNumber,
      message: message,
    });

    // Check the response from the API
    if (response.data.status === "success") {
      return {success: true, message: "SMS sent successfully"};
    } else {
      return {
        success: false,
        error: response.data.message || "Failed to send SMS",
      };
    }
  } catch (error) {
    console.error("Error sending SMS:", error);
    return {success: false, error: error.message};
  }
});
